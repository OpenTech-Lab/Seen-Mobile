/**
 * Spot Media Presign Lambda
 *
 * Generates presigned S3 PUT URLs for media uploads.
 * Auth: Client signs "PUT:<contentHash>:<timestamp>" with their Nostr
 * (secp256k1/schnorr) private key. This function verifies the BIP-340
 * schnorr signature before issuing the presigned URL.
 *
 * Request body (POST):
 *   { pubkey, contentHash, timestamp, signature, contentType? }
 *
 * Response:
 *   { uploadUrl, contentHash, expiresIn }
 */

const {
  S3Client,
  HeadObjectCommand,
  PutObjectCommand,
} = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");
const { DynamoDBClient, UpdateItemCommand } = require("@aws-sdk/client-dynamodb");
const { schnorr } = require("@noble/curves/secp256k1");
const crypto = require("crypto");

const BUCKET_NAME = process.env.BUCKET_NAME;
const RATE_LIMIT_PER_MINUTE = parseInt(process.env.RATE_LIMIT_PER_MINUTE || "10", 10);
const PRESIGN_EXPIRY_SECONDS = parseInt(process.env.PRESIGN_EXPIRY_SECONDS || "900", 10);
const MAX_TIMESTAMP_DRIFT_MS = 5 * 60 * 1000; // 5 minutes
const MAX_UPLOAD_BYTES = parseInt(process.env.MAX_UPLOAD_BYTES || "104857600", 10);
const RATE_LIMIT_TABLE = process.env.RATE_LIMIT_TABLE;
const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;
const ALLOWED_CONTENT_TYPES = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "video/mp4",
  "video/quicktime",
]);

const s3 = new S3Client({});
const dynamodb = new DynamoDBClient({});

// In-memory rate limiter keyed by pubkey.
// Resets on Lambda cold start — acceptable as a first line of defense.
// For production scale, back with DynamoDB atomic counters or WAF rate rules.
const rateBuckets = new Map();

async function isRateLimited(accountId, sourceIp) {
  const now = Date.now();
  const windowStart = now - 60_000;

  let bucket = rateBuckets.get(accountId);
  if (!bucket) {
    bucket = [];
    rateBuckets.set(accountId, bucket);
  }

  while (bucket.length > 0 && bucket[0] < windowStart) {
    bucket.shift();
  }

  if (bucket.length >= RATE_LIMIT_PER_MINUTE) {
    return true;
  }

  bucket.push(now);

  if (!RATE_LIMIT_TABLE) return true;
  const minute = Math.floor(now / 60_000);
  const expiresAt = Math.floor(now / 1000) + 180;
  const scopes = [`account:${accountId}:${minute}`, `ip:${sourceIp || "unknown"}:${minute}`];
  try {
    for (const scope of scopes) {
      await dynamodb.send(new UpdateItemCommand({
        TableName: RATE_LIMIT_TABLE,
        Key: { rate_key: { S: scope } },
        UpdateExpression: "ADD request_count :one SET expires_at = :expires",
        ConditionExpression: "attribute_not_exists(request_count) OR request_count < :limit",
        ExpressionAttributeValues: {
          ":one": { N: "1" },
          ":expires": { N: String(expiresAt) },
          ":limit": { N: String(RATE_LIMIT_PER_MINUTE) },
        },
      }));
    }
    return false;
  } catch (error) {
    if (error.name === "ConditionalCheckFailedException") return true;
    throw error;
  }
}

async function authenticatedAccount(event, pubkey) {
  if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
    throw new Error("Supabase authentication is not configured");
  }
  const authorization = event.headers?.authorization || event.headers?.Authorization;
  if (typeof authorization !== "string" || !authorization.startsWith("Bearer ")) {
    return null;
  }
  const headers = {
    apikey: SUPABASE_ANON_KEY,
    authorization,
  };
  const userResponse = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers,
    signal: AbortSignal.timeout(3000),
  });
  if (!userResponse.ok) return null;
  const user = await userResponse.json();
  if (!user?.id) return null;

  const profileUrl = new URL("/rest/v1/profiles", SUPABASE_URL);
  profileUrl.searchParams.set("id", `eq.${user.id}`);
  profileUrl.searchParams.set("legacy_pubkey", `eq.${pubkey}`);
  profileUrl.searchParams.set("select", "id");
  profileUrl.searchParams.set("limit", "1");
  const profileResponse = await fetch(profileUrl, {
    headers,
    signal: AbortSignal.timeout(3000),
  });
  if (!profileResponse.ok) return null;
  const profiles = await profileResponse.json();
  return Array.isArray(profiles) && profiles.length === 1 ? user.id : null;
}

function isValidHex(str, expectedLength) {
  if (typeof str !== "string" || str.length !== expectedLength) return false;
  return /^[0-9a-f]+$/.test(str);
}

/**
 * Verify a BIP-340 schnorr signature using @noble/curves.
 *
 * The client signs SHA-256(message) where message = "PUT:<contentHash>:<timestamp>".
 * This matches WalletService.signMessage on the Dart side which hashes with
 * SHA-256 before passing to BIP-340 _schnorrSign.
 */
function verifySignature(pubkey, message, signature) {
  if (!isValidHex(pubkey, 64)) return false;
  if (!isValidHex(signature, 128)) return false;
  if (typeof message !== "string" || message.length === 0) return false;

  try {
    const msgHash = crypto.createHash("sha256").update(message).digest();
    return schnorr.verify(signature, msgHash, pubkey);
  } catch {
    return false;
  }
}

function response(statusCode, body) {
  return {
    statusCode,
    headers: {
      "Content-Type": "application/json",
      "Cache-Control": "no-store",
    },
    body: JSON.stringify(body),
  };
}

exports.handler = async (event) => {
  try {
    const body =
      typeof event.body === "string" ? JSON.parse(event.body) : event.body;

    const { pubkey, contentHash, timestamp, signature, contentType, contentLength } =
      body || {};

    // ── Validate required fields ───────────────────────────────────────────

    if (!pubkey || !contentHash || !timestamp || !signature || !contentLength) {
      return response(400, {
        error: "Missing required upload fields",
      });
    }

    if (!isValidHex(contentHash, 64)) {
      return response(400, { error: "contentHash must be 64-char hex (SHA-256)" });
    }

    if (!isValidHex(pubkey, 64)) {
      return response(400, { error: "pubkey must be 64-char hex" });
    }

    if (!Number.isSafeInteger(contentLength) || contentLength < 1 || contentLength > MAX_UPLOAD_BYTES) {
      return response(400, { error: "Invalid upload size" });
    }

    const resolvedContentType = contentType || "application/octet-stream";
    if (!ALLOWED_CONTENT_TYPES.has(resolvedContentType)) {
      return response(400, { error: "Unsupported content type" });
    }

    // ── Timestamp drift check ──────────────────────────────────────────────

    const tsMs =
      typeof timestamp === "number"
        ? timestamp > 1e12
          ? timestamp
          : timestamp * 1000
        : parseInt(timestamp, 10) * 1000;

    if (isNaN(tsMs) || Math.abs(Date.now() - tsMs) > MAX_TIMESTAMP_DRIFT_MS) {
      return response(400, { error: "Timestamp too far from server time" });
    }

    // ── Rate limit (before signature check to prevent enumeration) ─────────

    const accountId = await authenticatedAccount(event, pubkey);
    if (!accountId) {
      return response(401, { error: "Authenticated account binding required" });
    }

    const sourceIp = event.requestContext?.http?.sourceIp;
    if (await isRateLimited(accountId, sourceIp)) {
      return response(429, { error: "Rate limit exceeded" });
    }

    // ── Verify BIP-340 schnorr signature ───────────────────────────────────

    const message = `PUT:${contentHash}:${timestamp}:${contentLength}:${resolvedContentType}`;
    if (!verifySignature(pubkey, message, signature)) {
      return response(403, { error: "Invalid signature" });
    }

    // ── Generate presigned PUT URL ─────────────────────────────────────────

    const key = contentHash;
    const checksumSha256 = Buffer.from(contentHash, "hex").toString("base64");

    try {
      await s3.send(new HeadObjectCommand({ Bucket: BUCKET_NAME, Key: key }));
      return response(200, {
        contentHash,
        alreadyExists: true,
        expiresIn: 0,
      });
    } catch (error) {
      const status = error && error.$metadata && error.$metadata.httpStatusCode;
      if (status !== 404 && error.name !== "NotFound" && error.name !== "NoSuchKey") {
        throw error;
      }
    }

    const command = new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: key,
      ContentType: resolvedContentType,
      ContentLength: contentLength,
      ChecksumSHA256: checksumSha256,
      IfNoneMatch: "*",
      Metadata: {
        "uploader-pubkey": pubkey,
        "upload-timestamp": String(timestamp),
      },
    });

    const uploadUrl = await getSignedUrl(s3, command, {
      expiresIn: PRESIGN_EXPIRY_SECONDS,
      signableHeaders: new Set(["content-type"]),
    });

    return response(200, {
      uploadUrl,
      contentHash,
      checksumSha256,
      expiresIn: PRESIGN_EXPIRY_SECONDS,
    });
  } catch (err) {
    console.error("Presign error:", err);
    return response(500, { error: "Internal server error" });
  }
};

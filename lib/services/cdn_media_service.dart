import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mobile/core/app_config.dart';
import 'package:mobile/core/encryption.dart';
import 'package:mobile/services/cache_manager.dart';
import 'package:mobile/services/user_prefs_service.dart';

/// CDN media service for accelerated media fetch and upload.
///
/// Fetch path: GET `https://<cloudfront>/<sha256Hash>`
/// Upload path: POST presign-lambda → presigned S3 PUT URL → PUT file bytes
///
/// All objects are keyed by their SHA-256 content hash, making the store
/// content-addressed and naturally deduplicating.
class CdnMediaService {
  CdnMediaService._({
    HttpClient? httpClient,
    String? cdnBaseUrl,
    String? presignEndpoint,
  }) : _httpClient = httpClient ?? HttpClient(),
       _cdnBaseUrl = cdnBaseUrl ?? _defaultCdnBaseUrl,
       _presignEndpoint = presignEndpoint ?? _resolvedPresignEndpoint;

  static final CdnMediaService instance = CdnMediaService._();

  /// Creates an instance with injected dependencies for testing.
  factory CdnMediaService.forTesting({
    HttpClient? httpClient,
    String? cdnBaseUrl,
    String? presignEndpoint,
  }) => CdnMediaService._(
    httpClient: httpClient,
    cdnBaseUrl: cdnBaseUrl,
    presignEndpoint: presignEndpoint,
  );

  final HttpClient _httpClient;
  final String _cdnBaseUrl;
  final String _presignEndpoint;

  /// Injected at build time via `--dart-define`:
  ///
  ///   flutter build apk \
  ///     --dart-define=CDN_BASE_URL=https://d1234.cloudfront.net \
  ///     --dart-define=CDN_PRESIGN_URL=https://xyz.lambda-url.ap-northeast-1.on.aws
  ///
  /// During local `flutter run`, the same keys may also be provided via `.env`.
  ///
  /// For fetch (read-only), falls back to the production CloudFront domain when
  /// not provided — this is a public, unauthenticated endpoint.
  static const _compileCdnBaseUrl = String.fromEnvironment('CDN_BASE_URL');
  static final String _defaultCdnBaseUrl = resolveCdnBaseUrl(
    compileValue: _compileCdnBaseUrl,
    runtimeValue: AppConfig.cdnBaseUrl,
  );
  static const _defaultPresignEndpoint = String.fromEnvironment(
    'CDN_PRESIGN_URL',
  );
  static final String _resolvedPresignEndpoint = resolvePresignEndpoint(
    compileValue: _defaultPresignEndpoint,
    runtimeValue: AppConfig.cdnPresignUrl,
  );

  static const _fetchTimeout = Duration(seconds: 10);
  static const _presignTimeout = Duration(seconds: 15);
  static const _uploadTimeout = Duration(seconds: 30);

  /// Max response body size for CDN fetches (100 MB).
  /// Prevents OOM on mobile when downloading large videos.
  static const _maxFetchBytes = 100 * 1024 * 1024;

  /// Whether the CDN endpoint is configured.
  bool get isConfigured => _cdnBaseUrl.isNotEmpty;

  /// Whether CDN fetch is enabled (configured + user preference).
  bool get isEnabled => isConfigured && UserPrefsService.instance.cdnEnabled;

  /// Whether CDN upload is enabled (configured + user preference).
  bool get isUploadEnabled =>
      _presignEndpoint.isNotEmpty && UserPrefsService.instance.cdnUploadEnabled;

  @visibleForTesting
  static String resolveCdnBaseUrl({
    String? compileValue,
    String? runtimeValue,
  }) {
    final runtime = runtimeValue?.trim();
    if (runtime != null && runtime.isNotEmpty) return runtime;
    final compile = compileValue?.trim();
    if (compile != null && compile.isNotEmpty) return compile;
    return 'https://d3ttkxcceqn0cp.cloudfront.net';
  }

  @visibleForTesting
  static String resolvePresignEndpoint({
    String? compileValue,
    String? runtimeValue,
  }) {
    final runtime = runtimeValue?.trim();
    if (runtime != null && runtime.isNotEmpty) return runtime;
    final compile = compileValue?.trim();
    if (compile != null && compile.isNotEmpty) return compile;
    return '';
  }

  // ── Fetch ──────────────────────────────────────────────────────────────────

  /// Fetches media from CDN by content hash.
  ///
  /// Returns the local [File] on success (also cached via [CacheManager]),
  /// or null if the CDN does not have this content or the fetch fails.
  Future<File?> fetchFromCdn(
    String contentHash, {
    bool ignorePreference = false,
  }) async {
    final fetchAllowed = ignorePreference ? isConfigured : isEnabled;
    if (!fetchAllowed) return null;

    try {
      final uri = Uri.parse('$_cdnBaseUrl/$contentHash');
      final request = await _httpClient.getUrl(uri).timeout(_fetchTimeout);
      final response = await request.close().timeout(_fetchTimeout);

      if (response.statusCode != 200) {
        await response.drain<void>();
        return null;
      }

      final bytes = await _collectBytes(response);
      if (bytes == null) {
        debugPrint('[CDN] Fetch failed: response exceeded size cap');
        return null;
      }

      // Verify SHA-256 integrity
      final downloadedHash = EncryptionUtils.sha256BytesHex(bytes);
      if (downloadedHash != contentHash) {
        debugPrint(
          '[CDN] Integrity check failed for $contentHash (got $downloadedHash)',
        );
        return null;
      }

      // Determine extension from Content-Type
      final contentType = response.headers.contentType;
      final ext = _extensionFromContentType(contentType);

      // Save to temp directory and register in cache
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/spot_cdn_media/$contentHash$ext');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);

      await CacheManager.instance.addToCache(contentHash, file.path);
      return file;
    } on TimeoutException {
      debugPrint('[CDN] Fetch timed out for $contentHash');
      return null;
    } catch (e) {
      debugPrint('[CDN] Fetch error for $contentHash: $e');
      return null;
    }
  }

  // ── Upload ─────────────────────────────────────────────────────────────────

  /// Uploads media to CDN via presigned S3 PUT URL.
  ///
  /// Steps:
  /// 1. Request presigned URL from Lambda (with Nostr wallet signature)
  /// 2. PUT file bytes directly to S3
  ///
  /// The file at [filePath] is the already-optimized output of
  /// [MediaProcessingService], which strips EXIF during re-encode. We upload
  /// the exact bytes whose SHA-256 matches [contentHash] — no further
  /// transformation, so the CDN content is hash-verifiable.
  ///
  /// This is fire-and-forget — failures are silently ignored since P2P
  /// seeding already ensures availability.
  ///
  /// [signPayload] is a callback that signs the message string using the
  /// user's Nostr wallet and returns (pubkey, signature).
  Future<void> uploadToCdn({
    required String contentHash,
    required String filePath,
    required Future<PresignAuth> Function(String message) signPayload,
    String? contentType,
  }) async {
    if (!isUploadEnabled) return;

    try {
      await _uploadToCdn(
        contentHash: contentHash,
        filePath: filePath,
        signPayload: signPayload,
        contentType: contentType,
        throwOnFailure: false,
      );
    } catch (_) {}
  }

  Future<void> ensureUploadedToCdn({
    required String contentHash,
    required String filePath,
    required Future<PresignAuth> Function(String message) signPayload,
    String? contentType,
  }) async {
    if (_presignEndpoint.isEmpty) {
      throw StateError('CDN upload is not configured for this build');
    }
    await _uploadToCdn(
      contentHash: contentHash,
      filePath: filePath,
      signPayload: signPayload,
      contentType: contentType,
      throwOnFailure: true,
    );
  }

  Future<void> _uploadToCdn({
    required String contentHash,
    required String filePath,
    required Future<PresignAuth> Function(String message) signPayload,
    required bool throwOnFailure,
    String? contentType,
  }) async {
    if (_presignEndpoint.isEmpty) {
      if (throwOnFailure) {
        throw StateError('CDN upload is not configured for this build');
      }
      return;
    }

    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        final message = '[CDN] Upload aborted: file not found at $filePath';
        debugPrint(message);
        if (throwOnFailure) throw StateError(message);
        return;
      }

      // Upload the exact optimized bytes — no re-encoding so hash stays valid.
      final bytes = await file.readAsBytes();
      final isImage = _isImagePath(filePath);

      final resolvedContentType =
          contentType ?? (isImage ? 'image/jpeg' : 'application/octet-stream');

      debugPrint('[CDN] Requesting presigned URL for $contentHash...');
      var presignResult = await _requestPresignUrl(
        contentHash: contentHash,
        contentLength: bytes.length,
        resolvedContentType: resolvedContentType,
        signPayload: signPayload,
      );
      if (!presignResult.isSuccess &&
          isTimestampDriftResponseBody(presignResult.body) &&
          presignResult.serverTimestampSeconds != null) {
        debugPrint(
          '[CDN] Retrying presign for $contentHash using server timestamp '
          '${presignResult.serverTimestampSeconds}',
        );
        presignResult = await _requestPresignUrl(
          contentHash: contentHash,
          contentLength: bytes.length,
          resolvedContentType: resolvedContentType,
          signPayload: signPayload,
          timestampSecondsOverride: presignResult.serverTimestampSeconds,
        );
      }

      if (!presignResult.isSuccess) {
        final message = _presignFailureMessage(
          statusCode: presignResult.statusCode,
          body: presignResult.body,
        );
        debugPrint(message);
        if (throwOnFailure) throw StateError(message);
        return;
      }

      if (presignResult.alreadyExists) {
        debugPrint('[CDN] Content already present for $contentHash');
        return;
      }

      final uploadUrl = presignResult.uploadUrl;
      if (uploadUrl == null) {
        const message = '[CDN] Presign response missing uploadUrl';
        debugPrint(message);
        if (throwOnFailure) throw StateError(message);
        return;
      }

      debugPrint('[CDN] Uploading bytes to S3...');

      // PUT to S3 via presigned URL
      final putUri = Uri.parse(uploadUrl);
      final putRequest = await _httpClient
          .putUrl(putUri)
          .timeout(_uploadTimeout);
      putRequest.headers.contentType = ContentType.parse(resolvedContentType);
      putRequest.contentLength = bytes.length;
      putRequest.headers.set(HttpHeaders.ifNoneMatchHeader, '*');
      putRequest.add(bytes);

      final putResponse = await putRequest.close().timeout(_uploadTimeout);
      await putResponse.drain<void>();

      if (putResponse.statusCode == 200 || putResponse.statusCode == 204) {
        debugPrint('[CDN] Successfully uploaded $contentHash');
      } else {
        final message =
            '[CDN] S3 upload failed with status ${putResponse.statusCode}';
        debugPrint(message);
        if (throwOnFailure) throw StateError(message);
      }
    } on TimeoutException {
      final message = '[CDN] Upload timed out for $contentHash';
      debugPrint(message);
      if (throwOnFailure) throw TimeoutException(message);
    } catch (e) {
      debugPrint('[CDN] Upload failed for $contentHash: $e');
      if (throwOnFailure) rethrow;
    }
  }

  Future<_PresignResult> _requestPresignUrl({
    required String contentHash,
    required int contentLength,
    required String resolvedContentType,
    required Future<PresignAuth> Function(String message) signPayload,
    int? timestampSecondsOverride,
  }) async {
    final timestampSeconds =
        timestampSecondsOverride ??
        (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000);
    final timestamp = timestampSeconds.toString();
    final message =
        'PUT:$contentHash:$timestamp:$contentLength:$resolvedContentType';
    final auth = await signPayload(message);

    final presignUri = Uri.parse(_presignEndpoint);
    final presignRequest = await _httpClient
        .postUrl(presignUri)
        .timeout(_presignTimeout);
    presignRequest.headers.contentType = ContentType.json;
    final accessToken =
        Supabase.instance.client.auth.currentSession?.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Authenticated session required for CDN upload');
    }
    presignRequest.headers.set(
      HttpHeaders.authorizationHeader,
      'Bearer $accessToken',
    );
    presignRequest.write(
      jsonEncode({
        'pubkey': auth.pubkey,
        'contentHash': contentHash,
        'timestamp': timestamp,
        'signature': auth.signature,
        'contentType': resolvedContentType,
        'contentLength': contentLength,
      }),
    );
    final presignResponse = await presignRequest.close().timeout(
      _presignTimeout,
    );
    final body = await _collectString(presignResponse);

    if (presignResponse.statusCode != 200) {
      return _PresignResult(
        statusCode: presignResponse.statusCode,
        body: body,
        serverTimestampSeconds: timestampSecondsFromDateHeader(
          presignResponse.headers.value(HttpHeaders.dateHeader),
        ),
      );
    }

    final presignJson = jsonDecode(body) as Map<String, dynamic>;
    return _PresignResult(
      statusCode: presignResponse.statusCode,
      body: body,
      uploadUrl: presignJson['uploadUrl'] as String?,
      alreadyExists: presignJson['alreadyExists'] == true,
      serverTimestampSeconds: timestampSecondsFromDateHeader(
        presignResponse.headers.value(HttpHeaders.dateHeader),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static bool _isImagePath(String path) {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  static String _extensionFromContentType(ContentType? contentType) {
    if (contentType == null) return '';
    final sub = contentType.subType.toLowerCase();
    return switch (sub) {
      'jpeg' => '.jpg',
      'png' => '.png',
      'webp' => '.webp',
      'mp4' => '.mp4',
      'quicktime' => '.mov',
      _ => '',
    };
  }

  /// Collects response bytes with a size cap to prevent OOM on mobile.
  /// Returns null if the response exceeds [_maxFetchBytes].
  static Future<Uint8List?> _collectBytes(HttpClientResponse response) async {
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
      if (builder.length > _maxFetchBytes) return null;
    }
    return builder.takeBytes();
  }

  static Future<String> _collectString(HttpClientResponse response) async {
    final builder = StringBuffer();
    await for (final chunk in response.transform(utf8.decoder)) {
      builder.write(chunk);
    }
    return builder.toString();
  }

  @visibleForTesting
  static bool isTimestampDriftResponseBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return false;
      final error = decoded['error']?.toString().trim().toLowerCase();
      return error == 'timestamp too far from server time';
    } catch (_) {
      return body.toLowerCase().contains('timestamp too far from server time');
    }
  }

  @visibleForTesting
  static int? timestampSecondsFromDateHeader(String? dateHeader) {
    final value = dateHeader?.trim();
    if (value == null || value.isEmpty) return null;
    try {
      return HttpDate.parse(value).toUtc().millisecondsSinceEpoch ~/ 1000;
    } catch (_) {
      return null;
    }
  }

  static String _presignFailureMessage({
    required int statusCode,
    required String body,
  }) {
    if (isTimestampDriftResponseBody(body)) {
      return '[CDN] Presign request failed ($statusCode): '
          'Device time appears out of sync. Turn on automatic date & time and try again.';
    }
    return '[CDN] Presign request failed ($statusCode): $body';
  }
}

/// Authentication payload returned by the wallet signing callback.
class PresignAuth {
  const PresignAuth({required this.pubkey, required this.signature});

  final String pubkey;
  final String signature;
}

class _PresignResult {
  const _PresignResult({
    required this.statusCode,
    required this.body,
    this.uploadUrl,
    this.alreadyExists = false,
    this.serverTimestampSeconds,
  });

  final int statusCode;
  final String body;
  final String? uploadUrl;
  final bool alreadyExists;
  final int? serverTimestampSeconds;

  bool get isSuccess =>
      statusCode == 200 && (uploadUrl != null || alreadyExists);
}

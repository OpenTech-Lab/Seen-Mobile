import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:pointycastle/export.dart';

import 'package:mobile/core/attestation.dart';
import 'package:mobile/core/encryption.dart';
import 'package:mobile/models/event_model.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/services/storage_service.dart';

/// Device-Bound Nostr Wallet.
///
/// Handles all cryptographic operations:
/// - secp256k1 key-pair generation and deterministic derivation from BIP39 mnemonic
/// - Nostr event ID computation and ECDSA signing
/// - Wallet persistence via [StorageService]
/// - Recovery payload creation and validation for QR backup
///
/// TODO: Replace ECDSA signing with proper Schnorr (BIP340) once a mature
///       Dart implementation is available. Nostr uses Schnorr signatures; ECDSA
///       is used here as a prototype substitute.
class WalletService {
  WalletService._();

  /// Prefix for the QR recovery envelope. This identifies the payload format;
  /// it is not encryption. Anyone who obtains the QR must be treated as
  /// having the recovery phrase.
  static const recoveryPayloadPrefix = 'seen-recovery-v1:';

  // ── secp256k1 curve parameters ────────────────────────────────────────────

  static final ECDomainParameters _curve = ECDomainParameters('secp256k1');

  // ── Key generation ────────────────────────────────────────────────────────

  /// Generates a random secp256k1 key-pair.
  /// Returns (privateKeyHex, publicKeyHex) where publicKeyHex is the
  /// x-coordinate of the EC point (32 bytes = 64 hex chars).
  static (String privateKeyHex, String publicKeyHex) generateKeypair() {
    final privBytes = EncryptionUtils.randomBytes(32);
    return _keypairFromPrivateBytes(privBytes);
  }

  /// Derives a key-pair deterministically from [mnemonic] words.
  /// Uses the BIP39 seed (first 32 bytes) as the private key scalar.
  static (String privateKeyHex, String publicKeyHex) keypairFromMnemonic(
    List<String> mnemonic,
  ) {
    final phrase = mnemonic.join(' ');
    final seedHex = bip39.mnemonicToSeedHex(phrase);
    // Use first 32 bytes of 512-bit BIP39 seed as the private key
    final privBytes = EncryptionUtils.hexToBytes(seedHex.substring(0, 64));
    return _keypairFromPrivateBytes(privBytes);
  }

  /// Internal: derives public key from raw 32-byte private key bytes.
  static (String, String) _keypairFromPrivateBytes(Uint8List privBytes) {
    // Clamp to valid secp256k1 range (1 <= scalar < n)
    final privInt = _bytesToBigInt(privBytes);
    final n = _curve.n;
    final clamped = (privInt % (n - BigInt.one)) + BigInt.one;
    final clampedBytes = _bigIntToBytes(clamped, 32);

    final privKey = ECPrivateKey(clamped, _curve);
    final pubPoint = _curve.G * privKey.d!;
    if (pubPoint == null || pubPoint.isInfinity) {
      throw StateError('Invalid private key produced an infinity point');
    }

    // x-only public key (Nostr convention)
    final xBytes = _bigIntToBytes(pubPoint.x!.toBigInteger()!, 32);

    return (
      EncryptionUtils.bytesToHex(clampedBytes),
      EncryptionUtils.bytesToHex(xBytes),
    );
  }

  // ── Mnemonic ──────────────────────────────────────────────────────────────

  /// Generates a new random 12-word BIP39 mnemonic.
  static List<String> generateMnemonic() {
    final phrase = bip39.generateMnemonic();
    return phrase.split(' ');
  }

  /// Validates a 12-word BIP39 mnemonic.
  static bool validateMnemonic(List<String> words) {
    return bip39.validateMnemonic(words.join(' '));
  }

  // ── Nostr event operations ────────────────────────────────────────────────

  /// Computes the Nostr event ID: SHA-256 of the canonical serialization.
  static String computeEventId(NostrEvent event) {
    final serialized = event.serialize();
    return EncryptionUtils.sha256Hex(serialized);
  }

  /// Signs a Nostr event using BIP340 Schnorr over secp256k1.
  /// Returns the 64-byte signature as a hex string.
  static String signNostrEvent(NostrEvent event, String privKeyHex) {
    final msgBytes = EncryptionUtils.hexToBytes(event.id);
    final privBytes = EncryptionUtils.hexToBytes(privKeyHex);
    return _schnorrSign(msgBytes, privBytes);
  }

  /// BIP340 Schnorr signing.
  static String _schnorrSign(Uint8List msg, Uint8List privBytes) {
    final n = _curve.n;

    var sk = _bytesToBigInt(privBytes);

    // P = sk·G
    final P = (_curve.G * sk)!;
    final px = _bigIntToBytes(P.x!.toBigInteger()!, 32);

    // If P.y is odd, negate sk so the public key has even y (BIP340 §3)
    if (P.y!.toBigInteger()!.isOdd) sk = n - sk;
    final skBytes = _bigIntToBytes(sk, 32);

    // t = sk ⊕ tagged_hash("BIP0340/aux", zeros)
    final auxHash = _taggedHash('BIP0340/aux', Uint8List(32));
    final t = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      t[i] = skBytes[i] ^ auxHash[i];
    }

    // rand = tagged_hash("BIP0340/nonce", t ‖ px ‖ msg)
    final rand = _taggedHash(
      'BIP0340/nonce',
      Uint8List.fromList([...t, ...px, ...msg]),
    );
    var k = _bytesToBigInt(rand) % n;
    if (k == BigInt.zero) k = BigInt.one; // astronomically unlikely

    // R = k·G
    final r = (_curve.G * k)!;
    final rx = _bigIntToBytes(r.x!.toBigInteger()!, 32);

    // If R.y is odd, negate k
    if (r.y!.toBigInteger()!.isOdd) k = n - k;

    // e = int(tagged_hash("BIP0340/challenge", rx ‖ px ‖ msg)) mod n
    final eBytes = _taggedHash(
      'BIP0340/challenge',
      Uint8List.fromList([...rx, ...px, ...msg]),
    );
    final e = _bytesToBigInt(eBytes) % n;

    // sig = rx ‖ (k + e·sk) mod n
    final sigS = _bigIntToBytes((k + e * sk) % n, 32);
    return EncryptionUtils.bytesToHex(Uint8List.fromList([...rx, ...sigS]));
  }

  /// BIP340 tagged hash: SHA256(SHA256(tag) ‖ SHA256(tag) ‖ data)
  static Uint8List _taggedHash(String tag, Uint8List data) {
    final tagBytes = Uint8List.fromList(utf8.encode(tag));
    final tagHash = SHA256Digest().process(tagBytes);
    return SHA256Digest().process(
      Uint8List.fromList([...tagHash, ...tagHash, ...data]),
    );
  }

  /// Signs an arbitrary message string using BIP340 Schnorr.
  ///
  /// Returns the 64-byte hex signature. The message is first hashed with
  /// SHA-256 to produce the 32-byte input that BIP340 expects.
  static String signMessage(String message, String privKeyHex) {
    final msgHash = EncryptionUtils.sha256(
      Uint8List.fromList(utf8.encode(message)),
    );
    final privBytes = EncryptionUtils.hexToBytes(privKeyHex);
    return _schnorrSign(msgHash, privBytes);
  }

  // ── Wallet persistence ────────────────────────────────────────────────────

  /// Persists [wallet] via [StorageService].
  static Future<void> saveWallet(WalletModel wallet) async {
    await StorageService.instance.saveWallet(wallet);
  }

  /// Loads the stored wallet, or returns null if none exists.
  static Future<WalletModel?> loadWallet() async {
    return StorageService.instance.loadWallet();
  }

  // ── Identity creation ─────────────────────────────────────────────────────

  /// Creates a brand-new wallet from scratch (random key-pair + mnemonic).
  static Future<WalletModel> createNewWallet() async {
    final mnemonic = generateMnemonic();
    return _buildWallet(mnemonic);
  }

  /// Reconstructs a wallet from an existing mnemonic (e.g. after migration).
  static Future<WalletModel> importFromMnemonic(List<String> mnemonic) async {
    if (!validateMnemonic(mnemonic)) {
      throw ArgumentError('Invalid BIP39 mnemonic');
    }
    return _buildWallet(mnemonic);
  }

  static Future<WalletModel> _buildWallet(List<String> mnemonic) async {
    final (privHex, pubHex) = keypairFromMnemonic(mnemonic);
    final deviceId = await AttestationService.getDeviceId();
    final npub = _encodeNpub(pubHex);

    return WalletModel(
      privateKeyHex: privHex,
      publicKeyHex: pubHex,
      npub: npub,
      mnemonic: mnemonic,
      deviceId: deviceId,
      isRevoked: false,
      createdAt: DateTime.now().toUtc(),
    );
  }

  // ── Recovery QR ───────────────────────────────────────────────────────────

  /// Creates a versioned recovery envelope for QR display.
  ///
  /// The mnemonic is intentionally included because it is the portable
  /// recovery secret. The source device ID is deliberately not used as an
  /// authenticator: it is not a secret and a restored wallet must receive the
  /// new device's own ID.
  static String createRecoveryPayload(WalletModel wallet) {
    final payload = jsonEncode({
      'type': 'seen-recovery',
      'version': 1,
      'mnemonic': wallet.mnemonic,
      'publicKey': wallet.publicKeyHex,
    });

    return '$recoveryPayloadPrefix${base64Url.encode(utf8.encode(payload))}';
  }

  /// Returns whether [raw] looks like a recovery QR created by this app.
  static bool isRecoveryPayload(String raw) =>
      raw.trim().startsWith(recoveryPayloadPrefix);

  /// Restores a wallet from a recovery QR envelope.
  ///
  /// The public key in the envelope is checked against the key derived from
  /// the mnemonic before the new wallet is created. [createNewWallet]'s normal
  /// device-attestation path then assigns the current device a fresh ID.
  static Future<WalletModel> importFromRecoveryPayload(String raw) async {
    final payload = _decodeRecoveryPayload(raw);
    if (payload['type'] != 'seen-recovery' || payload['version'] != 1) {
      throw const FormatException('Unsupported recovery QR format');
    }

    final rawWords = payload['mnemonic'];
    if (rawWords is! List || rawWords.length != 12) {
      throw const FormatException('Recovery QR does not contain 12 words');
    }

    final words = rawWords
        .map((word) => word.toString().trim().toLowerCase())
        .toList(growable: false);
    if (!validateMnemonic(words)) {
      throw const FormatException('Recovery QR contains an invalid phrase');
    }

    final encodedPublicKey = payload['publicKey']?.toString().trim();
    final (_, derivedPublicKey) = keypairFromMnemonic(words);
    if (encodedPublicKey != derivedPublicKey) {
      throw const FormatException('Recovery QR identity check failed');
    }

    return _buildWallet(words);
  }

  /// Compatibility shim for callers of the original migration helper.
  ///
  /// The old helper produced ciphertext that could not be decrypted on a new
  /// device because its key came from the secret inside the payload.
  @Deprecated('Use createRecoveryPayload instead')
  static Future<String> createMigrationPayload(WalletModel wallet) async {
    return createRecoveryPayload(wallet);
  }

  static Map<String, dynamic> _decodeRecoveryPayload(String raw) {
    final trimmed = raw.trim();
    if (!isRecoveryPayload(trimmed)) {
      throw const FormatException('Not a #seen recovery QR');
    }

    try {
      final encoded = trimmed.substring(recoveryPayloadPrefix.length);
      final decoded = utf8.decode(
        base64Url.decode(base64Url.normalize(encoded)),
      );
      final json = jsonDecode(decoded);
      if (json is! Map) {
        throw const FormatException('Recovery QR payload is not an object');
      }
      return Map<String, dynamic>.from(json);
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Recovery QR payload is unreadable');
    }
  }

  // ── Nostr public key encoding (simplified bech32) ─────────────────────────

  /// Encodes a 32-byte public key hex as a Nostr npub bech32 string.
  /// Uses a simplified encoding; for production use a proper bech32 library.
  static String _encodeNpub(String pubkeyHex) {
    // Simplified: real bech32 encoding would convert the 5-bit groups properly.
    // This produces a visually correct npub-prefixed string for prototype use.
    final bytes = EncryptionUtils.hexToBytes(pubkeyHex);
    final b64 = base64Url.encode(bytes).replaceAll('=', '');
    // Replace base64url chars to look more like bech32 (prototype only)
    return 'npub1${b64.toLowerCase().replaceAll('-', 'q').replaceAll('_', 'z')}';
  }

  // ── BigInt helpers ────────────────────────────────────────────────────────

  static BigInt _bytesToBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (final b in bytes) {
      result = (result << 8) | BigInt.from(b);
    }
    return result;
  }

  static Uint8List _bigIntToBytes(BigInt value, int length) {
    final result = Uint8List(length);
    var v = value;
    for (var i = length - 1; i >= 0; i--) {
      result[i] = (v & BigInt.from(0xff)).toInt();
      v >>= 8;
    }
    return result;
  }
}

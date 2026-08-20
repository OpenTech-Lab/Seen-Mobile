import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:mobile/models/identity_model.dart';
import 'package:mobile/models/wallet_model.dart';

/// Keys used in secure storage.
class _Keys {
  static const privateKey = 'wallet_privkey';
  static const publicKey = 'wallet_pubkey';
  static const mnemonic = 'wallet_mnemonic';
  static const deviceId = 'wallet_deviceid';
  static const npub = 'wallet_npub';
  static const createdAt = 'wallet_created_at';
  static const isRevoked = 'is_revoked';
  static const identityVault = 'identity_vault_v1';
}

/// Secure storage service backed by [FlutterSecureStorage].
///
/// On Android: uses Android Keystore (AES-256-GCM).
/// On iOS: uses iOS Keychain (Secure Enclave where available).
///
/// StorageService is a singleton — access via [StorageService.instance].
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Wallet ────────────────────────────────────────────────────────────────

  /// Persists all wallet fields individually so they can be loaded atomically.
  Future<void> saveWallet(WalletModel wallet) async {
    await Future.wait([
      _storage.write(key: _Keys.privateKey, value: wallet.privateKeyHex),
      _storage.write(key: _Keys.publicKey, value: wallet.publicKeyHex),
      _storage.write(key: _Keys.npub, value: wallet.npub),
      _storage.write(key: _Keys.mnemonic, value: jsonEncode(wallet.mnemonic)),
      _storage.write(key: _Keys.deviceId, value: wallet.deviceId),
      _storage.write(
        key: _Keys.createdAt,
        value: wallet.createdAt.toIso8601String(),
      ),
      _storage.write(
        key: _Keys.isRevoked,
        value: wallet.isRevoked ? 'true' : 'false',
      ),
    ]);
  }

  /// Persists all local personas in one encrypted secure-storage record.
  ///
  /// The vault is intentionally separate from the legacy single-wallet keys
  /// so existing installs can be migrated without losing their identity.
  Future<void> saveIdentityVault(IdentityVault vault) async {
    await _storage.write(
      key: _Keys.identityVault,
      value: jsonEncode(vault.toJson()),
    );
  }

  /// Loads the multi-identity vault, if this install has one.
  Future<IdentityVault?> loadIdentityVault() async {
    final raw = await _storage.read(key: _Keys.identityVault);
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return IdentityVault.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  /// Loads the stored wallet.  Returns null if no wallet has been saved yet.
  Future<WalletModel?> loadWallet() async {
    final privKey = await _storage.read(key: _Keys.privateKey);
    if (privKey == null) return null;

    final pubKey = await _storage.read(key: _Keys.publicKey);
    final npub = await _storage.read(key: _Keys.npub);
    final mnemonicJson = await _storage.read(key: _Keys.mnemonic);
    final deviceId = await _storage.read(key: _Keys.deviceId);
    final createdAtStr = await _storage.read(key: _Keys.createdAt);
    final isRevokedStr = await _storage.read(key: _Keys.isRevoked);

    if (pubKey == null ||
        npub == null ||
        mnemonicJson == null ||
        deviceId == null ||
        createdAtStr == null) {
      return null;
    }

    final mnemonic = List<String>.from(jsonDecode(mnemonicJson) as List);

    return WalletModel(
      privateKeyHex: privKey,
      publicKeyHex: pubKey,
      npub: npub,
      mnemonic: mnemonic,
      deviceId: deviceId,
      isRevoked: isRevokedStr == 'true',
      createdAt: DateTime.parse(createdAtStr),
    );
  }

  /// Deletes all wallet data from secure storage.
  Future<void> deleteWallet() async {
    await Future.wait([
      _storage.delete(key: _Keys.privateKey),
      _storage.delete(key: _Keys.publicKey),
      _storage.delete(key: _Keys.npub),
      _storage.delete(key: _Keys.mnemonic),
      _storage.delete(key: _Keys.deviceId),
      _storage.delete(key: _Keys.createdAt),
      _storage.delete(key: _Keys.isRevoked),
      _storage.delete(key: _Keys.identityVault),
    ]);
  }

  // ── Revocation ────────────────────────────────────────────────────────────

  /// Marks this wallet as revoked (called after identity migration).
  /// The private key is deleted but metadata is preserved so the user can
  /// see their revocation status.
  Future<void> setRevoked() async {
    await Future.wait([
      _storage.write(key: _Keys.isRevoked, value: 'true'),
      _storage.delete(key: _Keys.privateKey), // private key wiped on revoke
    ]);
  }

  /// Returns true if the stored wallet has been revoked.
  Future<bool> isRevoked() async {
    final value = await _storage.read(key: _Keys.isRevoked);
    return value == 'true';
  }
}

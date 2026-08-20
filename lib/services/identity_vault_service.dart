import 'package:mobile/core/wallet.dart';
import 'package:mobile/models/identity_model.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/services/storage_service.dart';

/// Manages the local owner vault and the public identities inside it.
///
/// The vault is device-local and encrypted by [StorageService]. It gives a
/// user a safe way to keep personal, company, studio, and brand keypairs
/// separate. It is not a server-side organization model yet.
class IdentityVaultService {
  IdentityVaultService._();

  static final IdentityVaultService instance = IdentityVaultService._();

  final StorageService _storage = StorageService.instance;
  Future<IdentityVault?>? _loadFuture;
  IdentityVault? _vault;

  IdentityVault? get currentVault => _vault;

  AccountIdentity? get activeIdentity => _vault?.activeIdentity;

  AccountIdentity? identityFor(String identityId) {
    final vault = _vault;
    if (vault == null) return null;
    for (final identity in vault.identities) {
      if (identity.id == identityId) return identity;
    }
    return null;
  }

  Future<IdentityVault?> load() {
    return _loadFuture ??= _loadInternal();
  }

  Future<IdentityVault?> _loadInternal() async {
    final stored = await _storage.loadIdentityVault();
    if (stored != null) {
      _vault = stored;
      return stored;
    }

    // Migrate the existing one-wallet install into a primary Personal
    // identity. Keep the legacy keys for backwards compatibility with older
    // app versions; logout/reset removes both formats.
    final legacyWallet = await _storage.loadWallet();
    if (legacyWallet == null) return null;

    final migrated = IdentityVault.fromPrimaryWallet(legacyWallet);
    _vault = migrated;
    await _storage.saveIdentityVault(migrated);
    return migrated;
  }

  Future<WalletModel?> loadActiveWallet() async {
    final vault = await load();
    return vault?.activeIdentity.wallet;
  }

  Future<void> initializeWithPrimaryWallet(WalletModel wallet) async {
    final vault = IdentityVault.fromPrimaryWallet(wallet);
    _vault = vault;
    _loadFuture = Future<IdentityVault?>.value(vault);
    await Future.wait([
      _storage.saveWallet(wallet),
      _storage.saveIdentityVault(vault),
    ]);
  }

  Future<AccountIdentity> createIdentity({
    required String label,
    required IdentityKind kind,
  }) async {
    final vault = await load();
    if (vault == null) {
      throw StateError('Create the primary identity before adding a persona');
    }

    final normalizedLabel = label.trim();
    if (normalizedLabel.isEmpty) {
      throw ArgumentError.value(label, 'label', 'Identity name is required');
    }

    final wallet = await WalletService.createNewWallet();
    final identity = AccountIdentity(
      id: wallet.publicKeyHex,
      label: normalizedLabel,
      kind: kind,
      wallet: wallet,
      isPrimary: false,
      createdAt: wallet.createdAt,
    );
    _vault = vault.add(identity);
    await _storage.saveIdentityVault(_vault!);
    return identity;
  }

  Future<void> switchIdentity(String identityId) async {
    final vault = await load();
    if (vault == null) throw StateError('No identity vault is available');
    final next = vault.switchTo(identityId);
    _vault = next;
    await _storage.saveIdentityVault(next);
  }

  Future<void> removeIdentity(String identityId) async {
    final vault = await load();
    if (vault == null) throw StateError('No identity vault is available');
    final next = vault.remove(identityId);
    _vault = next;
    await _storage.saveIdentityVault(next);
  }

  /// Stores a device-local anonymous Supabase session for [identityId].
  ///
  /// Refresh tokens are credentials, so callers must never put this value in
  /// a QR payload or log it. The enclosing vault is stored in secure storage.
  Future<void> saveAuthRefreshToken({
    required String identityId,
    required String refreshToken,
  }) async {
    final vault = await load();
    if (vault == null || refreshToken.trim().isEmpty) return;

    final identity = vault.identities.firstWhere(
      (candidate) => candidate.id == identityId,
      orElse: () => throw ArgumentError.value(
        identityId,
        'identityId',
        'Unknown identity',
      ),
    );
    _vault = vault.replaceIdentity(
      identity.copyWith(authRefreshToken: refreshToken.trim()),
    );
    await _storage.saveIdentityVault(_vault!);
  }

  Future<String?> authRefreshTokenFor(String identityId) async {
    final vault = await load();
    if (vault == null) return null;
    for (final identity in vault.identities) {
      if (identity.id == identityId) return identity.authRefreshToken;
    }
    return null;
  }

  Future<void> clear() async {
    _vault = null;
    _loadFuture = Future<IdentityVault?>.value(null);
    await _storage.deleteWallet();
  }
}

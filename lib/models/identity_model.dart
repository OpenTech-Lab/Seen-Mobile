import 'package:mobile/models/wallet_model.dart';

/// The public persona a user is currently acting as.
///
/// An identity is deliberately backed by its own [WalletModel]. A label such
/// as "Studio" is not a permission role: it is a separate cryptographic
/// identity whose recovery phrase must never be the main identity's phrase.
enum IdentityKind {
  personal('personal'),
  company('company'),
  studio('studio'),
  brand('brand'),
  custom('custom');

  const IdentityKind(this.storageValue);

  final String storageValue;

  static IdentityKind fromStorage(String? value) {
    for (final kind in IdentityKind.values) {
      if (kind.storageValue == value) return kind;
    }
    return IdentityKind.custom;
  }
}

/// A named public persona stored inside the local owner vault.
class AccountIdentity {
  const AccountIdentity({
    required this.id,
    required this.label,
    required this.kind,
    required this.wallet,
    required this.isPrimary,
    required this.createdAt,
    this.authRefreshToken,
  });

  /// Uses the public key as the stable local identifier.
  final String id;
  final String label;
  final IdentityKind kind;
  final WalletModel wallet;
  final bool isPrimary;
  final DateTime createdAt;

  /// Device-local Supabase session credential for this persona.
  ///
  /// This is kept in the encrypted identity vault and is never placed in a
  /// recovery QR. It only preserves same-device anonymous sessions; it does
  /// not turn an anonymous session into portable account ownership.
  final String? authRefreshToken;

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'kind': kind.storageValue,
    'wallet': wallet.toJson(),
    'isPrimary': isPrimary,
    'createdAt': createdAt.toIso8601String(),
    if (authRefreshToken != null) 'authRefreshToken': authRefreshToken,
  };

  factory AccountIdentity.fromJson(Map<String, dynamic> json) {
    final walletJson = json['wallet'];
    if (walletJson is! Map) {
      throw const FormatException('Identity wallet is missing');
    }

    final wallet = WalletModel.fromJson(Map<String, dynamic>.from(walletJson));
    final id = (json['id'] as String?)?.trim();
    if (id == null || id.isEmpty) {
      throw const FormatException('Identity id is missing');
    }

    final label = (json['label'] as String?)?.trim();
    return AccountIdentity(
      id: id,
      label: label == null || label.isEmpty ? 'Identity' : label,
      kind: IdentityKind.fromStorage(json['kind'] as String?),
      wallet: wallet,
      isPrimary: json['isPrimary'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
      authRefreshToken: (json['authRefreshToken'] as String?)?.trim(),
    );
  }

  AccountIdentity copyWith({
    String? label,
    IdentityKind? kind,
    WalletModel? wallet,
    bool? isPrimary,
    DateTime? createdAt,
    String? authRefreshToken,
  }) => AccountIdentity(
    id: id,
    label: label ?? this.label,
    kind: kind ?? this.kind,
    wallet: wallet ?? this.wallet,
    isPrimary: isPrimary ?? this.isPrimary,
    createdAt: createdAt ?? this.createdAt,
    authRefreshToken: authRefreshToken ?? this.authRefreshToken,
  );
}

/// Local owner vault containing one primary identity and optional personas.
class IdentityVault {
  const IdentityVault({
    required this.ownerIdentityId,
    required this.activeIdentityId,
    required this.identities,
  });

  final String ownerIdentityId;
  final String activeIdentityId;
  final List<AccountIdentity> identities;

  AccountIdentity get activeIdentity => identities.firstWhere(
    (identity) => identity.id == activeIdentityId,
    orElse: () => identities.first,
  );

  AccountIdentity get ownerIdentity => identities.firstWhere(
    (identity) => identity.id == ownerIdentityId,
    orElse: () => identities.first,
  );

  factory IdentityVault.fromPrimaryWallet(WalletModel wallet) {
    final identity = AccountIdentity(
      id: wallet.publicKeyHex,
      label: 'Personal',
      kind: IdentityKind.personal,
      wallet: wallet,
      isPrimary: true,
      createdAt: wallet.createdAt,
    );
    return IdentityVault(
      ownerIdentityId: identity.id,
      activeIdentityId: identity.id,
      identities: [identity],
    );
  }

  Map<String, dynamic> toJson() => {
    'ownerIdentityId': ownerIdentityId,
    'activeIdentityId': activeIdentityId,
    'identities': identities.map((identity) => identity.toJson()).toList(),
  };

  factory IdentityVault.fromJson(Map<String, dynamic> json) {
    final rawIdentities = json['identities'];
    if (rawIdentities is! List || rawIdentities.isEmpty) {
      throw const FormatException('Identity vault is empty');
    }

    final identities = rawIdentities
        .whereType<Map>()
        .map(
          (identity) =>
              AccountIdentity.fromJson(Map<String, dynamic>.from(identity)),
        )
        .toList(growable: false);
    if (identities.isEmpty) {
      throw const FormatException('Identity vault contains no identities');
    }

    final identityIds = identities.map((identity) => identity.id).toSet();
    final ownerId = (json['ownerIdentityId'] as String?)?.trim();
    final activeId = (json['activeIdentityId'] as String?)?.trim();
    return IdentityVault(
      ownerIdentityId: ownerId != null && identityIds.contains(ownerId)
          ? ownerId
          : identities.first.id,
      activeIdentityId: activeId != null && identityIds.contains(activeId)
          ? activeId
          : identities.first.id,
      identities: identities,
    );
  }

  IdentityVault switchTo(String identityId) {
    if (!identities.any((identity) => identity.id == identityId)) {
      throw ArgumentError.value(identityId, 'identityId', 'Unknown identity');
    }
    return IdentityVault(
      ownerIdentityId: ownerIdentityId,
      activeIdentityId: identityId,
      identities: identities,
    );
  }

  IdentityVault add(AccountIdentity identity, {bool activate = false}) {
    if (identities.any((existing) => existing.id == identity.id)) {
      throw ArgumentError.value(identity.id, 'identity.id', 'Already exists');
    }
    return IdentityVault(
      ownerIdentityId: ownerIdentityId,
      activeIdentityId: activate ? identity.id : activeIdentityId,
      identities: [...identities, identity],
    );
  }

  IdentityVault remove(String identityId) {
    if (identityId == ownerIdentityId) {
      throw StateError('The primary identity cannot be removed from the vault');
    }
    final remaining = identities
        .where((identity) => identity.id != identityId)
        .toList(growable: false);
    if (remaining.length == identities.length) {
      throw ArgumentError.value(identityId, 'identityId', 'Unknown identity');
    }
    final nextActive = activeIdentityId == identityId
        ? ownerIdentityId
        : activeIdentityId;
    return IdentityVault(
      ownerIdentityId: ownerIdentityId,
      activeIdentityId: nextActive,
      identities: remaining,
    );
  }

  IdentityVault replaceIdentity(AccountIdentity replacement) {
    if (!identities.any((identity) => identity.id == replacement.id)) {
      throw ArgumentError.value(
        replacement.id,
        'replacement.id',
        'Unknown identity',
      );
    }
    return IdentityVault(
      ownerIdentityId: ownerIdentityId,
      activeIdentityId: activeIdentityId,
      identities: [
        for (final identity in identities)
          identity.id == replacement.id ? replacement : identity,
      ],
    );
  }
}

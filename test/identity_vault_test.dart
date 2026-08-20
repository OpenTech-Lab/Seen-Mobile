import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/models/identity_model.dart';
import 'package:mobile/models/wallet_model.dart';

void main() {
  test('vault keeps primary and persona identities separate', () {
    final primaryWallet = _wallet('1', '2');
    final studioWallet = _wallet('3', '4');
    final primaryVault = IdentityVault.fromPrimaryWallet(primaryWallet);
    final studio = AccountIdentity(
      id: studioWallet.publicKeyHex,
      label: 'Cyan Studio',
      kind: IdentityKind.studio,
      wallet: studioWallet,
      isPrimary: false,
      createdAt: studioWallet.createdAt,
      authRefreshToken: 'device-only-token',
    );

    final withStudio = primaryVault.add(studio);
    final switched = withStudio.switchTo(studio.id);

    expect(
      withStudio.ownerIdentity.wallet.publicKeyHex,
      primaryWallet.publicKeyHex,
    );
    expect(switched.activeIdentity.label, 'Cyan Studio');
    expect(
      switched.activeIdentity.wallet.publicKeyHex,
      studioWallet.publicKeyHex,
    );

    final decoded = IdentityVault.fromJson(withStudio.toJson());
    expect(decoded.identities, hasLength(2));
    expect(decoded.identities.last.authRefreshToken, 'device-only-token');

    final removed = switched.remove(studio.id);
    expect(removed.identities, hasLength(1));
    expect(removed.activeIdentity.id, primaryVault.ownerIdentityId);
  });

  test('primary identity cannot be removed', () {
    final vault = IdentityVault.fromPrimaryWallet(_wallet('1', '2'));

    expect(
      () => vault.remove(vault.ownerIdentityId),
      throwsA(isA<StateError>()),
    );
  });
}

WalletModel _wallet(String privateDigit, String publicDigit) => WalletModel(
  privateKeyHex: privateDigit * 64,
  publicKeyHex: publicDigit * 64,
  npub: 'npub1$publicDigit',
  mnemonic: const [
    'alpha',
    'bravo',
    'charlie',
    'delta',
    'echo',
    'foxtrot',
    'golf',
    'hotel',
    'india',
    'juliet',
    'kilo',
    'lima',
  ],
  deviceId: 'device-$privateDigit',
  isRevoked: false,
  createdAt: DateTime.utc(2026, 3, 26, 10, 30),
);

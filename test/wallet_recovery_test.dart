import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/core/wallet.dart';
import 'package:mobile/models/wallet_model.dart';

void main() {
  test(
    'recovery QR round-trips the identity and uses the versioned envelope',
    () async {
      final wallet = _wallet();
      final payload = WalletService.createRecoveryPayload(wallet);

      expect(WalletService.isRecoveryPayload(payload), isTrue);

      final restored = await WalletService.importFromRecoveryPayload(payload);

      expect(restored.publicKeyHex, wallet.publicKeyHex);
      expect(restored.mnemonic, wallet.mnemonic);
    },
  );

  test('recovery QR rejects an identity mismatch', () async {
    final payload = WalletService.createRecoveryPayload(_wallet());
    final body = _decodeBody(payload);
    body['publicKey'] = 'f' * 64;
    final tampered = _encodeBody(body);

    expect(
      WalletService.importFromRecoveryPayload(tampered),
      throwsA(isA<FormatException>()),
    );
  });

  test('recovery QR rejects arbitrary QR data', () {
    expect(
      WalletService.importFromRecoveryPayload('hello'),
      throwsA(isA<FormatException>()),
    );
  });
}

Map<String, dynamic> _decodeBody(String payload) {
  final encoded = payload.substring(WalletService.recoveryPayloadPrefix.length);
  final json = jsonDecode(
    utf8.decode(base64Url.decode(base64Url.normalize(encoded))),
  );
  return Map<String, dynamic>.from(json as Map);
}

String _encodeBody(Map<String, dynamic> body) {
  return '${WalletService.recoveryPayloadPrefix}${base64Url.encode(utf8.encode(jsonEncode(body)))}';
}

WalletModel _wallet() {
  const mnemonic = [
    'abandon',
    'abandon',
    'abandon',
    'abandon',
    'abandon',
    'abandon',
    'abandon',
    'abandon',
    'abandon',
    'abandon',
    'abandon',
    'about',
  ];
  final (privateKeyHex, publicKeyHex) = WalletService.keypairFromMnemonic(
    mnemonic,
  );
  return WalletModel(
    privateKeyHex: privateKeyHex,
    publicKeyHex: publicKeyHex,
    npub: 'npub1test',
    mnemonic: mnemonic,
    deviceId: 'old-device',
    isRevoked: false,
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

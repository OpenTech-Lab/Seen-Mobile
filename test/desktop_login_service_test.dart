import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/services/desktop_login_service.dart';

void main() {
  const origin = 'https://opentech-ailab.org';
  final now = DateTime.utc(2026, 8, 20, 12);

  String qr({String? qrOrigin, String? expires}) {
    final uri = Uri(
      scheme: 'seen',
      host: 'desktop-login',
      queryParameters: {
        'challenge': 'challenge_123',
        'nonce': 'nonce_456',
        'expires':
            expires ?? now.add(const Duration(minutes: 1)).toIso8601String(),
        'origin': qrOrigin ?? origin,
        'browser': 'Chrome on Linux',
      },
    );
    return uri.toString();
  }

  test('parses a desktop-login QR and builds the canonical message', () {
    final challenge = DesktopLoginChallenge.tryParse(qr(), now: now);

    expect(challenge, isNotNull);
    expect(challenge!.challengeId, 'challenge_123');
    expect(challenge.browserLabel, 'Chrome on Linux');
    expect(
      challenge.canonicalMessage('a' * 64),
      startsWith('seen-desktop-login-v1|$origin|challenge_123|nonce_456|'),
    );
  });

  test('rejects recovery payloads, other origins, and expired challenges', () {
    expect(
      DesktopLoginChallenge.tryParse('seen-recovery-v1:payload', now: now),
      isNull,
    );
    expect(
      DesktopLoginChallenge.tryParse(
        qr(qrOrigin: 'https://phishing.example'),
        now: now,
      ),
      isNull,
    );
    expect(
      DesktopLoginChallenge.tryParse(
        qr(expires: now.subtract(const Duration(seconds: 1)).toIso8601String()),
        now: now,
      ),
      isNull,
    );
  });
}

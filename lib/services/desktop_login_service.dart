import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:mobile/core/app_config.dart';
import 'package:mobile/core/wallet.dart';
import 'package:mobile/models/wallet_model.dart';

/// The public data carried by a desktop-login QR. It contains no token or
/// private key; the nonce is only useful with the one-time challenge record on
/// the web server.
class DesktopLoginChallenge {
  const DesktopLoginChallenge({
    required this.challengeId,
    required this.nonce,
    required this.origin,
    required this.expiresAt,
    required this.browserLabel,
  });

  final String challengeId;
  final String nonce;
  final String origin;
  final String expiresAt;
  final String browserLabel;

  DateTime get expiresAtDate => DateTime.parse(expiresAt).toUtc();

  String canonicalMessage(String identityPublicKey) => [
    'seen-desktop-login-v1',
    origin,
    challengeId,
    nonce,
    expiresAt,
    identityPublicKey,
  ].join('|');

  /// Parses only the #seen desktop-login URI. Recovery QR payloads are
  /// intentionally handled by a different scanner and never accepted here.
  static DesktopLoginChallenge? tryParse(
    String raw, {
    String expectedOrigin = AppConfig.desktopLoginOrigin,
    DateTime? now,
  }) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null ||
        uri.scheme != 'seen' ||
        uri.host != 'desktop-login' ||
        uri.path.isNotEmpty ||
        uri.fragment.isNotEmpty) {
      return null;
    }

    final challengeId = uri.queryParameters['challenge']?.trim();
    final nonce = uri.queryParameters['nonce']?.trim();
    final expiresAt = uri.queryParameters['expires']?.trim();
    final origin = uri.queryParameters['origin']?.trim();
    if (challengeId == null ||
        nonce == null ||
        expiresAt == null ||
        origin == null ||
        challengeId.isEmpty ||
        nonce.isEmpty ||
        expiresAt.isEmpty ||
        origin.isEmpty ||
        _containsWhitespace(challengeId) ||
        _containsWhitespace(nonce)) {
      return null;
    }

    final parsedExpiry = DateTime.tryParse(expiresAt);
    if (parsedExpiry == null || !parsedExpiry.isUtc) return null;
    final canonicalExpectedOrigin = expectedOrigin.trim();
    final expected = Uri.tryParse(canonicalExpectedOrigin);
    final actual = Uri.tryParse(origin);
    if (expected == null ||
        actual == null ||
        expected.scheme != 'https' ||
        expected.host.isEmpty ||
        expected.path.isNotEmpty ||
        expected.query.isNotEmpty ||
        expected.fragment.isNotEmpty ||
        actual.toString() != canonicalExpectedOrigin ||
        actual.scheme != 'https') {
      return null;
    }

    final currentTime = now ?? DateTime.now().toUtc();
    if (!parsedExpiry.isAfter(currentTime)) return null;

    return DesktopLoginChallenge(
      challengeId: challengeId,
      nonce: nonce,
      origin: canonicalExpectedOrigin,
      expiresAt: expiresAt,
      browserLabel: uri.queryParameters['browser']?.trim().isNotEmpty == true
          ? uri.queryParameters['browser']!.trim()
          : 'Web browser',
    );
  }

  static bool _containsWhitespace(String value) =>
      RegExp(r'\s').hasMatch(value);
}

/// Approves one web challenge with the active wallet's BIP340 signature.
class DesktopLoginService {
  DesktopLoginService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> approve({
    required DesktopLoginChallenge challenge,
    required WalletModel wallet,
    String identityLabel = 'Mobile identity',
  }) async {
    if (!challenge.expiresAtDate.isAfter(DateTime.now().toUtc())) {
      throw const FormatException('Desktop login challenge expired');
    }
    if (wallet.privateKeyHex.trim().isEmpty ||
        wallet.publicKeyHex.trim().isEmpty) {
      throw const FormatException('The active identity is not available');
    }

    final signature = WalletService.signMessage(
      challenge.canonicalMessage(wallet.publicKeyHex),
      wallet.privateKeyHex,
    );
    final response = await _client.post(
      Uri.parse('${AppConfig.desktopLoginOrigin}/api/desktop-login/approve'),
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({
        'challengeId': challenge.challengeId,
        'nonce': challenge.nonce,
        'origin': challenge.origin,
        'expiresAt': challenge.expiresAt,
        'identityPublicKey': wallet.publicKeyHex,
        'identityLabel': identityLabel.trim().isEmpty
            ? 'Mobile identity'
            : identityLabel.trim(),
        'signature': signature,
        // The server stores only a hash of this value for telemetry. It is
        // deliberately not used as proof of ownership.
        'deviceId': wallet.deviceId,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw FormatException(_errorMessage(response));
    }

    final decoded = _decodeObject(response.body);
    if (decoded['approved'] != true) {
      throw const FormatException('Desktop login approval was not accepted');
    }
  }

  void dispose() => _client.close();

  static Map<String, dynamic> _decodeObject(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {
      // Convert malformed responses into the same safe user-facing error.
    }
    throw const FormatException(
      'Desktop login service returned an invalid response',
    );
  }

  static String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is String) {
        return decoded['error'] as String;
      }
    } catch (_) {
      // Use a generic message below; do not surface server response bodies.
    }
    return 'Desktop login approval was rejected';
  }
}

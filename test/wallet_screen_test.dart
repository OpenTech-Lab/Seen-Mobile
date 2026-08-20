import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/posting_quota_status.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/screens/wallet_screen.dart';

void main() {
  testWidgets('account screen exposes recovery phrase behind a reveal action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: WalletScreen(
          wallet: _wallet(),
          loadPostingQuota: () async => _quota(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Public key'), findsNothing);
    expect(find.text('Posting limits'), findsOneWidget);
    expect(find.text('1 left of 2'), findsOneWidget);
    expect(find.text('4 left of 5'), findsOneWidget);
    expect(find.text('Recovery phrase'), findsOneWidget);
    expect(find.text('Move to new device'), findsNothing);
    expect(find.text('Generate migration QR'), findsNothing);
    expect(find.text('Show recovery phrase'), findsOneWidget);
    expect(find.text('1. alpha'), findsNothing);
    expect(find.text('Delete this account'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Show recovery phrase'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Show recovery phrase'));
    await tester.pumpAndSettle();

    expect(find.text('1. alpha'), findsOneWidget);
    expect(find.text('12. lima'), findsOneWidget);
    expect(find.text('Copy phrase'), findsOneWidget);
    expect(find.text('Show recovery QR'), findsOneWidget);
    expect(find.text('Hide'), findsOneWidget);
  });
}

PostingQuotaStatus _quota() => PostingQuotaStatus(
  accountAgeDays: 4,
  currentTierName: 'newcomer',
  threadLimitPerDay: 2,
  replyLimitPerDay: 5,
  threadCountToday: 1,
  replyCountToday: 1,
  threadRemainingToday: 1,
  replyRemainingToday: 4,
  isPostingBlocked: false,
  resetsAt: DateTime.utc(2026, 3, 27),
);

WalletModel _wallet() => WalletModel(
  privateKeyHex:
      '1111111111111111111111111111111111111111111111111111111111111111',
  publicKeyHex:
      '2222222222222222222222222222222222222222222222222222222222222222',
  npub: 'npub1example',
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
  deviceId: 'device-1234567890',
  isRevoked: false,
  createdAt: DateTime.utc(2026, 3, 26, 10, 30),
);

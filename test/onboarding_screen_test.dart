import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/onboarding_screen.dart';

void main() {
  testWidgets('shows recovery QR scanning on the identity step', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingScreen(
          hasAcceptedTerms: (_) => true,
          acceptTerms: (_) async {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Scan recovery QR'), findsOneWidget);
  });
}

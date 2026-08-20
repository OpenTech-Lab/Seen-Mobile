import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/screens/interests_screen.dart';

void main() {
  testWidgets(
    'tapping a suggested topic chip dismisses the focused custom hashtag field',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: InterestsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      final fieldFinder = find.byType(TextField);
      expect(fieldFinder, findsOneWidget);

      await tester.tap(fieldFinder);
      await tester.pump();
      final fieldFocusNode = tester
          .state<EditableTextState>(find.byType(EditableText))
          .widget
          .focusNode;
      expect(fieldFocusNode.hasFocus, isTrue);

      // Tapping another interactive control elsewhere on the sheet (a
      // suggested-topic chip) should still dismiss the keyboard, matching
      // the behavior already covered by DismissKeyboardOnTap for blank
      // screen space.
      await tester.tap(find.text('#protest'));
      await tester.pump();

      expect(fieldFocusNode.hasFocus, isFalse);
    },
  );
}

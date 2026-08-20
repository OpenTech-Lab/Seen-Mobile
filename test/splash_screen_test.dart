import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/profile_model.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/screens/splash_screen.dart';
import 'package:mobile/services/app_refresh_service.dart';
import 'package:mobile/widgets/app_loading_view.dart';

Widget _localizedApp({required Widget home}) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async => null);
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  testWidgets('SplashScreen shows a loading page before home is ready', (
    tester,
  ) async {
    final blockers = [Completer<void>()];
    final service = _refreshServiceWithBlockers(blockers);

    await tester.pumpWidget(
      _localizedApp(
        home: SplashScreen(
          wallet: _wallet(),
          refreshService: service,
          verificationRunner: () async {},
          homeBuilder: (_) => const Text('Home ready'),
        ),
      ),
    );

    expect(find.byType(AppLoadingView), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.text('Loading #seen'), findsNothing);
    expect(find.text('Home ready'), findsNothing);

    blockers.single.complete();
    await tester.pumpAndSettle();

    expect(find.text('Home ready'), findsOneWidget);
    expect(find.text('Loading #seen'), findsNothing);
  });

  testWidgets(
    'SplashScreen keeps home visible while refreshing on app resume',
    (tester) async {
      final blockers = [Completer<void>(), Completer<void>()];
      var refreshCalls = 0;
      final service = _refreshServiceWithBlockers(
        blockers,
        onFetchProfile: () => refreshCalls++,
      );

      await tester.pumpWidget(
        _localizedApp(
          home: SplashScreen(
            wallet: _wallet(),
            refreshService: service,
            verificationRunner: () async {},
            homeBuilder: (_) => const Text('Home ready'),
          ),
        ),
      );

      blockers.first.complete();
      await tester.pumpAndSettle();
      expect(find.text('Home ready'), findsOneWidget);
      expect(refreshCalls, 1);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(find.text('Home ready'), findsOneWidget);
      expect(find.byType(AppLoadingView), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(refreshCalls, 2);

      blockers.last.complete();
      await tester.pumpAndSettle();

      expect(find.text('Refreshing data…'), findsNothing);
      expect(find.text('Home ready'), findsOneWidget);
    },
  );

  testWidgets(
    'SplashScreen logs out and redirects to onboarding when profile load fails on startup',
    (tester) async {
      var logoutCalls = 0;
      final service = AppRefreshService(
        initFollowState: () async {},
        fetchCurrentProfile: (_) async => throw StateError('profile missing'),
        fetchPosts: ({authorPubkey, limit = 20}) async => const [],
        savePosts: (_) async {},
        updateAuthorProfile:
            ({required authorPubkey, displayName, avatarContentHash}) async {},
      );

      await tester.pumpWidget(
        _localizedApp(
          home: SplashScreen(
            wallet: _wallet(),
            refreshService: service,
            verificationRunner: () async {},
            logoutRunner: () async => logoutCalls++,
            loggedOutBuilder: () => const Text('Onboarding welcome'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(logoutCalls, 1);
      expect(find.text('Onboarding welcome'), findsOneWidget);
      expect(find.text('Home ready'), findsNothing);
    },
  );
}

AppRefreshService _refreshServiceWithBlockers(
  List<Completer<void>> blockers, {
  VoidCallback? onFetchProfile,
}) {
  var fetchIndex = 0;
  return AppRefreshService(
    initFollowState: () async {},
    fetchCurrentProfile: (_) async {
      onFetchProfile?.call();
      await blockers[fetchIndex++].future;
      return const ProfileModel(id: 'profile-id');
    },
    fetchPosts: ({authorPubkey, limit = 20}) async => const [],
    savePosts: (_) async {},
    updateAuthorProfile:
        ({required authorPubkey, displayName, avatarContentHash}) async {},
  );
}

WalletModel _wallet() => WalletModel(
  privateKeyHex:
      '0000000000000000000000000000000000000000000000000000000000000001',
  publicKeyHex:
      '1111111111111111111111111111111111111111111111111111111111111111',
  npub: 'npub1test',
  mnemonic: const ['test'],
  deviceId: 'device-1',
  isRevoked: false,
  createdAt: DateTime.utc(2026, 3, 29),
);

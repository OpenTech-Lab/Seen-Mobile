import 'dart:async';

import 'package:flutter/material.dart';

import 'package:mobile/core/altcha.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/screens/altcha_gate_screen.dart';
import 'package:mobile/screens/home_screen.dart';
import 'package:mobile/screens/onboarding_screen.dart';
import 'package:mobile/services/app_refresh_service.dart';
import 'package:mobile/services/session_logout_service.dart';
import 'package:mobile/widgets/app_loading_view.dart';

typedef SplashHomeBuilder = Widget Function(WalletModel wallet);
typedef SplashVerificationRunner = Future<void> Function();
typedef SplashLogoutRunner = Future<void> Function();
typedef SplashLoggedOutBuilder = Widget Function();

/// Session entry screen for signed-in users.
///
/// Shows a quiet loading page on cold launch, then refreshes cached session data
/// in the background whenever the app resumes.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.wallet,
    this.refreshService,
    this.homeBuilder,
    this.verificationRunner,
    this.logoutRunner,
    this.loggedOutBuilder,
  });

  final WalletModel wallet;
  final AppRefreshService? refreshService;
  final SplashHomeBuilder? homeBuilder;
  final SplashVerificationRunner? verificationRunner;
  final SplashLogoutRunner? logoutRunner;
  final SplashLoggedOutBuilder? loggedOutBuilder;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();
  bool _isReady = false;
  bool _isRefreshing = false;

  AppRefreshService get _refreshService =>
      widget.refreshService ?? AppRefreshService.instance;
  SplashLogoutRunner get _logoutRunner =>
      widget.logoutRunner ??
      () => SessionLogoutService.instance.logout(preserveAuthSession: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_runInitialLoad());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_isReady) return;
    unawaited(_refreshOnResume());
  }

  Future<void> _runInitialLoad() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      await _runRefreshSequence(includeVerification: true);
    } on ProfileLoadFailedException catch (error) {
      debugPrint('[SplashScreen] Profile load failed on startup: $error');
      await _logoutAndRedirect();
      return;
    } catch (error) {
      debugPrint('[SplashScreen] Session refresh failed: $error');
    }

    if (!mounted) return;
    setState(() {
      _isReady = true;
      _isRefreshing = false;
    });
  }

  Future<void> _refreshOnResume() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      await _runRefreshSequence(includeVerification: false);
    } catch (error) {
      debugPrint('[SplashScreen] Resume refresh failed: $error');
    }
    await _homeKey.currentState?.triggerSessionRefresh();

    if (!mounted) return;
    setState(() => _isRefreshing = false);
  }

  Future<void> _runRefreshSequence({required bool includeVerification}) async {
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        if (includeVerification) {
          await _runVerification();
        }
        await _refreshService.refreshSessionData(widget.wallet);
        return;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      throw lastError;
    }
  }

  Future<void> _logoutAndRedirect() async {
    try {
      await _logoutRunner();
    } catch (error) {
      debugPrint('[SplashScreen] Logout after profile failure failed: $error');
    }

    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
      _isReady = false;
    });
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) =>
            widget.loggedOutBuilder?.call() ??
            const AltchaGateScreen(next: OnboardingScreen()),
      ),
      (route) => false,
    );
  }

  Future<void> _runVerification() async {
    final l10n = AppLocalizations.of(context)!;
    if (widget.verificationRunner != null) {
      await widget.verificationRunner!();
      return;
    }

    final challenge = AltchaService.generate();
    final solution = await AltchaService.solve(challenge);
    if (solution == null || !AltchaService.verify(challenge, solution)) {
      throw StateError(l10n.altchaVerificationFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_isReady) {
      return Scaffold(
        body: AppLoadingView(
          title: l10n.splashLoadingTitle,
          subtitle: l10n.splashLoadingSubtitle,
        ),
      );
    }

    final home =
        widget.homeBuilder?.call(widget.wallet) ??
        HomeScreen(key: _homeKey, wallet: widget.wallet);

    return home;
  }
}

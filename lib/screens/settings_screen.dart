import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mobile/l10n/app_localizations.dart';

import 'package:mobile/features/metadata/metadata_service.dart';
import 'package:mobile/models/asset_transport_policy.dart';
import 'package:mobile/models/profile_model.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/screens/altcha_gate_screen.dart';
import 'package:mobile/screens/asset_transport_settings_screen.dart';
import 'package:mobile/screens/desktop_login_scanner_screen.dart';
import 'package:mobile/screens/interests_screen.dart';
import 'package:mobile/screens/identity_switcher_screen.dart';
import 'package:mobile/screens/my_posts_screen.dart';
import 'package:mobile/screens/blocked_users_screen.dart';
import 'package:mobile/screens/onboarding_screen.dart';
import 'package:mobile/screens/privacy_policy_screen.dart';
import 'package:mobile/screens/terms_of_use_screen.dart';
import 'package:mobile/screens/wallet_screen.dart';
import 'package:mobile/services/app_data_reset_service.dart';
import 'package:mobile/services/cache_manager.dart';
import 'package:mobile/services/follow_service.dart';
import 'package:mobile/services/local_post_store.dart';
import 'package:mobile/services/session_logout_service.dart';
import 'package:mobile/services/user_prefs_service.dart';
import 'package:mobile/theme/spot_theme.dart';

String favoriteTopicsSummary(Iterable<String> topics) {
  return favoriteTopicsSummaryWithFallback(topics, notSetLabel: 'Not set');
}

String favoriteTopicsSummaryWithFallback(
  Iterable<String> topics, {
  required String notSetLabel,
}) {
  final unique = topics
      .map((topic) => topic.trim())
      .where((topic) => topic.isNotEmpty)
      .toList(growable: false);
  if (unique.isEmpty) return notSetLabel;
  if (unique.length <= 2) return unique.map((topic) => '#$topic').join(', ');
  return '#${unique[0]}, #${unique[1]} +${unique.length - 2}';
}

typedef LoadSettingsProfile = Future<ProfileModel> Function(WalletModel wallet);
typedef SaveProfileVisibility =
    Future<ProfileModel> Function(
      WalletModel wallet, {
      bool? threadsPublic,
      bool? repliesPublic,
      bool? footprintMapPublic,
    });
typedef ReadSafeModeEnabled = bool Function();
typedef SaveSafeModeEnabled = Future<void> Function(bool enabled);
typedef ReadPreferredLocale = Locale? Function();
typedef SavePreferredLocale = Future<void> Function(Locale? locale);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.wallet,
    this.loadProfileSettings,
    this.saveProfileVisibility,
    this.readSafeModeEnabled,
    this.saveSafeModeEnabled,
    this.readPreferredLocale,
    this.savePreferredLocale,
  });

  final WalletModel wallet;
  final LoadSettingsProfile? loadProfileSettings;
  final SaveProfileVisibility? saveProfileVisibility;
  final ReadSafeModeEnabled? readSafeModeEnabled;
  final SaveSafeModeEnabled? saveSafeModeEnabled;
  final ReadPreferredLocale? readPreferredLocale;
  final SavePreferredLocale? savePreferredLocale;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoggingOut = false;
  bool _isLoadingVisibility = true;
  bool _isSavingVisibility = false;
  bool _isSavingSafeMode = false;
  bool _isSavingPreferredLocale = false;
  bool _threadsPublic = true;
  bool _repliesPublic = true;
  bool _footprintMapPublic = false;
  late bool _safeModeEnabled;
  late Locale? _preferredLocale;

  AssetTransportPolicy get _assetTransportPolicy =>
      UserPrefsService.instance.assetTransportPolicy;

  LoadSettingsProfile get _profileLoader =>
      widget.loadProfileSettings ??
      MetadataService.instance.fetchCurrentProfile;
  SaveProfileVisibility get _visibilitySaver =>
      widget.saveProfileVisibility ??
      (wallet, {threadsPublic, repliesPublic, footprintMapPublic}) =>
          MetadataService.instance.updateCurrentProfileVisibility(
            wallet: wallet,
            threadsPublic: threadsPublic,
            repliesPublic: repliesPublic,
            footprintMapPublic: footprintMapPublic,
          );
  ReadSafeModeEnabled get _safeModeReader =>
      widget.readSafeModeEnabled ??
      () => UserPrefsService.instance.safeModeEnabled;
  SaveSafeModeEnabled get _safeModeWriter =>
      widget.saveSafeModeEnabled ??
      UserPrefsService.instance.saveSafeModeEnabled;
  ReadPreferredLocale get _preferredLocaleReader =>
      widget.readPreferredLocale ?? () => UserPrefsService.instance.uiLocale;
  SavePreferredLocale get _preferredLocaleWriter =>
      widget.savePreferredLocale ?? UserPrefsService.instance.saveUiLocale;

  @override
  void initState() {
    super.initState();
    _safeModeEnabled = _safeModeReader();
    _preferredLocale = _preferredLocaleReader();
    unawaited(_loadProfileVisibility());
  }

  void _applyProfileVisibility(ProfileModel profile) {
    _threadsPublic = profile.areThreadsPublic;
    _repliesPublic = profile.areRepliesPublic;
    _footprintMapPublic = profile.isFootprintMapPublic;
  }

  Future<void> _loadProfileVisibility() async {
    try {
      final profile = await _profileLoader(widget.wallet);
      if (!mounted) return;
      setState(() {
        _applyProfileVisibility(profile);
        _isLoadingVisibility = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingVisibility = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failedLoadPrivacy(error.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _saveVisibility({
    bool? threadsPublic,
    bool? repliesPublic,
    bool? footprintMapPublic,
  }) async {
    if (_isSavingVisibility) return;

    final previousThreadsPublic = _threadsPublic;
    final previousRepliesPublic = _repliesPublic;
    final previousFootprintMapPublic = _footprintMapPublic;

    setState(() {
      if (threadsPublic != null) {
        _threadsPublic = threadsPublic;
      }
      if (repliesPublic != null) {
        _repliesPublic = repliesPublic;
      }
      if (footprintMapPublic != null) {
        _footprintMapPublic = footprintMapPublic;
      }
      _isSavingVisibility = true;
    });

    try {
      final profile = await _visibilitySaver(
        widget.wallet,
        threadsPublic: threadsPublic,
        repliesPublic: repliesPublic,
        footprintMapPublic: footprintMapPublic,
      );
      if (!mounted) return;
      setState(() {
        _applyProfileVisibility(profile);
        _isSavingVisibility = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _threadsPublic = previousThreadsPublic;
        _repliesPublic = previousRepliesPublic;
        _footprintMapPublic = previousFootprintMapPublic;
        _isSavingVisibility = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failedUpdatePrivacy(error.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _setThreadsPublic(bool isPublic) async {
    await _saveVisibility(threadsPublic: isPublic);
  }

  Future<void> _setRepliesPublic(bool isPublic) async {
    await _saveVisibility(repliesPublic: isPublic);
  }

  Future<void> _setFootprintMapPublic(bool isPublic) async {
    await _saveVisibility(footprintMapPublic: isPublic);
  }

  Future<void> _setSafeModeEnabled(bool enabled) async {
    if (_isSavingSafeMode) return;

    final previousValue = _safeModeEnabled;
    setState(() {
      _safeModeEnabled = enabled;
      _isSavingSafeMode = true;
    });

    try {
      await _safeModeWriter(enabled);
      if (!mounted) return;
      setState(() => _isSavingSafeMode = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _safeModeEnabled = previousValue;
        _isSavingSafeMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.failedUpdateSafeMode(error.toString()),
          ),
        ),
      );
    }
  }

  Future<void> _openAssetTransportSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AssetTransportSettingsScreen()),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openIdentitySwitcher() async {
    final nextWallet = await Navigator.of(context).push<WalletModel>(
      MaterialPageRoute(builder: (_) => const IdentitySwitcherScreen()),
    );
    if (nextWallet != null && mounted) {
      Navigator.of(context).pop<WalletModel>(nextWallet);
    }
  }

  Future<void> _openAccount() async {
    final nextWallet = await Navigator.of(context).push<WalletModel>(
      MaterialPageRoute(builder: (_) => WalletScreen(wallet: widget.wallet)),
    );
    if (nextWallet != null && mounted) {
      Navigator.of(context).pop<WalletModel>(nextWallet);
    }
  }

  Future<void> _openDesktopLogin() async {
    final connected = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DesktopLoginScannerScreen(wallet: widget.wallet),
      ),
    );
    if (connected == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.desktopLoginApproved),
        ),
      );
    }
  }

  Future<void> _openFavoriteTopics() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InterestsScreen(
        onDone: () {
          if (mounted) {
            setState(() {});
          }
        },
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  String _favoriteTopicsValue(AppLocalizations l10n) =>
      favoriteTopicsSummaryWithFallback(
        UserPrefsService.instance.interests,
        notSetLabel: l10n.notSetValue,
      );

  static String _preferredLocaleTag(Locale? locale) {
    if (locale == null) return 'system';
    if (locale.languageCode == 'zh') return 'zh';
    return locale.languageCode;
  }

  static Locale? _localeFromTag(String tag) {
    return switch (tag) {
      'system' => null,
      'en' => const Locale('en'),
      'ja' => const Locale('ja'),
      'zh' => const Locale('zh'),
      _ => null,
    };
  }

  String _preferredLocaleLabel(AppLocalizations l10n) {
    return switch (_preferredLocaleTag(_preferredLocale)) {
      'en' => 'English',
      'ja' => '日本語',
      'zh' => '中文',
      _ => l10n.systemDefaultLanguageOption,
    };
  }

  Future<void> _openPreferredLocaleMenu() async {
    if (_isSavingPreferredLocale) return;

    final l10n = AppLocalizations.of(context)!;
    final selection = await showCupertinoModalPopup<String>(
      context: context,
      builder: (ctx) {
        final selectedTag = _preferredLocaleTag(_preferredLocale);
        CupertinoActionSheetAction languageAction({
          required String tag,
          required String label,
        }) {
          return CupertinoActionSheetAction(
            isDefaultAction: selectedTag == tag,
            onPressed: () => Navigator.of(ctx).pop(tag),
            child: Text(label),
          );
        }

        return CupertinoActionSheet(
          title: Text(l10n.languageLabel),
          message: Text(l10n.languageMenuMessage),
          actions: [
            languageAction(
              tag: 'system',
              label: l10n.systemDefaultLanguageOption,
            ),
            languageAction(tag: 'en', label: 'English'),
            languageAction(tag: 'ja', label: '日本語'),
            languageAction(tag: 'zh', label: '中文'),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancelAction),
          ),
        );
      },
    );

    if (!mounted || selection == null) return;
    final nextLocale = _localeFromTag(selection);
    if (_preferredLocaleTag(_preferredLocale) ==
        _preferredLocaleTag(nextLocale)) {
      return;
    }

    final previousLocale = _preferredLocale;
    setState(() {
      _preferredLocale = nextLocale;
      _isSavingPreferredLocale = true;
    });

    try {
      await _preferredLocaleWriter(nextLocale);
      if (!mounted) return;
      setState(() => _isSavingPreferredLocale = false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _preferredLocale = previousLocale;
        _isSavingPreferredLocale = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedUpdateLanguage(error.toString()))),
      );
    }
  }

  Future<void> _clearCache() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SpotColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotRadius.md),
        ),
        title: Text(l10n.clearCacheLabel, style: SpotType.subheading),
        content: Text(
          l10n.clearCacheDialogContent,
          style: SpotType.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelAction, style: SpotType.bodySecondary),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.clearButton,
              style: SpotType.body.copyWith(color: SpotColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await CacheManager.instance.purgeAll();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.cacheClearedSnackbar)));
      }
    }
  }

  Future<void> _clearAllData() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SpotColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotRadius.md),
        ),
        title: Text(l10n.clearLocalDataLabel, style: SpotType.subheading),
        content: Text(
          l10n.clearLocalDataDialogContent,
          style: SpotType.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelAction, style: SpotType.bodySecondary),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.clearAllButton,
              style: SpotType.body.copyWith(color: SpotColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await LocalPostStore.instance.runWithWritesPaused(() async {
        await Future.wait([
          CacheManager.instance.purgeAll(),
          CacheManager.instance.clearBlocklist(),
          LocalPostStore.instance.clearAll(force: true),
          FollowService.instance.clearAll(),
          UserPrefsService.instance.clearAll(),
        ]);
        AppDataResetService.instance.notifyLocalDataCleared();
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.localDataClearedSnackbar)));
      }
    }
  }

  Future<void> _confirmLogout() async {
    if (_isLoggingOut) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SpotColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotRadius.md),
        ),
        title: Text(l10n.logOutDialogTitle, style: SpotType.subheading),
        content: Text(l10n.logOutDialogContent, style: SpotType.bodySecondary),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancelAction, style: SpotType.bodySecondary),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l10n.logOutConfirmButton,
              style: SpotType.body.copyWith(color: SpotColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      await SessionLogoutService.instance.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => const AltchaGateScreen(next: OnboardingScreen()),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failedLogOut(error.toString()),
          ),
        ),
      );
      setState(() => _isLoggingOut = false);
    }
  }

  Future<void> _openPublicActivityMenu() async {
    final l10n = AppLocalizations.of(context)!;
    final selection = await showCupertinoModalPopup<MyPostsScreenMode>(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(l10n.publicActivityTitle),
        message: Text(l10n.publicActivityMessage),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(MyPostsScreenMode.threads),
            child: Text(l10n.postedThreadsOption),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.of(ctx).pop(MyPostsScreenMode.replies),
            child: Text(l10n.repliedThreadsOption),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(l10n.cancelAction),
        ),
      ),
    );

    if (!mounted || selection == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MyPostsScreen(wallet: widget.wallet, mode: selection),
      ),
    );
  }

  void _openTermsOfUse() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TermsOfUseScreen()),
    );
  }

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  void _openBlockedUsers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlockedUsersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SpotColors.bg,
      appBar: AppBar(
        backgroundColor: SpotColors.bg,
        title: Text(l10n.settingsTitle, style: SpotType.subheading),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: SpotSpacing.lg,
          vertical: SpotSpacing.lg,
        ),
        children: [
          _SettingsRow(
            icon: CupertinoIcons.star,
            label: l10n.favoriteTopicsLabel,
            value: _favoriteTopicsValue(l10n),
            onTap: _openFavoriteTopics,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsRow(
            icon: CupertinoIcons.wifi,
            label: l10n.assetTransportLabel,
            value: _assetTransportPolicy.label,
            onTap: _openAssetTransportSettings,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsRow(
            icon: CupertinoIcons.globe,
            label: l10n.languageLabel,
            value: _isSavingPreferredLocale
                ? l10n.savingLabel
                : _preferredLocaleLabel(l10n),
            onTap: _isSavingPreferredLocale ? null : _openPreferredLocaleMenu,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsRow(
            icon: CupertinoIcons.person_crop_circle,
            label: l10n.accountLabel,
            onTap: _openAccount,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsRow(
            icon: CupertinoIcons.person_2,
            label: l10n.identitiesLabel,
            onTap: _openIdentitySwitcher,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsRow(
            icon: CupertinoIcons.qrcode_viewfinder,
            label: l10n.connectToDesktopLabel,
            value: l10n.connectToDesktopValue,
            onTap: _openDesktopLogin,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsRow(
            icon: CupertinoIcons.doc_plaintext,
            label: l10n.termsOfUseTitle,
            onTap: _openTermsOfUse,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsRow(
            icon: CupertinoIcons.lock_shield,
            label: l10n.privacyPolicyTitle,
            onTap: _openPrivacyPolicy,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsRow(
            icon: CupertinoIcons.list_bullet,
            label: l10n.viewMyActivityLabel,
            onTap: _openPublicActivityMenu,
          ),
          const SizedBox(height: SpotSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SpotSpacing.sm),
            child: Text(l10n.privacySectionLabel, style: SpotType.label),
          ),
          _SettingsRow(
            icon: CupertinoIcons.person_crop_circle_badge_xmark,
            label: l10n.blockedUsersTitle,
            onTap: _openBlockedUsers,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsSwitchRow(
            icon: CupertinoIcons.map,
            label: l10n.footprintMapLabel,
            value: _footprintMapPublic,
            onChanged: _isLoadingVisibility || _isSavingVisibility
                ? null
                : _setFootprintMapPublic,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsSwitchRow(
            icon: CupertinoIcons.text_bubble,
            label: l10n.publicThreadsLabel,
            value: _threadsPublic,
            onChanged: _isLoadingVisibility || _isSavingVisibility
                ? null
                : _setThreadsPublic,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsSwitchRow(
            icon: CupertinoIcons.reply,
            label: l10n.publicRepliesLabel,
            value: _repliesPublic,
            onChanged: _isLoadingVisibility || _isSavingVisibility
                ? null
                : _setRepliesPublic,
          ),
          const SizedBox(height: SpotSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SpotSpacing.sm),
            child: Text(l10n.storageSectionLabel, style: SpotType.label),
          ),
          _SettingsRow(
            icon: CupertinoIcons.trash,
            label: l10n.clearCacheLabel,
            onTap: _clearCache,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsRow(
            icon: CupertinoIcons.delete,
            label: l10n.clearLocalDataLabel,
            onTap: _clearAllData,
          ),
          const SizedBox(height: SpotSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: SpotSpacing.sm),
            child: Text(l10n.sessionSectionLabel, style: SpotType.label),
          ),
          _SettingsSwitchRow(
            icon: CupertinoIcons.lock,
            label: l10n.safeModeLabel,
            value: _safeModeEnabled,
            onChanged: _isSavingSafeMode ? null : _setSafeModeEnabled,
          ),
          const SizedBox(height: SpotSpacing.sm),
          _SettingsRow(
            icon: CupertinoIcons.square_arrow_right,
            label: l10n.logOutLabel,
            value: _isLoggingOut ? l10n.signingOutLabel : null,
            onTap: _confirmLogout,
          ),
          const SizedBox(height: SpotSpacing.xxl),
        ],
      ),
    );
  }
}

class _SettingsSwitchRow extends StatelessWidget {
  const _SettingsSwitchRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadius.circular(SpotRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpotSpacing.lg,
          vertical: SpotSpacing.sm,
        ),
        decoration: SpotDecoration.cardBordered(),
        child: Row(
          children: [
            Icon(icon, size: 20, color: SpotColors.textSecondary),
            const SizedBox(width: SpotSpacing.md),
            Expanded(child: Text(label, style: SpotType.body)),
            Switch.adaptive(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpotRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpotSpacing.lg,
          vertical: SpotSpacing.md,
        ),
        decoration: SpotDecoration.cardBordered(),
        child: Row(
          children: [
            Icon(icon, size: 20, color: SpotColors.textSecondary),
            const SizedBox(width: SpotSpacing.md),
            Expanded(child: Text(label, style: SpotType.body)),
            if (value != null) ...[
              const SizedBox(width: SpotSpacing.sm),
              Text(
                value!,
                style: SpotType.caption.copyWith(
                  color: SpotColors.textTertiary,
                ),
              ),
              const SizedBox(width: SpotSpacing.xs),
            ],
            const Icon(
              CupertinoIcons.chevron_right,
              size: 14,
              color: SpotColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

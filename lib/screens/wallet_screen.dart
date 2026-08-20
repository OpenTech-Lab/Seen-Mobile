import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/features/metadata/metadata_service.dart';
import 'package:mobile/models/posting_quota_status.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/screens/altcha_gate_screen.dart';
import 'package:mobile/screens/onboarding_screen.dart';
import 'package:mobile/screens/recovery_qr_screen.dart';
import 'package:mobile/services/cache_manager.dart';
import 'package:mobile/services/follow_service.dart';
import 'package:mobile/services/identity_vault_service.dart';
import 'package:mobile/services/local_post_store.dart';
import 'package:mobile/services/user_prefs_service.dart';
import 'package:mobile/theme/spot_theme.dart';

/// Account screen for device and account controls.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, required this.wallet, this.loadPostingQuota});

  final WalletModel wallet;
  final Future<PostingQuotaStatus> Function()? loadPostingQuota;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  bool _isDeletingAccount = false;
  bool _isRecoveryPhraseVisible = false;
  late Future<PostingQuotaStatus> _postingQuotaFuture;

  @override
  void initState() {
    super.initState();
    _postingQuotaFuture = _loadPostingQuota();
  }

  Future<PostingQuotaStatus> _loadPostingQuota() {
    final loader = widget.loadPostingQuota;
    if (loader != null) {
      return loader();
    }
    return MetadataService.instance.fetchCurrentPostingQuotaStatus(
      widget.wallet,
    );
  }

  void _retryPostingQuota() {
    setState(() => _postingQuotaFuture = _loadPostingQuota());
  }

  Future<void> _confirmDeleteAccount() async {
    if (_isDeletingAccount) return;

    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SpotColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotRadius.md),
        ),
        title: Text(l10n.deleteAccountDialogTitle, style: SpotType.subheading),
        content: Text(
          l10n.deleteAccountDialogContent,
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
              l10n.deleteButton,
              style: SpotType.body.copyWith(color: SpotColors.danger),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteAccount();
    }
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isDeletingAccount = true);
    try {
      final identity = IdentityVaultService.instance.activeIdentity;
      final isPrimary = identity?.isPrimary ?? true;
      await MetadataService.instance.deleteCurrentAccount();
      if (isPrimary) {
        await Future.wait([
          CacheManager.instance.purgeAll(),
          CacheManager.instance.clearBlocklist(),
          LocalPostStore.instance.clearAll(),
          FollowService.instance.clearAll(),
          UserPrefsService.instance.clearAll(),
          IdentityVaultService.instance.clear(),
        ]);
      } else {
        await Future.wait([
          LocalPostStore.instance.removePostsByAuthor(
            widget.wallet.publicKeyHex,
          ),
          IdentityVaultService.instance.removeIdentity(
            widget.wallet.publicKeyHex,
          ),
        ]);
      }
      if (!mounted) return;
      if (isPrimary) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => const AltchaGateScreen(next: OnboardingScreen()),
          ),
          (route) => false,
        );
      } else {
        final owner = IdentityVaultService.instance.currentVault?.ownerIdentity;
        Navigator.of(context).pop(owner?.wallet);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.failedDeleteAccount(e.toString()))),
      );
      setState(() => _isDeletingAccount = false);
    }
  }

  Future<void> _copyRecoveryPhrase() async {
    final l10n = AppLocalizations.of(context)!;
    await Clipboard.setData(
      ClipboardData(text: widget.wallet.mnemonic.join(' ')),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.recoveryPhraseCopied)));
  }

  Future<void> _showRecoveryQr() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RecoveryQrScreen(wallet: widget.wallet),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final wallet = widget.wallet;

    return Scaffold(
      backgroundColor: SpotColors.bg,
      appBar: AppBar(
        backgroundColor: SpotColors.bg,
        title: Text(l10n.walletAccountTitle, style: SpotType.subheading),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SpotSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: _Avatar(pubkeyHex: wallet.publicKeyHex)),
            const SizedBox(height: SpotSpacing.lg),
            _Section(
              title: l10n.thisDeviceSectionTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.deviceSectionDescription,
                    style: SpotType.bodySecondary,
                  ),
                  const SizedBox(height: SpotSpacing.lg),
                  _MetaRow(
                    label: l10n.deviceLabel,
                    value: wallet.deviceId.length > 20
                        ? '${wallet.deviceId.substring(0, 14)}…'
                        : wallet.deviceId,
                  ),
                  _MetaRow(
                    label: l10n.createdLabel,
                    value: wallet.createdAt.toLocal().toString().substring(
                      0,
                      16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpotSpacing.lg),
            _Section(
              title: l10n.postingLimitsSectionTitle,
              child: FutureBuilder<PostingQuotaStatus>(
                future: _postingQuotaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return _InlineLoadingState(label: l10n.checkingDailyLimits);
                  }

                  if (snapshot.hasError) {
                    return _InlineErrorState(
                      message: l10n.postingLimitsLoadError,
                      onRetry: _retryPostingQuota,
                    );
                  }

                  final quota = snapshot.data!;
                  return _PostingLimitSummary(quota: quota);
                },
              ),
            ),
            const SizedBox(height: SpotSpacing.lg),
            _Section(
              title: l10n.recoveryPhraseLabel,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.recoveryPhraseWalletDescription,
                    style: SpotType.bodySecondary,
                  ),
                  const SizedBox(height: SpotSpacing.md),
                  if (!_isRecoveryPhraseVisible)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _isRecoveryPhraseVisible = true);
                        },
                        child: Text(l10n.showRecoveryPhraseButton),
                      ),
                    )
                  else ...[
                    Wrap(
                      spacing: SpotSpacing.xs,
                      runSpacing: SpotSpacing.xs,
                      children: wallet.mnemonic
                          .asMap()
                          .entries
                          .map((entry) {
                            return _RecoveryPhraseChip(
                              index: entry.key + 1,
                              word: entry.value,
                            );
                          })
                          .toList(growable: false),
                    ),
                    const SizedBox(height: SpotSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _copyRecoveryPhrase,
                            child: Text(l10n.copyPhraseButton),
                          ),
                        ),
                        const SizedBox(width: SpotSpacing.sm),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() => _isRecoveryPhraseVisible = false);
                            },
                            child: Text(l10n.hideButton),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpotSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _showRecoveryQr,
                        icon: const Icon(Icons.qr_code_2_rounded),
                        label: Text(l10n.showRecoveryQrButton),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: SpotSpacing.lg),
            _Section(
              title: l10n.dangerZoneSectionTitle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.deleteAccountDescription,
                    style: SpotType.bodySecondary,
                  ),
                  const SizedBox(height: SpotSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _isDeletingAccount
                          ? null
                          : _confirmDeleteAccount,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SpotColors.danger,
                      ),
                      child: _isDeletingAccount
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1,
                                color: SpotColors.danger,
                              ),
                            )
                          : Text(l10n.deleteAccountButton),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SpotSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

String formatPostingTierName(String tierName, {String unknown = 'Unknown'}) {
  final words = tierName
      .trim()
      .split(RegExp(r'[_\s]+'))
      .where((word) => word.isNotEmpty)
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      );
  return words.isEmpty ? unknown : words.join(' ');
}

String formatPostingResetTime(DateTime resetsAt) {
  final local = resetsAt.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute local time';
}

class _RecoveryPhraseChip extends StatelessWidget {
  const _RecoveryPhraseChip({required this.index, required this.word});

  final int index;
  final String word;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpotSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: SpotColors.surfaceHigh,
        borderRadius: BorderRadius.circular(SpotRadius.xs),
      ),
      child: Text(
        '$index. $word',
        style: SpotType.mono.copyWith(color: SpotColors.textPrimary),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.pubkeyHex});

  final String pubkeyHex;

  @override
  Widget build(BuildContext context) {
    final hex = pubkeyHex.length >= 6 ? pubkeyHex.substring(0, 6) : '888480';
    final value = int.tryParse(hex, radix: 16) ?? 0x888480;
    final r = ((value >> 16) & 0xFF);
    final g = ((value >> 8) & 0xFF);
    final b = (value & 0xFF);
    final accent = Color.fromARGB(
      255,
      r.clamp(80, 200),
      g.clamp(80, 180),
      b.clamp(60, 160),
    );

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: SpotColors.surface,
        border: Border.all(color: accent.withAlpha(120), width: 1),
      ),
      child: Center(
        child: Text(
          pubkeyHex.substring(0, 2).toUpperCase(),
          style: TextStyle(
            color: accent,
            fontSize: 26,
            fontWeight: FontWeight.w300,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

class _PostingLimitSummary extends StatelessWidget {
  const _PostingLimitSummary({required this.quota});

  final PostingQuotaStatus quota;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final blockReason = quota.postingBlockReason?.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (quota.isPostingBlocked) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(SpotSpacing.md),
            decoration: SpotDecoration.danger(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.postingBlocked,
                  style: SpotType.body.copyWith(color: SpotColors.danger),
                ),
                if (blockReason != null && blockReason.isNotEmpty) ...[
                  const SizedBox(height: SpotSpacing.xs),
                  Text(blockReason, style: SpotType.bodySecondary),
                ],
              ],
            ),
          ),
          const SizedBox(height: SpotSpacing.md),
        ],
        Text(l10n.postingQuotaDescription, style: SpotType.bodySecondary),
        const SizedBox(height: SpotSpacing.lg),
        _MetaRow(
          label: l10n.tierLabel,
          value: formatPostingTierName(
            quota.currentTierName,
            unknown: l10n.unknownLabel,
          ),
        ),
        _MetaRow(
          label: l10n.threadsLabel,
          value: l10n.postingRemainingOf(
            quota.threadRemainingToday,
            quota.threadLimitPerDay,
          ),
        ),
        _MetaRow(
          label: l10n.repliesLabel,
          value: l10n.postingRemainingOf(
            quota.replyRemainingToday,
            quota.replyLimitPerDay,
          ),
        ),
        _MetaRow(
          label: l10n.usedLabel,
          value: l10n.postingUsedCount(
            quota.threadCountToday,
            quota.replyCountToday,
          ),
        ),
        const SizedBox(height: SpotSpacing.sm),
        Text(
          l10n.postingQuotaResetsAt(formatPostingResetTime(quota.resetsAt)),
          style: SpotType.caption,
        ),
      ],
    );
  }
}

class _InlineLoadingState extends StatelessWidget {
  const _InlineLoadingState({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 1.5),
        ),
        const SizedBox(width: SpotSpacing.sm),
        Expanded(child: Text(label, style: SpotType.bodySecondary)),
      ],
    );
  }
}

class _InlineErrorState extends StatelessWidget {
  const _InlineErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(message, style: SpotType.body.copyWith(color: SpotColors.danger)),
        const SizedBox(height: SpotSpacing.md),
        OutlinedButton(onPressed: onRetry, child: Text(l10n.retryButton)),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(width: 64, child: Text(label, style: SpotType.label)),
          Expanded(child: Text(value, style: SpotType.bodySecondary)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpotSpacing.lg),
      decoration: SpotDecoration.cardBordered(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: SpotType.label),
          const SizedBox(height: SpotSpacing.md),
          child,
        ],
      ),
    );
  }
}

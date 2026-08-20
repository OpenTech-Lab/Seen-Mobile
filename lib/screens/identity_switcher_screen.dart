import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/identity_model.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/services/identity_vault_service.dart';
import 'package:mobile/theme/spot_theme.dart';
import 'package:mobile/widgets/profile_avatar.dart';

/// Lists the personas in the local owner vault.
///
/// Selecting an identity returns its wallet to the caller. The caller owns the
/// session transition so the old persona's cloud session can be preserved
/// before the vault's active identity is changed.
class IdentitySwitcherScreen extends StatefulWidget {
  const IdentitySwitcherScreen({super.key});

  @override
  State<IdentitySwitcherScreen> createState() => _IdentitySwitcherScreenState();
}

class _IdentitySwitcherScreenState extends State<IdentitySwitcherScreen> {
  IdentityVault? _vault;
  bool _isLoading = true;
  bool _isBusy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadVault());
  }

  Future<void> _loadVault() async {
    try {
      final vault = await IdentityVaultService.instance.load();
      if (!mounted) return;
      setState(() {
        _vault = vault;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _createIdentity() async {
    if (_isBusy) return;
    final draft = await _showIdentityDialog();
    if (!mounted || draft == null) return;

    setState(() {
      _isBusy = true;
      _error = null;
    });
    try {
      final identity = await IdentityVaultService.instance.createIdentity(
        label: draft.$1,
        kind: draft.$2,
      );
      if (!mounted) return;
      // Returning immediately makes the new persona active in the same way as
      // selecting an existing persona. Its recovery QR remains available from
      // Account after the switch.
      Navigator.of(context).pop<WalletModel>(identity.wallet);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isBusy = false;
      });
    }
  }

  Future<(String, IdentityKind)?> _showIdentityDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    var selectedKind = IdentityKind.custom;
    final result = await showDialog<(String, IdentityKind)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          backgroundColor: SpotColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpotRadius.md),
          ),
          title: Text(l10n.addIdentityTitle, style: SpotType.subheading),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.identitySwitcherSecurityNote,
                style: SpotType.bodySecondary,
              ),
              const SizedBox(height: SpotSpacing.lg),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 32,
                decoration: InputDecoration(
                  labelText: l10n.identityNameLabel,
                  hintText: l10n.identityNameHint,
                ),
                onTapOutside: (_) => FocusScope.of(dialogContext).unfocus(),
              ),
              const SizedBox(height: SpotSpacing.sm),
              DropdownButtonFormField<IdentityKind>(
                initialValue: selectedKind,
                decoration: InputDecoration(labelText: l10n.identityTypeLabel),
                items: [
                  for (final kind in IdentityKind.values)
                    DropdownMenuItem(
                      value: kind,
                      child: Text(_kindLabel(kind, l10n)),
                    ),
                ],
                onChanged: (kind) {
                  if (kind != null) {
                    setDialogState(() => selectedKind = kind);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancelAction, style: SpotType.bodySecondary),
            ),
            FilledButton(
              onPressed: () {
                final label = controller.text.trim();
                if (label.isEmpty) return;
                Navigator.of(dialogContext).pop((label, selectedKind));
              },
              child: Text(l10n.addIdentityButton),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  String _kindLabel(IdentityKind kind, AppLocalizations l10n) {
    return switch (kind) {
      IdentityKind.personal => l10n.personalIdentityType,
      IdentityKind.company => l10n.companyIdentityType,
      IdentityKind.studio => l10n.studioIdentityType,
      IdentityKind.brand => l10n.brandIdentityType,
      IdentityKind.custom => l10n.customIdentityType,
    };
  }

  Future<void> _removeIdentity(AccountIdentity identity) async {
    if (_isBusy || identity.isPrimary) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SpotColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpotRadius.md),
        ),
        title: Text(
          l10n.removeIdentityTitle(identity.label),
          style: SpotType.subheading,
        ),
        content: Text(
          l10n.removeIdentityContent,
          style: SpotType.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelAction, style: SpotType.bodySecondary),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.removeIdentityButton,
              style: SpotType.body.copyWith(color: SpotColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isBusy = true);
    try {
      final vault = _vault;
      if (vault == null) return;
      final wasActive = vault.activeIdentityId == identity.id;
      await IdentityVaultService.instance.removeIdentity(identity.id);
      if (!mounted) return;
      if (wasActive) {
        Navigator.of(context).pop<WalletModel>(vault.ownerIdentity.wallet);
      } else {
        setState(() {
          _vault = IdentityVaultService.instance.currentVault;
          _isBusy = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isBusy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final vault = _vault;
    return Scaffold(
      backgroundColor: SpotColors.bg,
      appBar: AppBar(
        backgroundColor: SpotColors.bg,
        title: Text(l10n.switchIdentityTitle, style: SpotType.subheading),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: SpotColors.accent,
                strokeWidth: 1.5,
              ),
            )
          : vault == null
          ? Center(child: Text(_error ?? l10n.identityVaultUnavailable))
          : ListView(
              padding: const EdgeInsets.all(SpotSpacing.lg),
              children: [
                Text(
                  l10n.switchIdentitySubtitle,
                  style: SpotType.bodySecondary,
                ),
                const SizedBox(height: SpotSpacing.md),
                DecoratedBox(
                  decoration: SpotDecoration.cardBordered(
                    radius: SpotRadius.md,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(SpotSpacing.md),
                    child: Text(
                      l10n.identitySwitcherSecurityNote,
                      style: SpotType.caption,
                    ),
                  ),
                ),
                const SizedBox(height: SpotSpacing.lg),
                for (final identity in vault.identities) ...[
                  _IdentityTile(
                    identity: identity,
                    kindLabel: _kindLabel(identity.kind, l10n),
                    isActive: identity.id == vault.activeIdentityId,
                    isBusy: _isBusy,
                    activeLabel: l10n.activeIdentityLabel,
                    primaryLabel: l10n.mainIdentityLabel,
                    onTap: () =>
                        Navigator.of(context).pop<WalletModel>(identity.wallet),
                    onRemove:
                        identity.isPrimary ||
                            identity.id == vault.activeIdentityId
                        ? null
                        : () => _removeIdentity(identity),
                  ),
                  const SizedBox(height: SpotSpacing.sm),
                ],
                const SizedBox(height: SpotSpacing.md),
                OutlinedButton.icon(
                  onPressed: _isBusy ? null : _createIdentity,
                  icon: const Icon(CupertinoIcons.person_badge_plus),
                  label: Text(l10n.addIdentityButton),
                ),
                if (_error != null) ...[
                  const SizedBox(height: SpotSpacing.md),
                  Text(
                    _error!,
                    style: SpotType.caption.copyWith(color: SpotColors.danger),
                  ),
                ],
              ],
            ),
    );
  }
}

class _IdentityTile extends StatelessWidget {
  const _IdentityTile({
    required this.identity,
    required this.kindLabel,
    required this.isActive,
    required this.isBusy,
    required this.activeLabel,
    required this.primaryLabel,
    required this.onTap,
    required this.onRemove,
  });

  final AccountIdentity identity;
  final String kindLabel;
  final bool isActive;
  final bool isBusy;
  final String activeLabel;
  final String primaryLabel;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? SpotColors.accentSubtle : SpotColors.surface,
      borderRadius: BorderRadius.circular(SpotRadius.md),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(SpotRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(SpotSpacing.md),
          child: Row(
            children: [
              ProfileAvatar(pubkey: identity.wallet.publicKeyHex, size: 46),
              const SizedBox(width: SpotSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(identity.label, style: SpotType.body),
                    const SizedBox(height: SpotSpacing.xs),
                    Text(
                      identity.isPrimary ? primaryLabel : kindLabel,
                      style: SpotType.caption,
                    ),
                  ],
                ),
              ),
              if (isActive)
                Text(
                  activeLabel,
                  style: SpotType.caption.copyWith(color: SpotColors.accent),
                ),
              if (onRemove != null)
                IconButton(
                  onPressed: isBusy ? null : onRemove,
                  icon: const Icon(CupertinoIcons.ellipsis, size: 18),
                  color: SpotColors.textSecondary,
                  tooltip: 'More',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

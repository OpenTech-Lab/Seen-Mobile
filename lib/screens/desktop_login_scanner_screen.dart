import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/services/desktop_login_service.dart';
import 'package:mobile/services/identity_vault_service.dart';
import 'package:mobile/theme/spot_theme.dart';

/// Scans the short-lived QR shown by the web app and asks the user to approve
/// the exact website/browser before signing with the selected identity.
class DesktopLoginScannerScreen extends StatefulWidget {
  const DesktopLoginScannerScreen({
    super.key,
    required this.wallet,
    this.loginService,
  });

  final WalletModel wallet;
  final DesktopLoginService? loginService;

  @override
  State<DesktopLoginScannerScreen> createState() =>
      _DesktopLoginScannerScreenState();
}

class _DesktopLoginScannerScreenState extends State<DesktopLoginScannerScreen> {
  late final MobileScannerController _controller;
  late final DesktopLoginService _loginService;
  late final bool _ownsLoginService;
  bool _didHandleCode = false;
  bool _isPickingImage = false;
  bool _isApproving = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
    );
    _ownsLoginService = widget.loginService == null;
    _loginService = widget.loginService ?? DesktopLoginService();
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_ownsLoginService) _loginService.dispose();
    super.dispose();
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_didHandleCode || _isApproving) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw == null || raw.isEmpty) continue;
      final challenge = DesktopLoginChallenge.tryParse(raw);
      if (challenge == null) continue;

      _didHandleCode = true;
      unawaited(_reviewChallenge(challenge));
      return;
    }
  }

  Future<void> _reviewChallenge(DesktopLoginChallenge challenge) async {
    await _controller.stop();
    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final shouldApprove = await showDialog<bool>(
      context: context,
      barrierDismissible: !_isApproving,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SpotColors.surface,
        title: Text(l10n.desktopLoginApprovalTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.desktopLoginApprovalDescription,
              style: SpotType.bodySecondary,
            ),
            const SizedBox(height: SpotSpacing.lg),
            _ApprovalDetail(
              label: l10n.desktopLoginWebsiteLabel,
              value: challenge.origin,
            ),
            const SizedBox(height: SpotSpacing.sm),
            _ApprovalDetail(
              label: l10n.desktopLoginBrowserLabel,
              value: challenge.browserLabel,
            ),
            const SizedBox(height: SpotSpacing.sm),
            _ApprovalDetail(
              label: l10n.desktopLoginExpiryLabel,
              value: _formatExpiry(context, challenge.expiresAtDate),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.approveDesktopLoginButton),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (shouldApprove != true) {
      _didHandleCode = false;
      await _controller.start();
      return;
    }

    setState(() => _isApproving = true);
    try {
      await _loginService.approve(
        challenge: challenge,
        wallet: widget.wallet,
        identityLabel:
            IdentityVaultService.instance.activeIdentity?.label ??
            l10n.mobileIdentityLabel,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.desktopLoginApproved)));
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isApproving = false);
      _didHandleCode = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.desktopLoginApprovalFailed)));
      await _controller.start();
    }
  }

  Future<void> _pickImage() async {
    if (_isPickingImage || _isApproving || _didHandleCode) return;

    setState(() => _isPickingImage = true);
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;

      final capture = await _controller.analyzeImage(image.path);
      if (!mounted) return;
      if (capture != null) {
        _handleCapture(capture);
      }
      if (!_didHandleCode) {
        _showMessage(AppLocalizations.of(context)!.desktopLoginInvalidQr);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context)!.desktopLoginInvalidQr);
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(l10n.desktopLoginScannerTitle),
        actions: [
          IconButton(
            onPressed: _isPickingImage || _isApproving ? null : _pickImage,
            tooltip: l10n.chooseDesktopLoginQrImageTooltip,
            icon: _isPickingImage
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  )
                : const Icon(Icons.photo_library_outlined),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(controller: _controller, onDetect: _handleCapture),
          Center(
            child: SizedBox(
              width: 250,
              height: 250,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: SpotColors.accent, width: 2),
                  borderRadius: BorderRadius.circular(SpotRadius.lg),
                ),
              ),
            ),
          ),
          Positioned(
            left: SpotSpacing.xxl,
            right: SpotSpacing.xxl,
            bottom: SpotSpacing.xxl,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(190),
                borderRadius: BorderRadius.circular(SpotRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(SpotSpacing.lg),
                child: Text(
                  _isApproving
                      ? l10n.loadingLabel
                      : l10n.desktopLoginScannerHint,
                  textAlign: TextAlign.center,
                  style: SpotType.bodySecondary.copyWith(
                    color: SpotColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatExpiry(BuildContext context, DateTime expiry) {
    final local = expiry.toLocal();
    final date = MaterialLocalizations.of(context).formatMediumDate(local);
    final time = MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(TimeOfDay.fromDateTime(local));
    return '$date, $time';
  }
}

class _ApprovalDetail extends StatelessWidget {
  const _ApprovalDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 74, child: Text(label, style: SpotType.caption)),
        Expanded(child: Text(value, style: SpotType.body)),
      ],
    );
  }
}

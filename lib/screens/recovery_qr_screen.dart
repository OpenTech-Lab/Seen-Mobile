import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:mobile/core/recovery_qr_image.dart';
import 'package:mobile/core/wallet.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/theme/spot_theme.dart';

/// Displays a portable recovery QR for the current wallet.
class RecoveryQrScreen extends StatefulWidget {
  const RecoveryQrScreen({super.key, required this.wallet});

  final WalletModel wallet;

  @override
  State<RecoveryQrScreen> createState() => _RecoveryQrScreenState();
}

class _RecoveryQrScreenState extends State<RecoveryQrScreen> {
  late final String _payload;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _payload = WalletService.createRecoveryPayload(widget.wallet);
  }

  Future<void> _saveToPhotos() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    try {
      final painter = QrPainter(
        data: _payload,
        version: QrVersions.auto,
        gapless: true,
        errorCorrectionLevel: QrErrorCorrectLevel.H,
      );
      final imageData = await painter.toImageData(1200);
      if (imageData == null) {
        throw StateError('QR image could not be rendered');
      }

      final hasAccess = await Gal.hasAccess(toAlbum: true);
      if (!hasAccess && !await Gal.requestAccess(toAlbum: true)) {
        throw StateError('Photo access was denied');
      }

      final rawBytes = Uint8List.fromList(
        imageData.buffer.asUint8List(
          imageData.offsetInBytes,
          imageData.lengthInBytes,
        ),
      );
      final bytes = addRecoveryQrQuietZone(rawBytes, padding: 120) ?? rawBytes;
      await Gal.putImageBytes(bytes, album: '#seen');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.recoveryQrSaved)),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.recoveryQrSaveFailed),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SpotColors.bg,
      appBar: AppBar(
        title: Text(l10n.recoveryQrTitle, style: SpotType.subheading),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(SpotSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.recoveryQrDescription, style: SpotType.bodySecondary),
              const SizedBox(height: SpotSpacing.xl),
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(SpotRadius.md),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(SpotSpacing.lg),
                    child: QrImageView(
                      data: _payload,
                      version: QrVersions.auto,
                      size: 260,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpotSpacing.xl),
              _AccountCheck(wallet: widget.wallet),
              const SizedBox(height: SpotSpacing.xl),
              Container(
                padding: const EdgeInsets.all(SpotSpacing.lg),
                decoration: SpotDecoration.danger(),
                child: Text(
                  l10n.recoveryQrWarning,
                  style: SpotType.bodySecondary.copyWith(
                    color: SpotColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: SpotSpacing.xl),
              FilledButton.icon(
                onPressed: _isSaving ? null : _saveToPhotos,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: SpotColors.onAccent,
                        ),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(l10n.saveRecoveryQrButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountCheck extends StatelessWidget {
  const _AccountCheck({required this.wallet});

  final WalletModel wallet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(SpotSpacing.md),
      decoration: SpotDecoration.cardBordered(),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: SpotColors.accent,
            size: 18,
          ),
          const SizedBox(width: SpotSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.accountLabel, style: SpotType.label),
                const SizedBox(height: SpotSpacing.xs),
                Text(wallet.npubShort, style: SpotType.mono),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

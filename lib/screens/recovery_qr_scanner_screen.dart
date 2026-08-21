import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:mobile/core/recovery_qr_image.dart';
import 'package:mobile/core/wallet.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/theme/spot_theme.dart';

/// Scans a recovery QR either from the camera or from an image in Photos.
class RecoveryQrScannerScreen extends StatefulWidget {
  const RecoveryQrScannerScreen({super.key});

  @override
  State<RecoveryQrScannerScreen> createState() =>
      _RecoveryQrScannerScreenState();
}

class _RecoveryQrScannerScreenState extends State<RecoveryQrScannerScreen> {
  late final MobileScannerController _controller;
  bool _didReturnPayload = false;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleCapture(BarcodeCapture capture) {
    if (_didReturnPayload) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue?.trim();
      if (raw == null || !WalletService.isRecoveryPayload(raw)) continue;

      _didReturnPayload = true;
      Navigator.of(context).pop(raw);
      return;
    }
  }

  Future<void> _pickImage() async {
    if (_isPickingImage || _didReturnPayload) return;

    setState(() => _isPickingImage = true);
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null || !mounted) return;

      final capture = await _analyzePickedImage(image.path);
      if (!mounted) return;
      if (capture != null) {
        _handleCapture(capture);
      }
      if (!_didReturnPayload) {
        _showMessage(AppLocalizations.of(context)!.recoveryQrNoCodeError);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(AppLocalizations.of(context)!.recoveryQrNoCodeError);
      }
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<BarcodeCapture?> _analyzePickedImage(String path) async {
    final capture = await _controller.analyzeImage(path);
    if (_containsRecoveryPayload(capture)) return capture;

    // Older exports were missing the QR quiet zone.  Normalize a temporary
    // copy so those backups remain recoverable after this app is updated.
    final normalizedPath = await _createNormalizedImage(path);
    if (normalizedPath == null) return capture;

    try {
      final normalizedCapture = await _controller.analyzeImage(normalizedPath);
      return normalizedCapture ?? capture;
    } finally {
      try {
        await File(normalizedPath).delete();
      } catch (_) {
        // Best-effort cleanup of the temporary scan copy.
      }
    }
  }

  bool _containsRecoveryPayload(BarcodeCapture? capture) {
    if (capture == null) return false;
    return capture.barcodes.any((barcode) {
      final raw = barcode.rawValue?.trim();
      return raw != null && WalletService.isRecoveryPayload(raw);
    });
  }

  Future<String?> _createNormalizedImage(String path) async {
    try {
      final sourceBytes = await File(path).readAsBytes();
      final normalizedBytes = addRecoveryQrQuietZone(
        Uint8List.fromList(sourceBytes),
      );
      if (normalizedBytes == null) return null;

      final file = File(
        '${Directory.systemTemp.path}/seen-recovery-${DateTime.now().microsecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(normalizedBytes, flush: true);
      return file.path;
    } on img.ImageException {
      return null;
    } catch (_) {
      return null;
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
        title: Text(l10n.recoveryQrScannerTitle),
        actions: [
          IconButton(
            onPressed: _isPickingImage ? null : _pickImage,
            tooltip: l10n.chooseRecoveryQrImageTooltip,
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
                  l10n.recoveryQrScannerHint,
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
}

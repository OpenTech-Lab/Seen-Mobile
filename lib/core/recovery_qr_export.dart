import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:qr_flutter/qr_flutter.dart';

/// Size of the QR symbol itself inside the exported PNG.
const double kRecoveryQrExportSize = 1200;

/// White margin kept around the symbol so scanners can lock onto it.
const double kRecoveryQrQuietZone = 120;

/// Renders [payload] as an opaque black-on-white recovery QR PNG.
///
/// [QrPainter] paints only the dark modules and leaves the background fully
/// transparent, so every pixel of a plain export is black and only the alpha
/// channel separates the modules.  Galleries composite that over a dark
/// backdrop, which is why a saved QR looked like a solid black square and
/// could not be scanned back.  Painting an opaque white background plus the
/// quiet zone here keeps the export readable however the gallery renders
/// transparency, and however the file is later re-encoded.
Future<Uint8List> renderRecoveryQrPng(
  String payload, {
  double size = kRecoveryQrExportSize,
  double quietZone = kRecoveryQrQuietZone,
}) async {
  final painter = QrPainter(
    data: payload,
    version: QrVersions.auto,
    gapless: true,
    errorCorrectionLevel: QrErrorCorrectLevel.H,
  );

  final canvasSize = size + quietZone * 2;
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(
    recorder,
    ui.Rect.fromLTWH(0, 0, canvasSize, canvasSize),
  );
  canvas.drawRect(
    ui.Rect.fromLTWH(0, 0, canvasSize, canvasSize),
    ui.Paint()..color = const ui.Color(0xFFFFFFFF),
  );
  canvas.translate(quietZone, quietZone);
  painter.paint(canvas, ui.Size(size, size));

  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(canvasSize.round(), canvasSize.round());
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('Recovery QR could not be encoded');
      }
      return Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    } finally {
      image.dispose();
    }
  } finally {
    picture.dispose();
  }
}

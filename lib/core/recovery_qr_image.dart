import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Adds the white quiet zone required around a QR code for reliable decoding.
///
/// The QR export previously had no surrounding pixels because [QrPainter]
/// paints only the modules.  A quiet zone also makes older saved exports
/// usable when they are picked from Photos.
Uint8List? addRecoveryQrQuietZone(Uint8List bytes, {int? padding}) {
  final img.Image? source;
  try {
    source = img.decodeImage(bytes);
  } catch (_) {
    return null;
  }
  if (source == null || source.width <= 0 || source.height <= 0) {
    return null;
  }

  final resolvedPadding =
      padding ??
      (source.width < source.height ? source.width : source.height) ~/ 12;
  final safePadding = resolvedPadding < 32 ? 32 : resolvedPadding;
  final expanded = img.copyExpandCanvas(
    source,
    padding: safePadding,
    backgroundColor: img.ColorRgb8(255, 255, 255),
  );
  return Uint8List.fromList(img.encodePng(expanded));
}

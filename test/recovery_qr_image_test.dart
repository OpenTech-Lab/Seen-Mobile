import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:mobile/core/recovery_qr_image.dart';

void main() {
  test('adds an opaque white quiet zone around an exported QR image', () {
    final source = img.Image(width: 100, height: 100, numChannels: 4);
    source.clear(img.ColorRgba8(0, 0, 0, 255));
    final sourceBytes = Uint8List.fromList(img.encodePng(source));

    final normalized = addRecoveryQrQuietZone(sourceBytes, padding: 40);

    expect(normalized, isNotNull);
    final decoded = img.decodeImage(normalized!);
    expect(decoded, isNotNull);
    expect(decoded!.width, 180);
    expect(decoded.height, 180);
    final corner = decoded.getPixel(0, 0);
    expect(corner.r, 255);
    expect(corner.g, 255);
    expect(corner.b, 255);
    expect(corner.a, 255);
  });

  test('returns null for bytes that are not an image', () {
    expect(addRecoveryQrQuietZone(Uint8List.fromList([1, 2, 3])), isNull);
  });
}

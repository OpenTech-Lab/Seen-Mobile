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

  test('flattens a transparent legacy export onto white', () {
    // Legacy exports (before the opaque renderer) were black at every pixel
    // with the background held only in the alpha channel.  Restoring one from
    // Photos depends on this helper turning that back into a readable QR.
    final source = img.Image(width: 60, height: 60, numChannels: 4);
    source.clear(img.ColorRgba8(0, 0, 0, 0));
    for (var y = 10; y < 30; y++) {
      for (var x = 10; x < 30; x++) {
        source.setPixelRgba(x, y, 0, 0, 0, 255);
      }
    }
    final normalized = addRecoveryQrQuietZone(
      Uint8List.fromList(img.encodePng(source)),
      padding: 40,
    );

    expect(normalized, isNotNull);
    final decoded = img.decodeImage(normalized!)!;

    // The formerly-transparent background must become white, not stay dark.
    final background = decoded.getPixel(90, 90);
    expect(background.r, 255);
    expect(background.g, 255);
    expect(background.b, 255);

    // The dark module must survive the flatten.
    final module = decoded.getPixel(60, 60);
    expect(module.r, 0);
    expect(module.g, 0);
    expect(module.b, 0);
  });

  test('returns null for bytes that are not an image', () {
    expect(addRecoveryQrQuietZone(Uint8List.fromList([1, 2, 3])), isNull);
  });
}

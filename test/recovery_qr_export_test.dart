import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:mobile/core/recovery_qr_export.dart';

const _payload =
    'nostr:recovery:nsec1qqqsyqcyq5rqwzqfpg9scrgwpugpzysnzs23v9ccrydpk8qarc0';

void main() {
  testWidgets('exported recovery QR is fully opaque', (tester) async {
    // Regression guard: QrPainter paints only the dark modules, so a plain
    // export is black at every pixel with the background carried solely in the
    // alpha channel.  Galleries composite that over black, turning the saved
    // QR into an unscannable black square.
    final bytes = await tester.runAsync(() => renderRecoveryQrPng(_payload));
    final image = img.decodeImage(bytes!);
    expect(image, isNotNull);

    var transparent = 0;
    for (final pixel in image!) {
      if (pixel.a != 255) transparent++;
    }
    expect(transparent, 0, reason: 'export must not rely on transparency');
  });

  testWidgets('exported recovery QR has a white quiet zone and dark modules', (
    tester,
  ) async {
    final bytes = await tester.runAsync(() => renderRecoveryQrPng(_payload));
    final image = img.decodeImage(bytes!)!;

    expect(image.width, image.height);
    expect(
      image.width,
      (kRecoveryQrExportSize + kRecoveryQrQuietZone * 2).round(),
    );

    for (final corner in <List<int>>[
      [0, 0],
      [image.width - 1, 0],
      [0, image.height - 1],
      [image.width - 1, image.height - 1],
    ]) {
      final pixel = image.getPixel(corner[0], corner[1]);
      expect(pixel.r, 255);
      expect(pixel.g, 255);
      expect(pixel.b, 255);
    }

    // The symbol itself must actually be drawn: expect a real mix of light and
    // dark, not a blank white canvas.
    var dark = 0;
    var light = 0;
    for (final pixel in image) {
      if (pixel.r < 64) {
        dark++;
      } else if (pixel.r > 192) {
        light++;
      }
    }
    expect(dark, greaterThan(0));
    expect(light, greaterThan(dark));
  });
}

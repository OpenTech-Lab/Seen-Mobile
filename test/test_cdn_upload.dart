import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/encryption.dart';
import 'package:mobile/core/wallet.dart';
import 'package:mobile/models/media_post.dart';

void main() {
  test('test manual cdn upload', () async {
    final wallet = await WalletService.createNewWallet();
    print('Generated Wallet Pubkey: ${wallet.publicKeyHex}');

    final imagePath = Platform.environment['SEEN_CDN_TEST_IMAGE'];
    if (imagePath == null || imagePath.isEmpty) {
      print('Set SEEN_CDN_TEST_IMAGE to run the manual CDN upload test.');
      return;
    }
    final file = File(imagePath);
    if (!file.existsSync()) {
      print('Image not found: $imagePath');
      return;
    }

    final bytes = await file.readAsBytes();
    final hash = EncryptionUtils.sha256BytesHex(bytes);
    print('Image SHA-256: $hash');

    // 1. Presign
    final timestamp = (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000)
        .toString();
    const contentType = 'image/jpeg';
    final message = 'PUT:$hash:$timestamp:${bytes.length}:$contentType';
    final sig = WalletService.signMessage(message, wallet.privateKeyHex);

    final presignUrl =
        'https://votdyixeh3e6jlfinn4vmdug2q0jyoax.lambda-url.ap-northeast-1.on.aws/';
    print('\nRequesting presign URL...');

    final client = HttpClient();
    final req = await client.postUrl(Uri.parse(presignUrl));
    req.headers.contentType = ContentType.json;
    req.write(
      jsonEncode({
        'pubkey': wallet.publicKeyHex,
        'contentHash': hash,
        'timestamp': timestamp,
        'signature': sig,
        'contentType': contentType,
        'contentLength': bytes.length,
      }),
    );

    final res = await req.close();
    final bodyStr = await res.transform(utf8.decoder).join();
    if (res.statusCode != 200) {
      print('Presign failed: HTTP ${res.statusCode} - $bodyStr');
      return;
    }

    final Map<String, dynamic> json = jsonDecode(bodyStr);
    if (!json.containsKey('uploadUrl')) {
      print('No uploadUrl! $bodyStr');
      return;
    }
    final uploadUrl = json['uploadUrl'];

    // 2. Upload
    print('\nUploading S3...');
    final putReq = await client.putUrl(Uri.parse(uploadUrl));
    putReq.headers.contentType = ContentType('image', 'jpeg');
    putReq.contentLength = bytes.length;
    putReq.headers.set(HttpHeaders.ifNoneMatchHeader, '*');
    putReq.add(bytes);

    final putRes = await putReq.close();
    await putRes.drain();
    if (putRes.statusCode == 200 || putRes.statusCode == 204) {
      print('Upload Success HTTP ${putRes.statusCode}');
    } else {
      print('Upload Failed HTTP ${putRes.statusCode}');
      return;
    }

    // 3. Build the post payload that would be published through the app metadata flow.
    print('\nBuilding Spot post payload...');
    final post = MediaPost(
      id: hash,
      pubkey: wallet.publicKeyHex,
      contentHashes: [hash],
      mediaPaths: [file.path],
      capturedAt: DateTime.now().toUtc(),
      eventTags: ['test_upload'],
      sourceType: PostSourceType.firsthand,
      isTextOnly: false,
      nostrEventId: hash,
    );

    print(
      '✅ Upload success. Spot post payload prepared for ${post.nostrEventId}.',
    );
    client.close();
  });
}

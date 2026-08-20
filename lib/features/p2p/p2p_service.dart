import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:mobile/core/encryption.dart';
import 'package:mobile/features/metadata/metadata_service.dart';
import 'package:mobile/models/asset_transport_policy.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/services/cache_manager.dart';
import 'package:mobile/services/user_prefs_service.dart';

const _peerProtocol = 'spot-p2p-http-v1';
const _mediaFetchTimeout = Duration(seconds: 8);
const _endpointCacheTtl = Duration(minutes: 2);
const _mediaHeaderFileName = 'x-spot-file-name';

/// Lightweight P2P media transport.
///
/// This implementation uses Supabase metadata only for peer endpoint discovery. Raw
/// media bytes are served directly from device to device over HTTP.
///
/// It does not attempt NAT traversal. Peers must be online and reachable from
/// the requesting device for full-media fetches to succeed.
class P2PService {
  P2PService._({
    HttpClient? httpClient,
    Future<List<Uri>> Function(String pubkey)? peerEndpointResolver,
    Future<List<Uri>> Function(int port)? localEndpointResolver,
    Future<Directory> Function()? tempDirLoader,
    AssetTransportPolicy Function()? transportPolicyGetter,
    Future<bool> Function()? wifiChecker,
    Stream<void>? connectivityChanges,
  }) : _httpClient = httpClient ?? HttpClient(),
       _peerEndpointResolver = peerEndpointResolver,
       _localEndpointResolver = localEndpointResolver,
       _tempDirLoader = tempDirLoader ?? getTemporaryDirectory,
       _transportPolicyGetter =
           transportPolicyGetter ??
           (() => UserPrefsService.instance.assetTransportPolicy),
       _wifiChecker = wifiChecker ?? _defaultWifiChecker,
       _connectivityChanges =
           connectivityChanges ??
           Connectivity().onConnectivityChanged.map((_) {});

  static final P2PService instance = P2PService._();

  factory P2PService.forTesting({
    HttpClient? httpClient,
    Future<List<Uri>> Function(String pubkey)? peerEndpointResolver,
    Future<List<Uri>> Function(int port)? localEndpointResolver,
    Future<Directory> Function()? tempDirLoader,
    AssetTransportPolicy Function()? transportPolicyGetter,
    Future<bool> Function()? wifiChecker,
    Stream<void>? connectivityChanges,
  }) => P2PService._(
    httpClient: httpClient,
    peerEndpointResolver: peerEndpointResolver,
    localEndpointResolver: localEndpointResolver,
    tempDirLoader: tempDirLoader,
    transportPolicyGetter: transportPolicyGetter,
    wifiChecker: wifiChecker,
    connectivityChanges: connectivityChanges,
  );

  final HttpClient _httpClient;
  final Future<List<Uri>> Function(String pubkey)? _peerEndpointResolver;
  final Future<List<Uri>> Function(int port)? _localEndpointResolver;
  final Future<Directory> Function() _tempDirLoader;
  final AssetTransportPolicy Function() _transportPolicyGetter;
  final Future<bool> Function() _wifiChecker;
  final Stream<void> _connectivityChanges;

  bool _started = false;
  int _seedingCount = 0;
  HttpServer? _server;
  WalletModel? _wallet;
  List<Uri> _localEndpoints = const [];
  StreamSubscription<void>? _connectivitySubscription;
  final Map<String, ({DateTime fetchedAt, List<Uri> endpoints})>
  _peerEndpointCache = {};

  void configure({required WalletModel wallet}) {
    _wallet = wallet;
    _connectivitySubscription ??= _connectivityChanges.listen((_) {
      unawaited(refreshTransportAvailability());
    });
  }

  // ── Swarm lifecycle ───────────────────────────────────────────────────────

  Future<void> startSwarm() async {
    if (!await isTransportAllowedNow()) {
      await stopSwarm();
      return;
    }
    await _startSwarmInternal();
  }

  Future<void> refreshTransportAvailability() async {
    if (await isTransportAllowedNow()) {
      await _startSwarmInternal();
    } else {
      await stopSwarm();
    }
  }

  Future<void> _startSwarmInternal() async {
    if (_started) return;
    final server = await HttpServer.bind(InternetAddress.anyIPv4, 0);
    _server = server;
    _started = true;

    unawaited(
      server.forEach((request) async {
        await _handleHttpRequest(request);
      }),
    );

    _localEndpoints = _localEndpointResolver != null
        ? await _localEndpointResolver(server.port)
        : await _discoverLocalEndpoints(server.port);
    unawaited(_publishPeerAnnouncement());
  }

  Future<void> stopSwarm() async {
    _started = false;
    _seedingCount = 0;
    final server = _server;
    _server = null;
    final wallet = _wallet;
    _localEndpoints = const [];
    if (server != null) {
      await server.close(force: true);
    }
    if (wallet != null) {
      try {
        await MetadataService.instance.clearPeerEndpoints(wallet);
      } catch (error) {
        debugPrint('[P2PService] Failed to clear peer endpoints: $error');
      }
    }
  }

  Future<void> shutdown() async {
    await stopSwarm();
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  // ── Seeding ───────────────────────────────────────────────────────────────

  Future<void> seedMedia(String filePath, String contentHash) async {
    await CacheManager.instance.addToCache(contentHash, filePath);
    _seedingCount++;
  }

  Future<void> seedIfEligible(
    String contentHash,
    String filePath,
    double watchFraction,
  ) async {
    if (watchFraction < 0.5) return;
    if (!await _isOnWifi()) return;
    await seedMedia(filePath, contentHash);
  }

  // ── Fetching ──────────────────────────────────────────────────────────────

  Future<File?> requestMedia(String contentHash, {String? authorPubkey}) async {
    final cached = CacheManager.instance.getCached(contentHash);
    if (cached != null) return cached;
    if (!await isTransportAllowedNow()) return null;
    if (authorPubkey == null || authorPubkey.isEmpty) return null;

    final endpoints = await _resolvePeerEndpoints(authorPubkey);
    for (final endpoint in endpoints) {
      final fetched = await _downloadFromEndpoint(endpoint, contentHash);
      if (fetched != null) return fetched;
    }
    return null;
  }

  // ── Deletion / revocation ─────────────────────────────────────────────────

  Future<void> dropFromCache(String contentHash) async {
    await CacheManager.instance.purgeCached(contentHash);
    if (_seedingCount > 0) _seedingCount--;
  }

  // ── Status ────────────────────────────────────────────────────────────────

  int get seedingCount => _seedingCount;
  int get peerCount => _peerEndpointCache.length;
  bool get isRunning => _started;
  bool get isSeeding => _seedingCount > 0;
  int get cacheSizeBytes => CacheManager.instance.totalCacheBytes;
  List<Uri> get localEndpoints => List.unmodifiable(_localEndpoints);
  AssetTransportPolicy get transportPolicy => _transportPolicyGetter();

  Future<bool> isTransportAllowedNow() async {
    return switch (transportPolicy) {
      AssetTransportPolicy.off => false,
      AssetTransportPolicy.always => true,
      AssetTransportPolicy.wifiOnly => _wifiChecker(),
    };
  }

  // ── Private: endpoint publication/discovery ──────────────────────────────

  Future<void> _publishPeerAnnouncement() async {
    final wallet = _wallet;
    if (wallet == null || _localEndpoints.isEmpty) return;

    try {
      await MetadataService.instance.publishPeerEndpoints(
        _localEndpoints,
        wallet,
        protocol: _peerProtocol,
      );
    } catch (_) {}
  }

  Future<List<Uri>> _resolvePeerEndpoints(String pubkey) async {
    final cached = _peerEndpointCache[pubkey];
    if (cached != null &&
        DateTime.now().difference(cached.fetchedAt) < _endpointCacheTtl) {
      return cached.endpoints;
    }

    final endpoints = _peerEndpointResolver != null
        ? await _peerEndpointResolver(pubkey)
        : await MetadataService.instance.resolvePeerEndpoints(pubkey);

    _peerEndpointCache[pubkey] = (
      fetchedAt: DateTime.now(),
      endpoints: endpoints,
    );
    return endpoints;
  }

  Future<List<Uri>> _discoverLocalEndpoints(int port) async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
    );

    final endpoints = <Uri>[];
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        if (!_isUsablePeerAddress(address)) continue;
        endpoints.add(Uri.parse('http://${address.address}:$port'));
      }
    }

    return endpoints.toList(growable: false);
  }

  bool _isUsablePeerAddress(InternetAddress address) {
    if (address.type != InternetAddressType.IPv4 || address.isLoopback) {
      return false;
    }
    final raw = address.rawAddress;
    if (raw.length != 4) return false;
    if (raw[0] == 169 && raw[1] == 254) return false; // link-local
    if (raw[0] == 127) return false;
    return true;
  }

  // ── Private: HTTP media server/fetch ─────────────────────────────────────

  Future<void> _handleHttpRequest(HttpRequest request) async {
    try {
      if (!await isTransportAllowedNow()) {
        request.response.statusCode = HttpStatus.forbidden;
        await request.response.close();
        return;
      }

      if (request.method != 'GET') {
        request.response.statusCode = HttpStatus.methodNotAllowed;
        await request.response.close();
        return;
      }

      final segments = request.uri.pathSegments;
      if (segments.length != 2 || segments.first != 'media') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final contentHash = segments[1];
      final file = CacheManager.instance.getCached(contentHash);
      if (file == null || !file.existsSync()) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      request.response.headers.set(
        HttpHeaders.contentTypeHeader,
        _contentTypeForPath(file.path),
      );
      request.response.headers.set(_mediaHeaderFileName, p.basename(file.path));
      request.response.headers.set(
        HttpHeaders.contentLengthHeader,
        await file.length(),
      );
      await request.response.addStream(file.openRead());
      await request.response.close();
    } catch (_) {
      try {
        request.response.statusCode = HttpStatus.internalServerError;
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<File?> _downloadFromEndpoint(Uri endpoint, String contentHash) async {
    final uri = endpoint.replace(
      pathSegments: [
        ...endpoint.pathSegments.where((segment) => segment.isNotEmpty),
        'media',
        contentHash,
      ],
    );

    try {
      final request = await _httpClient.getUrl(uri).timeout(_mediaFetchTimeout);
      final response = await request.close().timeout(_mediaFetchTimeout);
      if (response.statusCode != HttpStatus.ok) return null;

      final bytes = await consolidateHttpClientResponseBytes(response);
      if (EncryptionUtils.sha256BytesHex(bytes) != contentHash) return null;

      final fileName =
          response.headers.value(_mediaHeaderFileName) ??
          '$contentHash${_extensionForContentType(response.headers.contentType?.mimeType)}';
      final ext = p.extension(fileName);

      final dir = await _tempDirLoader();
      final mediaDir = Directory(p.join(dir.path, 'spot_remote_media'));
      if (!mediaDir.existsSync()) {
        await mediaDir.create(recursive: true);
      }
      final file = File(
        p.join(mediaDir.path, '$contentHash${ext.isEmpty ? '.bin' : ext}'),
      );
      await file.writeAsBytes(bytes, flush: true);
      await CacheManager.instance.addToCache(contentHash, file.path);
      return file;
    } catch (_) {
      return null;
    }
  }

  String _contentTypeForPath(String path) {
    switch (p.extension(path).toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }

  String _extensionForContentType(String? mimeType) {
    switch (mimeType) {
      case 'image/jpeg':
        return '.jpg';
      case 'image/png':
        return '.png';
      case 'image/gif':
        return '.gif';
      case 'image/webp':
        return '.webp';
      case 'video/mp4':
        return '.mp4';
      case 'video/quicktime':
        return '.mov';
      default:
        return '.bin';
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<bool> _isOnWifi() async {
    return _wifiChecker();
  }

  static Future<bool> _defaultWifiChecker() async {
    final Object status = await Connectivity().checkConnectivity();
    if (status is List<ConnectivityResult>) {
      return status.contains(ConnectivityResult.wifi) ||
          status.contains(ConnectivityResult.ethernet);
    }
    if (status is ConnectivityResult) {
      return status == ConnectivityResult.wifi ||
          status == ConnectivityResult.ethernet;
    }
    return false;
  }
}

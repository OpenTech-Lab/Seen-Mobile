import 'dart:async';

import 'package:mobile/features/event/event_ordering.dart';
import 'package:mobile/features/ebes/trust_service.dart';
import 'package:mobile/features/metadata/metadata_service.dart';
import 'package:mobile/models/event_model.dart';
import 'package:mobile/models/media_post.dart';
import 'package:mobile/models/witness_model.dart';

/// Aggregates Supabase metadata rows into [CivicEvent] domain objects.
class EventRepository {
  EventRepository({MetadataService? metadataService})
    : _metadata = metadataService ?? MetadataService.instance;

  final MetadataService _metadata;
  final _trust = const TrustService();

  final Map<String, CivicEvent> _cache = {};
  final Map<String, MediaPost> _optimisticPostsById = {};
  final _controller = StreamController<CivicEvent>.broadcast();
  final _changes = StreamController<void>.broadcast();

  StreamSubscription<List<Map<String, dynamic>>>? _globalPostsSub;
  StreamSubscription<List<Map<String, dynamic>>>? _profileSub;
  StreamSubscription<List<Map<String, dynamic>>>? _witnessSub;
  StreamSubscription<List<Map<String, dynamic>>>? _blocklistSub;
  final Map<String, StreamSubscription<List<Map<String, dynamic>>>>
  _authorPostsSubs = {};

  List<Map<String, dynamic>> _globalPostRows = const [];
  final Map<String, List<Map<String, dynamic>>> _authorPostRows = {};
  List<Map<String, dynamic>> _witnessRows = const [];

  bool _globalRequested = false;
  bool _rebuildInFlight = false;
  bool _rebuildQueued = false;
  Future<void> _pendingRefresh = Future<void>.value();

  // ── Subscription ──────────────────────────────────────────────────────────

  Stream<CivicEvent> subscribeToEvents() {
    _globalRequested = true;
    unawaited(_attachStreams());
    return _controller.stream;
  }

  Stream<CivicEvent> subscribeToAuthorPosts(String authorPubkey) {
    _authorPostRows.putIfAbsent(authorPubkey, () => const []);
    unawaited(_attachStreams(authorPubkey: authorPubkey));
    return _controller.stream;
  }

  Stream<void> subscribeToChanges() {
    _globalRequested = true;
    unawaited(_attachStreams());
    return _changes.stream;
  }

  Stream<void> subscribeToAuthorChanges(String authorPubkey) {
    _authorPostRows.putIfAbsent(authorPubkey, () => const []);
    unawaited(_attachStreams(authorPubkey: authorPubkey));
    return _changes.stream;
  }

  Future<void> _attachStreams({String? authorPubkey}) async {
    if (_globalRequested && _globalPostsSub == null) {
      _globalPostsSub = _metadata.client
          .from('post_feed')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .limit(200)
          .listen((rows) {
            _globalPostRows = List<Map<String, dynamic>>.from(rows);
            unawaited(_rebuildFromRows());
          });
    }

    _profileSub ??= _metadata.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .listen((_) {
          unawaited(_rebuildFromRows());
        });

    _witnessSub ??= _metadata.client
        .from('witness_feed')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(500)
        .listen((rows) {
          _witnessRows = List<Map<String, dynamic>>.from(rows);
          unawaited(_rebuildFromRows());
        });

    _blocklistSub ??= _metadata.client
        .from('blocklist')
        .stream(primaryKey: ['id'])
        .order('blocked_at', ascending: false)
        .listen((_) {
          unawaited(_rebuildFromRows());
        });

    if (authorPubkey != null && !_authorPostsSubs.containsKey(authorPubkey)) {
      final authorIds = await _metadata.resolveAuthorIds(authorPubkey);
      if (authorIds.isEmpty) {
        _authorPostRows[authorPubkey] = const [];
        await _rebuildFromRows();
      } else {
        _authorPostsSubs[authorPubkey] = _metadata.client
            .from('post_feed')
            .stream(primaryKey: ['id'])
            .inFilter('user_id', authorIds)
            .order('created_at', ascending: false)
            .limit(200)
            .listen((rows) {
              _authorPostRows[authorPubkey] = List<Map<String, dynamic>>.from(
                rows,
              );
              unawaited(_rebuildFromRows());
            });
      }
    }
  }

  // ── Query ─────────────────────────────────────────────────────────────────

  Future<CivicEvent?> getEventByTag(String hashtag) async {
    if (_cache.containsKey(hashtag)) return _cache[hashtag];

    final posts = await _metadata.fetchPosts(hashtag: hashtag, limit: 200);
    if (posts.isEmpty) return null;

    final witnesses = await _metadata.fetchWitnesses([hashtag]);
    _replaceCache(_allKnownPosts(extraPosts: posts), witnesses: witnesses);
    return _cache[hashtag];
  }

  List<CivicEvent> getAllEvents() {
    return sortEventsByLastActivity(_cache.values);
  }

  List<MediaPost> getAllPosts() {
    final byId = <String, MediaPost>{};
    for (final event in _cache.values) {
      for (final post in event.posts) {
        byId[post.id] = post;
      }
    }
    return byId.values.toList(growable: false)
      ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
  }

  List<MediaPost> getPostsForAuthor(String authorPubkey) {
    return getAllPosts()
        .where((post) => post.pubkey == authorPubkey)
        .toList(growable: false);
  }

  Future<List<MediaPost>> fetchPostsPage({DateTime? before, int limit = 20}) =>
      _metadata.fetchPosts(before: before, limit: limit);

  // ── Local mutation ────────────────────────────────────────────────────────

  void addPost(MediaPost post) {
    _optimisticPostsById[post.id] = post;
    _replaceCache(
      _allKnownPosts(extraPosts: [post]),
      witnesses: _currentWitnessesForPosts(_allKnownPosts(extraPosts: [post])),
    );
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  Future<void> reset() => refresh();

  Future<void> refresh() async {
    final next = _pendingRefresh.then((_) async {
      _cache.clear();
      _optimisticPostsById.clear();
      _globalPostRows = const [];
      _authorPostRows.updateAll((_, currentRows) => const []);
      _witnessRows = const [];
      _emitChange();
      await _restartStreams();
    });
    _pendingRefresh = next.catchError((_) {});
    await next;
  }

  Future<void> _restartStreams() async {
    await _cancelStreams();
    await _attachStreams();
    for (final authorPubkey in _authorPostRows.keys) {
      await _attachStreams(authorPubkey: authorPubkey);
    }
  }

  Future<void> dispose() async {
    await _cancelStreams();
    await _controller.close();
    await _changes.close();
  }

  Future<void> _cancelStreams() async {
    await _globalPostsSub?.cancel();
    _globalPostsSub = null;

    await _profileSub?.cancel();
    _profileSub = null;

    await _witnessSub?.cancel();
    _witnessSub = null;

    await _blocklistSub?.cancel();
    _blocklistSub = null;

    for (final sub in _authorPostsSubs.values) {
      await sub.cancel();
    }
    _authorPostsSubs.clear();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _rebuildFromRows() async {
    if (_rebuildInFlight) {
      _rebuildQueued = true;
      return;
    }

    _rebuildInFlight = true;
    try {
      do {
        _rebuildQueued = false;

        final rowsById = <String, Map<String, dynamic>>{};
        for (final row in _globalPostRows) {
          final id = row['id']?.toString();
          if (id != null) rowsById[id] = row;
        }
        for (final rows in _authorPostRows.values) {
          for (final row in rows) {
            final id = row['id']?.toString();
            if (id != null) rowsById[id] = row;
          }
        }

        final remotePosts = await _metadata.mapPostRows(
          rowsById.values
              .where((row) => row['deleted_at'] == null)
              .toList(growable: false),
        );
        final remoteIds = remotePosts.map((post) => post.id).toSet();
        _optimisticPostsById.removeWhere((id, _) => remoteIds.contains(id));

        final combinedPosts = [
          ...remotePosts,
          ..._optimisticPostsById.values.where(
            (post) => !remoteIds.contains(post.id),
          ),
        ];

        final witnesses = _currentWitnessesForPosts(combinedPosts);
        _replaceCache(combinedPosts, witnesses: witnesses);
      } while (_rebuildQueued);
    } finally {
      _rebuildInFlight = false;
    }
  }

  List<MediaPost> _allKnownPosts({Iterable<MediaPost> extraPosts = const []}) {
    final byId = {
      for (final post in _cache.values.expand((event) => event.posts))
        post.id: post,
      for (final post in _optimisticPostsById.values) post.id: post,
      for (final post in extraPosts) post.id: post,
    };
    return byId.values.toList(growable: false);
  }

  List<Witness> _currentWitnessesForPosts(List<MediaPost> posts) {
    final hashtags = posts
        .expand((post) => post.eventTags)
        .where((tag) => tag.isNotEmpty)
        .toSet();
    final rows = _witnessRows
        .where(
          (row) => hashtags.contains(row['event_hashtag']?.toString() ?? ''),
        )
        .toList(growable: false);

    if (rows.isEmpty) return const [];

    // Use a synchronous snapshot when possible; fall back to the last seen rows
    // if profile enrichment fails.
    return rows
        .map(
          (row) => Witness.fromSupabaseRow(
            row,
            fallbackUserId: row['user_id']?.toString() ?? '',
          ),
        )
        .whereType<Witness>()
        .toList(growable: false);
  }

  void _replaceCache(
    List<MediaPost> posts, {
    required List<Witness> witnesses,
  }) {
    final existingPosts = {
      for (final post in _cache.values.expand((event) => event.posts))
        post.id: post,
    };
    final nextCache = <String, CivicEvent>{};

    final sortedPosts = posts.toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

    for (final original in sortedPosts) {
      final post = existingPosts.containsKey(original.id)
          ? original.mergeLocalStateFrom(existingPosts[original.id]!)
          : original;
      final hashtag = post.eventTag ?? '_unsorted';
      final existing = nextCache[hashtag];

      if (existing == null) {
        nextCache[hashtag] = CivicEvent(
          hashtag: hashtag,
          title: '#$hashtag',
          posts: [post],
          centerLat: post.latitude,
          centerLon: post.longitude,
          firstSeen: post.capturedAt,
          participantCount: 1,
        );
        continue;
      }

      final updatedPosts = [...existing.posts, post]
        ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

      final geoTagged = updatedPosts
          .where((candidate) => candidate.hasGps)
          .toList();
      double? lat;
      double? lon;
      if (geoTagged.isNotEmpty) {
        lat =
            geoTagged
                .map((candidate) => candidate.latitude!)
                .reduce((a, b) => a + b) /
            geoTagged.length;
        lon =
            geoTagged
                .map((candidate) => candidate.longitude!)
                .reduce((a, b) => a + b) /
            geoTagged.length;
      }

      nextCache[hashtag] = existing.copyWith(
        posts: updatedPosts,
        centerLat: lat ?? existing.centerLat,
        centerLon: lon ?? existing.centerLon,
        participantCount: updatedPosts
            .map((candidate) => candidate.pubkey)
            .toSet()
            .length,
        firstSeen: updatedPosts.first.capturedAt,
      );
    }

    final witnessGroups = <String, List<Witness>>{};
    for (final witness in witnesses) {
      witnessGroups
          .putIfAbsent(witness.eventId, () => <Witness>[])
          .add(witness);
    }

    final rebuilt = <String, CivicEvent>{};
    for (final entry in nextCache.entries) {
      final event = entry.value.copyWith(
        witnesses: witnessGroups[entry.key] ?? const [],
      );
      rebuilt[entry.key] = _applyTrust(event);
    }

    _cache
      ..clear()
      ..addAll(rebuilt);

    _emitChange();

    if (_controller.isClosed) return;
    for (final event in getAllEvents()) {
      _controller.add(event);
    }
  }

  void _emitChange() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  CivicEvent _applyTrust(CivicEvent event) {
    final postCountByPubkey = <String, int>{};
    for (final candidate in _cache.values.expand((cached) => cached.posts)) {
      postCountByPubkey[candidate.pubkey] =
          (postCountByPubkey[candidate.pubkey] ?? 0) + 1;
    }
    for (final candidate in event.posts) {
      postCountByPubkey[candidate.pubkey] =
          (postCountByPubkey[candidate.pubkey] ?? 0) + 1;
    }

    final score = _trust.computeEventTrust(
      event,
      event.witnesses,
      postCountByPubkey: postCountByPubkey,
    );
    final status = _trust.statusFromScore(score, event.witnesses);
    return event.copyWith(trustScore: score, status: status);
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:mobile/models/media_post.dart';

/// Persists locally-seen posts so feed metadata survives app reloads even
/// before remote metadata sync repopulates the same events from history.
///
/// All write operations are serialised through [_pendingWrite] to prevent
/// concurrent read→merge→write cycles from overwriting each other — a race
/// condition that previously caused image-bearing posts to vanish from the
/// feed after a refresh.
class LocalPostStore {
  LocalPostStore._();

  static final LocalPostStore instance = LocalPostStore._();
  final _changes = StreamController<List<MediaPost>>.broadcast();
  Directory? _debugStorageDirectory;

  /// Serialises all mutating operations (save / replace / remove / setLiked)
  /// so that each read→merge→write cycle completes before the next begins.
  Future<void> _pendingWrite = Future<void>.value();
  int _writePauseDepth = 0;

  Stream<List<MediaPost>> get changes => _changes.stream;

  bool get _writesPaused => _writePauseDepth > 0;

  Future<List<MediaPost>> loadPosts({
    String? authorPubkey,
    bool includeFailedToSend = false,
  }) async {
    // Wait for any in-flight write to finish so we read a consistent snapshot.
    await _pendingWrite;
    final posts = await _readPosts();
    final filtered = posts.where((post) {
      if (authorPubkey != null && post.pubkey != authorPubkey) return false;
      if (!includeFailedToSend && post.isPendingRetry) return false;
      return true;
    }).toList();
    filtered.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return filtered;
  }

  Future<void> savePost(MediaPost post) async {
    await savePosts([post]);
  }

  Future<void> savePosts(Iterable<MediaPost> incoming) async {
    if (_writesPaused) return;
    await _enqueue(() async {
      if (_writesPaused) return;
      final posts = await _readPosts();
      final byId = {for (final existing in posts) existing.id: existing};
      for (final post in incoming) {
        final existing = byId[post.id];
        byId[post.id] = existing == null
            ? post
            : post.mergeLocalStateFrom(existing);
      }
      await _writePosts(byId.values);
    });
  }

  Future<void> replacePost(String oldPostId, MediaPost replacement) async {
    if (_writesPaused) return;
    await _enqueue(() async {
      if (_writesPaused) return;
      final posts = await _readPosts();
      final byId = {for (final existing in posts) existing.id: existing};
      byId.remove(oldPostId);
      final existing = byId[replacement.id];
      byId[replacement.id] = existing == null
          ? replacement
          : replacement.mergeLocalStateFrom(existing);
      await _writePosts(byId.values);
    });
  }

  Future<MediaPost> setLikedByMe(MediaPost post, bool isLikedByMe) async {
    final updated = post.copyWith(isLikedByMe: isLikedByMe);
    if (_writesPaused) return updated;
    await _enqueue(() async {
      if (_writesPaused) return;
      final posts = await _readPosts();
      final byId = {for (final existing in posts) existing.id: existing};
      byId[updated.id] = updated;
      await _writePosts(byId.values);
    });
    return updated;
  }

  Future<void> updateAuthorProfile({
    required String authorPubkey,
    String? displayName,
    String? avatarContentHash,
  }) async {
    if (_writesPaused) return;
    await _enqueue(() async {
      if (_writesPaused) return;
      final posts = await _readPosts();
      final updated = posts
          .map((post) {
            if (post.pubkey != authorPubkey) return post;
            return post.copyWith(
              authorDisplayName: displayName,
              authorAvatarContentHash: avatarContentHash,
            );
          })
          .toList(growable: false);
      await _writePosts(updated);
    });
  }

  Future<void> removePost(String postId) async {
    if (_writesPaused) return;
    await _enqueue(() async {
      if (_writesPaused) return;
      final posts = await _readPosts();
      posts.removeWhere((post) => post.id == postId);
      await _writePosts(posts);
    });
  }

  Future<void> removeMatchingPost(MediaPost target) async {
    final contentHashes = target.contentHashes.toSet();
    if (_writesPaused) return;
    await _enqueue(() async {
      if (_writesPaused) return;
      final posts = await _readPosts();
      posts.removeWhere(
        (post) =>
            post.id == target.id ||
            post.nostrEventId == target.nostrEventId ||
            post.contentHashes.any(contentHashes.contains),
      );
      await _writePosts(posts);
    });
  }

  Future<void> removePostsByAuthor(String authorPubkey) async {
    if (_writesPaused) return;
    await _enqueue(() async {
      if (_writesPaused) return;
      final posts = await _readPosts();
      posts.removeWhere((post) => post.pubkey == authorPubkey);
      await _writePosts(posts);
    });
  }

  Future<void> clearAll({bool force = false}) async {
    if (_writesPaused && !force) return;
    await _enqueue(() async {
      if (_writesPaused && !force) return;
      await _writePosts([]);
    });
  }

  Future<T> runWithWritesPaused<T>(Future<T> Function() action) async {
    _writePauseDepth++;
    try {
      await _pendingWrite;
      return await action();
    } finally {
      _writePauseDepth--;
    }
  }

  void debugSetStorageDirectory(Directory? directory) {
    _debugStorageDirectory = directory;
  }

  // ── Write queue ──────────────────────────────────────────────────────────

  /// Enqueues [work] so it runs only after the previous write completes.
  ///
  /// Errors are caught and swallowed to avoid breaking the chain — each
  /// operation is independent.
  Future<void> _enqueue(Future<void> Function() work) {
    final next = _pendingWrite.then((_) => work()).catchError((_) {});
    _pendingWrite = next;
    return next;
  }

  // ── Storage ──────────────────────────────────────────────────────────────

  Future<File> get _storeFile async {
    final dir =
        _debugStorageDirectory ?? await getApplicationDocumentsDirectory();
    return File('${dir.path}/local_posts.json');
  }

  Future<List<MediaPost>> _readPosts() async {
    try {
      final file = await _storeFile;
      if (!file.existsSync()) return [];
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return [];
      final decoded = jsonDecode(raw) as List;
      final list = <MediaPost>[];
      for (final row in decoded.whereType<Map<String, dynamic>>()) {
        try {
          list.add(MediaPost.fromJson(row));
        } catch (_) {}
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  Future<void> _writePosts(Iterable<MediaPost> posts) async {
    final sorted = posts.toList()
      ..sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    final file = await _storeFile;
    await file.writeAsString(
      jsonEncode(sorted.map((post) => post.toJson()).toList()),
    );
    if (!_changes.isClosed) {
      _changes.add(List.unmodifiable(sorted));
    }
  }
}

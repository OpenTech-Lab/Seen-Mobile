import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:mobile/core/single_flight.dart';
import 'package:mobile/core/profile_description.dart';
import 'package:mobile/core/tag_normalizer.dart';
import 'package:mobile/features/metadata/metadata_post_mapper.dart';
import 'package:mobile/models/follow_stats.dart';
import 'package:mobile/models/media_post.dart';
import 'package:mobile/models/posting_quota_status.dart';
import 'package:mobile/models/profile_model.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/models/witness_model.dart';
import 'package:mobile/services/identity_vault_service.dart';

bool isDeleteAlreadyGoneError(PostgrestException error) {
  final message = error.message.trim().toLowerCase();
  return error.code == 'P0001' && message == 'post not found for deletion';
}

Map<String, dynamic> buildSoftDeletePostParams({
  required String requestedPostId,
  required String contentHash,
}) {
  final params = <String, dynamic>{};
  final normalizedPostId = requestedPostId.trim();
  final normalizedHash = contentHash.trim();
  if (normalizedPostId.isNotEmpty) {
    params['p_requested_post_id'] = normalizedPostId;
  }
  if (normalizedHash.isNotEmpty) {
    params['p_content_hash'] = normalizedHash;
  }
  return params;
}

const _profileSelectColumns =
    'id, created_at, display_name, description, legacy_pubkey, legacy_npub, '
    'avatar_seed, avatar_content_hash, threads_public, '
    'replies_public, footprint_map_public';

String? _normalizedIdentityValue(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

bool isProfileSessionCompatibleWithWallet(
  ProfileModel? profile,
  WalletModel wallet,
) {
  if (profile == null) return false;

  final profilePubkey = _normalizedIdentityValue(profile.legacyPubkey);
  final profileDeviceId = _normalizedIdentityValue(profile.deviceId);
  if (profilePubkey == null && profileDeviceId == null) {
    return true;
  }

  if (profilePubkey != null && profilePubkey != wallet.publicKeyHex) {
    return false;
  }
  if (profileDeviceId != null && profileDeviceId != wallet.deviceId) {
    return false;
  }

  return true;
}

/// Supabase-backed metadata service for posts, events, reports, and witnesses.
///
/// The old Nostr wallet identity is still synced into `profiles.legacy_pubkey`
/// so the existing UI can keep using pubkey-shaped author identifiers while
/// metadata itself moves to Supabase.
class MetadataService {
  MetadataService._();

  static final MetadataService instance = MetadataService._();
  final SingleFlight<User?> _signInFlight = SingleFlight<User?>();
  final SingleFlight<void> _profileSyncFlight = SingleFlight<void>();

  SupabaseClient get client => Supabase.instance.client;

  Future<User?> ensureSignedIn() async {
    final current = client.auth.currentUser;
    if (current != null) return current;

    return _signInFlight.run(() async {
      final existing = client.auth.currentUser;
      if (existing != null) return existing;

      try {
        final response = await client.auth.signInAnonymously();
        return response.user;
      } on AuthException catch (error) {
        debugPrint(
          '[MetadataService] Anonymous sign-in failed: ${error.message}',
        );
        throw StateError(
          'Supabase anonymous sign-in failed. Enable Anonymous Auth and verify '
          'SUPABASE_URL/SUPABASE_ANON_KEY. ${error.message}',
        );
      }
    });
  }

  /// Activates the Supabase session associated with a local persona.
  ///
  /// The current backend still gives each anonymous persona its own
  /// `auth.uid()`. Keeping the refresh token in the encrypted local vault
  /// prevents switching back and forth on the same device from creating a
  /// fresh, disconnected anonymous profile every time.
  Future<void> activateWalletSession(WalletModel wallet) async {
    final vaultService = IdentityVaultService.instance;
    final previousIdentity = vaultService.activeIdentity;
    final currentRefreshToken = client.auth.currentSession?.refreshToken;
    if (previousIdentity != null &&
        currentRefreshToken != null &&
        previousIdentity.wallet.publicKeyHex != wallet.publicKeyHex) {
      await vaultService.saveAuthRefreshToken(
        identityId: previousIdentity.id,
        refreshToken: currentRefreshToken,
      );
    }

    final targetRefreshToken = await vaultService.authRefreshTokenFor(
      wallet.publicKeyHex,
    );
    var restoredTargetSession = false;
    if (targetRefreshToken != null && targetRefreshToken.isNotEmpty) {
      try {
        final response = await client.auth.setSession(targetRefreshToken);
        restoredTargetSession = response.user != null;
      } on AuthException catch (error) {
        debugPrint(
          '[MetadataService] Saved persona session could not be restored: '
          '${error.message}',
        );
      }
    }

    if (!restoredTargetSession &&
        previousIdentity != null &&
        previousIdentity.wallet.publicKeyHex != wallet.publicKeyHex &&
        client.auth.currentUser != null) {
      await client.auth.signOut();
    }

    await syncLegacyProfile(wallet);
  }

  Future<void> syncLegacyProfile(WalletModel wallet) async {
    return _profileSyncFlight.run(() async {
      final user = await _ensureSignedInForWallet(wallet);
      if (user == null) {
        throw StateError('Unable to create a Supabase auth session');
      }
      final existingProfile = await _fetchProfileById(user.id);
      final localIdentity = IdentityVaultService.instance.identityFor(
        wallet.publicKeyHex,
      );
      final displayName =
          existingProfile?.displayName?.trim().isNotEmpty == true
          ? existingProfile!.displayName!.trim()
          : localIdentity?.label ?? _defaultDisplayNameForWallet(wallet);
      final avatarSeed = existingProfile?.avatarSeed?.trim().isNotEmpty == true
          ? existingProfile!.avatarSeed!.trim()
          : wallet.publicKeyHex.substring(0, 12);

      debugPrint('[MetadataService] Syncing profile for ${user.id}');
      try {
        await client.from('profiles').upsert({
          'id': user.id,
          'display_name': displayName,
          'description': existingProfile?.description,
          'legacy_pubkey': wallet.publicKeyHex,
          'legacy_npub': wallet.npub,
          'avatar_seed': avatarSeed,
          'avatar_content_hash': existingProfile?.avatarContentHash,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'id');
        await _upsertPrivateDeviceId(user.id, wallet.deviceId);
        await _rememberWalletSession(wallet);
        debugPrint('[MetadataService] Profile sync complete for ${user.id}');
      } on PostgrestException catch (error, stackTrace) {
        debugPrint(
          '[MetadataService] Profile sync failed for ${user.id}: '
          'message=${error.message} code=${error.code} '
          'details=${error.details} hint=${error.hint}',
        );
        debugPrintStack(
          label: '[MetadataService] Profile sync stack for ${user.id}',
          stackTrace: stackTrace,
        );
        throw StateError(
          'Supabase profile sync failed. Check profiles table/RLS setup. '
          '${error.message}'
          '${error.details != null ? ' details=${error.details}' : ''}'
          '${error.hint != null ? ' hint=${error.hint}' : ''}',
        );
      }
    });
  }

  Future<User?> _ensureSignedInForWallet(WalletModel wallet) async {
    final current = client.auth.currentUser;
    if (current == null) {
      return ensureSignedIn();
    }

    final currentProfile = await _fetchProfileById(current.id);
    if (isProfileSessionCompatibleWithWallet(currentProfile, wallet)) {
      return current;
    }

    debugPrint(
      '[MetadataService] Discarding incompatible saved auth session for '
      'wallet ${wallet.publicKeyHex.substring(0, 8)}',
    );
    try {
      await client.auth.signOut();
    } on AuthException catch (error) {
      debugPrint(
        '[MetadataService] Failed to clear incompatible auth session: '
        '${error.message}',
      );
      throw StateError(
        'Failed to clear incompatible Supabase auth session. '
        '${error.message}',
      );
    }

    return ensureSignedIn();
  }

  Future<ProfileModel> fetchCurrentProfile(WalletModel wallet) async {
    await syncLegacyProfile(wallet);
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Missing Supabase user after profile sync');
    }
    final profile = await _fetchProfileById(user.id);
    if (profile == null) {
      throw StateError('Supabase profile row missing after sync');
    }
    return profile;
  }

  Future<ProfileModel?> fetchProfileByPubkey(String pubkey) async {
    final authorIds = await resolveAuthorIds(pubkey);
    if (authorIds.isEmpty) return null;

    final rows = List<Map<String, dynamic>>.from(
      await client
          .from('profiles')
          .select(_profileSelectColumns)
          .inFilter('id', authorIds)
          .limit(1),
    );
    if (rows.isEmpty) return null;
    return ProfileModel.fromRow(rows.first);
  }

  Future<List<ProfileModel>> searchProfiles(
    String query, {
    int limit = 20,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return const [];

    final pattern = '%${_escapeLikePattern(trimmedQuery)}%';
    final seenIds = <String>{};
    final matches = <ProfileModel>[];

    Future<void> collectMatches(
      PostgrestFilterBuilder<List<Map<String, dynamic>>> builder,
    ) async {
      if (matches.length >= limit) return;

      final rows = List<Map<String, dynamic>>.from(await builder.limit(limit));
      for (final row in rows) {
        final profile = ProfileModel.fromRow(row);
        final pubkey = profile.legacyPubkey?.trim();
        if (pubkey == null || pubkey.isEmpty || !seenIds.add(profile.id)) {
          continue;
        }
        matches.add(profile);
        if (matches.length >= limit) return;
      }
    }

    await collectMatches(
      client
          .from('profiles')
          .select(_profileSelectColumns)
          .ilike('display_name', pattern),
    );
    await collectMatches(
      client
          .from('profiles')
          .select(_profileSelectColumns)
          .ilike('description', pattern),
    );
    await collectMatches(
      client
          .from('profiles')
          .select(_profileSelectColumns)
          .ilike('legacy_pubkey', pattern),
    );

    return matches;
  }

  Future<ProfileModel> updateCurrentProfile({
    required WalletModel wallet,
    required String displayName,
    required String description,
    String? avatarContentHash,
  }) async {
    await syncLegacyProfile(wallet);
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Missing Supabase user after profile sync');
    }

    final normalizedDisplayName = displayName.trim().isNotEmpty
        ? displayName.trim()
        : _defaultDisplayNameForWallet(wallet);
    final normalizedDescription = validateProfileDescription(description);
    final existingProfile = await _fetchProfileById(user.id);

    await client.from('profiles').upsert({
      'id': user.id,
      'display_name': normalizedDisplayName,
      'description': normalizedDescription,
      'legacy_pubkey': wallet.publicKeyHex,
      'legacy_npub': wallet.npub,
      'avatar_seed': existingProfile?.avatarSeed?.trim().isNotEmpty == true
          ? existingProfile!.avatarSeed!.trim()
          : wallet.publicKeyHex.substring(0, 12),
      'avatar_content_hash':
          avatarContentHash ?? existingProfile?.avatarContentHash,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'id');
    await _upsertPrivateDeviceId(user.id, wallet.deviceId);

    final updatedProfile = await _fetchProfileById(user.id);
    if (updatedProfile == null) {
      throw StateError('Supabase profile row missing after update');
    }
    return updatedProfile;
  }

  Future<ProfileModel> updateCurrentProfileVisibility({
    required WalletModel wallet,
    bool? threadsPublic,
    bool? repliesPublic,
    bool? footprintMapPublic,
  }) async {
    await syncLegacyProfile(wallet);
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Missing Supabase user after profile sync');
    }

    final existingProfile = await _fetchProfileById(user.id);
    await client.from('profiles').upsert({
      'id': user.id,
      'legacy_pubkey': wallet.publicKeyHex,
      'legacy_npub': wallet.npub,
      'threads_public':
          threadsPublic ?? existingProfile?.areThreadsPublic ?? true,
      'replies_public':
          repliesPublic ?? existingProfile?.areRepliesPublic ?? true,
      'footprint_map_public':
          footprintMapPublic ?? existingProfile?.isFootprintMapPublic ?? false,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'id');
    await _upsertPrivateDeviceId(user.id, wallet.deviceId);

    final updatedProfile = await _fetchProfileById(user.id);
    if (updatedProfile == null) {
      throw StateError('Supabase profile row missing after visibility update');
    }
    return updatedProfile;
  }

  Future<void> deleteCurrentAccount() async {
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError(
        'Missing Supabase session for account deletion. Restart the app and try again.',
      );
    }

    await client.from('profiles').delete().eq('id', user.id);
    await client.auth.signOut();
  }

  Future<FollowStats> fetchCurrentFollowStats(WalletModel wallet) async {
    await syncLegacyProfile(wallet);
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Missing Supabase user after profile sync');
    }
    return fetchFollowStatsForProfileId(user.id);
  }

  Future<FollowStats?> fetchFollowStatsByPubkey(String pubkey) async {
    final authorIds = await resolveAuthorIds(pubkey);
    if (authorIds.isEmpty) return null;
    return fetchFollowStatsForProfileId(authorIds.first);
  }

  Future<FollowStats> fetchFollowStatsForProfileId(String profileId) async {
    try {
      final response = await client.rpc(
        'get_follow_stats',
        params: {'p_profile_id': profileId},
      );

      if (response is List && response.isNotEmpty && response.first is Map) {
        return FollowStats.fromRpcRow(
          Map<String, dynamic>.from(response.first as Map),
        );
      }
      if (response is Map) {
        return FollowStats.fromRpcRow(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('[MetadataService] Failed to fetch follow stats: $e');
    }
    return const FollowStats.empty();
  }

  Future<FollowStats> setFollowingForPubkey({
    required String targetPubkey,
    required bool shouldFollow,
    required WalletModel wallet,
  }) async {
    await syncLegacyProfile(wallet);
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Missing Supabase user after profile sync');
    }

    final authorIds = await resolveAuthorIds(targetPubkey);
    if (authorIds.isEmpty) {
      throw StateError('Target profile is unavailable for follow actions');
    }

    final targetProfileId = authorIds.first;
    if (targetProfileId == user.id) {
      return fetchFollowStatsForProfileId(targetProfileId);
    }

    if (shouldFollow) {
      await client.from('follows').upsert({
        'follower_id': user.id,
        'followed_profile_id': targetProfileId,
      }, onConflict: 'follower_id,followed_profile_id');
    } else {
      await client
          .from('follows')
          .delete()
          .eq('follower_id', user.id)
          .eq('followed_profile_id', targetProfileId);
    }

    return fetchFollowStatsForProfileId(targetProfileId);
  }

  Future<MediaPost> publishPost(MediaPost draft, WalletModel wallet) async {
    final normalizedDraft = draft.copyWith(
      eventTags: normalizeUniqueTags(draft.eventTags),
    );
    await syncLegacyProfile(wallet);

    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Missing Supabase user after profile sync');
    }

    final response = await client.rpc(
      'publish_post_with_limits',
      params: MetadataPostMapper.toPublishRpcParams(normalizedDraft),
    );
    final inserted = _singleRowFromRpcResponse(
      response,
      functionName: 'publish_post_with_limits',
    );

    final mapped = (await mapPostRows([inserted])).single;
    return mapped.copyWith(
      mediaPaths: normalizedDraft.mediaPaths,
      previewBase64: normalizedDraft.previewBase64,
      previewMimeType: normalizedDraft.previewMimeType,
      visibleLocationLabel: normalizedDraft.visibleLocationLabel,
      deliveryState: PostDeliveryState.sent,
      lastPublishError: null,
    );
  }

  Future<PostingQuotaStatus> fetchCurrentPostingQuotaStatus(
    WalletModel wallet,
  ) async {
    await syncLegacyProfile(wallet);
    final response = await client.rpc('get_posting_limit_status');
    final row = _singleRowFromRpcResponse(
      response,
      functionName: 'get_posting_limit_status',
    );
    return PostingQuotaStatus.fromRpcRow(row);
  }

  Map<String, dynamic> _singleRowFromRpcResponse(
    dynamic response, {
    required String functionName,
  }) {
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    if (response is List && response.isNotEmpty && response.first is Map) {
      return Map<String, dynamic>.from(response.first as Map);
    }
    throw StateError(
      '$functionName returned an unexpected response shape: '
      '${response.runtimeType}',
    );
  }

  Future<void> deletePost(
    String postId,
    String contentHash,
    WalletModel wallet,
  ) async {
    await syncLegacyProfile(wallet);
    try {
      await client.rpc(
        'soft_delete_post',
        params: buildSoftDeletePostParams(
          requestedPostId: postId,
          contentHash: contentHash,
        ),
      );
    } on PostgrestException catch (error) {
      if (isDeleteAlreadyGoneError(error)) {
        debugPrint('[MetadataService] Delete already applied for $postId');
        return;
      }
      rethrow;
    }
  }

  Future<void> reportContent({
    required String postId,
    required String contentHash,
    required String reason,
    required WalletModel wallet,
    String? details,
  }) async {
    await syncLegacyProfile(wallet);
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Missing Supabase user after profile sync');
    }

    await client.rpc(
      'submit_content_report',
      params: {
        'p_post_id': postId,
        'p_content_hash': contentHash,
        'p_reason': reason,
        'p_details': details,
      },
    );
  }

  Future<void> reportUser({
    required String reportedPubkey,
    required String reason,
    required WalletModel wallet,
    String? details,
  }) async {
    final normalizedPubkey = reportedPubkey.trim();
    if (normalizedPubkey.isEmpty) {
      throw StateError('Reported user pubkey is required');
    }

    await syncLegacyProfile(wallet);
    if (client.auth.currentUser == null) {
      throw StateError('Missing Supabase user after profile sync');
    }

    final authorIds = await resolveAuthorIds(normalizedPubkey);
    await client.rpc(
      'submit_user_report',
      params: {
        'p_reported_user_id': authorIds.isEmpty ? null : authorIds.first,
        'p_reported_legacy_pubkey': normalizedPubkey,
        'p_reason': reason,
        'p_details': details,
      },
    );
  }

  Future<void> publishWitness({
    required String hashtag,
    required String witnessType,
    required WalletModel wallet,
    double? lat,
    double? lon,
  }) async {
    final normalizedHashtag = normalizeTag(hashtag);
    if (normalizedHashtag.isEmpty) {
      throw StateError('Witness hashtag is required');
    }
    await syncLegacyProfile(wallet);
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Missing Supabase user after profile sync');
    }

    await client.rpc(
      'ensure_event_exists',
      params: {
        'p_hashtag': normalizedHashtag,
        'p_title': '#$normalizedHashtag',
        'p_latitude': lat,
        'p_longitude': lon,
      },
    );

    await client.rpc(
      'set_witness_signal',
      params: {
        'p_event_hashtag': normalizedHashtag,
        'p_witness_type': witnessType,
        'p_latitude': lat,
        'p_longitude': lon,
      },
    );
  }

  Future<void> publishPeerEndpoints(
    List<Uri> endpoints,
    WalletModel wallet, {
    String protocol = 'spot-p2p-http-v1',
  }) async {
    await syncLegacyProfile(wallet);
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Missing Supabase user after profile sync');
    }

    await client.from('peer_endpoints').upsert({
      'user_id': user.id,
      'device_id': wallet.deviceId,
      'protocol': protocol,
      'endpoints': endpoints.map((endpoint) => endpoint.toString()).toList(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<void> clearPeerEndpoints(WalletModel wallet) async {
    await syncLegacyProfile(wallet);
    final user = client.auth.currentUser;
    if (user == null) {
      throw StateError('Missing Supabase user after profile sync');
    }

    await client.from('peer_endpoints').upsert({
      'user_id': user.id,
      'device_id': wallet.deviceId,
      'protocol': 'spot-p2p-http-v1',
      'endpoints': <String>[],
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<List<Uri>> resolvePeerEndpoints(String authorPubkey) async {
    final authorIds = await resolveAuthorIds(authorPubkey);
    if (authorIds.isEmpty) return const [];

    final rows = List<Map<String, dynamic>>.from(
      await client
          .from('peer_endpoints')
          .select('endpoints')
          .inFilter('user_id', authorIds),
    );

    final endpoints = <Uri>[];
    for (final row in rows) {
      final rawEndpoints = row['endpoints'];
      if (rawEndpoints is! List) continue;
      for (final raw in rawEndpoints) {
        final parsed = Uri.tryParse(raw.toString());
        if (parsed != null &&
            parsed.hasScheme &&
            parsed.host.isNotEmpty &&
            !endpoints.contains(parsed)) {
          endpoints.add(parsed);
        }
      }
    }

    return endpoints;
  }

  Future<List<MediaPost>> fetchPosts({
    String? authorPubkey,
    String? hashtag,
    DateTime? before,
    int limit = 20,
  }) async {
    List<String>? authorIds;
    if (authorPubkey != null) {
      authorIds = await resolveAuthorIds(authorPubkey);
      if (authorIds.isEmpty) return const [];
    }

    var query = client.from('post_feed').select().isFilter('deleted_at', null);

    if (before != null) {
      query = query.lt('created_at', before.toUtc().toIso8601String());
    }
    if (hashtag != null && hashtag.isNotEmpty) {
      query = query.eq('event_hashtag', hashtag);
    }
    if (authorIds != null && authorIds.isNotEmpty) {
      query = query.inFilter('user_id', authorIds);
    }

    final rows = List<Map<String, dynamic>>.from(
      await query.order('created_at', ascending: false).limit(limit),
    );
    return mapPostRows(rows);
  }

  Future<List<Witness>> fetchWitnesses(Iterable<String> hashtags) async {
    final uniqueHashtags = hashtags
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
    if (uniqueHashtags.isEmpty) return const [];

    final rows = List<Map<String, dynamic>>.from(
      await client
          .from('witness_feed')
          .select()
          .inFilter('event_hashtag', uniqueHashtags)
          .order('created_at', ascending: false),
    );

    return mapWitnessRows(rows);
  }

  Future<Set<String>> fetchBlockedHashes(Iterable<String> hashes) async {
    final uniqueHashes = hashes
        .where((hash) => hash.isNotEmpty)
        .toSet()
        .toList();
    if (uniqueHashes.isEmpty) return const <String>{};

    final rows = List<Map<String, dynamic>>.from(
      await client
          .from('blocklist')
          .select('content_hash')
          .inFilter('content_hash', uniqueHashes),
    );

    return rows
        .map((row) => row['content_hash']?.toString())
        .whereType<String>()
        .toSet();
  }

  Future<List<String>> resolveAuthorIds(String authorPubkey) async {
    final value = authorPubkey.trim();
    if (value.isEmpty) return const [];

    final rows = List<Map<String, dynamic>>.from(
      await client.from('profiles').select('id').eq('legacy_pubkey', value),
    );

    final ids = rows
        .map((row) => row['id']?.toString())
        .whereType<String>()
        .toSet();
    if (ids.isNotEmpty) return ids.toList(growable: false);

    final uuidLike = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    if (uuidLike.hasMatch(value)) {
      return [value];
    }

    return const [];
  }

  Future<List<MediaPost>> mapPostRows(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return const [];

    final userIds = rows
        .map((row) => row['user_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList(growable: false);

    final profileMap = await _loadProfiles(userIds);
    final posts = rows
        .map((row) {
          final userId = row['user_id']?.toString() ?? '';
          final profile = profileMap[userId];
          final authorKey = profile?['legacy_pubkey']?.toString();
          return MetadataPostMapper.fromRow(
            row,
            authorKey: authorKey?.isNotEmpty == true ? authorKey! : userId,
            authorDisplayName: profile?['display_name']?.toString(),
            authorAvatarContentHash: profile?['avatar_content_hash']
                ?.toString(),
          );
        })
        .toList(growable: false);

    final blocked = await fetchBlockedHashes(
      posts.expand((post) => post.contentHashes),
    );

    return posts
        .where(
          (post) => post.contentHashes.every((hash) => !blocked.contains(hash)),
        )
        .toList(growable: false);
  }

  Future<List<Witness>> mapWitnessRows(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return const [];

    final userIds = rows
        .map((row) => row['user_id']?.toString())
        .whereType<String>()
        .toSet()
        .toList(growable: false);

    final profileMap = await _loadProfiles(userIds);
    final witnesses = <Witness>[];

    for (final row in rows) {
      final userId = row['user_id']?.toString() ?? '';
      final witness = Witness.fromSupabaseRow(
        row,
        fallbackUserId: userId,
        legacyPubkey: profileMap[userId]?['legacy_pubkey']?.toString(),
      );
      if (witness != null) {
        witnesses.add(witness);
      }
    }

    return witnesses;
  }

  Future<Map<String, Map<String, dynamic>>> _loadProfiles(
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return const {};

    final rows = List<Map<String, dynamic>>.from(
      await client
          .from('profiles')
          .select(
            'id, legacy_pubkey, legacy_npub, display_name, avatar_seed, '
            'avatar_content_hash',
          )
          .inFilter('id', userIds),
    );

    return {
      for (final row in rows)
        if (row['id'] != null) row['id'].toString(): row,
    };
  }

  Future<ProfileModel?> _fetchProfileById(String userId) async {
    final rows = List<Map<String, dynamic>>.from(
      await client
          .from('profiles')
          .select(_profileSelectColumns)
          .eq('id', userId)
          .limit(1),
    );
    if (rows.isEmpty) return null;
    final privateRows = List<Map<String, dynamic>>.from(
      await client
          .from('profile_private')
          .select('device_id')
          .eq('user_id', userId)
          .limit(1),
    );
    final row = Map<String, dynamic>.from(rows.first);
    if (privateRows.isNotEmpty) {
      row['device_id'] = privateRows.first['device_id'];
    }
    return ProfileModel.fromRow(row);
  }

  Future<void> _upsertPrivateDeviceId(String userId, String deviceId) async {
    await client.from('profile_private').upsert({
      'user_id': userId,
      'device_id': deviceId,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<void> _rememberWalletSession(WalletModel wallet) async {
    final refreshToken = client.auth.currentSession?.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) return;
    await IdentityVaultService.instance.saveAuthRefreshToken(
      identityId: wallet.publicKeyHex,
      refreshToken: refreshToken,
    );
  }

  String _escapeLikePattern(String value) => value
      .replaceAll(r'\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  String _defaultDisplayNameForWallet(WalletModel wallet) =>
      'citizen-${wallet.publicKeyHex.substring(0, 8)}';
}

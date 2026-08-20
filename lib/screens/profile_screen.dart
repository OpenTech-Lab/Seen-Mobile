import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mobile/core/encryption.dart';
import 'package:mobile/core/profile_description.dart';
import 'package:mobile/core/wallet.dart';
import 'package:mobile/features/event/event_repository.dart';
import 'package:mobile/features/metadata/metadata_service.dart';
import 'package:mobile/features/p2p/p2p_service.dart';
import 'package:mobile/models/follow_stats.dart';
import 'package:mobile/models/media_post.dart';
import 'package:mobile/models/profile_model.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/screens/discover_screen.dart';
import 'package:mobile/screens/post_composer_screen.dart';
import 'package:mobile/screens/settings_screen.dart';
import 'package:mobile/screens/thread_screen.dart';
import 'package:mobile/services/app_data_reset_service.dart';
import 'package:mobile/services/cache_manager.dart';
import 'package:mobile/services/cdn_media_service.dart';
import 'package:mobile/services/follow_service.dart';
import 'package:mobile/services/local_post_store.dart';
import 'package:mobile/services/media_resolver.dart';
import 'package:mobile/services/media_sync_service.dart';
import 'package:mobile/services/media_processing_service.dart';
import 'package:mobile/services/post_publish_service.dart';
import 'package:mobile/services/post_merge.dart';
import 'package:mobile/services/post_thread_ordering.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/theme/spot_theme.dart';
import 'package:mobile/widgets/footprint_map_tab.dart';
import 'package:mobile/widgets/profile_avatar.dart';
import 'package:mobile/widgets/profile_activity_summary.dart';
import 'package:mobile/widgets/profile_post_thread_row.dart';
import 'package:mobile/widgets/profile_stats_row.dart';
import 'package:mobile/widgets/profile_thread_tab_bar.dart';

/// Profile screen — shows identity summary and the user's own posts.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.wallet,
    required this.eventRepo,
  });

  final WalletModel wallet;
  final EventRepository eventRepo;

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  EventRepository get _repo => widget.eventRepo;
  StreamSubscription<void>? _repoSub;
  StreamSubscription<List<MediaPost>>? _localSub;
  StreamSubscription<void>? _followSub;
  StreamSubscription<void>? _resetSub;
  late final TabController _contentTabController;

  List<MediaPost> _posts = [];
  List<MediaPost> _remotePosts = [];
  List<MediaPost> _persistedPosts = [];
  final Set<String> _loadingMediaPostIds = {};
  bool _isLoading = true;
  String? _error;
  final Set<String> _retryingPostIds = {};
  ProfileModel? _profile;
  FollowStats _followStats = const FollowStats.empty();
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    _contentTabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
    _initFeed();
  }

  @override
  void dispose() {
    _repoSub?.cancel();
    _localSub?.cancel();
    _followSub?.cancel();
    _resetSub?.cancel();
    _contentTabController.dispose();
    super.dispose();
  }

  Future<void> _initFeed() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _localSub ??= LocalPostStore.instance.changes.listen(
        _onLocalPostsChanged,
      );
      _resetSub ??= AppDataResetService.instance.localDataCleared.listen((_) {
        unawaited(_handleLocalDataCleared());
      });
      _followSub ??= FollowService.instance.changes.listen((_) {
        unawaited(_loadFollowStats());
      });
      await _loadPersistedPosts();
      await _loadProfile();
      await _loadFollowStats();
      _repoSub ??= _repo
          .subscribeToAuthorChanges(widget.wallet.publicKeyHex)
          .listen((_) => _onRepoChanged());
      _onRepoChanged();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onRepoChanged() {
    if (!mounted) return;
    _remotePosts = _visibleRemotePosts(
      _repo.getPostsForAuthor(widget.wallet.publicKeyHex),
    );
    _syncVisiblePosts();
  }

  Future<void> _refresh() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _remotePosts = [];
      _posts = [];
    });
    try {
      await _loadPersistedPosts();
      await _repo.refresh();
      await _loadProfile();
      await _loadFollowStats();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> triggerRefresh() async {
    await _loadPersistedPosts();
    await _loadProfile();
    await _loadFollowStats();
  }

  Future<void> _loadPersistedPosts() async {
    final persisted = await LocalPostStore.instance.loadPosts(
      authorPubkey: widget.wallet.publicKeyHex,
      includeFailedToSend: true,
    );
    _persistedPosts = _visiblePersistedPosts(persisted);
    _syncVisiblePosts();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await MetadataService.instance.fetchCurrentProfile(
        widget.wallet,
      );
      if (!mounted) return;
      final normalizedDisplayName = profile.displayName?.trim();
      setState(() {
        _profile = profile;
        _posts = _posts
            .map(
              (post) => post.pubkey == widget.wallet.publicKeyHex
                  ? post.copyWith(
                      authorDisplayName:
                          normalizedDisplayName?.isNotEmpty == true
                          ? normalizedDisplayName
                          : null,
                      authorAvatarContentHash: profile.avatarContentHash,
                    )
                  : post,
            )
            .toList(growable: false);
      });
    } catch (e) {
      debugPrint('[ProfileScreen] Failed to load profile: $e');
    }
  }

  Future<void> _loadFollowStats() async {
    try {
      final stats = await MetadataService.instance.fetchCurrentFollowStats(
        widget.wallet,
      );
      if (!mounted) return;
      setState(() => _followStats = stats);
    } catch (e) {
      debugPrint('[ProfileScreen] Failed to load follow stats: $e');
    }
  }

  List<MediaPost> _visiblePersistedPosts(Iterable<MediaPost> posts) {
    return posts
        .where(
          (post) =>
              post.pubkey == widget.wallet.publicKeyHex &&
              post.contentHashes.every(
                (hash) => !CacheManager.instance.isBlocked(hash),
              ),
        )
        .toList();
  }

  List<MediaPost> _visibleRemotePosts(Iterable<MediaPost> posts) {
    return posts
        .where(
          (post) => post.contentHashes.every(
            (hash) => !CacheManager.instance.isBlocked(hash),
          ),
        )
        .toList(growable: false);
  }

  void _syncVisiblePosts() {
    if (!mounted) return;
    final rebuilt = reconcilePostsPreservingLocalState(_posts, [
      _remotePosts,
      _persistedPosts,
    ]);
    if (orderedPostsEqual(rebuilt, _posts)) return;
    setState(() => _posts = rebuilt);
  }

  void _onLocalPostsChanged(List<MediaPost> persisted) {
    _persistedPosts = _visiblePersistedPosts(persisted);
    _syncVisiblePosts();
  }

  Future<void> _handleLocalDataCleared() async {
    if (!mounted) return;
    setState(() {
      _persistedPosts = [];
      _remotePosts = [];
      _posts = [];
    });
    try {
      await _repo.refresh();
      await _loadFollowStats();
    } catch (_) {}
  }

  void _toggleLike(MediaPost post) {
    final updated = post.copyWith(isLikedByMe: !post.isLikedByMe);
    setState(() => _posts = replacePostsById(_posts, [updated]));
    unawaited(LocalPostStore.instance.setLikedByMe(post, updated.isLikedByMe));
  }

  void _updateMediaPost(MediaPost post) {
    setState(() {
      _posts = replacePostsById(_posts, [post]);
      _loadingMediaPostIds.remove(post.id);
    });
    unawaited(LocalPostStore.instance.savePost(post));
  }

  Future<void> _hydrateMediaPost(MediaPost post) async {
    if (_loadingMediaPostIds.contains(post.id)) return;
    setState(() => _loadingMediaPostIds.add(post.id));

    try {
      await P2PService.instance.startSwarm();
      final sync = MediaSyncService(fetchMedia: MediaResolver.instance.resolve);
      final hydrated = await sync.hydratePost(post);

      if (!mounted) return;
      _updateMediaPost(hydrated);
    } catch (_) {
      if (mounted) {
        setState(() => _loadingMediaPostIds.remove(post.id));
      }
    }
  }

  Future<void> _purgePostCache(MediaPost post) async {
    for (final contentHash in post.contentHashes) {
      await CacheManager.instance.purgeCached(contentHash);
    }
  }

  void _openProfileThread(BuildContext context, MediaPost post) {
    final rootPostId = post.replyToId == null
        ? post.nostrEventId
        : visibleThreadRootIdForPost(_posts, post.nostrEventId);
    Navigator.of(context).push(
      buildThreadScreenRoute(
        rootPostId: rootPostId,
        initialPosts: _posts,
        wallet: widget.wallet,
        eventRepo: _repo,
      ),
    );
  }

  Future<void> _deletePost(MediaPost post) async {
    final l10n = AppLocalizations.of(context)!;
    // Optimistic removal from UI
    setState(() {
      _posts = _posts
          .where(
            (candidate) =>
                candidate.id != post.id &&
                candidate.nostrEventId != post.nostrEventId &&
                !candidate.contentHashes.any(post.contentHashes.contains),
          )
          .toList();
    });
    await LocalPostStore.instance.removeMatchingPost(post);
    if (post.isPendingRetry) {
      await _purgePostCache(post);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.removedLocalPost)),
        );
      }
      return;
    }
    try {
      await MetadataService.instance.deletePost(
        post.nostrEventId,
        post.contentHash,
        widget.wallet,
      );
      await _purgePostCache(post);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.postDeleted)),
        );
      }
    } catch (e) {
      await LocalPostStore.instance.savePost(post);
      // Restore post on failure
      debugPrint(
        '[ProfileScreen] Failed to delete post ${post.nostrEventId}: $e',
      );
      if (mounted) {
        setState(() {
          _posts = mergePostsPreservingLocalState(_posts, [post]);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.failedDeletePost)));
      }
    }
  }

  Future<void> _retryPost(MediaPost post) async {
    final l10n = AppLocalizations.of(context)!;
    if (_retryingPostIds.contains(post.id)) return;
    setState(() => _retryingPostIds.add(post.id));
    try {
      final published = await PostPublishService.instance.publishDraft(
        draft: post,
        wallet: widget.wallet,
        eventRepo: _repo,
        replaceLocalPostId: post.id,
      );
      if (!mounted) return;
      final withoutOld = _posts.where((item) => item.id != post.id).toList();
      setState(() {
        _retryingPostIds.remove(post.id);
        _posts = mergePostsPreservingLocalState(withoutOld, [published]);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.postSent)));
    } on MissingCategoryTagError catch (e) {
      if (!mounted) return;
      setState(() => _retryingPostIds.remove(post.id));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } on PublishDeniedError catch (e) {
      final failed = await PostPublishService.instance.saveFailedPublish(
        post,
        e,
      );
      if (!mounted) return;
      setState(() {
        _retryingPostIds.remove(post.id);
        _posts = replacePostsById(_posts, [failed]);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      final failed = await PostPublishService.instance.saveFailedPublish(
        post,
        e,
      );
      if (!mounted) return;
      setState(() {
        _retryingPostIds.remove(post.id);
        _posts = replacePostsById(_posts, [failed]);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.retryFailed)),
      );
    }
  }

  Future<void> _reportPost(MediaPost post) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await MetadataService.instance.reportContent(
        postId: post.nostrEventId,
        contentHash: post.contentHash,
        reason: 'harmful',
        wallet: widget.wallet,
      );
      // Also block locally so it disappears from this user's feed
      setState(() => _posts = _posts.where((p) => p.id != post.id).toList());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.reportedContentHidden)),
        );
      }
    } catch (_) {}
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SettingsScreen(wallet: widget.wallet)),
    );
  }

  void _openDiscoverTag(BuildContext ctx, String tag) {
    Navigator.of(ctx).push(
      buildDiscoverScreenRoute(
        wallet: widget.wallet,
        initialSearchQuery: '#$tag',
      ),
    );
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(
      text: _profile?.displayName ?? '',
    );
    final descriptionController = TextEditingController(
      text: _profile?.description ?? '',
    );
    final picker = ImagePicker();
    XFile? selectedAvatar;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SpotColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SpotRadius.xl),
        ),
      ),
      builder: (sheetContext) {
        final l10n = AppLocalizations.of(sheetContext)!;
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final descriptionWordCount = countProfileDescriptionWords(
              descriptionController.text,
            );
            final isDescriptionTooLong =
                descriptionWordCount > maxProfileDescriptionWords;
            return Padding(
              padding: EdgeInsets.only(
                left: SpotSpacing.lg,
                right: SpotSpacing.lg,
                top: SpotSpacing.lg,
                bottom:
                    MediaQuery.of(sheetContext).viewInsets.bottom +
                    SpotSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.editProfileTitle, style: SpotType.subheading),
                  const SizedBox(height: SpotSpacing.lg),
                  Center(
                    child: GestureDetector(
                      onTap: _isSavingProfile
                          ? null
                          : () async {
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 88,
                                maxWidth: 1200,
                                maxHeight: 1200,
                              );
                              if (picked == null) return;
                              setSheetState(() => selectedAvatar = picked);
                            },
                      child: selectedAvatar != null
                          ? Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: FileImage(File(selectedAvatar!.path)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : ProfileAvatar(
                              pubkey: widget.wallet.publicKeyHex,
                              avatarContentHash: _profile?.avatarContentHash,
                              size: 84,
                            ),
                    ),
                  ),
                  const SizedBox(height: SpotSpacing.sm),
                  Center(
                    child: Text(
                      l10n.tapAvatarHint,
                      style: SpotType.caption,
                    ),
                  ),
                  const SizedBox(height: SpotSpacing.lg),
                  TextField(
                    controller: nameController,
                    enabled: !_isSavingProfile,
                    maxLength: 32,
                    decoration: InputDecoration(
                      labelText: l10n.usernameFieldLabel,
                      hintText: l10n.usernameFieldHint,
                    ),
                    onTapOutside: (_) =>
                        FocusScope.of(sheetContext).unfocus(),
                  ),
                  const SizedBox(height: SpotSpacing.md),
                  TextField(
                    controller: descriptionController,
                    enabled: !_isSavingProfile,
                    minLines: 3,
                    maxLines: 3,
                    onChanged: (_) => setSheetState(() {}),
                    decoration: InputDecoration(
                      labelText: l10n.descriptionFieldLabel,
                      hintText: l10n.descriptionFieldHint,
                      helperText: l10n.descriptionWordCountHelper(
                        descriptionWordCount,
                        maxProfileDescriptionWords,
                      ),
                      errorText: isDescriptionTooLong
                          ? l10n.descriptionTooLongError
                          : null,
                    ),
                    onTapOutside: (_) =>
                        FocusScope.of(sheetContext).unfocus(),
                  ),
                  const SizedBox(height: SpotSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSavingProfile || isDescriptionTooLong
                          ? null
                          : () async {
                              Navigator.of(sheetContext).pop();
                              await _saveProfile(
                                displayName: nameController.text,
                                description: descriptionController.text,
                                selectedAvatar: selectedAvatar,
                              );
                            },
                      child: Text(
                        _isSavingProfile ? l10n.savingLabel : l10n.saveProfileButton,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveProfile({
    required String displayName,
    required String description,
    XFile? selectedAvatar,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSavingProfile = true);
    try {
      String? avatarContentHash = _profile?.avatarContentHash;
      String? avatarUploadWarning;
      if (selectedAvatar != null) {
        try {
          final optimized = await MediaProcessingService.instance
              .optimizeForUpload(File(selectedAvatar.path), isVideo: false);
          final bytes = await optimized.readAsBytes();
          avatarContentHash = EncryptionUtils.sha256BytesHex(
            Uint8List.fromList(bytes),
          );

          await CacheManager.instance.addToCache(
            avatarContentHash,
            optimized.path,
          );
          await CdnMediaService.instance.ensureUploadedToCdn(
            contentHash: avatarContentHash,
            filePath: optimized.path,
            contentType: _profileImageContentType(
              optimized.path,
              mimeType: selectedAvatar.mimeType,
            ),
            signPayload: (message) async => PresignAuth(
              pubkey: widget.wallet.publicKeyHex,
              signature: WalletService.signMessage(
                message,
                widget.wallet.privateKeyHex,
              ),
            ),
          );
        } catch (error) {
          avatarContentHash = _profile?.avatarContentHash;
          avatarUploadWarning = _avatarUploadWarningMessage(error, l10n);
        }
      }

      final updatedProfile = await MetadataService.instance
          .updateCurrentProfile(
            wallet: widget.wallet,
            displayName: displayName,
            description: description,
            avatarContentHash: avatarContentHash,
          );
      final normalizedDisplayName = updatedProfile.displayName?.trim();
      final updatedPosts = _posts
          .map(
            (post) => post.pubkey == widget.wallet.publicKeyHex
                ? post.copyWith(
                    authorDisplayName: normalizedDisplayName?.isNotEmpty == true
                        ? normalizedDisplayName
                        : null,
                    authorAvatarContentHash: updatedProfile.avatarContentHash,
                  )
                : post,
          )
          .toList(growable: false);
      await LocalPostStore.instance.updateAuthorProfile(
        authorPubkey: widget.wallet.publicKeyHex,
        displayName: normalizedDisplayName?.isNotEmpty == true
            ? normalizedDisplayName
            : null,
        avatarContentHash: updatedProfile.avatarContentHash,
      );
      if (!mounted) return;
      setState(() {
        _profile = updatedProfile;
        _posts = updatedPosts;
      });
      final successMessage = avatarUploadWarning == null
          ? l10n.profileUpdated
          : l10n.profileUpdatedWithWarning(avatarUploadWarning!);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));
    } on ProfileDescriptionTooLongError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.failedUpdateProfile(e.toString()))));
    } finally {
      if (mounted) setState(() => _isSavingProfile = false);
    }
  }

  String _avatarUploadWarningMessage(Object error, AppLocalizations l10n) {
    final message = error.toString().toLowerCase();
    if (message.contains('device time appears out of sync') ||
        message.contains('timestamp too far from server time')) {
      return l10n.avatarNotUpdatedTimeSync;
    }
    return l10n.avatarNotUpdated;
  }

  String _profileImageContentType(String path, {String? mimeType}) {
    if (mimeType?.startsWith('image/') == true) return mimeType!;
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final threads = topLevelThreadPosts(_posts);
    final replies = replyPosts(_posts);
    final tabIndex = _contentTabController.index;
    final showReplies = tabIndex == 1;
    final showMap = tabIndex == 2;
    final visiblePosts = showReplies ? replies : threads;
    final emptyTitle = showReplies ? l10n.noRepliesYet : l10n.noThreadsYet;
    final emptySubtitle = showReplies
        ? l10n.repliesPostedHint
        : l10n.captureAMomentHint;
    final summaryPosts = _posts.where((post) => !post.isPendingRetry);
    final activitySummary = buildProfileActivitySummary(
      posts: summaryPosts,
      accountCreatedAt: _profile?.createdAt ?? widget.wallet.createdAt,
    );
    return Scaffold(
      backgroundColor: SpotColors.bg,
      appBar: AppBar(
        backgroundColor: SpotColors.bg,
        title: Text(l10n.profileTitle, style: SpotType.subheading),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.settings, size: 20),
            color: SpotColors.textSecondary,
            tooltip: l10n.settingsTooltip,
            onPressed: _openSettings,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: SpotColors.accent,
        backgroundColor: SpotColors.surface,
        displacement: 28,
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            // ── Profile header ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _ProfileHeader(
                wallet: widget.wallet,
                postCount: _posts.length,
                followStats: _followStats,
                profile: _profile,
                activitySummary: activitySummary,
                onEdit: _editProfile,
                isSavingProfile: _isSavingProfile,
              ),
            ),

            // ── Divider ────────────────────────────────────────────────────
            const SliverToBoxAdapter(child: Divider(height: 1, thickness: 0.5)),

            SliverToBoxAdapter(
              child: ProfileThreadTabBar(controller: _contentTabController),
            ),

            // ── Posts / Map ────────────────────────────────────────────────
            if (showMap)
              SliverLayoutBuilder(
                builder: (context, constraints) => SliverToBoxAdapter(
                  child: SizedBox(
                    height: constraints.remainingPaintExtent,
                    child: FootprintMapTab(posts: _posts),
                  ),
                ),
              )
            else if (_isLoading && visiblePosts.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: SpotColors.accent,
                      strokeWidth: 1,
                    ),
                  ),
                ),
              )
            else if (_error != null && visiblePosts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    l10n.couldNotLoadPosts,
                    style: SpotType.bodySecondary,
                  ),
                ),
              )
            else if (visiblePosts.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.camera,
                        color: SpotColors.overlay,
                        size: 32,
                      ),
                      const SizedBox(height: SpotSpacing.lg),
                      Text(
                        emptyTitle,
                        style: SpotType.bodySecondary.copyWith(
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: SpotSpacing.xs),
                      Text(emptySubtitle, style: SpotType.caption),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate((ctx, i) {
                  final post = visiblePosts[i];
                  return InkWell(
                    onTap: post.isPendingRetry
                        ? null
                        : () => _openProfileThread(ctx, post),
                    child: ProfilePostThreadRow(
                      post: post,
                      onTagTap: (tag) => _openDiscoverTag(ctx, tag),
                      isMediaLoading: _loadingMediaPostIds.contains(post.id),
                      onMediaUpdated: _hydrateMediaPost,
                      onReply: post.isPendingRetry
                          ? null
                          : () => showPostComposer(
                              ctx,
                              wallet: widget.wallet,
                              eventRepo: _repo,
                              replyToPost: post,
                            ),
                      onDelete: () => _deletePost(post),
                      onReport: () => _reportPost(post),
                      onLike: post.isPendingRetry
                          ? null
                          : () => _toggleLike(post),
                      onRetryPublish: post.isPendingRetry
                          ? () => _retryPost(post)
                          : null,
                      isRetrying: _retryingPostIds.contains(post.id),
                    ),
                  );
                }, childCount: visiblePosts.length),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Profile header ─────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.wallet,
    required this.postCount,
    required this.followStats,
    required this.profile,
    required this.activitySummary,
    required this.onEdit,
    required this.isSavingProfile,
  });

  final WalletModel wallet;
  final int postCount;
  final FollowStats followStats;
  final ProfileModel? profile;
  final ProfileActivitySummary activitySummary;
  final VoidCallback onEdit;
  final bool isSavingProfile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpotSpacing.lg,
        SpotSpacing.xl,
        SpotSpacing.lg,
        SpotSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: isSavingProfile ? null : onEdit,
                child: ProfileAvatar(
                  pubkey: wallet.publicKeyHex,
                  avatarContentHash: profile?.avatarContentHash,
                  size: 72,
                ),
              ),
              const SizedBox(width: SpotSpacing.lg),
              Expanded(
                child: ProfileStatsRow(
                  postCount: postCount,
                  followingCount: followStats.followingCount,
                  followerCount: followStats.followerCount,
                  joinedAt: activitySummary.accountCreatedAt,
                  lastThreadAt: activitySummary.lastThreadAt,
                  lastReplyAt: activitySummary.lastReplyAt,
                ),
              ),
            ],
          ),
          const SizedBox(height: SpotSpacing.md),
          Text(
            profile?.displayName?.trim().isNotEmpty == true
                ? profile!.displayName!.trim()
                : l10n.youLabel,
            style: SpotType.subheading,
          ),
          if (profile?.description?.trim().isNotEmpty == true) ...[
            const SizedBox(height: SpotSpacing.xs),
            Text(profile!.description!.trim(), style: SpotType.bodySecondary),
          ],
          const SizedBox(height: SpotSpacing.md),
          ProfileLocationChips(summary: activitySummary),
          const SizedBox(height: SpotSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isSavingProfile ? null : onEdit,
              child: Text(isSavingProfile ? l10n.savingLabel : l10n.editProfileTitle),
            ),
          ),
        ],
      ),
    );
  }
}

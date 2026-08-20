import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/core/tag_normalizer.dart';
import 'package:mobile/features/event/event_repository.dart';
import 'package:mobile/features/event/event_screen.dart';
import 'package:mobile/features/metadata/metadata_service.dart';
import 'package:mobile/features/p2p/p2p_service.dart';
import 'package:mobile/models/event_model.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/screens/discover_screen.dart';
import 'package:mobile/screens/feed_screen.dart';
import 'package:mobile/screens/post_composer_screen.dart';
import 'package:mobile/screens/profile_screen.dart';
import 'package:mobile/services/follow_service.dart';
import 'package:mobile/services/identity_vault_service.dart';
import 'package:mobile/theme/spot_theme.dart';
import 'package:mobile/widgets/tabbed_screen_chrome.dart';

/// Main app shell with bottom navigation.
List<String> orderedFavoriteEventTags({
  required Iterable<String> followedTags,
  required Iterable<CivicEvent> events,
}) {
  final latestActivityByTag = <String, DateTime>{};
  for (final event in events) {
    final normalizedTag = normalizeTag(event.hashtag);
    if (normalizedTag.isEmpty) continue;
    final latestActivity = event.lastActivityAt;
    final existingActivity = latestActivityByTag[normalizedTag];
    if (existingActivity == null || latestActivity.isAfter(existingActivity)) {
      latestActivityByTag[normalizedTag] = latestActivity;
    }
  }

  final tags = followedTags
      .map(normalizeTag)
      .where((tag) => tag.isNotEmpty)
      .toSet()
      .toList(growable: false);
  tags.sort((a, b) {
    final aActivity = latestActivityByTag[a];
    final bActivity = latestActivityByTag[b];
    if (aActivity != null && bActivity != null) {
      return bActivity.compareTo(aActivity);
    }
    if (aActivity != null) return -1;
    if (bActivity != null) return 1;
    return a.compareTo(b);
  });
  return tags;
}

CivicEvent? eventForFavoriteTag(Iterable<CivicEvent> events, String tag) {
  final normalizedTag = normalizeTag(tag);
  if (normalizedTag.isEmpty) return null;
  for (final event in events) {
    if (normalizeTag(event.hashtag) == normalizedTag) return event;
  }
  return null;
}

List<CivicEvent> eventsForFollowedTags({
  required Iterable<CivicEvent> events,
  required Iterable<String> followedTags,
}) {
  final normalizedTags = followedTags
      .map(normalizeTag)
      .where((tag) => tag.isNotEmpty)
      .toSet();
  if (normalizedTags.isEmpty) return const <CivicEvent>[];

  return events
      .where((event) => normalizedTags.contains(normalizeTag(event.hashtag)))
      .toList(growable: false);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.wallet});

  final WalletModel wallet;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;
  late final EventRepository _eventRepo;
  late WalletModel _activeWallet;
  late GlobalKey<FeedScreenState> _feedKey;
  late GlobalKey<ProfileScreenState> _profileKey;
  late List<Widget> _tabs;
  bool _isSwitchingIdentity = false;

  @override
  void initState() {
    super.initState();
    _activeWallet = widget.wallet;
    _eventRepo = EventRepository();
    _buildTabs();
    P2PService.instance.configure(wallet: _activeWallet);
    unawaited(P2PService.instance.refreshTransportAvailability());
  }

  @override
  void dispose() {
    _eventRepo.dispose();
    unawaited(P2PService.instance.shutdown());
    super.dispose();
  }

  Future<void> triggerSessionRefresh() async {
    await P2PService.instance.refreshTransportAvailability();
    await _eventRepo.refresh();
    await _profileKey.currentState?.triggerRefresh();
  }

  void _buildTabs() {
    _feedKey = GlobalKey<FeedScreenState>();
    _profileKey = GlobalKey<ProfileScreenState>();
    _tabs = [
      FeedScreen(key: _feedKey, wallet: _activeWallet, eventRepo: _eventRepo),
      DiscoverScreen(wallet: _activeWallet),
      _EventsListTab(eventRepo: _eventRepo, wallet: _activeWallet),
      ProfileScreen(
        key: _profileKey,
        wallet: _activeWallet,
        eventRepo: _eventRepo,
        onWalletChanged: (wallet) => unawaited(_switchIdentity(wallet)),
      ),
    ];
  }

  Future<void> _switchIdentity(WalletModel nextWallet) async {
    if (_isSwitchingIdentity ||
        nextWallet.publicKeyHex == _activeWallet.publicKeyHex) {
      return;
    }

    final previousWallet = _activeWallet;
    setState(() => _isSwitchingIdentity = true);
    try {
      // Stop the old persona's local peer announcement while its session is
      // still active, then restore/create the target persona's cloud session.
      await P2PService.instance.stopSwarm();
      await MetadataService.instance.activateWalletSession(nextWallet);
      await IdentityVaultService.instance.switchIdentity(
        nextWallet.publicKeyHex,
      );
      if (!mounted) return;
      setState(() {
        _activeWallet = nextWallet;
        _selectedTab = 3;
        _buildTabs();
        _isSwitchingIdentity = false;
      });
      P2PService.instance.configure(wallet: _activeWallet);
      unawaited(P2PService.instance.refreshTransportAvailability());
    } catch (error) {
      debugPrint('[HomeScreen] Identity switch failed: $error');
      P2PService.instance.configure(wallet: previousWallet);
      unawaited(P2PService.instance.refreshTransportAvailability());
      if (!mounted) return;
      setState(() => _isSwitchingIdentity = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.identitySwitchFailed(error.toString()),
          ),
        ),
      );
    }
  }

  void _openComposer() {
    showPostComposer(
      context,
      wallet: _activeWallet,
      eventRepo: _eventRepo,
      onPublished: (post) {
        if (!mounted) return;
        setState(() => _selectedTab = 0);
        _feedKey.currentState?.showPublishedPost(post);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SpotColors.bg,
      body: Stack(
        children: [
          for (int i = 0; i < _tabs.length; i++)
            IgnorePointer(
              ignoring: _selectedTab != i,
              child: AnimatedOpacity(
                opacity: _selectedTab == i ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: _tabs[i],
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _selectedTab != 0
          ? null
          : GestureDetector(
              onTap: _openComposer,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: SpotColors.bg,
                  border: Border.all(color: SpotColors.border, width: 0.5),
                ),
                child: const Icon(
                  CupertinoIcons.plus,
                  color: SpotColors.textSecondary,
                  size: 22,
                ),
              ),
            ),
      floatingActionButtonLocation: _selectedTab != 0
          ? null
          : FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomNav() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(color: SpotColors.bg),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpotSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: CupertinoIcons.house,
                selectedIcon: CupertinoIcons.house_fill,
                label: l10n.homeNavLabel,
                selected: _selectedTab == 0,
                onTap: () => setState(() => _selectedTab = 0),
                onDoubleTap: () {
                  setState(() => _selectedTab = 0);
                  _feedKey.currentState?.triggerRefresh();
                },
              ),
              _NavItem(
                icon: CupertinoIcons.compass,
                label: l10n.discoverNavLabel,
                selected: _selectedTab == 1,
                onTap: () => setState(() => _selectedTab = 1),
              ),
              _NavItem(
                icon: CupertinoIcons.folder,
                selectedIcon: CupertinoIcons.folder_fill,
                label: l10n.eventsNavLabel,
                selected: _selectedTab == 2,
                onTap: () => setState(() => _selectedTab = 2),
              ),
              _NavItem(
                icon: CupertinoIcons.person,
                selectedIcon: CupertinoIcons.person_fill,
                label: l10n.profileNavLabel,
                selected: _selectedTab == 3,
                onTap: () => setState(() => _selectedTab = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatefulWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.selectedIcon,
    this.onDoubleTap,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onDoubleTap;

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 70),
      reverseDuration: const Duration(milliseconds: 300),
      lowerBound: 0.82,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleCtrl.reverse();
  void _onTapUp(TapUpDetails _) => _scaleCtrl.fling(velocity: 1.5);
  void _onTapCancel() => _scaleCtrl.fling(velocity: 1.5);

  @override
  Widget build(BuildContext context) {
    final activeIcon = widget.selectedIcon ?? widget.icon;
    final currentIcon = widget.selected ? activeIcon : widget.icon;

    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _scaleCtrl,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpotSpacing.sm,
            vertical: SpotSpacing.xs,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(
              horizontal: SpotSpacing.lg,
              vertical: SpotSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: widget.selected
                  ? SpotColors.accent.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SizedBox(
              height: 36,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedSlide(
                    offset: widget.selected
                        ? const Offset(0, -0.28)
                        : Offset.zero,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: CurvedAnimation(
                          parent: anim,
                          curve: Curves.easeOutBack,
                        ),
                        child: child,
                      ),
                      child: Icon(
                        currentIcon,
                        key: ValueKey(currentIcon),
                        color: widget.selected
                            ? SpotColors.accent
                            : SpotColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedOpacity(
                      opacity: widget.selected ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        widget.label,
                        style: SpotType.caption.copyWith(
                          color: SpotColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Events list tab ────────────────────────────────────────────────────────────

class _EventsListTab extends StatefulWidget {
  const _EventsListTab({required this.eventRepo, required this.wallet});

  final EventRepository eventRepo;
  final WalletModel wallet;

  @override
  State<_EventsListTab> createState() => _EventsListTabState();
}

class _EventsListTabState extends State<_EventsListTab>
    with SingleTickerProviderStateMixin {
  StreamSubscription<void>? _eventsSub;
  StreamSubscription<void>? _followSub;
  late final TabController _tabController;
  bool _followReady = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _eventsSub = widget.eventRepo.subscribeToChanges().listen((_) {
      if (mounted) setState(() {});
    });
    unawaited(_initFollowState());
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    _followSub?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initFollowState() async {
    await FollowService.instance.init();
    if (!mounted) return;
    _followSub = FollowService.instance.changes.listen((_) {
      if (mounted) setState(() {});
    });
    setState(() => _followReady = true);
  }

  void _openEvent(BuildContext context, CivicEvent event) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventScreen(event: event, wallet: widget.wallet),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final events = widget.eventRepo.getAllEvents();
    final followedEvents = _followReady
        ? eventsForFollowedTags(
            events: events,
            followedTags: FollowService.instance.followedTags,
          )
        : const <CivicEvent>[];

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          SpotTabbedScreenHeader(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(l10n.eventsTabTitle, style: SpotType.subheading),
            ),
          ),
          SpotTabbedScreenTabBar(
            controller: _tabController,
            tabs: [
              Tab(text: l10n.allEventsTabLabel),
              Tab(text: l10n.followingTabLabel),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AllEventsTabContent(
                  events: events,
                  onOpenEvent: (event) => _openEvent(context, event),
                ),
                _FollowingEventsTabContent(
                  isFollowReady: _followReady,
                  followedEvents: followedEvents,
                  hasFollowedTags: _followReady
                      ? FollowService.instance.followedTags.isNotEmpty
                      : false,
                  onOpenEvent: (event) => _openEvent(context, event),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AllEventsTabContent extends StatelessWidget {
  const _AllEventsTabContent({required this.events, required this.onOpenEvent});

  final List<CivicEvent> events;
  final ValueChanged<CivicEvent> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const _EventsEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: SpotSpacing.lg,
        vertical: SpotSpacing.lg,
      ),
      itemBuilder: (context, index) => _EventRow(
        event: events[index],
        onTap: () => onOpenEvent(events[index]),
      ),
      separatorBuilder: (context, index) =>
          const SizedBox(height: SpotSpacing.xs),
      itemCount: events.length,
    );
  }
}

class _FollowingEventsTabContent extends StatelessWidget {
  const _FollowingEventsTabContent({
    required this.isFollowReady,
    required this.followedEvents,
    required this.hasFollowedTags,
    required this.onOpenEvent,
  });

  final bool isFollowReady;
  final List<CivicEvent> followedEvents;
  final bool hasFollowedTags;
  final ValueChanged<CivicEvent> onOpenEvent;

  @override
  Widget build(BuildContext context) {
    if (!isFollowReady) {
      return const Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            color: SpotColors.accent,
            strokeWidth: 1,
          ),
        ),
      );
    }

    if (followedEvents.isEmpty) {
      return _FollowingEventsEmptyState(hasFollowedTags: hasFollowedTags);
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: SpotSpacing.lg,
        vertical: SpotSpacing.lg,
      ),
      itemBuilder: (context, index) => _EventRow(
        event: followedEvents[index],
        onTap: () => onOpenEvent(followedEvents[index]),
      ),
      separatorBuilder: (context, index) =>
          const SizedBox(height: SpotSpacing.xs),
      itemCount: followedEvents.length,
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.onTap});

  final CivicEvent event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpotRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SpotSpacing.lg,
          vertical: SpotSpacing.md,
        ),
        decoration: SpotDecoration.card(radius: SpotRadius.sm),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('#${event.hashtag}', style: SpotType.body),
                  const SizedBox(height: 3),
                  Text(
                    l10n.eventPostsContributors(
                      event.posts.length,
                      event.participantCount,
                    ),
                    style: SpotType.caption,
                  ),
                  const SizedBox(height: SpotSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: _EventDateChip(
                          label: l10n.createdLabel,
                          icon: Icons.event_outlined,
                          value: formatEventListDate(event.firstSeen),
                        ),
                      ),
                      const SizedBox(width: SpotSpacing.xs),
                      Expanded(
                        child: _EventDateChip(
                          label: l10n.eventPostLabel,
                          icon: Icons.article_outlined,
                          value: formatEventListDate(event.lastPostAt),
                        ),
                      ),
                      const SizedBox(width: SpotSpacing.xs),
                      Expanded(
                        child: _EventDateChip(
                          label: l10n.eventReplyLabel,
                          icon: Icons.reply,
                          value: formatEventListDate(event.lastReplyAt),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_right,
              color: SpotColors.overlay,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

String formatEventListDate(DateTime? value, {String empty = '-'}) {
  if (value == null) return empty;
  return DateFormat('yyyy/MM/dd').format(value.toLocal());
}

class _EventDateChip extends StatelessWidget {
  const _EventDateChip({
    required this.label,
    required this.icon,
    required this.value,
  });

  final String label;
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label ${value == '-' ? 'none' : value}',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpotSpacing.xs,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: SpotColors.surfaceHigh,
            borderRadius: BorderRadius.circular(SpotRadius.full),
            border: Border.all(color: SpotColors.border, width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: SpotColors.textSecondary),
              const SizedBox(width: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: SpotType.caption.copyWith(
                      color: SpotColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventsEmptyState extends StatelessWidget {
  const _EventsEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            CupertinoIcons.folder,
            color: SpotColors.overlay,
            size: 40,
          ),
          const SizedBox(height: SpotSpacing.lg),
          Text(
            l10n.noEventsYet,
            style: SpotType.bodySecondary.copyWith(fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }
}

class _FollowingEventsEmptyState extends StatelessWidget {
  const _FollowingEventsEmptyState({required this.hasFollowedTags});

  final bool hasFollowedTags;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = hasFollowedTags
        ? l10n.noFollowedEventsLive
        : l10n.noFollowedTagsYet;
    final body = hasFollowedTags
        ? l10n.followedTagsDescription
        : l10n.followTagPrompt;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SpotSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.star,
              color: SpotColors.overlay,
              size: 36,
            ),
            const SizedBox(height: SpotSpacing.lg),
            Text(
              title,
              style: SpotType.bodySecondary.copyWith(
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SpotSpacing.xs),
            Text(
              body,
              style: SpotType.caption.copyWith(color: SpotColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

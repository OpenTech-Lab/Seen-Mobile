import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'package:mobile/core/post_location_formatter.dart';
import 'package:mobile/core/tag_normalizer.dart';
import 'package:mobile/models/media_post.dart';
import 'package:mobile/models/wallet_model.dart';
import 'package:mobile/services/cache_manager.dart';
import 'package:mobile/services/camera_service.dart';
import 'package:mobile/services/geo_lookup.dart';
import 'package:mobile/services/post_media_preparation_service.dart';
import 'package:mobile/services/post_publish_service.dart';
import 'package:mobile/theme/spot_theme.dart';

/// Full-screen camera UI.
/// Tap = photo · Hold = video · Shield = Privacy Mode
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, required this.wallet, this.replyToPost});

  final WalletModel wallet;

  /// When set, this post is being composed as a reply to [replyToPost].
  final MediaPost? replyToPost;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  bool _isInitialized = false;
  bool _isRecording = false;
  bool _isDangerMode = false;
  bool _isVirtualMode = false;
  bool _isCapturing = false;
  bool _gpsFetched = false;

  GpsLock? _gpsLock;
  String _eventTag = '';
  String? _spotName;
  // Accumulated media files — up to 4 items per post
  final List<XFile> _capturedFiles = [];
  final List<bool> _capturedIsVideos = [];

  final _tagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _fetchGps();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await CameraService.instance.initialize();
      if (_cameras.isEmpty) return;
      _controller = CameraController(
        _cameras.first,
        ResolutionPreset.medium,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _controller!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (_) {}
  }

  Future<void> _fetchGps() async {
    final lock = await CameraService.instance.lockGPS();
    if (mounted) {
      setState(() {
        _gpsLock = lock;
        _gpsFetched = true;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || _isCapturing) return;
    setState(() => _isCapturing = true);
    HapticFeedback.lightImpact();
    try {
      final gps = await CameraService.instance.lockGPS();
      if (mounted) setState(() => _gpsLock = gps);
      final xfile = await CameraService.instance.capturePhoto(_controller!);
      if (mounted) {
        setState(() {
          _capturedFiles.add(xfile);
          _capturedIsVideos.add(false);
        });
      }
    } catch (e) {
      _showError('Capture failed: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _startRecording() async {
    if (_controller == null || _isRecording) return;
    HapticFeedback.mediumImpact();
    final gps = await CameraService.instance.lockGPS();
    if (mounted) setState(() => _gpsLock = gps);
    await CameraService.instance.startRecording(_controller!);
    if (mounted) setState(() => _isRecording = true);
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;
    HapticFeedback.lightImpact();
    try {
      final xfile = await CameraService.instance.stopRecording(_controller!);
      if (mounted) {
        setState(() {
          _capturedFiles.add(xfile);
          _capturedIsVideos.add(true);
          _isRecording = false;
        });
      }
    } catch (e) {
      _showError('Recording failed: $e');
      if (mounted) setState(() => _isRecording = false);
    }
  }

  Future<void> _publishPost(String caption) async {
    if (_capturedFiles.isEmpty) return;

    MediaPost? post;

    try {
      final enteredTag = normalizeTag(_eventTag);
      final inheritedTag = normalizeTag(widget.replyToPost?.eventTag ?? '');
      final effectiveTag = enteredTag.isNotEmpty
          ? enteredTag
          : (inheritedTag.isNotEmpty ? inheritedTag : null);
      final categoryValidationMessage = validateThreadCategoryRequirement(
        replyToId: widget.replyToPost?.nostrEventId,
        eventTags: [?effectiveTag],
      );
      if (categoryValidationMessage != null) {
        _showError(categoryValidationMessage);
        return;
      }

      final preparedMedia = await PostMediaPreparationService.instance
          .prepareAssets(
            List.generate(
              _capturedFiles.length,
              (index) => PostMediaAsset(
                file: File(_capturedFiles[index].path),
                isVideo: _capturedIsVideos[index],
              ),
            ),
            blurFaces: _isDangerMode,
          );

      final primaryHash = preparedMedia.hashes.first;
      final effectiveSpotName = _spotName?.trim().isNotEmpty == true
          ? _spotName!.trim()
          : null;
      final publishedLatitude = publishedPostLatitude(
        exactLatitude: _gpsLock?.latitude,
        spotName: effectiveSpotName,
      );
      final publishedLongitude = publishedPostLongitude(
        exactLongitude: _gpsLock?.longitude,
        spotName: effectiveSpotName,
      );
      final visibleLocationLabel = visiblePublishedLocationText(
        isVirtual: _isVirtualMode,
        exactLatitude: _gpsLock?.latitude,
        exactLongitude: _gpsLock?.longitude,
        spotName: effectiveSpotName,
      );

      post = MediaPost(
        id: primaryHash,
        pubkey: widget.wallet.publicKeyHex,
        contentHashes: preparedMedia.hashes,
        mediaPaths: preparedMedia.paths,
        // Exact GPS only for Spot check-ins; coarsen by default.
        // Virtual mode: GPS is stored locally but NOT published.
        latitude: publishedLatitude,
        longitude: publishedLongitude,
        capturedAt: _gpsLock?.timestamp ?? DateTime.now().toUtc(),
        eventTags: effectiveTag != null ? [effectiveTag] : const [],
        isDangerMode: _isDangerMode,
        isVirtual: _isVirtualMode,
        previewBase64: preparedMedia.previewBase64,
        previewMimeType: preparedMedia.previewMimeType,
        caption: caption.isEmpty ? null : caption,
        replyToId: widget.replyToPost?.nostrEventId,
        nostrEventId: primaryHash,
        spotName: effectiveSpotName,
        visibleLocationLabel: visibleLocationLabel,
      );

      // Register ALL files in cache BEFORE publish so self-delivery finds them
      for (var i = 0; i < preparedMedia.hashes.length; i++) {
        await CacheManager.instance.addToCache(
          preparedMedia.hashes[i],
          preparedMedia.paths[i],
        );
      }
      await PostPublishService.instance.publishDraft(
        draft: post,
        wallet: widget.wallet,
      );
      if (mounted) {
        Navigator.of(context).pop();
      }
    } on MissingCategoryTagError catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } on PublishDeniedError catch (e) {
      if (!mounted) return;
      _showError(e.message);
    } catch (e) {
      if (post != null) {
        await PostPublishService.instance.saveFailedPublish(post, e);
      }
      if (!mounted) return;
      _showError(
        post != null
            ? 'Publish failed. Saved in Profile so you can retry.'
            : 'Publish failed before media could be prepared.',
      );
      Navigator.of(context).pop();
    }
  }

  void _discardCapture() => setState(() {
    _capturedFiles.clear();
    _capturedIsVideos.clear();
  });

  Future<void> _pickFromGallery() async {
    // Allow picking multiple files at once (up to 4 total)
    final remaining = 4 - _capturedFiles.length;
    if (remaining <= 0) {
      _showError('Maximum 4 media items per post');
      return;
    }
    final picked = await ImagePicker().pickMultipleMedia(limit: remaining);
    if (picked.isEmpty || !mounted) return;
    setState(() {
      for (final media in picked) {
        final path = media.path.toLowerCase();
        final isVideo =
            media.mimeType?.startsWith('video') == true ||
            path.endsWith('.mp4') ||
            path.endsWith('.mov') ||
            path.endsWith('.avi') ||
            path.endsWith('.mkv');
        _capturedFiles.add(media);
        _capturedIsVideos.add(isVideo);
      }
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              color: SpotColors.accent,
              strokeWidth: 1,
            ),
          ),
        ),
      );
    }

    if (_capturedFiles.isNotEmpty) {
      return _PreviewScreen(
        files: _capturedFiles,
        isVideos: _capturedIsVideos,
        isDangerMode: _isDangerMode,
        isVirtualMode: _isVirtualMode,
        gpsLock: _gpsLock,
        eventTag: normalizeTag(_eventTag).isNotEmpty
            ? normalizeTag(_eventTag)
            : widget.replyToPost?.eventTag,
        replyToPost: widget.replyToPost,
        spotName: _spotName,
        onSpotNameChanged: (v) => setState(() => _spotName = v),
        onConfirm: _publishPost,
        onDiscard: _discardCapture,
        onAddMore: _capturedFiles.length < 4 ? _pickFromGallery : null,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + SpotSpacing.sm,
            left: SpotSpacing.md,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha(120),
                ),
                child: const Icon(
                  CupertinoIcons.chevron_back,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
            ),
          ),

          // Mode banner (Privacy or Virtual)
          if (_isDangerMode || _isVirtualMode)
            Positioned(
              top: MediaQuery.of(context).padding.top + SpotSpacing.md,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SpotSpacing.md,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _isVirtualMode
                        ? SpotColors.accent.withAlpha(220)
                        : SpotColors.danger.withAlpha(220),
                    borderRadius: BorderRadius.circular(SpotRadius.xs),
                  ),
                  child: Text(
                    _isVirtualMode
                        ? 'Virtual · no location published'
                        : 'Privacy mode',
                    style: SpotType.label.copyWith(
                      color: _isVirtualMode
                          ? SpotColors.onAccent
                          : SpotColors.onDanger,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),

          // GPS lock indicator
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: SpotSpacing.lg,
            child: _GpsIndicator(gpsLock: _gpsLock, fetched: _gpsFetched),
          ),

          // Controls
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ControlsPanel(
              isDangerMode: _isDangerMode,
              isVirtualMode: _isVirtualMode,
              isRecording: _isRecording,
              tagController: _tagController,
              onDangerToggle: () => setState(() {
                _isDangerMode = !_isDangerMode;
                if (_isDangerMode) _isVirtualMode = false;
              }),
              onVirtualToggle: () => setState(() {
                _isVirtualMode = !_isVirtualMode;
                if (_isVirtualMode) _isDangerMode = false;
              }),
              onTagChanged: (v) => _eventTag = normalizeTag(v),
              onTap: _capturePhoto,
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              onGallery: _pickFromGallery,
            ),
          ),
        ],
      ),
    );
  }
}

// ── GPS indicator ──────────────────────────────────────────────────────────────

class _GpsIndicator extends StatelessWidget {
  const _GpsIndicator({this.gpsLock, required this.fetched});
  final GpsLock? gpsLock;
  final bool fetched;

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final Color iconColor;
    final String label;

    if (gpsLock != null) {
      icon = CupertinoIcons.location_fill;
      iconColor = SpotColors.success;
      label =
          '${gpsLock!.latitude.toStringAsFixed(4)}, '
          '${gpsLock!.longitude.toStringAsFixed(4)}';
    } else if (!fetched) {
      icon = CupertinoIcons.location;
      iconColor = SpotColors.warning;
      label = 'Locating…';
    } else {
      icon = CupertinoIcons.location_slash;
      iconColor = SpotColors.textTertiary;
      label = 'No GPS';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpotSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(140),
        borderRadius: BorderRadius.circular(SpotRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 12),
          const SizedBox(width: SpotSpacing.xs),
          Text(label, style: SpotType.caption.copyWith(color: Colors.white70)),
        ],
      ),
    );
  }
}

// ── Controls panel ─────────────────────────────────────────────────────────────

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    required this.isDangerMode,
    required this.isVirtualMode,
    required this.isRecording,
    required this.tagController,
    required this.onDangerToggle,
    required this.onVirtualToggle,
    required this.onTagChanged,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onGallery,
  });

  final bool isDangerMode;
  final bool isVirtualMode;
  final bool isRecording;
  final TextEditingController tagController;
  final VoidCallback onDangerToggle;
  final VoidCallback onVirtualToggle;
  final ValueChanged<String> onTagChanged;
  final VoidCallback onTap;
  final GestureLongPressStartCallback onLongPressStart;
  final GestureLongPressEndCallback onLongPressEnd;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: SpotSpacing.xl,
        right: SpotSpacing.xl,
        bottom: MediaQuery.of(context).padding.bottom + SpotSpacing.xl,
        top: SpotSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withAlpha(200), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Event tag input
          TextField(
            controller: tagController,
            onChanged: onTagChanged,
            inputFormatters: const [CanonicalTagTextInputFormatter()],
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Event tag (optional)',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              prefixText: '# ',
              prefixStyle: const TextStyle(color: Colors.white54, fontSize: 13),
              filled: true,
              fillColor: Colors.black.withAlpha(120),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SpotRadius.sm),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SpotSpacing.md,
                vertical: SpotSpacing.sm,
              ),
            ),
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          ),
          const SizedBox(height: SpotSpacing.md),

          // Mode selector pill — Standard / Virtual
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ModePill(
                label: 'STANDARD',
                icon: CupertinoIcons.location,
                active: !isVirtualMode,
                activeColor: SpotColors.success,
                onTap: isVirtualMode ? onVirtualToggle : null,
              ),
              const SizedBox(width: 2),
              _ModePill(
                label: 'VIRTUAL',
                icon: CupertinoIcons.gamecontroller,
                active: isVirtualMode,
                activeColor: SpotColors.accent,
                onTap: !isVirtualMode ? onVirtualToggle : null,
              ),
            ],
          ),

          const SizedBox(height: SpotSpacing.lg),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Danger toggle
              GestureDetector(
                onTap: onDangerToggle,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDangerMode
                        ? SpotColors.danger.withAlpha(40)
                        : Colors.transparent,
                    border: Border.all(
                      color: isDangerMode ? SpotColors.danger : Colors.white24,
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    CupertinoIcons.shield,
                    color: isDangerMode ? SpotColors.danger : Colors.white38,
                    size: 20,
                  ),
                ),
              ),

              // Capture button
              GestureDetector(
                onTap: onTap,
                onLongPressStart: onLongPressStart,
                onLongPressEnd: onLongPressEnd,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isRecording ? SpotColors.danger : Colors.white,
                    border: Border.all(color: Colors.white54, width: 2),
                  ),
                  child: Icon(
                    isRecording
                        ? CupertinoIcons.stop_fill
                        : CupertinoIcons.circle_fill,
                    color: isRecording ? Colors.white : Colors.black,
                    size: isRecording ? 28 : 32,
                  ),
                ),
              ),

              // Gallery picker
              GestureDetector(
                onTap: onGallery,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24, width: 0.5),
                  ),
                  child: const Icon(
                    CupertinoIcons.photo,
                    color: Colors.white54,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: SpotSpacing.sm),
          Text(
            isRecording ? 'Release to stop' : 'Tap · photo   Hold · video',
            style: SpotType.caption.copyWith(color: Colors.white38),
          ),
        ],
      ),
    );
  }
}

// ── Preview / publish screen ───────────────────────────────────────────────────

/// Maximum characters allowed in a caption — keeps posts visual-first.
const int _kCaptionLimit = 150;

class _PreviewScreen extends StatefulWidget {
  const _PreviewScreen({
    required this.files,
    required this.isVideos,
    required this.isDangerMode,
    required this.isVirtualMode,
    this.gpsLock,
    this.eventTag,
    this.replyToPost,
    this.spotName,
    this.onSpotNameChanged,
    required this.onConfirm,
    required this.onDiscard,
    this.onAddMore,
  });

  final List<XFile> files;
  final List<bool> isVideos;
  final bool isDangerMode;
  final bool isVirtualMode;
  final GpsLock? gpsLock;
  final String? eventTag;
  final MediaPost? replyToPost;
  final String? spotName;
  final ValueChanged<String?>? onSpotNameChanged;
  final void Function(String caption) onConfirm;
  final VoidCallback onDiscard;

  /// Null when already at 4-item limit.
  final VoidCallback? onAddMore;

  @override
  State<_PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<_PreviewScreen> {
  final _captionController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _showSpotNameDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SpotColors.surface,
        title: Text('Check in at a spot', style: SpotType.heading),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 100,
          style: SpotType.body,
          decoration: InputDecoration(
            hintText: 'e.g. Eiffel Tower, Central Park…',
            hintStyle: SpotType.body.copyWith(color: SpotColors.textTertiary),
            counterText: '',
          ),
          onSubmitted: (v) {
            final trimmed = v.trim();
            if (trimmed.isNotEmpty) {
              widget.onSpotNameChanged?.call(trimmed);
            }
            Navigator.of(ctx).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: SpotColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final trimmed = ctrl.text.trim();
              if (trimmed.isNotEmpty) {
                widget.onSpotNameChanged?.call(trimmed);
              }
              Navigator.of(ctx).pop();
            },
            child: Text('Set', style: TextStyle(color: SpotColors.accent)),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.replyToPost != null ? 'Reply' : 'Review',
          style: SpotType.subheading.copyWith(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark, size: 20),
          onPressed: widget.onDiscard,
        ),
      ),
      body: Column(
        children: [
          // ── Media area ───────────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (d) {
                if (widget.files.length <= 1) return;
                if (d.primaryVelocity! < 0 &&
                    _selectedIndex < widget.files.length - 1) {
                  setState(() => _selectedIndex++);
                } else if (d.primaryVelocity! > 0 && _selectedIndex > 0) {
                  setState(() => _selectedIndex--);
                }
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  widget.isVideos[_selectedIndex]
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                CupertinoIcons.videocam,
                                color: Colors.white38,
                                size: 48,
                              ),
                              const SizedBox(height: SpotSpacing.sm),
                              Text(
                                'Video ${_selectedIndex + 1} of ${widget.files.length}',
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Image.file(
                          File(widget.files[_selectedIndex].path),
                          fit: BoxFit.contain,
                        ),
                  // Page dots / count indicator
                  if (widget.files.length > 1)
                    Positioned(
                      bottom: SpotSpacing.sm,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(widget.files.length, (i) {
                          return Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i == _selectedIndex
                                  ? Colors.white
                                  : Colors.white38,
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Bottom panel ─────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              SpotSpacing.lg,
              SpotSpacing.md,
              SpotSpacing.lg,
              MediaQuery.of(context).padding.bottom + SpotSpacing.lg,
            ),
            color: SpotColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail strip + add-more button
                SizedBox(
                  height: 52,
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.files.length,
                          separatorBuilder: (ctx, i) =>
                              const SizedBox(width: SpotSpacing.xs),
                          itemBuilder: (ctx, i) => GestureDetector(
                            onTap: () => setState(() => _selectedIndex = i),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  SpotRadius.xs,
                                ),
                                border: Border.all(
                                  color: i == _selectedIndex
                                      ? SpotColors.accent
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  SpotRadius.xs,
                                ),
                                child: widget.isVideos[i]
                                    ? Container(
                                        color: const Color(0xFF222222),
                                        child: const Icon(
                                          CupertinoIcons.play_circle,
                                          color: Colors.white54,
                                          size: 22,
                                        ),
                                      )
                                    : Image.file(
                                        File(widget.files[i].path),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.onAddMore != null) ...[
                        const SizedBox(width: SpotSpacing.sm),
                        GestureDetector(
                          onTap: widget.onAddMore,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                SpotRadius.xs,
                              ),
                              border: Border.all(
                                color: SpotColors.border,
                                width: 0.5,
                              ),
                              color: SpotColors.bg,
                            ),
                            child: const Icon(
                              CupertinoIcons.plus,
                              color: SpotColors.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: SpotSpacing.sm),

                // Reply-to indicator
                if (widget.replyToPost != null) ...[
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.arrow_turn_up_left,
                        size: 12,
                        color: SpotColors.textTertiary,
                      ),
                      const SizedBox(width: SpotSpacing.xs),
                      Text(
                        'Replying to ${_shortPubkey(widget.replyToPost!.pubkey)}',
                        style: SpotType.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: SpotSpacing.xs),
                ],

                // Mode / GPS info
                if (widget.isVirtualMode)
                  _PreviewMetaRow(
                    icon: CupertinoIcons.gamecontroller,
                    label: 'Virtual · location not published',
                    color: SpotColors.accent,
                  )
                else ...[
                  _PreviewMetaRow(
                    icon: widget.spotName?.trim().isNotEmpty == true
                        ? CupertinoIcons.map_pin_ellipse
                        : CupertinoIcons.location,
                    label: _buildGpsLabel(
                      widget.isDangerMode,
                      widget.gpsLock,
                      spotName: widget.spotName,
                    ),
                    color: widget.spotName?.trim().isNotEmpty == true
                        ? SpotColors.accent
                        : SpotColors.success,
                  ),
                  // Spot check-in input
                  if (!widget.isVirtualMode) ...[
                    const SizedBox(height: SpotSpacing.xs),
                    GestureDetector(
                      onTap: () {
                        final hasSpot =
                            widget.spotName?.trim().isNotEmpty == true;
                        if (hasSpot) {
                          widget.onSpotNameChanged?.call(null);
                        } else {
                          _showSpotNameDialog(context);
                        }
                      },
                      child: _PreviewMetaRow(
                        icon: CupertinoIcons.map_pin,
                        label: widget.spotName?.trim().isNotEmpty == true
                            ? 'Spot: ${widget.spotName!.trim()}  ✕'
                            : 'Check in at a spot…',
                        color: widget.spotName?.trim().isNotEmpty == true
                            ? SpotColors.accent
                            : SpotColors.textTertiary,
                      ),
                    ),
                  ],
                ],
                if (widget.eventTag?.isNotEmpty == true)
                  _PreviewMetaRow(
                    icon: CupertinoIcons.tag,
                    label: '#${widget.eventTag}',
                    color: SpotColors.textSecondary,
                  ),
                const SizedBox(height: SpotSpacing.sm),

                // Caption input — capped at 150 chars
                ValueListenableBuilder(
                  valueListenable: _captionController,
                  builder: (ctx, value, child) {
                    final len = value.text.length;
                    return TextField(
                      controller: _captionController,
                      maxLines: 2,
                      minLines: 1,
                      maxLength: _kCaptionLimit,
                      style: SpotType.body,
                      decoration: InputDecoration(
                        hintText:
                            'Add a caption… (optional, max $_kCaptionLimit chars)',
                        hintStyle: SpotType.body.copyWith(
                          color: SpotColors.textTertiary,
                        ),
                        counterText: len > (_kCaptionLimit - 30)
                            ? '$len/$_kCaptionLimit'
                            : '',
                        counterStyle: SpotType.caption.copyWith(
                          color: len >= _kCaptionLimit
                              ? SpotColors.danger
                              : SpotColors.textTertiary,
                        ),
                        filled: true,
                        fillColor: SpotColors.bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SpotRadius.sm),
                          borderSide: const BorderSide(
                            color: SpotColors.border,
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SpotRadius.sm),
                          borderSide: const BorderSide(
                            color: SpotColors.border,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(SpotRadius.sm),
                          borderSide: const BorderSide(
                            color: SpotColors.accent,
                            width: 0.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SpotSpacing.md,
                          vertical: SpotSpacing.sm,
                        ),
                      ),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    );
                  },
                ),
                const SizedBox(height: SpotSpacing.md),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onDiscard,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: SpotSpacing.md,
                          ),
                        ),
                        child: const Text('Discard'),
                      ),
                    ),
                    const SizedBox(width: SpotSpacing.md),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () =>
                            widget.onConfirm(_captionController.text.trim()),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: SpotSpacing.md,
                          ),
                        ),
                        child: Text(
                          widget.files.length > 1
                              ? 'Publish ${widget.files.length} items'
                              : 'Publish',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _shortPubkey(String pubkey) {
  if (pubkey.length <= 12) return pubkey;
  return '${pubkey.substring(0, 6)}…${pubkey.substring(pubkey.length - 4)}';
}

/// Builds the GPS label shown in the preview screen metadata row.
/// Default:   "Japan/Tokyo" — city-level only (coarsened)
/// Spot:      "SpotName · Japan/Tokyo" — exact GPS
/// Danger:    "Japan/Tokyo  (faces blurred)"
String _buildGpsLabel(bool isDangerMode, GpsLock? gpsLock, {String? spotName}) {
  if (gpsLock == null) return 'No location';
  final lat = gpsLock.latitude;
  final lon = gpsLock.longitude;
  final geo = GeoLookup.instance.nearest(lat, lon);
  final place = geo != null
      ? '${geo.country}/${geo.city}'
      : '${lat.toStringAsFixed(1)}, ${lon.toStringAsFixed(1)}';

  // Spot check-in: show spot name + place
  if (spotName?.trim().isNotEmpty == true) {
    return '${spotName!.trim()}  ·  $place';
  }

  // Privacy mode: city-level privacy note
  if (isDangerMode) {
    return '$place  (Privacy mode)';
  }

  // Default: city-level only
  return place;
}

class _PreviewMetaRow extends StatelessWidget {
  const _PreviewMetaRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: SpotSpacing.sm),
          Expanded(
            child: Text(
              label,
              style: SpotType.bodySecondary.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mode pill ──────────────────────────────────────────────────────────────────

/// A selectable pill used in the REAL / VIRTUAL mode selector row.
class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;

  /// Null when already selected (no-op).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : Colors.white38;
    final bg = active ? activeColor.withAlpha(35) : Colors.transparent;
    final border = active ? activeColor.withAlpha(160) : Colors.white24;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: SpotSpacing.md,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(SpotRadius.full),
          border: Border.all(color: border, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 5),
            Text(
              label,
              style: SpotType.label.copyWith(color: color, letterSpacing: 0.8),
            ),
          ],
        ),
      ),
    );
  }
}

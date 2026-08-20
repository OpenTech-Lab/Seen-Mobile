import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mobile/core/tag_normalizer.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/services/user_prefs_service.dart';
import 'package:mobile/theme/spot_theme.dart';

/// Suggested hashtags shown during interest selection.
const _suggestedInterests = [
  'protest',
  'fire',
  'earthquake',
  'flood',
  'accident',
  'rally',
  'crime',
  'weather',
  'politics',
  'sports',
  'breaking',
  'missing',
  'disaster',
  'local',
  'environment',
];

/// Bottom-sheet modal for choosing favorite topics/interests.
///
/// Used both from the one-time Home flow and from Settings so the user can
/// revisit and update the same topic list later. The choice is persisted and
/// used by the personalized discovery/feed ranking.
class InterestsScreen extends StatefulWidget {
  const InterestsScreen({super.key, this.onDone});

  /// Called after the user confirms their selection.
  final VoidCallback? onDone;

  @override
  State<InterestsScreen> createState() => _InterestsScreenState();
}

class _InterestsScreenState extends State<InterestsScreen> {
  final Set<String> _selected = {};
  final _customController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-seed from previously saved interests (in case user re-opens)
    _selected.addAll(UserPrefsService.instance.interests);
  }

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _toggle(String tag) {
    setState(() {
      if (_selected.contains(tag)) {
        _selected.remove(tag);
      } else {
        _selected.add(tag);
      }
    });
  }

  void _addCustom() {
    final tag = normalizeTag(_customController.text);
    if (tag.isEmpty) return;
    setState(() {
      _selected.add(tag);
      _customController.clear();
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) return;
    setState(() => _isSaving = true);
    await UserPrefsService.instance.saveInterests(_selected.toList());
    if (mounted) {
      widget.onDone?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isValid = _selected.length >= 3;

    return Container(
      decoration: const BoxDecoration(
        color: SpotColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SpotRadius.xl),
        ),
      ),
      padding: EdgeInsets.only(
        left: SpotSpacing.lg,
        right: SpotSpacing.lg,
        top: SpotSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + SpotSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: SpotColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: SpotSpacing.xl),

            Text(l10n.favoriteTopicsTitle, style: SpotType.subheading),
            const SizedBox(height: SpotSpacing.xs),
            Text(
              l10n.favoriteTopicsSubtitle,
              style: SpotType.bodySecondary,
            ),
            const SizedBox(height: SpotSpacing.xl),

            // Suggested chips
            Wrap(
              spacing: SpotSpacing.sm,
              runSpacing: SpotSpacing.sm,
              children: _suggestedInterests.map((tag) {
                final active = _selected.contains(tag);
                return GestureDetector(
                  onTap: () => _toggle(tag),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: SpotSpacing.md,
                      vertical: SpotSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? SpotColors.accent.withAlpha(40)
                          : SpotColors.bg,
                      borderRadius: BorderRadius.circular(SpotRadius.full),
                      border: Border.all(
                        color: active ? SpotColors.accent : SpotColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: SpotType.bodySecondary.copyWith(
                        color: active
                            ? SpotColors.accent
                            : SpotColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: SpotSpacing.xl),

            // Custom hashtag input
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: SpotDecoration.input(),
                    child: TextField(
                      controller: _customController,
                      inputFormatters: const [CanonicalTagTextInputFormatter()],
                      style: SpotType.body,
                      decoration: InputDecoration(
                        hintText: l10n.addCustomHashtagHint,
                        prefixText: '#',
                        prefixStyle: TextStyle(color: SpotColors.textTertiary),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: SpotSpacing.lg,
                          vertical: SpotSpacing.md,
                        ),
                        border: InputBorder.none,
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addCustom(),
                      onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    ),
                  ),
                ),
                const SizedBox(width: SpotSpacing.sm),
                GestureDetector(
                  onTap: _addCustom,
                  child: Container(
                    padding: const EdgeInsets.all(SpotSpacing.md),
                    decoration: BoxDecoration(
                      color: SpotColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(SpotRadius.sm),
                    ),
                    child: const Icon(
                      CupertinoIcons.plus,
                      color: SpotColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            // Show custom-added tags not in the suggested list
            if (_selected.any((t) => !_suggestedInterests.contains(t))) ...[
              const SizedBox(height: SpotSpacing.md),
              Wrap(
                spacing: SpotSpacing.sm,
                runSpacing: SpotSpacing.sm,
                children: _selected
                    .where((t) => !_suggestedInterests.contains(t))
                    .map(
                      (tag) => GestureDetector(
                        onTap: () => _toggle(tag),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SpotSpacing.md,
                            vertical: SpotSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: SpotColors.accent.withAlpha(40),
                            borderRadius: BorderRadius.circular(
                              SpotRadius.full,
                            ),
                            border: Border.all(
                              color: SpotColors.accent,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: SpotType.bodySecondary.copyWith(
                              color: SpotColors.accent,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],

            const SizedBox(height: SpotSpacing.xxl),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isValid && !_isSaving ? _save : null,
                child: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: SpotColors.onAccent,
                        ),
                      )
                    : Text(
                        _selected.isEmpty
                            ? l10n.selectAtLeast3
                            : l10n.saveNInterests(_selected.length),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

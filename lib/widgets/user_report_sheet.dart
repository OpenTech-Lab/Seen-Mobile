import 'package:flutter/material.dart';

import 'package:mobile/core/community_safety.dart';
import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/theme/spot_theme.dart';

class UserReportSheet extends StatefulWidget {
  const UserReportSheet({
    super.key,
    required this.onSubmit,
    this.closeOnSuccess = true,
  });

  final Future<void> Function(UserReportReason reason, String? details)
  onSubmit;
  final bool closeOnSuccess;

  @override
  State<UserReportSheet> createState() => _UserReportSheetState();
}

class _UserReportSheetState extends State<UserReportSheet> {
  final TextEditingController _detailsController = TextEditingController();
  UserReportReason _selectedReason = UserReportReason.harassment;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      final details = _detailsController.text.trim();
      await widget.onSubmit(_selectedReason, details.isEmpty ? null : details);
      if (mounted && widget.closeOnSuccess) {
        Navigator.of(context).pop(true);
      } else if (mounted) {
        setState(() => _isSubmitting = false);
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorText = AppLocalizations.of(
            context,
          )!.failedError(error.toString());
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpotSpacing.lg,
          SpotSpacing.md,
          SpotSpacing.lg,
          SpotSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: SpotSpacing.lg),
                decoration: BoxDecoration(
                  color: SpotColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(l10n.reportUserTitle, style: SpotType.subheading),
            const SizedBox(height: SpotSpacing.xs),
            Text(l10n.reportUserSubtitle, style: SpotType.bodySecondary),
            const SizedBox(height: SpotSpacing.lg),
            Text(l10n.reportReasonLabel, style: SpotType.body),
            const SizedBox(height: SpotSpacing.sm),
            Wrap(
              spacing: SpotSpacing.sm,
              runSpacing: SpotSpacing.sm,
              children: UserReportReason.values
                  .map((reason) {
                    final selected = reason == _selectedReason;
                    return ChoiceChip(
                      label: Text(
                        _labelForReason(l10n, reason),
                        style: SpotType.caption.copyWith(
                          color: selected
                              ? SpotColors.onAccent
                              : SpotColors.textSecondary,
                        ),
                      ),
                      selected: selected,
                      selectedColor: SpotColors.accent,
                      onSelected: _isSubmitting
                          ? null
                          : (_) => setState(() => _selectedReason = reason),
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: SpotSpacing.lg),
            Text(l10n.reportDetailsLabel, style: SpotType.body),
            const SizedBox(height: SpotSpacing.sm),
            TextField(
              controller: _detailsController,
              minLines: 3,
              maxLines: 5,
              enabled: !_isSubmitting,
              style: SpotType.body,
              decoration: InputDecoration(
                hintText: l10n.reportUserDetailsHint,
                hintStyle: SpotType.bodySecondary.copyWith(
                  color: SpotColors.textTertiary,
                ),
                filled: true,
                fillColor: SpotColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SpotRadius.sm),
                  borderSide: BorderSide.none,
                ),
              ),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: SpotSpacing.sm),
              Text(
                _errorText!,
                style: SpotType.caption.copyWith(color: SpotColors.danger),
              ),
            ],
            const SizedBox(height: SpotSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: SpotSpacing.md),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: SpotColors.onAccent,
                          strokeWidth: 1.5,
                        ),
                      )
                    : Text(l10n.submitUserReportButton),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelForReason(AppLocalizations l10n, UserReportReason reason) {
    return switch (reason) {
      UserReportReason.harassment => l10n.reportReasonHarassment,
      UserReportReason.hate => l10n.reportReasonHate,
      UserReportReason.sexualContent => l10n.reportReasonSexualContent,
      UserReportReason.violence => l10n.reportReasonViolence,
      UserReportReason.spam => l10n.reportReasonSpam,
      UserReportReason.impersonation => l10n.reportReasonImpersonation,
      UserReportReason.other => l10n.reportReasonOther,
    };
  }
}

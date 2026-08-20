import 'package:flutter/material.dart';

import 'package:mobile/theme/spot_theme.dart';

/// A quiet, brand-led loading state. Status copy remains available to
/// assistive technologies without adding visual noise to the launch surface.
class AppLoadingView extends StatelessWidget {
  const AppLoadingView({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SpotColors.bg,
      child: Center(
        child: Semantics(
          container: true,
          liveRegion: true,
          label: [title, ?subtitle].join(' '),
          child: Image.asset(
            'assets/logo_transparent.png',
            width: 52,
            height: 52,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.radio_button_checked,
              color: SpotColors.textPrimary,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }
}

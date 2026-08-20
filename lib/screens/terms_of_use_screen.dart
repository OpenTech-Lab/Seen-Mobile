import 'package:flutter/material.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/theme/spot_theme.dart';
import 'package:mobile/widgets/policy_widgets.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SpotColors.bg,
      appBar: AppBar(
        backgroundColor: SpotColors.bg,
        title: Text(l10n.termsOfUseTitle, style: SpotType.subheading),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            SpotSpacing.xxl,
            SpotSpacing.xl,
            SpotSpacing.xxl,
            SpotSpacing.xxxl,
          ),
          child: _TermsContent(),
        ),
      ),
    );
  }
}

class _TermsContent extends StatelessWidget {
  const _TermsContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PolicyMeta(date: 'Effective: April 3, 2026'),
        SizedBox(height: SpotSpacing.xl),
        PolicySection(
          heading: '1. Acceptance of Terms',
          body:
              'By downloading, installing, or using #seen, you agree to be bound by these Terms of Use. If you do not agree to these terms, do not use the app.',
        ),
        PolicySection(
          heading: '2. User Accounts',
          body:
              'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You must not share your account with others or create accounts for the purpose of abuse.',
        ),
        PolicySection(
          heading: '3. User-Generated Content',
          body:
              'You retain ownership of content you post on #seen. By posting content, you grant #seen a non-exclusive, royalty-free license to display, distribute, and store your content within the platform. You are solely responsible for the accuracy, legality, and appropriateness of the content you create.',
        ),
        PolicySection(
          heading: '4. Prohibited Content',
          body:
              'You may not post or share any of the following:\n\n'
              '• Harassment, threats, or targeted abuse of any individual\n'
              '• Hate speech based on race, ethnicity, religion, gender, sexual orientation, disability, or national origin\n'
              '• Sexual exploitation, non-consensual intimate imagery, or content involving minors\n'
              '• Graphic violence or content designed to glorify harm\n'
              '• Spam, scams, or deceptive content\n'
              '• Impersonation of another person or entity\n'
              '• Any content that violates applicable local, national, or international law',
        ),
        PolicySection(
          heading: '5. Moderation & Enforcement',
          body:
              'We reserve the right to remove any content that violates these Terms without prior notice. Accounts found in violation may be restricted from posting or permanently suspended. Reports submitted via the in-app report tools are reviewed by our moderation team. We aim to respond to reports in a timely manner.',
        ),
        PolicySection(
          heading: '6. Peer-to-Peer Features',
          body:
              '#seen includes peer-to-peer (P2P) networking features that allow content to be transmitted directly between nearby devices. By using P2P features, you acknowledge that content may be relayed to other users on the same local network.',
        ),
        PolicySection(
          heading: '7. Location Data',
          body:
              'Certain features require access to your device\'s location. Location data is used solely to provide location-based features within the app, such as event timelines and footprint maps. You may revoke location permissions at any time via your device settings.',
        ),
        PolicySection(
          heading: '8. Disclaimer of Warranties',
          body:
              '#seen is provided "as is" and "as available" without warranties of any kind, either express or implied. We do not warrant that the app will be uninterrupted, error-free, or free of harmful components.',
        ),
        PolicySection(
          heading: '9. Limitation of Liability',
          body:
              'To the maximum extent permitted by law, #seen and its developers shall not be liable for any indirect, incidental, special, or consequential damages arising out of or related to your use of the app, including loss of data or content.',
        ),
        PolicySection(
          heading: '10. Changes to These Terms',
          body:
              'We may update these Terms of Use at any time. When we do, we will update the effective date above. Continued use of #seen after any changes constitutes your acceptance of the revised Terms.',
        ),
        PolicySection(
          heading: '11. Contact',
          body:
              'If you have any questions about these Terms of Use, please contact us:\n\nsupport@icyanstudio.net',
        ),
      ],
    );
  }
}

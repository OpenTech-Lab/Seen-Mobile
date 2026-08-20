import 'package:flutter/material.dart';

import 'package:mobile/l10n/app_localizations.dart';
import 'package:mobile/theme/spot_theme.dart';
import 'package:mobile/widgets/policy_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: SpotColors.bg,
      appBar: AppBar(
        backgroundColor: SpotColors.bg,
        title: Text(l10n.privacyPolicyTitle, style: SpotType.subheading),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            SpotSpacing.xxl,
            SpotSpacing.xl,
            SpotSpacing.xxl,
            SpotSpacing.xxxl,
          ),
          child: _PrivacyContent(),
        ),
      ),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PolicyMeta(date: 'Effective: April 3, 2026'),
        SizedBox(height: SpotSpacing.xl),
        PolicySection(
          heading: '1. Information We Collect',
          body:
              'We collect the following types of information when you use #seen:\n\n'
              '• Account data: username and profile information you provide\n'
              '• Content: photos, videos, and text you post\n'
              '• Location: device location when you grant permission, used for event timelines and the footprint map\n'
              '• Device info: device type and operating system version, used for diagnostics\n'
              '• Usage data: interactions within the app such as events viewed and posts created',
        ),
        PolicySection(
          heading: '2. How We Use Your Information',
          body:
              'We use the information we collect to:\n\n'
              '• Provide, operate, and improve the app and its features\n'
              '• Display your content to other users of the platform\n'
              '• Authenticate your identity and protect account security\n'
              '• Moderate content and enforce our community Terms of Use\n'
              '• Respond to support requests and reports',
        ),
        PolicySection(
          heading: '3. User-Generated Content',
          body:
              'Content you post on #seen (photos, videos, text, profile data) is visible to other users of the platform. You are responsible for the content you share. Deleting a post removes it from the platform; however, content previously transmitted via peer-to-peer may persist on other devices.',
        ),
        PolicySection(
          heading: '4. Peer-to-Peer Data Transmission',
          body:
              '#seen includes peer-to-peer (P2P) networking that transmits content directly between nearby devices. When P2P is active, device endpoint information (such as local IP address) may be shared with other users in proximity. You can control P2P asset transport behavior in Settings > Asset Transport.',
        ),
        PolicySection(
          heading: '5. On-Device Face Detection',
          body:
              '#seen uses on-device machine learning for face detection to assist with photo-related features. All face detection processing is performed locally on your device. No facial data is stored, transmitted to our servers, or shared with third parties.',
        ),
        PolicySection(
          heading: '6. Third-Party Services',
          body:
              '#seen uses the following third-party services which may process your data under their own privacy policies:\n\n'
              '• Supabase — cloud database and authentication (supabase.com/privacy)\n'
              '• Amazon CloudFront — media delivery network (aws.amazon.com/privacy)',
        ),
        PolicySection(
          heading: '7. Data Retention',
          body:
              'Your account data and content are retained until you delete your account. Locally cached media can be cleared at any time via Settings > Clear Cache. To request deletion of your account and associated data, contact us at support@icyanstudio.net.',
        ),
        PolicySection(
          heading: '8. Security',
          body:
              'We implement industry-standard security measures including encrypted storage of sensitive credentials on your device. However, no method of transmission over the internet or electronic storage is 100% secure, and we cannot guarantee absolute security.',
        ),
        PolicySection(
          heading: '9. Your Rights',
          body:
              'You may access, update, or delete your account and personal data at any time from within the app. For data access requests or erasure requests beyond what the app provides, contact us at support@icyanstudio.net.',
        ),
        PolicySection(
          heading: '10. Children\'s Privacy',
          body:
              '#seen is not directed to children under the age of 13. We do not knowingly collect personal information from children under 13. If we become aware that a child under 13 has provided personal information, we will delete it promptly.',
        ),
        PolicySection(
          heading: '11. Changes to This Policy',
          body:
              'We may update this Privacy Policy from time to time. When we do, we will update the effective date above. Continued use of the app after changes constitutes your acceptance of the updated policy.',
        ),
        PolicySection(
          heading: '12. Contact',
          body:
              'If you have any questions or concerns about this Privacy Policy or how your data is handled, please contact us:\n\nsupport@icyanstudio.net',
        ),
      ],
    );
  }
}

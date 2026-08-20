import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh'),
    Locale('zh', 'TW'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'#seen'**
  String get appTitle;

  /// No description provided for @cancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelAction;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @backButton.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @copiedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copiedSnackbar;

  /// No description provided for @loadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loadingLabel;

  /// No description provided for @savingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingLabel;

  /// No description provided for @updatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get updatingLabel;

  /// No description provided for @locatingLabel.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get locatingLabel;

  /// No description provided for @verifyingStatus.
  ///
  /// In en, this message translates to:
  /// **'Verifying…'**
  String get verifyingStatus;

  /// No description provided for @verifiedStatus.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedStatus;

  /// No description provided for @verificationFailedStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get verificationFailedStatus;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @clearButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearButton;

  /// No description provided for @clearAllButton.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAllButton;

  /// No description provided for @hideButton.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hideButton;

  /// No description provided for @unlockButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlockButton;

  /// No description provided for @followButton.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get followButton;

  /// No description provided for @followingLabel.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingLabel;

  /// No description provided for @followersLabel.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followersLabel;

  /// No description provided for @postsLabel.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get postsLabel;

  /// No description provided for @joinedLabel.
  ///
  /// In en, this message translates to:
  /// **'Joined'**
  String get joinedLabel;

  /// No description provided for @notSetValue.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSetValue;

  /// No description provided for @youLabel.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get youLabel;

  /// No description provided for @citizenDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get citizenDefaultName;

  /// No description provided for @altchaAttribution.
  ///
  /// In en, this message translates to:
  /// **'Protected by ALTCHA'**
  String get altchaAttribution;

  /// No description provided for @altchaVerificationFailed.
  ///
  /// In en, this message translates to:
  /// **'ALTCHA verification failed'**
  String get altchaVerificationFailed;

  /// No description provided for @reportedContentHidden.
  ///
  /// In en, this message translates to:
  /// **'Reported. Content hidden.'**
  String get reportedContentHidden;

  /// No description provided for @welcomeTagline.
  ///
  /// In en, this message translates to:
  /// **'Decentralised media.\nVerified at capture.'**
  String get welcomeTagline;

  /// No description provided for @welcomeBullet1.
  ///
  /// In en, this message translates to:
  /// **'Device-bound cryptographic identity'**
  String get welcomeBullet1;

  /// No description provided for @welcomeBullet2.
  ///
  /// In en, this message translates to:
  /// **'GPS-locked at the moment of capture'**
  String get welcomeBullet2;

  /// No description provided for @welcomeBullet3.
  ///
  /// In en, this message translates to:
  /// **'Privacy mode — blur faces in photos, hide location'**
  String get welcomeBullet3;

  /// No description provided for @welcomeBullet4.
  ///
  /// In en, this message translates to:
  /// **'Peer-to-peer, no central servers'**
  String get welcomeBullet4;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStartedButton;

  /// No description provided for @createIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Create identity'**
  String get createIdentityTitle;

  /// No description provided for @importIdentityTitle.
  ///
  /// In en, this message translates to:
  /// **'Import identity'**
  String get importIdentityTitle;

  /// No description provided for @createIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A keypair will be generated and stored securely on this device.'**
  String get createIdentitySubtitle;

  /// No description provided for @importIdentitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your 12-word recovery phrase.'**
  String get importIdentitySubtitle;

  /// No description provided for @generateIdentityButton.
  ///
  /// In en, this message translates to:
  /// **'Generate new identity'**
  String get generateIdentityButton;

  /// No description provided for @importExistingButton.
  ///
  /// In en, this message translates to:
  /// **'Import existing'**
  String get importExistingButton;

  /// No description provided for @importIdentityButton.
  ///
  /// In en, this message translates to:
  /// **'Import identity'**
  String get importIdentityButton;

  /// No description provided for @importExactWordsError.
  ///
  /// In en, this message translates to:
  /// **'Enter exactly 12 recovery words.'**
  String get importExactWordsError;

  /// No description provided for @invalidPhraseError.
  ///
  /// In en, this message translates to:
  /// **'Invalid phrase: {error}'**
  String invalidPhraseError(String error);

  /// No description provided for @failedError.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedError(String error);

  /// No description provided for @identityReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'Identity ready'**
  String get identityReadyTitle;

  /// No description provided for @yourPublicKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Your public key'**
  String get yourPublicKeyLabel;

  /// No description provided for @recoveryPhraseLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase'**
  String get recoveryPhraseLabel;

  /// No description provided for @recoveryPhraseOnboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'The only way to restore your identity if you lose this device. Write these down and keep them safe.'**
  String get recoveryPhraseOnboardingDescription;

  /// No description provided for @showRecoveryPhraseButton.
  ///
  /// In en, this message translates to:
  /// **'Show recovery phrase'**
  String get showRecoveryPhraseButton;

  /// No description provided for @showRecoveryQrButton.
  ///
  /// In en, this message translates to:
  /// **'Show recovery QR'**
  String get showRecoveryQrButton;

  /// No description provided for @recoveryQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Recovery QR'**
  String get recoveryQrTitle;

  /// No description provided for @recoveryQrDescription.
  ///
  /// In en, this message translates to:
  /// **'Scan this code on a new device to restore your identity.'**
  String get recoveryQrDescription;

  /// No description provided for @recoveryQrWarning.
  ///
  /// In en, this message translates to:
  /// **'Anyone who can scan this code can control your account. Keep it private.'**
  String get recoveryQrWarning;

  /// No description provided for @saveRecoveryQrButton.
  ///
  /// In en, this message translates to:
  /// **'Save recovery QR'**
  String get saveRecoveryQrButton;

  /// No description provided for @recoveryQrSaved.
  ///
  /// In en, this message translates to:
  /// **'Recovery QR saved to your photos.'**
  String get recoveryQrSaved;

  /// No description provided for @recoveryQrSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not save the recovery QR.'**
  String get recoveryQrSaveFailed;

  /// No description provided for @scanRecoveryQrButton.
  ///
  /// In en, this message translates to:
  /// **'Scan recovery QR'**
  String get scanRecoveryQrButton;

  /// No description provided for @recoveryQrScannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan recovery QR'**
  String get recoveryQrScannerTitle;

  /// No description provided for @recoveryQrScannerHint.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at your recovery QR code.'**
  String get recoveryQrScannerHint;

  /// No description provided for @chooseRecoveryQrImageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Choose QR image'**
  String get chooseRecoveryQrImageTooltip;

  /// No description provided for @recoveryQrNoCodeError.
  ///
  /// In en, this message translates to:
  /// **'No recovery QR code found in that image.'**
  String get recoveryQrNoCodeError;

  /// No description provided for @invalidRecoveryQrError.
  ///
  /// In en, this message translates to:
  /// **'That is not a valid #seen recovery QR.'**
  String get invalidRecoveryQrError;

  /// No description provided for @savedWordsButton.
  ///
  /// In en, this message translates to:
  /// **'I have saved these words'**
  String get savedWordsButton;

  /// No description provided for @confirmBackupFirst.
  ///
  /// In en, this message translates to:
  /// **'Confirm backup first'**
  String get confirmBackupFirst;

  /// No description provided for @securingAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Securing account'**
  String get securingAccountTitle;

  /// No description provided for @checkingOwnerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Checking how this device can verify the saved owner…'**
  String get checkingOwnerSubtitle;

  /// No description provided for @savedAccountLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved account locked'**
  String get savedAccountLockedTitle;

  /// No description provided for @accountLockedDescription.
  ///
  /// In en, this message translates to:
  /// **'Public threads stay public, but private account access on this phone stays locked until the current owner unlocks or resets it.'**
  String get accountLockedDescription;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @createdLabel.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get createdLabel;

  /// No description provided for @unlockThisAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock this account'**
  String get unlockThisAccountButton;

  /// No description provided for @unlockWithPhraseButton.
  ///
  /// In en, this message translates to:
  /// **'Unlock with recovery phrase'**
  String get unlockWithPhraseButton;

  /// No description provided for @notMyAccountButton.
  ///
  /// In en, this message translates to:
  /// **'This is not my account'**
  String get notMyAccountButton;

  /// No description provided for @unlockCancelledError.
  ///
  /// In en, this message translates to:
  /// **'Unlock was cancelled or failed. #seen will stay locked until this device owner confirms access.'**
  String get unlockCancelledError;

  /// No description provided for @failedResetAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset the saved account: {error}'**
  String failedResetAccount(String error);

  /// No description provided for @unlockWithPhraseDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock with recovery phrase'**
  String get unlockWithPhraseDialogTitle;

  /// No description provided for @unlockPhraseDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the 12-word recovery phrase for this saved account.'**
  String get unlockPhraseDescription;

  /// No description provided for @enterExactPhraseError.
  ///
  /// In en, this message translates to:
  /// **'Enter the exact 12-word recovery phrase.'**
  String get enterExactPhraseError;

  /// No description provided for @phraseMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase does not match this saved account.'**
  String get phraseMismatchError;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @termsOfUseTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUseTitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @favoriteTopicsLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorite Topics'**
  String get favoriteTopicsLabel;

  /// No description provided for @assetTransportLabel.
  ///
  /// In en, this message translates to:
  /// **'Asset Transport'**
  String get assetTransportLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageMenuMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose the language used throughout the app.'**
  String get languageMenuMessage;

  /// No description provided for @systemDefaultLanguageOption.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefaultLanguageOption;

  /// No description provided for @viewMyActivityLabel.
  ///
  /// In en, this message translates to:
  /// **'View My Activity'**
  String get viewMyActivityLabel;

  /// No description provided for @privacySectionLabel.
  ///
  /// In en, this message translates to:
  /// **'PRIVACY'**
  String get privacySectionLabel;

  /// No description provided for @footprintMapLabel.
  ///
  /// In en, this message translates to:
  /// **'Footprint Map'**
  String get footprintMapLabel;

  /// No description provided for @publicThreadsLabel.
  ///
  /// In en, this message translates to:
  /// **'Public Threads'**
  String get publicThreadsLabel;

  /// No description provided for @publicRepliesLabel.
  ///
  /// In en, this message translates to:
  /// **'Public Replies'**
  String get publicRepliesLabel;

  /// No description provided for @storageSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageSectionLabel;

  /// No description provided for @clearCacheLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCacheLabel;

  /// No description provided for @clearLocalDataLabel.
  ///
  /// In en, this message translates to:
  /// **'Clear Local Data'**
  String get clearLocalDataLabel;

  /// No description provided for @sessionSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'SESSION'**
  String get sessionSectionLabel;

  /// No description provided for @safeModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Safe Mode'**
  String get safeModeLabel;

  /// No description provided for @logOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOutLabel;

  /// No description provided for @signingOutLabel.
  ///
  /// In en, this message translates to:
  /// **'Signing out…'**
  String get signingOutLabel;

  /// No description provided for @clearCacheDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will delete all cached media files. Your posts and settings will not be affected.'**
  String get clearCacheDialogContent;

  /// No description provided for @cacheClearedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheClearedSnackbar;

  /// No description provided for @clearLocalDataDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will delete ALL local data including:\n• Cached media\n• Saved posts\n• Favorite tags and preferences\n• Blocklist\n\nYour account will NOT be deleted. Remote data will re-sync from Supabase.'**
  String get clearLocalDataDialogContent;

  /// No description provided for @localDataClearedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Local data cleared. Restart app to re-sync.'**
  String get localDataClearedSnackbar;

  /// No description provided for @logOutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log out?'**
  String get logOutDialogTitle;

  /// No description provided for @logOutDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Before logging out, make sure you have saved your 12-word recovery phrase. You will need it to restore this same identity later. Logging out will sign you out on this device and erase local app data. Your Supabase account and remote posts will remain intact.'**
  String get logOutDialogContent;

  /// No description provided for @logOutConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOutConfirmButton;

  /// No description provided for @failedLoadPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Failed to load privacy settings: {error}'**
  String failedLoadPrivacy(String error);

  /// No description provided for @failedUpdatePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Failed to update privacy settings: {error}'**
  String failedUpdatePrivacy(String error);

  /// No description provided for @failedUpdateSafeMode.
  ///
  /// In en, this message translates to:
  /// **'Failed to update safe mode: {error}'**
  String failedUpdateSafeMode(String error);

  /// No description provided for @failedUpdateLanguage.
  ///
  /// In en, this message translates to:
  /// **'Failed to update language: {error}'**
  String failedUpdateLanguage(String error);

  /// No description provided for @failedLogOut.
  ///
  /// In en, this message translates to:
  /// **'Failed to log out: {error}'**
  String failedLogOut(String error);

  /// No description provided for @publicActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'Public Activity'**
  String get publicActivityTitle;

  /// No description provided for @publicActivityMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose which of your public posts to open.'**
  String get publicActivityMessage;

  /// No description provided for @postedThreadsOption.
  ///
  /// In en, this message translates to:
  /// **'Posted Threads'**
  String get postedThreadsOption;

  /// No description provided for @repliedThreadsOption.
  ///
  /// In en, this message translates to:
  /// **'Replied Threads'**
  String get repliedThreadsOption;

  /// No description provided for @walletAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get walletAccountTitle;

  /// No description provided for @thisDeviceSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get thisDeviceSectionTitle;

  /// No description provided for @deviceSectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Profile name and avatar are edited from the Profile tab. Device signing keys stay internal to the app.'**
  String get deviceSectionDescription;

  /// No description provided for @deviceLabel.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get deviceLabel;

  /// No description provided for @postingLimitsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Posting limits'**
  String get postingLimitsSectionTitle;

  /// No description provided for @checkingDailyLimits.
  ///
  /// In en, this message translates to:
  /// **'Checking your current daily limits…'**
  String get checkingDailyLimits;

  /// No description provided for @postingLimitsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your posting limits right now.'**
  String get postingLimitsLoadError;

  /// No description provided for @recoveryPhraseWalletDescription.
  ///
  /// In en, this message translates to:
  /// **'These 12 words are the only way to restore this identity after logging out or moving to a new device.'**
  String get recoveryPhraseWalletDescription;

  /// No description provided for @copyPhraseButton.
  ///
  /// In en, this message translates to:
  /// **'Copy phrase'**
  String get copyPhraseButton;

  /// No description provided for @recoveryPhraseCopied.
  ///
  /// In en, this message translates to:
  /// **'Recovery phrase copied'**
  String get recoveryPhraseCopied;

  /// No description provided for @dangerZoneSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Danger zone'**
  String get dangerZoneSectionTitle;

  /// No description provided for @deleteAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Delete this account from Supabase and erase local app data from this device.'**
  String get deleteAccountDescription;

  /// No description provided for @deleteAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Delete this account'**
  String get deleteAccountButton;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this account?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogContent.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove your #seen profile and posts from Supabase, then erase local app data from this device. This cannot be undone.'**
  String get deleteAccountDialogContent;

  /// No description provided for @failedDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account: {error}'**
  String failedDeleteAccount(String error);

  /// No description provided for @postingBlocked.
  ///
  /// In en, this message translates to:
  /// **'Posting is currently blocked for this account.'**
  String get postingBlocked;

  /// No description provided for @postingQuotaDescription.
  ///
  /// In en, this message translates to:
  /// **'You can check your remaining thread and reply publishes here before opening the composer.'**
  String get postingQuotaDescription;

  /// No description provided for @tierLabel.
  ///
  /// In en, this message translates to:
  /// **'Tier'**
  String get tierLabel;

  /// No description provided for @threadsLabel.
  ///
  /// In en, this message translates to:
  /// **'Threads'**
  String get threadsLabel;

  /// No description provided for @repliesLabel.
  ///
  /// In en, this message translates to:
  /// **'Replies'**
  String get repliesLabel;

  /// No description provided for @usedLabel.
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get usedLabel;

  /// No description provided for @postingQuotaResetsAt.
  ///
  /// In en, this message translates to:
  /// **'Resets at {resetTime} (next UTC midnight).'**
  String postingQuotaResetsAt(String resetTime);

  /// No description provided for @postingRemainingOf.
  ///
  /// In en, this message translates to:
  /// **'{remaining} left of {total}'**
  String postingRemainingOf(int remaining, int total);

  /// No description provided for @postingUsedCount.
  ///
  /// In en, this message translates to:
  /// **'{threads} threads, {replies} replies'**
  String postingUsedCount(int threads, int replies);

  /// No description provided for @latestTabLabel.
  ///
  /// In en, this message translates to:
  /// **'LATEST'**
  String get latestTabLabel;

  /// No description provided for @followingTabLabel.
  ///
  /// In en, this message translates to:
  /// **'FOLLOWING'**
  String get followingTabLabel;

  /// No description provided for @couldNotLoadPosts.
  ///
  /// In en, this message translates to:
  /// **'Could not load posts'**
  String get couldNotLoadPosts;

  /// No description provided for @noPostsYet.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get noPostsYet;

  /// No description provided for @beFirstToRecord.
  ///
  /// In en, this message translates to:
  /// **'Be the first to record'**
  String get beFirstToRecord;

  /// No description provided for @noFollowingPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts from people you follow'**
  String get noFollowingPosts;

  /// No description provided for @tapAvatarToFollow.
  ///
  /// In en, this message translates to:
  /// **'Tap an avatar to follow someone'**
  String get tapAvatarToFollow;

  /// No description provided for @homeNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeNavLabel;

  /// No description provided for @discoverNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverNavLabel;

  /// No description provided for @eventsNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsNavLabel;

  /// No description provided for @profileNavLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileNavLabel;

  /// No description provided for @eventsTabTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get eventsTabTitle;

  /// No description provided for @allEventsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get allEventsTabLabel;

  /// No description provided for @noEventsYet.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEventsYet;

  /// No description provided for @noFollowedEventsLive.
  ///
  /// In en, this message translates to:
  /// **'No followed events live'**
  String get noFollowedEventsLive;

  /// No description provided for @noFollowedTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No followed tags yet'**
  String get noFollowedTagsYet;

  /// No description provided for @followedTagsDescription.
  ///
  /// In en, this message translates to:
  /// **'Followed tags will show up here when matching live events appear.'**
  String get followedTagsDescription;

  /// No description provided for @followTagPrompt.
  ///
  /// In en, this message translates to:
  /// **'Follow a tag from Discover or an event detail screen to see it here.'**
  String get followTagPrompt;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @usernameFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameFieldLabel;

  /// No description provided for @usernameFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Citizen name'**
  String get usernameFieldHint;

  /// No description provided for @descriptionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionFieldLabel;

  /// No description provided for @descriptionFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Simple description about you'**
  String get descriptionFieldHint;

  /// No description provided for @tapAvatarHint.
  ///
  /// In en, this message translates to:
  /// **'Tap avatar to choose a new image'**
  String get tapAvatarHint;

  /// No description provided for @saveProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfileButton;

  /// No description provided for @descriptionTooLongError.
  ///
  /// In en, this message translates to:
  /// **'Use 100 words or fewer'**
  String get descriptionTooLongError;

  /// No description provided for @captureAMomentHint.
  ///
  /// In en, this message translates to:
  /// **'Capture a moment to see it here'**
  String get captureAMomentHint;

  /// No description provided for @repliesPostedHint.
  ///
  /// In en, this message translates to:
  /// **'Replies you posted will appear here'**
  String get repliesPostedHint;

  /// No description provided for @noThreadsYet.
  ///
  /// In en, this message translates to:
  /// **'No threads yet'**
  String get noThreadsYet;

  /// No description provided for @noRepliesYet.
  ///
  /// In en, this message translates to:
  /// **'No replies yet'**
  String get noRepliesYet;

  /// No description provided for @removedLocalPost.
  ///
  /// In en, this message translates to:
  /// **'Removed local unsent post'**
  String get removedLocalPost;

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted. Swarm participants will be notified to remove local copies.'**
  String get postDeleted;

  /// No description provided for @failedDeletePost.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete post'**
  String get failedDeletePost;

  /// No description provided for @postSent.
  ///
  /// In en, this message translates to:
  /// **'Post sent'**
  String get postSent;

  /// No description provided for @retryFailed.
  ///
  /// In en, this message translates to:
  /// **'Retry failed. The post is still saved locally.'**
  String get retryFailed;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @profileUpdatedWithWarning.
  ///
  /// In en, this message translates to:
  /// **'Profile updated. {warning}'**
  String profileUpdatedWithWarning(String warning);

  /// No description provided for @failedUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String failedUpdateProfile(String error);

  /// No description provided for @avatarNotUpdated.
  ///
  /// In en, this message translates to:
  /// **'Avatar not updated. Please try again.'**
  String get avatarNotUpdated;

  /// No description provided for @avatarNotUpdatedTimeSync.
  ///
  /// In en, this message translates to:
  /// **'Avatar not updated. Turn on automatic date & time and try again.'**
  String get avatarNotUpdatedTimeSync;

  /// No description provided for @takePhotoOption.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhotoOption;

  /// No description provided for @recordVideoOption.
  ///
  /// In en, this message translates to:
  /// **'Record Video'**
  String get recordVideoOption;

  /// No description provided for @maxMediaItemsWarning.
  ///
  /// In en, this message translates to:
  /// **'Maximum 4 media items per post'**
  String get maxMediaItemsWarning;

  /// No description provided for @categoryTagHint.
  ///
  /// In en, this message translates to:
  /// **'Category tag (e.g. AWSSummitTokyo2026)'**
  String get categoryTagHint;

  /// No description provided for @addMoreTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Add more tags…'**
  String get addMoreTagsHint;

  /// No description provided for @createCategoryTagTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create category tag'**
  String get createCategoryTagTooltip;

  /// No description provided for @createTagTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create tag'**
  String get createTagTooltip;

  /// No description provided for @postModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Post mode'**
  String get postModeLabel;

  /// No description provided for @standardModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get standardModeLabel;

  /// No description provided for @virtualModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Virtual'**
  String get virtualModeLabel;

  /// No description provided for @checkInLabel.
  ///
  /// In en, this message translates to:
  /// **'Check in at a spot'**
  String get checkInLabel;

  /// No description provided for @checkInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Publish exact location with a place name'**
  String get checkInSubtitle;

  /// No description provided for @blurFacesLabel.
  ///
  /// In en, this message translates to:
  /// **'Blur faces'**
  String get blurFacesLabel;

  /// No description provided for @blurFacesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically blur detected faces in photos'**
  String get blurFacesSubtitle;

  /// No description provided for @aiGeneratedLabel.
  ///
  /// In en, this message translates to:
  /// **'AI-generated content'**
  String get aiGeneratedLabel;

  /// No description provided for @aiGeneratedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Content was created or assisted by AI'**
  String get aiGeneratedSubtitle;

  /// No description provided for @secondhandLabel.
  ///
  /// In en, this message translates to:
  /// **'Someone else\'s story'**
  String get secondhandLabel;

  /// No description provided for @secondhandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You are sharing a secondhand account'**
  String get secondhandSubtitle;

  /// No description provided for @publishFailedSaved.
  ///
  /// In en, this message translates to:
  /// **'Publish failed. Saved in Profile so you can retry.'**
  String get publishFailedSaved;

  /// No description provided for @publishFailedError.
  ///
  /// In en, this message translates to:
  /// **'Publish failed: {error}'**
  String publishFailedError(String error);

  /// No description provided for @publishButton.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishButton;

  /// No description provided for @confirmAndPostButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Post'**
  String get confirmAndPostButton;

  /// No description provided for @beforePostTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you post'**
  String get beforePostTitle;

  /// No description provided for @yesLabel.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesLabel;

  /// No description provided for @noLabel.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noLabel;

  /// No description provided for @rightsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I have the rights to share this content'**
  String get rightsConfirmation;

  /// No description provided for @defamationConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This content does not defame any individuals or groups'**
  String get defamationConfirmation;

  /// No description provided for @lawsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'I confirm this complies with applicable laws in my jurisdiction'**
  String get lawsConfirmation;

  /// No description provided for @captionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a caption… (optional, max {limit} chars)'**
  String captionHint(int limit);

  /// No description provided for @addCategoryTagWarning.
  ///
  /// In en, this message translates to:
  /// **'Add a category tag before posting a new thread.'**
  String get addCategoryTagWarning;

  /// No description provided for @tagFieldHint.
  ///
  /// In en, this message translates to:
  /// **'First tag is the event category · press Space or , to add more'**
  String get tagFieldHint;

  /// No description provided for @checkInSpotHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Eiffel Tower, Central Park…'**
  String get checkInSpotHint;

  /// No description provided for @checkInSpotPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Check in at a spot…'**
  String get checkInSpotPlaceholder;

  /// No description provided for @publishNItems.
  ///
  /// In en, this message translates to:
  /// **'Publish {count} items'**
  String publishNItems(int count);

  /// No description provided for @discoverSearchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search threads or #tags'**
  String get discoverSearchPlaceholder;

  /// No description provided for @discoverTitle.
  ///
  /// In en, this message translates to:
  /// **'Discover'**
  String get discoverTitle;

  /// No description provided for @removeFavoriteLabel.
  ///
  /// In en, this message translates to:
  /// **'Remove Favorite'**
  String get removeFavoriteLabel;

  /// No description provided for @addFavoriteLabel.
  ///
  /// In en, this message translates to:
  /// **'Add as Favorite'**
  String get addFavoriteLabel;

  /// No description provided for @trendingTabLabel.
  ///
  /// In en, this message translates to:
  /// **'TRENDING'**
  String get trendingTabLabel;

  /// No description provided for @forYouTabLabel.
  ///
  /// In en, this message translates to:
  /// **'FOR YOU'**
  String get forYouTabLabel;

  /// No description provided for @nearbyTabLabel.
  ///
  /// In en, this message translates to:
  /// **'NEARBY'**
  String get nearbyTabLabel;

  /// No description provided for @usersTabLabel.
  ///
  /// In en, this message translates to:
  /// **'USERS'**
  String get usersTabLabel;

  /// No description provided for @noThreadsFound.
  ///
  /// In en, this message translates to:
  /// **'No threads found for \"{search}\"'**
  String noThreadsFound(String search);

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found for \"{search}\"'**
  String noUsersFound(String search);

  /// No description provided for @nothingTrending.
  ///
  /// In en, this message translates to:
  /// **'Nothing trending in the last 48 h'**
  String get nothingTrending;

  /// No description provided for @noRecommendedPosts.
  ///
  /// In en, this message translates to:
  /// **'No recommended posts yet'**
  String get noRecommendedPosts;

  /// No description provided for @setInterestsPrompt.
  ///
  /// In en, this message translates to:
  /// **'Set your interests to see personalised content'**
  String get setInterestsPrompt;

  /// No description provided for @noEventsNearby.
  ///
  /// In en, this message translates to:
  /// **'No events near you'**
  String get noEventsNearby;

  /// No description provided for @enableLocationPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enable location to see nearby events'**
  String get enableLocationPrompt;

  /// No description provided for @allowLocationButton.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get allowLocationButton;

  /// No description provided for @participantsLabel.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participantsLabel;

  /// No description provided for @splashLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading #seen'**
  String get splashLoadingTitle;

  /// No description provided for @splashLoadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fetching latest data and saving it locally…'**
  String get splashLoadingSubtitle;

  /// No description provided for @splashRefreshingTitle.
  ///
  /// In en, this message translates to:
  /// **'Refreshing data…'**
  String get splashRefreshingTitle;

  /// No description provided for @splashRefreshingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Checking for new posts and saving updates locally…'**
  String get splashRefreshingSubtitle;

  /// No description provided for @assetTransportScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Asset Transport'**
  String get assetTransportScreenTitle;

  /// No description provided for @peerTransportSection.
  ///
  /// In en, this message translates to:
  /// **'Peer Transport'**
  String get peerTransportSection;

  /// No description provided for @peerTransportDescription.
  ///
  /// In en, this message translates to:
  /// **'Control when #seen can share and fetch full images and videos over peer transport to avoid unexpected mobile-data use.'**
  String get peerTransportDescription;

  /// No description provided for @cdnAccelerationSection.
  ///
  /// In en, this message translates to:
  /// **'CDN Acceleration'**
  String get cdnAccelerationSection;

  /// No description provided for @cdnAccelerationDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a content delivery network for faster media loading. CDN fetch and upload are enabled by default; disable them here to use only peer-to-peer transport.'**
  String get cdnAccelerationDescription;

  /// No description provided for @cdnFetchLabel.
  ///
  /// In en, this message translates to:
  /// **'CDN fetch & cache'**
  String get cdnFetchLabel;

  /// No description provided for @cdnFetchDescription.
  ///
  /// In en, this message translates to:
  /// **'Download media from CDN when available (faster).'**
  String get cdnFetchDescription;

  /// No description provided for @cdnUploadLabel.
  ///
  /// In en, this message translates to:
  /// **'CDN upload'**
  String get cdnUploadLabel;

  /// No description provided for @cdnUploadDescription.
  ///
  /// In en, this message translates to:
  /// **'Upload your media to CDN so others can fetch it faster.'**
  String get cdnUploadDescription;

  /// No description provided for @alwaysOption.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get alwaysOption;

  /// No description provided for @wifiOnlyOption.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi only'**
  String get wifiOnlyOption;

  /// No description provided for @offOption.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get offOption;

  /// No description provided for @cdnUploadNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'CDN upload is not configured for this build'**
  String get cdnUploadNotConfigured;

  /// No description provided for @threadTitle.
  ///
  /// In en, this message translates to:
  /// **'Thread'**
  String get threadTitle;

  /// No description provided for @threadNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Thread not available'**
  String get threadNotAvailable;

  /// No description provided for @replyToPostUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The post you are replying to is unavailable.'**
  String get replyToPostUnavailable;

  /// No description provided for @videoLabel.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get videoLabel;

  /// No description provided for @imageLabel.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get imageLabel;

  /// No description provided for @loadingFullVideo.
  ///
  /// In en, this message translates to:
  /// **'Loading full video…'**
  String get loadingFullVideo;

  /// No description provided for @loadingFullImage.
  ///
  /// In en, this message translates to:
  /// **'Loading full image…'**
  String get loadingFullImage;

  /// No description provided for @loadingFullMedia.
  ///
  /// In en, this message translates to:
  /// **'Loading full media…'**
  String get loadingFullMedia;

  /// No description provided for @mediaUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Full media is still unavailable. Preview only for now.'**
  String get mediaUnavailable;

  /// No description provided for @couldNotLoadMedia.
  ///
  /// In en, this message translates to:
  /// **'Could not load the full media right now.'**
  String get couldNotLoadMedia;

  /// No description provided for @tapToPause.
  ///
  /// In en, this message translates to:
  /// **'Tap to pause'**
  String get tapToPause;

  /// No description provided for @tapToPlay.
  ///
  /// In en, this message translates to:
  /// **'Tap to play'**
  String get tapToPlay;

  /// No description provided for @couldNotRenderImage.
  ///
  /// In en, this message translates to:
  /// **'Could not render this image'**
  String get couldNotRenderImage;

  /// No description provided for @couldNotRenderPreview.
  ///
  /// In en, this message translates to:
  /// **'Could not render this preview'**
  String get couldNotRenderPreview;

  /// No description provided for @tapRetryToLoad.
  ///
  /// In en, this message translates to:
  /// **'Tap retry to load full media'**
  String get tapRetryToLoad;

  /// No description provided for @myPostedThreadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Posted Threads'**
  String get myPostedThreadsTitle;

  /// No description provided for @myRepliedThreadsTitle.
  ///
  /// In en, this message translates to:
  /// **'Replied Threads'**
  String get myRepliedThreadsTitle;

  /// No description provided for @threadsPublicHint.
  ///
  /// In en, this message translates to:
  /// **'Threads you post publicly will appear here'**
  String get threadsPublicHint;

  /// No description provided for @repliesPublicHint.
  ///
  /// In en, this message translates to:
  /// **'Replies you post publicly will appear here'**
  String get repliesPublicHint;

  /// No description provided for @muteUser.
  ///
  /// In en, this message translates to:
  /// **'Mute user'**
  String get muteUser;

  /// No description provided for @unmuteUser.
  ///
  /// In en, this message translates to:
  /// **'Unmute user'**
  String get unmuteUser;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block user'**
  String get blockUser;

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock user'**
  String get unblockUser;

  /// No description provided for @blockedUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get blockedUsersTitle;

  /// No description provided for @blockedUsersEmpty.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t blocked anyone.'**
  String get blockedUsersEmpty;

  /// No description provided for @blockedUsersUnblockButton.
  ///
  /// In en, this message translates to:
  /// **'Unblock'**
  String get blockedUsersUnblockButton;

  /// No description provided for @blockedUsersUnblockConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Unblock this user?'**
  String get blockedUsersUnblockConfirmTitle;

  /// No description provided for @blockedUsersUnblockConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'They will be able to see your content and interact with you again.'**
  String get blockedUsersUnblockConfirmBody;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report user'**
  String get reportUser;

  /// No description provided for @userOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'User options'**
  String get userOptionsTitle;

  /// No description provided for @threadsPrivate.
  ///
  /// In en, this message translates to:
  /// **'This account is not sharing top-level threads on its public profile.'**
  String get threadsPrivate;

  /// No description provided for @repliesPrivate.
  ///
  /// In en, this message translates to:
  /// **'This account is not sharing replies on its public profile.'**
  String get repliesPrivate;

  /// No description provided for @footprintMapPrivate.
  ///
  /// In en, this message translates to:
  /// **'This account is not sharing its footprint map with other users.'**
  String get footprintMapPrivate;

  /// No description provided for @userReported.
  ///
  /// In en, this message translates to:
  /// **'User reported.'**
  String get userReported;

  /// No description provided for @followUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Follow update failed: {error}'**
  String followUpdateFailed(String error);

  /// No description provided for @favoriteTopicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorite Topics'**
  String get favoriteTopicsTitle;

  /// No description provided for @favoriteTopicsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick at least 3 topics to personalise your For You feed.'**
  String get favoriteTopicsSubtitle;

  /// No description provided for @addCustomHashtagHint.
  ///
  /// In en, this message translates to:
  /// **'Add custom hashtag'**
  String get addCustomHashtagHint;

  /// No description provided for @selectAtLeast3.
  ///
  /// In en, this message translates to:
  /// **'Select at least 3'**
  String get selectAtLeast3;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete post'**
  String get deletePost;

  /// No description provided for @reportContent.
  ///
  /// In en, this message translates to:
  /// **'Report content'**
  String get reportContent;

  /// No description provided for @savedLocallyOnly.
  ///
  /// In en, this message translates to:
  /// **'Saved locally only. Tap refresh to resend.'**
  String get savedLocallyOnly;

  /// No description provided for @notPostedYet.
  ///
  /// In en, this message translates to:
  /// **'Not posted yet. Tap refresh to resend.'**
  String get notPostedYet;

  /// No description provided for @tapPhotoHoldVideo.
  ///
  /// In en, this message translates to:
  /// **'Tap · photo   Hold · video'**
  String get tapPhotoHoldVideo;

  /// No description provided for @writeReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply…'**
  String get writeReplyHint;

  /// No description provided for @replyingToUser.
  ///
  /// In en, this message translates to:
  /// **'Replying to {pubkey}'**
  String replyingToUser(String pubkey);

  /// No description provided for @replyToEvent.
  ///
  /// In en, this message translates to:
  /// **'Reply to {event}'**
  String replyToEvent(String event);

  /// No description provided for @tapToLoadMedia.
  ///
  /// In en, this message translates to:
  /// **'Tap to load media'**
  String get tapToLoadMedia;

  /// No description provided for @tapToLoadFull.
  ///
  /// In en, this message translates to:
  /// **'Tap to load full'**
  String get tapToLoadFull;

  /// No description provided for @downloadingFromCdn.
  ///
  /// In en, this message translates to:
  /// **'Downloading from CDN…'**
  String get downloadingFromCdn;

  /// No description provided for @preparingVideo.
  ///
  /// In en, this message translates to:
  /// **'Preparing video…'**
  String get preparingVideo;

  /// No description provided for @imageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Image unavailable now'**
  String get imageUnavailable;

  /// No description provided for @noGps.
  ///
  /// In en, this message translates to:
  /// **'No GPS'**
  String get noGps;

  /// No description provided for @locationHidden.
  ///
  /// In en, this message translates to:
  /// **'Location hidden'**
  String get locationHidden;

  /// No description provided for @noLocation.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get noLocation;

  /// No description provided for @pinnedPost.
  ///
  /// In en, this message translates to:
  /// **'Pinned post'**
  String get pinnedPost;

  /// No description provided for @videoNOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Video {n} of {total}'**
  String videoNOfTotal(int n, int total);

  /// No description provided for @openInDiscover.
  ///
  /// In en, this message translates to:
  /// **'Open in Discover'**
  String get openInDiscover;

  /// No description provided for @openFullScreenMap.
  ///
  /// In en, this message translates to:
  /// **'Open full screen map'**
  String get openFullScreenMap;

  /// No description provided for @zoomIn.
  ///
  /// In en, this message translates to:
  /// **'Zoom in'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In en, this message translates to:
  /// **'Zoom out'**
  String get zoomOut;

  /// No description provided for @mapAttribution.
  ///
  /// In en, this message translates to:
  /// **'Map tiles: OpenStreetMap / CARTO'**
  String get mapAttribution;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @threadsTabLabel.
  ///
  /// In en, this message translates to:
  /// **'THREADS'**
  String get threadsTabLabel;

  /// No description provided for @repliesTabLabel.
  ///
  /// In en, this message translates to:
  /// **'REPLIES'**
  String get repliesTabLabel;

  /// No description provided for @mapTabLabel.
  ///
  /// In en, this message translates to:
  /// **'MAP'**
  String get mapTabLabel;

  /// No description provided for @footprintMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Footprint Map'**
  String get footprintMapTitle;

  /// No description provided for @noLocations.
  ///
  /// In en, this message translates to:
  /// **'No locations'**
  String get noLocations;

  /// No description provided for @unknownLabel.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknownLabel;

  /// No description provided for @eventPostLabel.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get eventPostLabel;

  /// No description provided for @eventReplyLabel.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get eventReplyLabel;

  /// No description provided for @eventPostsContributors.
  ///
  /// In en, this message translates to:
  /// **'{count} posts · {contributors} contributors'**
  String eventPostsContributors(int count, int contributors);

  /// No description provided for @mediaViewerPageTitle.
  ///
  /// In en, this message translates to:
  /// **'{label} {n}/{total}'**
  String mediaViewerPageTitle(String label, int n, int total);

  /// No description provided for @threadsArePrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Threads are private'**
  String get threadsArePrivateTitle;

  /// No description provided for @repliesArePrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Replies are private'**
  String get repliesArePrivateTitle;

  /// No description provided for @footprintMapIsPrivateTitle.
  ///
  /// In en, this message translates to:
  /// **'Footprint map is private'**
  String get footprintMapIsPrivateTitle;

  /// No description provided for @repliesFromAccountHint.
  ///
  /// In en, this message translates to:
  /// **'Replies from this account will appear here'**
  String get repliesFromAccountHint;

  /// No description provided for @noTopLevelThreadsHint.
  ///
  /// In en, this message translates to:
  /// **'No top-level threads from this account yet'**
  String get noTopLevelThreadsHint;

  /// No description provided for @saveNInterests.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Save {count} interest} other{Save {count} interests}}'**
  String saveNInterests(int count);

  /// No description provided for @threadStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Thread'**
  String get threadStatLabel;

  /// No description provided for @replyStatLabel.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get replyStatLabel;

  /// No description provided for @footprintCountriesVisited.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} country visited} other{{count} countries visited}}'**
  String footprintCountriesVisited(int count);

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewLabel;

  /// No description provided for @mediaCheckBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later'**
  String get mediaCheckBackLater;

  /// No description provided for @mediaDownloadViaCdnOrP2p.
  ///
  /// In en, this message translates to:
  /// **'Downloads via CDN or P2P'**
  String get mediaDownloadViaCdnOrP2p;

  /// No description provided for @protectedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get protectedTooltip;

  /// No description provided for @aiGeneratedTooltip.
  ///
  /// In en, this message translates to:
  /// **'AI-generated'**
  String get aiGeneratedTooltip;

  /// No description provided for @notSentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Not sent'**
  String get notSentTooltip;

  /// No description provided for @secondhandTooltip.
  ///
  /// In en, this message translates to:
  /// **'Secondhand'**
  String get secondhandTooltip;

  /// No description provided for @descriptionWordCountHelper.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} words'**
  String descriptionWordCountHelper(int count, int max);

  /// No description provided for @replyToShortKey.
  ///
  /// In en, this message translates to:
  /// **'Reply to {key}'**
  String replyToShortKey(String key);

  /// No description provided for @whatsHappeningHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s happening?'**
  String get whatsHappeningHint;

  /// No description provided for @postButton.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postButton;

  /// No description provided for @beforePostSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please confirm all of the following before sharing.'**
  String get beforePostSubtitle;

  /// No description provided for @accuracyConfirmation.
  ///
  /// In en, this message translates to:
  /// **'The information I\'m sharing is accurate to the best of my knowledge'**
  String get accuracyConfirmation;

  /// No description provided for @ugcTermsTitle.
  ///
  /// In en, this message translates to:
  /// **'Agree to the community terms'**
  String get ugcTermsTitle;

  /// No description provided for @ugcTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'#seen includes user-generated posts and profiles. You must agree to these terms before you can access community content.'**
  String get ugcTermsSubtitle;

  /// No description provided for @ugcTermsSafetyHeading.
  ///
  /// In en, this message translates to:
  /// **'No tolerance for abusive behavior'**
  String get ugcTermsSafetyHeading;

  /// No description provided for @ugcTermsBulletRespect.
  ///
  /// In en, this message translates to:
  /// **'Do not post objectionable content, harassment, hate, threats, sexual exploitation, or graphic abuse.'**
  String get ugcTermsBulletRespect;

  /// No description provided for @ugcTermsBulletModeration.
  ///
  /// In en, this message translates to:
  /// **'Reported posts and accounts may be hidden, reviewed, blocked from posting, or removed.'**
  String get ugcTermsBulletModeration;

  /// No description provided for @ugcTermsBulletReporting.
  ///
  /// In en, this message translates to:
  /// **'Use the report and block tools whenever you encounter unsafe content or abusive users.'**
  String get ugcTermsBulletReporting;

  /// No description provided for @ugcTermsBulletEnforcement.
  ///
  /// In en, this message translates to:
  /// **'Violations may result in content removal, posting restrictions, or account suspension.'**
  String get ugcTermsBulletEnforcement;

  /// No description provided for @ugcTermsAgreement.
  ///
  /// In en, this message translates to:
  /// **'I agree to #seen\'s Terms of Use and Privacy Policy, and understand there is no tolerance for objectionable content or abusive users.'**
  String get ugcTermsAgreement;

  /// No description provided for @ugcTermsAgreeButton.
  ///
  /// In en, this message translates to:
  /// **'Agree and continue'**
  String get ugcTermsAgreeButton;

  /// No description provided for @ugcTermsViewTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get ugcTermsViewTerms;

  /// No description provided for @ugcTermsViewPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get ugcTermsViewPrivacy;

  /// No description provided for @reportUserTitle.
  ///
  /// In en, this message translates to:
  /// **'Report this user'**
  String get reportUserTitle;

  /// No description provided for @reportUserSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell moderators what this account is doing so they can review it.'**
  String get reportUserSubtitle;

  /// No description provided for @reportReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reportReasonLabel;

  /// No description provided for @reportDetailsLabel.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get reportDetailsLabel;

  /// No description provided for @reportUserDetailsHint.
  ///
  /// In en, this message translates to:
  /// **'Optional details for moderators'**
  String get reportUserDetailsHint;

  /// No description provided for @submitUserReportButton.
  ///
  /// In en, this message translates to:
  /// **'Submit report'**
  String get submitUserReportButton;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonHate.
  ///
  /// In en, this message translates to:
  /// **'Hate or extremism'**
  String get reportReasonHate;

  /// No description provided for @reportReasonSexualContent.
  ///
  /// In en, this message translates to:
  /// **'Sexual content'**
  String get reportReasonSexualContent;

  /// No description provided for @reportReasonViolence.
  ///
  /// In en, this message translates to:
  /// **'Violence'**
  String get reportReasonViolence;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or scams'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonImpersonation.
  ///
  /// In en, this message translates to:
  /// **'Impersonation'**
  String get reportReasonImpersonation;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

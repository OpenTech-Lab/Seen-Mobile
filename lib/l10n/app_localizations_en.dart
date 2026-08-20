// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => '#seen';

  @override
  String get cancelAction => 'Cancel';

  @override
  String get retryButton => 'Retry';

  @override
  String get backButton => 'Back';

  @override
  String get continueButton => 'Continue';

  @override
  String get copiedSnackbar => 'Copied';

  @override
  String get loadingLabel => 'Loading';

  @override
  String get savingLabel => 'Saving…';

  @override
  String get updatingLabel => 'Updating…';

  @override
  String get locatingLabel => 'Locating…';

  @override
  String get verifyingStatus => 'Verifying…';

  @override
  String get verifiedStatus => 'Verified';

  @override
  String get verificationFailedStatus => 'Verification failed';

  @override
  String get deleteButton => 'Delete';

  @override
  String get clearButton => 'Clear';

  @override
  String get clearAllButton => 'Clear All';

  @override
  String get hideButton => 'Hide';

  @override
  String get unlockButton => 'Unlock';

  @override
  String get followButton => 'Follow';

  @override
  String get followingLabel => 'Following';

  @override
  String get followersLabel => 'Followers';

  @override
  String get postsLabel => 'Posts';

  @override
  String get joinedLabel => 'Joined';

  @override
  String get notSetValue => 'Not set';

  @override
  String get youLabel => 'You';

  @override
  String get citizenDefaultName => 'Citizen';

  @override
  String get altchaAttribution => 'Protected by ALTCHA';

  @override
  String get altchaVerificationFailed => 'ALTCHA verification failed';

  @override
  String get reportedContentHidden => 'Reported. Content hidden.';

  @override
  String get welcomeTagline => 'Decentralised media.\nVerified at capture.';

  @override
  String get welcomeBullet1 => 'Device-bound cryptographic identity';

  @override
  String get welcomeBullet2 => 'GPS-locked at the moment of capture';

  @override
  String get welcomeBullet3 =>
      'Privacy mode — blur faces in photos, hide location';

  @override
  String get welcomeBullet4 => 'Peer-to-peer, no central servers';

  @override
  String get getStartedButton => 'Get started';

  @override
  String get createIdentityTitle => 'Create identity';

  @override
  String get importIdentityTitle => 'Import identity';

  @override
  String get createIdentitySubtitle =>
      'A keypair will be generated and stored securely on this device.';

  @override
  String get importIdentitySubtitle => 'Enter your 12-word recovery phrase.';

  @override
  String get generateIdentityButton => 'Generate new identity';

  @override
  String get importExistingButton => 'Import existing';

  @override
  String get importIdentityButton => 'Import identity';

  @override
  String get importExactWordsError => 'Enter exactly 12 recovery words.';

  @override
  String invalidPhraseError(String error) {
    return 'Invalid phrase: $error';
  }

  @override
  String failedError(String error) {
    return 'Failed: $error';
  }

  @override
  String get identityReadyTitle => 'Identity ready';

  @override
  String get yourPublicKeyLabel => 'Your public key';

  @override
  String get recoveryPhraseLabel => 'Recovery phrase';

  @override
  String get recoveryPhraseOnboardingDescription =>
      'The only way to restore your identity if you lose this device. Write these down and keep them safe.';

  @override
  String get showRecoveryPhraseButton => 'Show recovery phrase';

  @override
  String get showRecoveryQrButton => 'Show recovery QR';

  @override
  String get recoveryQrTitle => 'Recovery QR';

  @override
  String get recoveryQrDescription =>
      'Scan this code on a new device to restore your identity.';

  @override
  String get recoveryQrWarning =>
      'Anyone who can scan this code can control your account. Keep it private.';

  @override
  String get saveRecoveryQrButton => 'Save recovery QR';

  @override
  String get recoveryQrSaved => 'Recovery QR saved to your photos.';

  @override
  String get recoveryQrSaveFailed => 'Could not save the recovery QR.';

  @override
  String get scanRecoveryQrButton => 'Scan recovery QR';

  @override
  String get recoveryQrScannerTitle => 'Scan recovery QR';

  @override
  String get recoveryQrScannerHint =>
      'Point the camera at your recovery QR code.';

  @override
  String get chooseRecoveryQrImageTooltip => 'Choose QR image';

  @override
  String get recoveryQrNoCodeError =>
      'No recovery QR code found in that image.';

  @override
  String get invalidRecoveryQrError => 'That is not a valid #seen recovery QR.';

  @override
  String get savedWordsButton => 'I have saved these words';

  @override
  String get confirmBackupFirst => 'Confirm backup first';

  @override
  String get securingAccountTitle => 'Securing account';

  @override
  String get checkingOwnerSubtitle =>
      'Checking how this device can verify the saved owner…';

  @override
  String get savedAccountLockedTitle => 'Saved account locked';

  @override
  String get accountLockedDescription =>
      'Public threads stay public, but private account access on this phone stays locked until the current owner unlocks or resets it.';

  @override
  String get accountLabel => 'Account';

  @override
  String get identitiesLabel => 'Identities';

  @override
  String get switchIdentityTitle => 'Switch identity';

  @override
  String get switchIdentitySubtitle =>
      'Keep personal, company, studio, and brand identities separate on this device.';

  @override
  String get identitySwitcherSecurityNote =>
      'Each identity has its own keypair. Never share your main identity\'s recovery phrase.';

  @override
  String get mainIdentityLabel => 'Main identity';

  @override
  String get activeIdentityLabel => 'Active';

  @override
  String get addIdentityButton => 'Add identity';

  @override
  String get addIdentityTitle => 'Add identity';

  @override
  String get identityNameLabel => 'Identity name';

  @override
  String get identityNameHint => 'Personal, Studio, Brand…';

  @override
  String get identityTypeLabel => 'Type';

  @override
  String get personalIdentityType => 'Personal';

  @override
  String get companyIdentityType => 'Company';

  @override
  String get studioIdentityType => 'Studio';

  @override
  String get brandIdentityType => 'Brand';

  @override
  String get customIdentityType => 'Custom';

  @override
  String removeIdentityTitle(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeIdentityContent =>
      'This removes the identity and its recovery secret from this device. Remote data is not deleted.';

  @override
  String get removeIdentityButton => 'Remove identity';

  @override
  String get identityVaultUnavailable =>
      'No local identity vault is available.';

  @override
  String identitySwitchFailed(String error) {
    return 'Could not switch identity: $error';
  }

  @override
  String get createdLabel => 'Created';

  @override
  String get unlockThisAccountButton => 'Unlock this account';

  @override
  String get unlockWithPhraseButton => 'Unlock with recovery phrase';

  @override
  String get notMyAccountButton => 'This is not my account';

  @override
  String get unlockCancelledError =>
      'Unlock was cancelled or failed. #seen will stay locked until this device owner confirms access.';

  @override
  String failedResetAccount(String error) {
    return 'Failed to reset the saved account: $error';
  }

  @override
  String get unlockWithPhraseDialogTitle => 'Unlock with recovery phrase';

  @override
  String get unlockPhraseDescription =>
      'Enter the 12-word recovery phrase for this saved account.';

  @override
  String get enterExactPhraseError =>
      'Enter the exact 12-word recovery phrase.';

  @override
  String get phraseMismatchError =>
      'Recovery phrase does not match this saved account.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get termsOfUseTitle => 'Terms of Use';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get favoriteTopicsLabel => 'Favorite Topics';

  @override
  String get assetTransportLabel => 'Asset Transport';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageMenuMessage =>
      'Choose the language used throughout the app.';

  @override
  String get systemDefaultLanguageOption => 'System Default';

  @override
  String get viewMyActivityLabel => 'View My Activity';

  @override
  String get privacySectionLabel => 'PRIVACY';

  @override
  String get footprintMapLabel => 'Footprint Map';

  @override
  String get publicThreadsLabel => 'Public Threads';

  @override
  String get publicRepliesLabel => 'Public Replies';

  @override
  String get storageSectionLabel => 'Storage';

  @override
  String get clearCacheLabel => 'Clear Cache';

  @override
  String get clearLocalDataLabel => 'Clear Local Data';

  @override
  String get sessionSectionLabel => 'SESSION';

  @override
  String get safeModeLabel => 'Safe Mode';

  @override
  String get logOutLabel => 'Log Out';

  @override
  String get signingOutLabel => 'Signing out…';

  @override
  String get clearCacheDialogContent =>
      'This will delete all cached media files. Your posts and settings will not be affected.';

  @override
  String get cacheClearedSnackbar => 'Cache cleared';

  @override
  String get clearLocalDataDialogContent =>
      'This will delete ALL local data including:\n• Cached media\n• Saved posts\n• Favorite tags and preferences\n• Blocklist\n\nYour account will NOT be deleted. Remote data will re-sync from Supabase.';

  @override
  String get localDataClearedSnackbar =>
      'Local data cleared. Restart app to re-sync.';

  @override
  String get logOutDialogTitle => 'Log out?';

  @override
  String get logOutDialogContent =>
      'Before logging out, make sure you have saved your 12-word recovery phrase. You will need it to restore this same identity later. Logging out will sign you out on this device and erase local app data. Your Supabase account and remote posts will remain intact.';

  @override
  String get logOutConfirmButton => 'Log Out';

  @override
  String failedLoadPrivacy(String error) {
    return 'Failed to load privacy settings: $error';
  }

  @override
  String failedUpdatePrivacy(String error) {
    return 'Failed to update privacy settings: $error';
  }

  @override
  String failedUpdateSafeMode(String error) {
    return 'Failed to update safe mode: $error';
  }

  @override
  String failedUpdateLanguage(String error) {
    return 'Failed to update language: $error';
  }

  @override
  String failedLogOut(String error) {
    return 'Failed to log out: $error';
  }

  @override
  String get publicActivityTitle => 'Public Activity';

  @override
  String get publicActivityMessage =>
      'Choose which of your public posts to open.';

  @override
  String get postedThreadsOption => 'Posted Threads';

  @override
  String get repliedThreadsOption => 'Replied Threads';

  @override
  String get walletAccountTitle => 'Account';

  @override
  String get thisDeviceSectionTitle => 'This device';

  @override
  String get deviceSectionDescription =>
      'Profile name and avatar are edited from the Profile tab. Device signing keys stay internal to the app.';

  @override
  String get deviceLabel => 'Device';

  @override
  String get postingLimitsSectionTitle => 'Posting limits';

  @override
  String get checkingDailyLimits => 'Checking your current daily limits…';

  @override
  String get postingLimitsLoadError =>
      'Could not load your posting limits right now.';

  @override
  String get recoveryPhraseWalletDescription =>
      'These 12 words are the only way to restore this identity after logging out or moving to a new device.';

  @override
  String get copyPhraseButton => 'Copy phrase';

  @override
  String get recoveryPhraseCopied => 'Recovery phrase copied';

  @override
  String get dangerZoneSectionTitle => 'Danger zone';

  @override
  String get deleteAccountDescription =>
      'Delete this account from Supabase and erase local app data from this device.';

  @override
  String get deleteAccountButton => 'Delete this account';

  @override
  String get deleteAccountDialogTitle => 'Delete this account?';

  @override
  String get deleteAccountDialogContent =>
      'This will permanently remove your #seen profile and posts from Supabase, then erase local app data from this device. This cannot be undone.';

  @override
  String failedDeleteAccount(String error) {
    return 'Failed to delete account: $error';
  }

  @override
  String get postingBlocked => 'Posting is currently blocked for this account.';

  @override
  String get postingQuotaDescription =>
      'You can check your remaining thread and reply publishes here before opening the composer.';

  @override
  String get tierLabel => 'Tier';

  @override
  String get threadsLabel => 'Threads';

  @override
  String get repliesLabel => 'Replies';

  @override
  String get usedLabel => 'Used';

  @override
  String postingQuotaResetsAt(String resetTime) {
    return 'Resets at $resetTime (next UTC midnight).';
  }

  @override
  String postingRemainingOf(int remaining, int total) {
    return '$remaining left of $total';
  }

  @override
  String postingUsedCount(int threads, int replies) {
    return '$threads threads, $replies replies';
  }

  @override
  String get latestTabLabel => 'LATEST';

  @override
  String get followingTabLabel => 'FOLLOWING';

  @override
  String get couldNotLoadPosts => 'Could not load posts';

  @override
  String get noPostsYet => 'No posts yet';

  @override
  String get beFirstToRecord => 'Be the first to record';

  @override
  String get noFollowingPosts => 'No posts from people you follow';

  @override
  String get tapAvatarToFollow => 'Tap an avatar to follow someone';

  @override
  String get homeNavLabel => 'Home';

  @override
  String get discoverNavLabel => 'Discover';

  @override
  String get eventsNavLabel => 'Events';

  @override
  String get profileNavLabel => 'Profile';

  @override
  String get eventsTabTitle => 'Events';

  @override
  String get allEventsTabLabel => 'ALL';

  @override
  String get noEventsYet => 'No events yet';

  @override
  String get noFollowedEventsLive => 'No followed events live';

  @override
  String get noFollowedTagsYet => 'No followed tags yet';

  @override
  String get followedTagsDescription =>
      'Followed tags will show up here when matching live events appear.';

  @override
  String get followTagPrompt =>
      'Follow a tag from Discover or an event detail screen to see it here.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get usernameFieldLabel => 'Username';

  @override
  String get usernameFieldHint => 'Citizen name';

  @override
  String get descriptionFieldLabel => 'Description';

  @override
  String get descriptionFieldHint => 'Simple description about you';

  @override
  String get tapAvatarHint => 'Tap avatar to choose a new image';

  @override
  String get saveProfileButton => 'Save Profile';

  @override
  String get descriptionTooLongError => 'Use 100 words or fewer';

  @override
  String get captureAMomentHint => 'Capture a moment to see it here';

  @override
  String get repliesPostedHint => 'Replies you posted will appear here';

  @override
  String get noThreadsYet => 'No threads yet';

  @override
  String get noRepliesYet => 'No replies yet';

  @override
  String get removedLocalPost => 'Removed local unsent post';

  @override
  String get postDeleted =>
      'Post deleted. Swarm participants will be notified to remove local copies.';

  @override
  String get failedDeletePost => 'Failed to delete post';

  @override
  String get postSent => 'Post sent';

  @override
  String get retryFailed => 'Retry failed. The post is still saved locally.';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String profileUpdatedWithWarning(String warning) {
    return 'Profile updated. $warning';
  }

  @override
  String failedUpdateProfile(String error) {
    return 'Failed to update profile: $error';
  }

  @override
  String get avatarNotUpdated => 'Avatar not updated. Please try again.';

  @override
  String get avatarNotUpdatedTimeSync =>
      'Avatar not updated. Turn on automatic date & time and try again.';

  @override
  String get takePhotoOption => 'Take Photo';

  @override
  String get recordVideoOption => 'Record Video';

  @override
  String get maxMediaItemsWarning => 'Maximum 4 media items per post';

  @override
  String get categoryTagHint => 'Category tag (e.g. AWSSummitTokyo2026)';

  @override
  String get addMoreTagsHint => 'Add more tags…';

  @override
  String get createCategoryTagTooltip => 'Create category tag';

  @override
  String get createTagTooltip => 'Create tag';

  @override
  String get postModeLabel => 'Post mode';

  @override
  String get standardModeLabel => 'Standard';

  @override
  String get virtualModeLabel => 'Virtual';

  @override
  String get checkInLabel => 'Check in at a spot';

  @override
  String get checkInSubtitle => 'Publish exact location with a place name';

  @override
  String get blurFacesLabel => 'Blur faces';

  @override
  String get blurFacesSubtitle => 'Automatically blur detected faces in photos';

  @override
  String get aiGeneratedLabel => 'AI-generated content';

  @override
  String get aiGeneratedSubtitle => 'Content was created or assisted by AI';

  @override
  String get secondhandLabel => 'Someone else\'s story';

  @override
  String get secondhandSubtitle => 'You are sharing a secondhand account';

  @override
  String get publishFailedSaved =>
      'Publish failed. Saved in Profile so you can retry.';

  @override
  String publishFailedError(String error) {
    return 'Publish failed: $error';
  }

  @override
  String get publishButton => 'Publish';

  @override
  String get confirmAndPostButton => 'Confirm & Post';

  @override
  String get beforePostTitle => 'Before you post';

  @override
  String get yesLabel => 'Yes';

  @override
  String get noLabel => 'No';

  @override
  String get rightsConfirmation => 'I have the rights to share this content';

  @override
  String get defamationConfirmation =>
      'This content does not defame any individuals or groups';

  @override
  String get lawsConfirmation =>
      'I confirm this complies with applicable laws in my jurisdiction';

  @override
  String captionHint(int limit) {
    return 'Add a caption… (optional, max $limit chars)';
  }

  @override
  String get addCategoryTagWarning =>
      'Add a category tag before posting a new thread.';

  @override
  String get tagFieldHint =>
      'First tag is the event category · press Space or , to add more';

  @override
  String get checkInSpotHint => 'e.g. Eiffel Tower, Central Park…';

  @override
  String get checkInSpotPlaceholder => 'Check in at a spot…';

  @override
  String publishNItems(int count) {
    return 'Publish $count items';
  }

  @override
  String get discoverSearchPlaceholder => 'Search threads or #tags';

  @override
  String get discoverTitle => 'Discover';

  @override
  String get removeFavoriteLabel => 'Remove Favorite';

  @override
  String get addFavoriteLabel => 'Add as Favorite';

  @override
  String get trendingTabLabel => 'TRENDING';

  @override
  String get forYouTabLabel => 'FOR YOU';

  @override
  String get nearbyTabLabel => 'NEARBY';

  @override
  String get usersTabLabel => 'USERS';

  @override
  String noThreadsFound(String search) {
    return 'No threads found for \"$search\"';
  }

  @override
  String noUsersFound(String search) {
    return 'No users found for \"$search\"';
  }

  @override
  String get nothingTrending => 'Nothing trending in the last 48 h';

  @override
  String get noRecommendedPosts => 'No recommended posts yet';

  @override
  String get setInterestsPrompt =>
      'Set your interests to see personalised content';

  @override
  String get noEventsNearby => 'No events near you';

  @override
  String get enableLocationPrompt => 'Enable location to see nearby events';

  @override
  String get allowLocationButton => 'Allow Location';

  @override
  String get participantsLabel => 'Participants';

  @override
  String get splashLoadingTitle => 'Loading #seen';

  @override
  String get splashLoadingSubtitle =>
      'Fetching latest data and saving it locally…';

  @override
  String get splashRefreshingTitle => 'Refreshing data…';

  @override
  String get splashRefreshingSubtitle =>
      'Checking for new posts and saving updates locally…';

  @override
  String get assetTransportScreenTitle => 'Asset Transport';

  @override
  String get peerTransportSection => 'Peer Transport';

  @override
  String get peerTransportDescription =>
      'Control when #seen can share and fetch full images and videos over peer transport to avoid unexpected mobile-data use.';

  @override
  String get cdnAccelerationSection => 'CDN Acceleration';

  @override
  String get cdnAccelerationDescription =>
      'Use a content delivery network for faster media loading. CDN fetch and upload are enabled by default; disable them here to use only peer-to-peer transport.';

  @override
  String get cdnFetchLabel => 'CDN fetch & cache';

  @override
  String get cdnFetchDescription =>
      'Download media from CDN when available (faster).';

  @override
  String get cdnUploadLabel => 'CDN upload';

  @override
  String get cdnUploadDescription =>
      'Upload your media to CDN so others can fetch it faster.';

  @override
  String get alwaysOption => 'Always';

  @override
  String get wifiOnlyOption => 'Wi-Fi only';

  @override
  String get offOption => 'Off';

  @override
  String get cdnUploadNotConfigured =>
      'CDN upload is not configured for this build';

  @override
  String get threadTitle => 'Thread';

  @override
  String get threadNotAvailable => 'Thread not available';

  @override
  String get replyToPostUnavailable =>
      'The post you are replying to is unavailable.';

  @override
  String get videoLabel => 'Video';

  @override
  String get imageLabel => 'Image';

  @override
  String get loadingFullVideo => 'Loading full video…';

  @override
  String get loadingFullImage => 'Loading full image…';

  @override
  String get loadingFullMedia => 'Loading full media…';

  @override
  String get mediaUnavailable =>
      'Full media is still unavailable. Preview only for now.';

  @override
  String get couldNotLoadMedia => 'Could not load the full media right now.';

  @override
  String get tapToPause => 'Tap to pause';

  @override
  String get tapToPlay => 'Tap to play';

  @override
  String get couldNotRenderImage => 'Could not render this image';

  @override
  String get couldNotRenderPreview => 'Could not render this preview';

  @override
  String get tapRetryToLoad => 'Tap retry to load full media';

  @override
  String get myPostedThreadsTitle => 'Posted Threads';

  @override
  String get myRepliedThreadsTitle => 'Replied Threads';

  @override
  String get threadsPublicHint => 'Threads you post publicly will appear here';

  @override
  String get repliesPublicHint => 'Replies you post publicly will appear here';

  @override
  String get muteUser => 'Mute user';

  @override
  String get unmuteUser => 'Unmute user';

  @override
  String get blockUser => 'Block user';

  @override
  String get unblockUser => 'Unblock user';

  @override
  String get blockedUsersTitle => 'Blocked Users';

  @override
  String get blockedUsersEmpty => 'You haven\'t blocked anyone.';

  @override
  String get blockedUsersUnblockButton => 'Unblock';

  @override
  String get blockedUsersUnblockConfirmTitle => 'Unblock this user?';

  @override
  String get blockedUsersUnblockConfirmBody =>
      'They will be able to see your content and interact with you again.';

  @override
  String get reportUser => 'Report user';

  @override
  String get userOptionsTitle => 'User options';

  @override
  String get threadsPrivate =>
      'This account is not sharing top-level threads on its public profile.';

  @override
  String get repliesPrivate =>
      'This account is not sharing replies on its public profile.';

  @override
  String get footprintMapPrivate =>
      'This account is not sharing its footprint map with other users.';

  @override
  String get userReported => 'User reported.';

  @override
  String followUpdateFailed(String error) {
    return 'Follow update failed: $error';
  }

  @override
  String get favoriteTopicsTitle => 'Favorite Topics';

  @override
  String get favoriteTopicsSubtitle =>
      'Pick at least 3 topics to personalise your For You feed.';

  @override
  String get addCustomHashtagHint => 'Add custom hashtag';

  @override
  String get selectAtLeast3 => 'Select at least 3';

  @override
  String get deletePost => 'Delete post';

  @override
  String get reportContent => 'Report content';

  @override
  String get savedLocallyOnly => 'Saved locally only. Tap refresh to resend.';

  @override
  String get notPostedYet => 'Not posted yet. Tap refresh to resend.';

  @override
  String get tapPhotoHoldVideo => 'Tap · photo   Hold · video';

  @override
  String get writeReplyHint => 'Write a reply…';

  @override
  String replyingToUser(String pubkey) {
    return 'Replying to $pubkey';
  }

  @override
  String replyToEvent(String event) {
    return 'Reply to $event';
  }

  @override
  String get tapToLoadMedia => 'Tap to load media';

  @override
  String get tapToLoadFull => 'Tap to load full';

  @override
  String get downloadingFromCdn => 'Downloading from CDN…';

  @override
  String get preparingVideo => 'Preparing video…';

  @override
  String get imageUnavailable => 'Image unavailable now';

  @override
  String get noGps => 'No GPS';

  @override
  String get locationHidden => 'Location hidden';

  @override
  String get noLocation => 'No location';

  @override
  String get pinnedPost => 'Pinned post';

  @override
  String videoNOfTotal(int n, int total) {
    return 'Video $n of $total';
  }

  @override
  String get openInDiscover => 'Open in Discover';

  @override
  String get openFullScreenMap => 'Open full screen map';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get mapAttribution => 'Map tiles: OpenStreetMap / CARTO';

  @override
  String get locationLabel => 'Location';

  @override
  String get threadsTabLabel => 'THREADS';

  @override
  String get repliesTabLabel => 'REPLIES';

  @override
  String get mapTabLabel => 'MAP';

  @override
  String get footprintMapTitle => 'Footprint Map';

  @override
  String get noLocations => 'No locations';

  @override
  String get unknownLabel => 'Unknown';

  @override
  String get eventPostLabel => 'Post';

  @override
  String get eventReplyLabel => 'Reply';

  @override
  String eventPostsContributors(int count, int contributors) {
    return '$count posts · $contributors contributors';
  }

  @override
  String mediaViewerPageTitle(String label, int n, int total) {
    return '$label $n/$total';
  }

  @override
  String get threadsArePrivateTitle => 'Threads are private';

  @override
  String get repliesArePrivateTitle => 'Replies are private';

  @override
  String get footprintMapIsPrivateTitle => 'Footprint map is private';

  @override
  String get repliesFromAccountHint =>
      'Replies from this account will appear here';

  @override
  String get noTopLevelThreadsHint =>
      'No top-level threads from this account yet';

  @override
  String saveNInterests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Save $count interests',
      one: 'Save $count interest',
    );
    return '$_temp0';
  }

  @override
  String get threadStatLabel => 'Thread';

  @override
  String get replyStatLabel => 'Reply';

  @override
  String footprintCountriesVisited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count countries visited',
      one: '$count country visited',
    );
    return '$_temp0';
  }

  @override
  String get previewLabel => 'Preview';

  @override
  String get mediaCheckBackLater => 'Check back later';

  @override
  String get mediaDownloadViaCdnOrP2p => 'Downloads via CDN or P2P';

  @override
  String get protectedTooltip => 'Protected';

  @override
  String get aiGeneratedTooltip => 'AI-generated';

  @override
  String get notSentTooltip => 'Not sent';

  @override
  String get secondhandTooltip => 'Secondhand';

  @override
  String descriptionWordCountHelper(int count, int max) {
    return '$count/$max words';
  }

  @override
  String replyToShortKey(String key) {
    return 'Reply to $key';
  }

  @override
  String get whatsHappeningHint => 'What\'s happening?';

  @override
  String get postButton => 'Post';

  @override
  String get beforePostSubtitle =>
      'Please confirm all of the following before sharing.';

  @override
  String get accuracyConfirmation =>
      'The information I\'m sharing is accurate to the best of my knowledge';

  @override
  String get ugcTermsTitle => 'Agree to the community terms';

  @override
  String get ugcTermsSubtitle =>
      '#seen includes user-generated posts and profiles. You must agree to these terms before you can access community content.';

  @override
  String get ugcTermsSafetyHeading => 'No tolerance for abusive behavior';

  @override
  String get ugcTermsBulletRespect =>
      'Do not post objectionable content, harassment, hate, threats, sexual exploitation, or graphic abuse.';

  @override
  String get ugcTermsBulletModeration =>
      'Reported posts and accounts may be hidden, reviewed, blocked from posting, or removed.';

  @override
  String get ugcTermsBulletReporting =>
      'Use the report and block tools whenever you encounter unsafe content or abusive users.';

  @override
  String get ugcTermsBulletEnforcement =>
      'Violations may result in content removal, posting restrictions, or account suspension.';

  @override
  String get ugcTermsAgreement =>
      'I agree to #seen\'s Terms of Use and Privacy Policy, and understand there is no tolerance for objectionable content or abusive users.';

  @override
  String get ugcTermsAgreeButton => 'Agree and continue';

  @override
  String get ugcTermsViewTerms => 'Terms of Use';

  @override
  String get ugcTermsViewPrivacy => 'Privacy Policy';

  @override
  String get reportUserTitle => 'Report this user';

  @override
  String get reportUserSubtitle =>
      'Tell moderators what this account is doing so they can review it.';

  @override
  String get reportReasonLabel => 'Reason';

  @override
  String get reportDetailsLabel => 'Details';

  @override
  String get reportUserDetailsHint => 'Optional details for moderators';

  @override
  String get submitUserReportButton => 'Submit report';

  @override
  String get reportReasonHarassment => 'Harassment';

  @override
  String get reportReasonHate => 'Hate or extremism';

  @override
  String get reportReasonSexualContent => 'Sexual content';

  @override
  String get reportReasonViolence => 'Violence';

  @override
  String get reportReasonSpam => 'Spam or scams';

  @override
  String get reportReasonImpersonation => 'Impersonation';

  @override
  String get reportReasonOther => 'Other';
}

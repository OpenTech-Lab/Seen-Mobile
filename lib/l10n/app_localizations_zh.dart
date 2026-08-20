// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '#seen';

  @override
  String get cancelAction => '取消';

  @override
  String get retryButton => '重試';

  @override
  String get backButton => '返回';

  @override
  String get continueButton => '繼續';

  @override
  String get copiedSnackbar => '已複製';

  @override
  String get loadingLabel => '載入中';

  @override
  String get savingLabel => '儲存中…';

  @override
  String get updatingLabel => '更新中…';

  @override
  String get locatingLabel => '定位中…';

  @override
  String get verifyingStatus => '驗證中…';

  @override
  String get verifiedStatus => '已驗證';

  @override
  String get verificationFailedStatus => '驗證失敗';

  @override
  String get deleteButton => '刪除';

  @override
  String get clearButton => '清除';

  @override
  String get clearAllButton => '全部清除';

  @override
  String get hideButton => '隱藏';

  @override
  String get unlockButton => '解鎖';

  @override
  String get followButton => '追蹤';

  @override
  String get followingLabel => '追蹤中';

  @override
  String get followersLabel => '追蹤者';

  @override
  String get postsLabel => '貼文';

  @override
  String get joinedLabel => '加入時間';

  @override
  String get notSetValue => '未設定';

  @override
  String get youLabel => '你';

  @override
  String get citizenDefaultName => '公民';

  @override
  String get altchaAttribution => '由ALTCHA保護';

  @override
  String get altchaVerificationFailed => 'ALTCHA驗證失敗';

  @override
  String get reportedContentHidden => '已檢舉。內容已隱藏。';

  @override
  String get welcomeTagline => '去中心化媒體。\n拍攝時即時驗證。';

  @override
  String get welcomeBullet1 => '與裝置綁定的密碼學身份';

  @override
  String get welcomeBullet2 => '拍攝時GPS鎖定';

  @override
  String get welcomeBullet3 => '隱私模式 — 模糊照片中的臉孔、隱藏位置';

  @override
  String get welcomeBullet4 => '點對點，無中央伺服器';

  @override
  String get getStartedButton => '開始使用';

  @override
  String get createIdentityTitle => '建立身份';

  @override
  String get importIdentityTitle => '匯入身份';

  @override
  String get createIdentitySubtitle => '將會生成密鑰對並安全地儲存在此裝置上。';

  @override
  String get importIdentitySubtitle => '輸入您的12個單詞的恢復短語。';

  @override
  String get generateIdentityButton => '生成新身份';

  @override
  String get importExistingButton => '匯入現有身份';

  @override
  String get importIdentityButton => '匯入身份';

  @override
  String get importExactWordsError => '請精確輸入12個恢復單詞。';

  @override
  String invalidPhraseError(String error) {
    return '無效短語：$error';
  }

  @override
  String failedError(String error) {
    return '失敗：$error';
  }

  @override
  String get identityReadyTitle => '身份已準備就緒';

  @override
  String get yourPublicKeyLabel => '您的公鑰';

  @override
  String get recoveryPhraseLabel => '恢復短語';

  @override
  String get recoveryPhraseOnboardingDescription =>
      '這是在您遺失此裝置後恢復身份的唯一方法。請寫下這些單詞並妥善保管。';

  @override
  String get showRecoveryPhraseButton => '顯示恢復短語';

  @override
  String get showRecoveryQrButton => '顯示恢復 QR 碼';

  @override
  String get recoveryQrTitle => '恢復 QR 碼';

  @override
  String get recoveryQrDescription => '在新裝置上掃描此代碼即可恢復您的身份。';

  @override
  String get recoveryQrWarning => '任何能掃描此代碼的人都可以控制您的帳戶。請妥善保管。';

  @override
  String get saveRecoveryQrButton => '儲存恢復 QR 碼';

  @override
  String get recoveryQrSaved => '恢復 QR 碼已儲存到您的照片。';

  @override
  String get recoveryQrSaveFailed => '無法儲存恢復 QR 碼。';

  @override
  String get scanRecoveryQrButton => '掃描恢復 QR 碼';

  @override
  String get recoveryQrScannerTitle => '掃描恢復 QR 碼';

  @override
  String get recoveryQrScannerHint => '將相機對準恢復 QR 碼。';

  @override
  String get chooseRecoveryQrImageTooltip => '選擇 QR 圖片';

  @override
  String get recoveryQrNoCodeError => '在該圖片中找不到恢復 QR 碼。';

  @override
  String get invalidRecoveryQrError => '這不是有效的 #seen 恢復 QR 碼。';

  @override
  String get savedWordsButton => '我已儲存這些單詞';

  @override
  String get confirmBackupFirst => '請先確認備份';

  @override
  String get securingAccountTitle => '保護帳戶中';

  @override
  String get checkingOwnerSubtitle => '正在檢查此裝置驗證已儲存擁有者的方式…';

  @override
  String get savedAccountLockedTitle => '已儲存的帳戶已鎖定';

  @override
  String get accountLockedDescription =>
      '公開討論串仍為公開狀態，但此手機上的私人帳戶存取將保持鎖定，直到當前擁有者解鎖或重置。';

  @override
  String get accountLabel => '帳戶';

  @override
  String get identitiesLabel => '身份';

  @override
  String get switchIdentityTitle => '切換身份';

  @override
  String get switchIdentitySubtitle => '在此裝置上分開管理個人、公司、工作室和品牌身份。';

  @override
  String get identitySwitcherSecurityNote => '每個身份都有自己的金鑰對。請勿分享主要身份的恢復短語。';

  @override
  String get mainIdentityLabel => '主要身份';

  @override
  String get activeIdentityLabel => '使用中';

  @override
  String get addIdentityButton => '新增身份';

  @override
  String get addIdentityTitle => '新增身份';

  @override
  String get identityNameLabel => '身份名稱';

  @override
  String get identityNameHint => '個人、工作室、品牌…';

  @override
  String get identityTypeLabel => '類型';

  @override
  String get personalIdentityType => '個人';

  @override
  String get companyIdentityType => '公司';

  @override
  String get studioIdentityType => '工作室';

  @override
  String get brandIdentityType => '品牌';

  @override
  String get customIdentityType => '自訂';

  @override
  String removeIdentityTitle(String name) {
    return '移除$name？';
  }

  @override
  String get removeIdentityContent => '這會從此裝置移除身份及其恢復秘密。遠端資料不會被刪除。';

  @override
  String get removeIdentityButton => '移除身份';

  @override
  String get identityVaultUnavailable => '找不到本機身份保管庫。';

  @override
  String identitySwitchFailed(String error) {
    return '無法切換身份：$error';
  }

  @override
  String get createdLabel => '建立時間';

  @override
  String get unlockThisAccountButton => '解鎖此帳戶';

  @override
  String get unlockWithPhraseButton => '使用恢復短語解鎖';

  @override
  String get notMyAccountButton => '這不是我的帳戶';

  @override
  String get unlockCancelledError => '解鎖已取消或失敗。在此裝置擁有者確認存取之前，Spot將保持鎖定。';

  @override
  String failedResetAccount(String error) {
    return '重置已儲存帳戶失敗：$error';
  }

  @override
  String get unlockWithPhraseDialogTitle => '使用恢復短語解鎖';

  @override
  String get unlockPhraseDescription => '輸入此已儲存帳戶的12個單詞恢復短語。';

  @override
  String get enterExactPhraseError => '請輸入精確的12個單詞恢復短語。';

  @override
  String get phraseMismatchError => '恢復短語與此已儲存帳戶不符。';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsTooltip => '設定';

  @override
  String get termsOfUseTitle => '使用條款';

  @override
  String get privacyPolicyTitle => '隱私權政策';

  @override
  String get favoriteTopicsLabel => '最愛主題';

  @override
  String get assetTransportLabel => '資源傳輸';

  @override
  String get languageLabel => '語言';

  @override
  String get languageMenuMessage => '選擇整個應用程式要使用的語言。';

  @override
  String get systemDefaultLanguageOption => '跟隨系統';

  @override
  String get viewMyActivityLabel => '查看我的活動';

  @override
  String get privacySectionLabel => '隱私';

  @override
  String get footprintMapLabel => '足跡地圖';

  @override
  String get publicThreadsLabel => '公開討論串';

  @override
  String get publicRepliesLabel => '公開回覆';

  @override
  String get storageSectionLabel => '儲存空間';

  @override
  String get clearCacheLabel => '清除快取';

  @override
  String get clearLocalDataLabel => '清除本機資料';

  @override
  String get sessionSectionLabel => '工作階段';

  @override
  String get safeModeLabel => '安全模式';

  @override
  String get logOutLabel => '登出';

  @override
  String get signingOutLabel => '登出中…';

  @override
  String get clearCacheDialogContent => '這將刪除所有快取的媒體檔案。您的貼文和設定不會受到影響。';

  @override
  String get cacheClearedSnackbar => '快取已清除';

  @override
  String get clearLocalDataDialogContent =>
      '這將刪除所有本機資料，包括：\n• 快取媒體\n• 已儲存的貼文\n• 最愛標籤和偏好設定\n• 封鎖清單\n\n您的帳戶不會被刪除。遠端資料將從Supabase重新同步。';

  @override
  String get localDataClearedSnackbar => '本機資料已清除。請重新啟動應用程式以重新同步。';

  @override
  String get logOutDialogTitle => '確定要登出嗎？';

  @override
  String get logOutDialogContent =>
      '登出前，請確保您已儲存12個單詞的恢復短語。稍後恢復相同身份時需要用到它。登出將使您在此裝置上登出並清除本機應用程式資料。您的Supabase帳戶和遠端貼文將保持完整。';

  @override
  String get logOutConfirmButton => '登出';

  @override
  String failedLoadPrivacy(String error) {
    return '載入隱私設定失敗：$error';
  }

  @override
  String failedUpdatePrivacy(String error) {
    return '更新隱私設定失敗：$error';
  }

  @override
  String failedUpdateSafeMode(String error) {
    return '更新安全模式失敗：$error';
  }

  @override
  String failedUpdateLanguage(String error) {
    return '更新語言失敗：$error';
  }

  @override
  String failedLogOut(String error) {
    return '登出失敗：$error';
  }

  @override
  String get publicActivityTitle => '公開活動';

  @override
  String get publicActivityMessage => '選擇要開啟的公開貼文。';

  @override
  String get postedThreadsOption => '已發佈的討論串';

  @override
  String get repliedThreadsOption => '已回覆的討論串';

  @override
  String get walletAccountTitle => '帳戶';

  @override
  String get thisDeviceSectionTitle => '此裝置';

  @override
  String get deviceSectionDescription =>
      '個人資料名稱和頭像可在個人資料分頁中編輯。裝置簽名密鑰保留在應用程式內部。';

  @override
  String get deviceLabel => '裝置';

  @override
  String get postingLimitsSectionTitle => '發文限制';

  @override
  String get checkingDailyLimits => '正在確認您目前的每日限制…';

  @override
  String get postingLimitsLoadError => '目前無法載入您的發文限制。';

  @override
  String get recoveryPhraseWalletDescription => '這12個單詞是登出或移至新裝置後恢復此身份的唯一方法。';

  @override
  String get copyPhraseButton => '複製短語';

  @override
  String get recoveryPhraseCopied => '恢復短語已複製';

  @override
  String get dangerZoneSectionTitle => '危險區域';

  @override
  String get deleteAccountDescription => '從Supabase刪除此帳戶並清除此裝置上的本機應用程式資料。';

  @override
  String get deleteAccountButton => '刪除此帳戶';

  @override
  String get deleteAccountDialogTitle => '刪除此帳戶？';

  @override
  String get deleteAccountDialogContent =>
      '這將永久從Supabase移除您的Spot個人資料和貼文，然後清除此裝置上的本機應用程式資料。此操作無法復原。';

  @override
  String failedDeleteAccount(String error) {
    return '刪除帳戶失敗：$error';
  }

  @override
  String get postingBlocked => '此帳戶的發文目前已被封鎖。';

  @override
  String get postingQuotaDescription => '您可以在開啟編輯器前在此確認剩餘的討論串和回覆發布次數。';

  @override
  String get tierLabel => '等級';

  @override
  String get threadsLabel => '討論串';

  @override
  String get repliesLabel => '回覆';

  @override
  String get usedLabel => '已使用';

  @override
  String postingQuotaResetsAt(String resetTime) {
    return '將於$resetTime重置（下一個UTC午夜）。';
  }

  @override
  String postingRemainingOf(int remaining, int total) {
    return '$total個中剩餘$remaining個';
  }

  @override
  String postingUsedCount(int threads, int replies) {
    return '討論串$threads個，回覆$replies個';
  }

  @override
  String get latestTabLabel => '最新';

  @override
  String get followingTabLabel => '追蹤中';

  @override
  String get couldNotLoadPosts => '無法載入貼文';

  @override
  String get noPostsYet => '尚無貼文';

  @override
  String get beFirstToRecord => '成為第一個記錄者';

  @override
  String get noFollowingPosts => '沒有您追蹤的人的貼文';

  @override
  String get tapAvatarToFollow => '點擊頭像來追蹤某人';

  @override
  String get homeNavLabel => '首頁';

  @override
  String get discoverNavLabel => '探索';

  @override
  String get eventsNavLabel => '活動';

  @override
  String get profileNavLabel => '個人資料';

  @override
  String get eventsTabTitle => '活動';

  @override
  String get allEventsTabLabel => '全部';

  @override
  String get noEventsYet => '尚無活動';

  @override
  String get noFollowedEventsLive => '沒有正在進行的追蹤活動';

  @override
  String get noFollowedTagsYet => '尚未追蹤任何標籤';

  @override
  String get followedTagsDescription => '當有符合的直播活動出現時，追蹤的標籤將在此顯示。';

  @override
  String get followTagPrompt => '從探索或活動詳情畫面追蹤標籤以在此顯示。';

  @override
  String get profileTitle => '個人資料';

  @override
  String get editProfileTitle => '編輯個人資料';

  @override
  String get usernameFieldLabel => '用戶名';

  @override
  String get usernameFieldHint => '公民名稱';

  @override
  String get descriptionFieldLabel => '簡介';

  @override
  String get descriptionFieldHint => '關於您的簡單描述';

  @override
  String get tapAvatarHint => '點擊頭像選擇新圖片';

  @override
  String get saveProfileButton => '儲存個人資料';

  @override
  String get descriptionTooLongError => '請使用100個單詞或更少';

  @override
  String get captureAMomentHint => '記錄一個時刻以顯示在此';

  @override
  String get repliesPostedHint => '您發布的回覆將在此顯示';

  @override
  String get noThreadsYet => '尚無討論串';

  @override
  String get noRepliesYet => '尚無回覆';

  @override
  String get removedLocalPost => '已移除本機未發送的貼文';

  @override
  String get postDeleted => '貼文已刪除。群集參與者將收到移除本機副本的通知。';

  @override
  String get failedDeletePost => '刪除貼文失敗';

  @override
  String get postSent => '貼文已發送';

  @override
  String get retryFailed => '重試失敗。貼文仍儲存在本機。';

  @override
  String get profileUpdated => '個人資料已更新';

  @override
  String profileUpdatedWithWarning(String warning) {
    return '個人資料已更新。$warning';
  }

  @override
  String failedUpdateProfile(String error) {
    return '更新個人資料失敗：$error';
  }

  @override
  String get avatarNotUpdated => '頭像未更新。請再試一次。';

  @override
  String get avatarNotUpdatedTimeSync => '頭像未更新。請開啟自動日期和時間後再試。';

  @override
  String get takePhotoOption => '拍照';

  @override
  String get recordVideoOption => '錄影';

  @override
  String get maxMediaItemsWarning => '每則貼文最多4個媒體項目';

  @override
  String get categoryTagHint => '分類標籤（例如：AWSSummitTokyo2026）';

  @override
  String get addMoreTagsHint => '新增更多標籤…';

  @override
  String get createCategoryTagTooltip => '建立分類標籤';

  @override
  String get createTagTooltip => '建立標籤';

  @override
  String get postModeLabel => '發文模式';

  @override
  String get standardModeLabel => '標準';

  @override
  String get virtualModeLabel => '虛擬';

  @override
  String get checkInLabel => '在某個地點打卡';

  @override
  String get checkInSubtitle => '以地點名稱發布精確位置';

  @override
  String get blurFacesLabel => '模糊臉孔';

  @override
  String get blurFacesSubtitle => '自動模糊照片中偵測到的臉孔';

  @override
  String get aiGeneratedLabel => 'AI生成內容';

  @override
  String get aiGeneratedSubtitle => '內容由AI創建或輔助生成';

  @override
  String get secondhandLabel => '他人的故事';

  @override
  String get secondhandSubtitle => '您正在分享間接描述';

  @override
  String get publishFailedSaved => '發布失敗。已儲存至個人資料，您可以重試。';

  @override
  String publishFailedError(String error) {
    return '發布失敗：$error';
  }

  @override
  String get publishButton => '發布';

  @override
  String get confirmAndPostButton => '確認並發文';

  @override
  String get beforePostTitle => '發文前';

  @override
  String get yesLabel => '是';

  @override
  String get noLabel => '否';

  @override
  String get rightsConfirmation => '我擁有分享此內容的權利';

  @override
  String get defamationConfirmation => '此內容不誹謗任何個人或群體';

  @override
  String get lawsConfirmation => '我確認這符合我所在地區的適用法律';

  @override
  String captionHint(int limit) {
    return '新增說明… (選填，最多$limit個字元)';
  }

  @override
  String get addCategoryTagWarning => '發布新討論串前請先新增分類標籤。';

  @override
  String get tagFieldHint => '第一個標籤是活動分類 · 按空格或 , 新增更多';

  @override
  String get checkInSpotHint => '例如：台北101、中正紀念堂…';

  @override
  String get checkInSpotPlaceholder => '在某個地點打卡…';

  @override
  String publishNItems(int count) {
    return '發布$count個項目';
  }

  @override
  String get discoverSearchPlaceholder => '搜尋討論串或 #標籤';

  @override
  String get discoverTitle => '探索';

  @override
  String get removeFavoriteLabel => '移除最愛';

  @override
  String get addFavoriteLabel => '加入最愛';

  @override
  String get trendingTabLabel => '熱門';

  @override
  String get forYouTabLabel => '為你推薦';

  @override
  String get nearbyTabLabel => '附近';

  @override
  String get usersTabLabel => '用戶';

  @override
  String noThreadsFound(String search) {
    return '找不到「$search」的討論串';
  }

  @override
  String noUsersFound(String search) {
    return '找不到「$search」的用戶';
  }

  @override
  String get nothingTrending => '過去48小時沒有熱門內容';

  @override
  String get noRecommendedPosts => '目前還沒有推薦貼文';

  @override
  String get setInterestsPrompt => '設定您的興趣以查看個人化內容';

  @override
  String get noEventsNearby => '附近沒有活動';

  @override
  String get enableLocationPrompt => '啟用位置以查看附近活動';

  @override
  String get allowLocationButton => '允許位置存取';

  @override
  String get participantsLabel => '參與者';

  @override
  String get splashLoadingTitle => '載入Spot中';

  @override
  String get splashLoadingSubtitle => '正在獲取最新資料並儲存至本機…';

  @override
  String get splashRefreshingTitle => '更新資料中…';

  @override
  String get splashRefreshingSubtitle => '正在確認新貼文並儲存更新至本機…';

  @override
  String get assetTransportScreenTitle => '資源傳輸';

  @override
  String get peerTransportSection => '點對點傳輸';

  @override
  String get peerTransportDescription =>
      '控制Spot何時可以透過點對點傳輸共享和獲取完整圖片和影片，以避免意外使用行動數據。';

  @override
  String get cdnAccelerationSection => 'CDN加速';

  @override
  String get cdnAccelerationDescription =>
      '使用內容傳遞網路加快媒體載入速度。CDN擷取和上傳預設為啟用；在此停用以僅使用點對點傳輸。';

  @override
  String get cdnFetchLabel => 'CDN擷取與快取';

  @override
  String get cdnFetchDescription => '可用時從CDN下載媒體（更快）。';

  @override
  String get cdnUploadLabel => 'CDN上傳';

  @override
  String get cdnUploadDescription => '將您的媒體上傳至CDN，讓其他人可以更快速地獲取。';

  @override
  String get alwaysOption => '始終';

  @override
  String get wifiOnlyOption => '僅限Wi-Fi';

  @override
  String get offOption => '關閉';

  @override
  String get cdnUploadNotConfigured => '此版本未設定CDN上傳';

  @override
  String get threadTitle => '討論串';

  @override
  String get threadNotAvailable => '討論串無法使用';

  @override
  String get replyToPostUnavailable => '您正在回覆的貼文無法使用。';

  @override
  String get videoLabel => '影片';

  @override
  String get imageLabel => '圖片';

  @override
  String get loadingFullVideo => '載入完整影片中…';

  @override
  String get loadingFullImage => '載入完整圖片中…';

  @override
  String get loadingFullMedia => '載入完整媒體中…';

  @override
  String get mediaUnavailable => '完整媒體目前仍無法使用。目前僅顯示預覽。';

  @override
  String get couldNotLoadMedia => '目前無法載入完整媒體。';

  @override
  String get tapToPause => '點擊暫停';

  @override
  String get tapToPlay => '點擊播放';

  @override
  String get couldNotRenderImage => '無法渲染此圖片';

  @override
  String get couldNotRenderPreview => '無法渲染此預覽';

  @override
  String get tapRetryToLoad => '點擊重試以載入完整媒體';

  @override
  String get myPostedThreadsTitle => '已發佈的討論串';

  @override
  String get myRepliedThreadsTitle => '已回覆的討論串';

  @override
  String get threadsPublicHint => '您公開發布的討論串將在此顯示';

  @override
  String get repliesPublicHint => '您公開發布的回覆將在此顯示';

  @override
  String get muteUser => '靜音用戶';

  @override
  String get unmuteUser => '取消靜音';

  @override
  String get blockUser => '封鎖用戶';

  @override
  String get unblockUser => '解除封鎖';

  @override
  String get blockedUsersTitle => '已封鎖的用戶';

  @override
  String get blockedUsersEmpty => '您尚未封鎖任何人。';

  @override
  String get blockedUsersUnblockButton => '解除封鎖';

  @override
  String get blockedUsersUnblockConfirmTitle => '解除封鎖此用戶？';

  @override
  String get blockedUsersUnblockConfirmBody => '他們將能夠查看您的內容並再次與您互動。';

  @override
  String get reportUser => '檢舉用戶';

  @override
  String get userOptionsTitle => '用戶選項';

  @override
  String get threadsPrivate => '此帳戶未在其公開個人資料上分享頂層討論串。';

  @override
  String get repliesPrivate => '此帳戶未在其公開個人資料上分享回覆。';

  @override
  String get footprintMapPrivate => '此帳戶未與其他用戶分享足跡地圖。';

  @override
  String get userReported => '用戶已被檢舉。';

  @override
  String followUpdateFailed(String error) {
    return '追蹤更新失敗：$error';
  }

  @override
  String get favoriteTopicsTitle => '最愛主題';

  @override
  String get favoriteTopicsSubtitle => '選擇至少3個主題以個人化您的推薦動態。';

  @override
  String get addCustomHashtagHint => '新增自訂主題標籤';

  @override
  String get selectAtLeast3 => '請至少選擇3個';

  @override
  String get deletePost => '刪除貼文';

  @override
  String get reportContent => '檢舉內容';

  @override
  String get savedLocallyOnly => '僅儲存至本機。點擊重新整理以重新發送。';

  @override
  String get notPostedYet => '尚未發布。點擊重新整理以重新發送。';

  @override
  String get tapPhotoHoldVideo => '點擊 · 拍照   長按 · 錄影';

  @override
  String get writeReplyHint => '寫下回覆…';

  @override
  String replyingToUser(String pubkey) {
    return '正在回覆$pubkey';
  }

  @override
  String replyToEvent(String event) {
    return '回覆$event';
  }

  @override
  String get tapToLoadMedia => '點擊載入媒體';

  @override
  String get tapToLoadFull => '點擊載入完整版';

  @override
  String get downloadingFromCdn => '從CDN下載中…';

  @override
  String get preparingVideo => '準備影片中…';

  @override
  String get imageUnavailable => '目前無法使用圖片';

  @override
  String get noGps => '無GPS';

  @override
  String get locationHidden => '位置已隱藏';

  @override
  String get noLocation => '無位置資訊';

  @override
  String get pinnedPost => '置頂貼文';

  @override
  String videoNOfTotal(int n, int total) {
    return '影片 $n/$total';
  }

  @override
  String get openInDiscover => '在探索中開啟';

  @override
  String get openFullScreenMap => '開啟全螢幕地圖';

  @override
  String get zoomIn => '放大';

  @override
  String get zoomOut => '縮小';

  @override
  String get mapAttribution => '地圖圖塊：OpenStreetMap / CARTO';

  @override
  String get locationLabel => '位置';

  @override
  String get threadsTabLabel => '討論串';

  @override
  String get repliesTabLabel => '回覆';

  @override
  String get mapTabLabel => '地圖';

  @override
  String get footprintMapTitle => '足跡地圖';

  @override
  String get noLocations => '無位置資訊';

  @override
  String get unknownLabel => '未知';

  @override
  String get eventPostLabel => '貼文';

  @override
  String get eventReplyLabel => '回覆';

  @override
  String eventPostsContributors(int count, int contributors) {
    return '$count則貼文 · $contributors位貢獻者';
  }

  @override
  String mediaViewerPageTitle(String label, int n, int total) {
    return '$label $n/$total';
  }

  @override
  String get threadsArePrivateTitle => '討論串為私人';

  @override
  String get repliesArePrivateTitle => '回覆為私人';

  @override
  String get footprintMapIsPrivateTitle => '足跡地圖為私人';

  @override
  String get repliesFromAccountHint => '此帳號的回覆將顯示於此';

  @override
  String get noTopLevelThreadsHint => '此帳號尚無頂層討論串';

  @override
  String saveNInterests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '儲存 $count 個興趣',
    );
    return '$_temp0';
  }

  @override
  String get threadStatLabel => '討論串';

  @override
  String get replyStatLabel => '回覆';

  @override
  String footprintCountriesVisited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已造訪 $count 個國家',
    );
    return '$_temp0';
  }

  @override
  String get previewLabel => '預覽';

  @override
  String get mediaCheckBackLater => '稍後再查看';

  @override
  String get mediaDownloadViaCdnOrP2p => '透過 CDN 或 P2P 下載';

  @override
  String get protectedTooltip => '已保護';

  @override
  String get aiGeneratedTooltip => 'AI 生成';

  @override
  String get notSentTooltip => '未傳送';

  @override
  String get secondhandTooltip => '二手資訊';

  @override
  String descriptionWordCountHelper(int count, int max) {
    return '$count/$max 字';
  }

  @override
  String replyToShortKey(String key) {
    return '回覆 $key';
  }

  @override
  String get whatsHappeningHint => '現在發生什麼事？';

  @override
  String get postButton => '發布';

  @override
  String get beforePostSubtitle => '分享前請確認以下所有事項。';

  @override
  String get accuracyConfirmation => '我所分享的資訊在我所知範圍內是準確的';

  @override
  String get ugcTermsTitle => '同意社群使用條款';

  @override
  String get ugcTermsSubtitle => '#seen 含有使用者產生的貼文與個人檔案。您必須先同意這些條款，才能存取社群內容。';

  @override
  String get ugcTermsSafetyHeading => '對不當內容與濫用行為零容忍';

  @override
  String get ugcTermsBulletRespect => '請勿張貼令人反感的內容、騷擾、仇恨、威脅、性剝削或血腥暴力虐待內容。';

  @override
  String get ugcTermsBulletModeration => '被檢舉的貼文與帳號可能會被隱藏、審查、禁止發文或移除。';

  @override
  String get ugcTermsBulletReporting => '當您遇到不安全內容或濫用使用者時，請使用檢舉與封鎖工具。';

  @override
  String get ugcTermsBulletEnforcement => '違規行為可能導致內容刪除、發文限制或帳號停用。';

  @override
  String get ugcTermsAgreement =>
      '我同意 #seen 的使用條款與隱私權政策，並了解 #seen 對令人反感的內容或濫用使用者採取零容忍政策。';

  @override
  String get ugcTermsAgreeButton => '同意並繼續';

  @override
  String get ugcTermsViewTerms => '使用條款';

  @override
  String get ugcTermsViewPrivacy => '隱私權政策';

  @override
  String get reportUserTitle => '檢舉此使用者';

  @override
  String get reportUserSubtitle => '請告訴管理員此帳號的問題，以便他們進行審查。';

  @override
  String get reportReasonLabel => '原因';

  @override
  String get reportDetailsLabel => '詳細資訊';

  @override
  String get reportUserDetailsHint => '提供給管理員的選填說明';

  @override
  String get submitUserReportButton => '送出檢舉';

  @override
  String get reportReasonHarassment => '騷擾';

  @override
  String get reportReasonHate => '仇恨或極端主義';

  @override
  String get reportReasonSexualContent => '色情內容';

  @override
  String get reportReasonViolence => '暴力';

  @override
  String get reportReasonSpam => '垃圾訊息或詐騙';

  @override
  String get reportReasonImpersonation => '冒充他人';

  @override
  String get reportReasonOther => '其他';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '#seen';

  @override
  String get cancelAction => '取消';

  @override
  String get retryButton => '重試';

  @override
  String get backButton => '返回';

  @override
  String get continueButton => '繼續';

  @override
  String get copiedSnackbar => '已複製';

  @override
  String get loadingLabel => '載入中';

  @override
  String get savingLabel => '儲存中…';

  @override
  String get updatingLabel => '更新中…';

  @override
  String get locatingLabel => '定位中…';

  @override
  String get verifyingStatus => '驗證中…';

  @override
  String get verifiedStatus => '已驗證';

  @override
  String get verificationFailedStatus => '驗證失敗';

  @override
  String get deleteButton => '刪除';

  @override
  String get clearButton => '清除';

  @override
  String get clearAllButton => '全部清除';

  @override
  String get hideButton => '隱藏';

  @override
  String get unlockButton => '解鎖';

  @override
  String get followButton => '追蹤';

  @override
  String get followingLabel => '追蹤中';

  @override
  String get followersLabel => '追蹤者';

  @override
  String get postsLabel => '貼文';

  @override
  String get joinedLabel => '加入時間';

  @override
  String get notSetValue => '未設定';

  @override
  String get youLabel => '你';

  @override
  String get citizenDefaultName => '公民';

  @override
  String get altchaAttribution => '由ALTCHA保護';

  @override
  String get altchaVerificationFailed => 'ALTCHA驗證失敗';

  @override
  String get reportedContentHidden => '已檢舉。內容已隱藏。';

  @override
  String get welcomeTagline => '去中心化媒體。\n拍攝時即時驗證。';

  @override
  String get welcomeBullet1 => '與裝置綁定的密碼學身份';

  @override
  String get welcomeBullet2 => '拍攝時GPS鎖定';

  @override
  String get welcomeBullet3 => '隱私模式 — 模糊照片中的臉孔、隱藏位置';

  @override
  String get welcomeBullet4 => '點對點，無中央伺服器';

  @override
  String get getStartedButton => '開始使用';

  @override
  String get createIdentityTitle => '建立身份';

  @override
  String get importIdentityTitle => '匯入身份';

  @override
  String get createIdentitySubtitle => '將會生成密鑰對並安全地儲存在此裝置上。';

  @override
  String get importIdentitySubtitle => '輸入您的12個單詞的恢復短語。';

  @override
  String get generateIdentityButton => '生成新身份';

  @override
  String get importExistingButton => '匯入現有身份';

  @override
  String get importIdentityButton => '匯入身份';

  @override
  String get importExactWordsError => '請精確輸入12個恢復單詞。';

  @override
  String invalidPhraseError(String error) {
    return '無效短語：$error';
  }

  @override
  String failedError(String error) {
    return '失敗：$error';
  }

  @override
  String get identityReadyTitle => '身份已準備就緒';

  @override
  String get yourPublicKeyLabel => '您的公鑰';

  @override
  String get recoveryPhraseLabel => '恢復短語';

  @override
  String get recoveryPhraseOnboardingDescription =>
      '這是在您遺失此裝置後恢復身份的唯一方法。請寫下這些單詞並妥善保管。';

  @override
  String get showRecoveryPhraseButton => '顯示恢復短語';

  @override
  String get showRecoveryQrButton => '顯示恢復 QR 碼';

  @override
  String get recoveryQrTitle => '恢復 QR 碼';

  @override
  String get recoveryQrDescription => '在新裝置上掃描此代碼即可恢復您的身份。';

  @override
  String get recoveryQrWarning => '任何能掃描此代碼的人都可以控制您的帳戶。請妥善保管。';

  @override
  String get saveRecoveryQrButton => '儲存恢復 QR 碼';

  @override
  String get recoveryQrSaved => '恢復 QR 碼已儲存到您的照片。';

  @override
  String get recoveryQrSaveFailed => '無法儲存恢復 QR 碼。';

  @override
  String get scanRecoveryQrButton => '掃描恢復 QR 碼';

  @override
  String get recoveryQrScannerTitle => '掃描恢復 QR 碼';

  @override
  String get recoveryQrScannerHint => '將相機對準恢復 QR 碼。';

  @override
  String get chooseRecoveryQrImageTooltip => '選擇 QR 圖片';

  @override
  String get recoveryQrNoCodeError => '在該圖片中找不到恢復 QR 碼。';

  @override
  String get invalidRecoveryQrError => '這不是有效的 #seen 恢復 QR 碼。';

  @override
  String get savedWordsButton => '我已儲存這些單詞';

  @override
  String get confirmBackupFirst => '請先確認備份';

  @override
  String get securingAccountTitle => '保護帳戶中';

  @override
  String get checkingOwnerSubtitle => '正在檢查此裝置驗證已儲存擁有者的方式…';

  @override
  String get savedAccountLockedTitle => '已儲存的帳戶已鎖定';

  @override
  String get accountLockedDescription =>
      '公開討論串仍為公開狀態，但此手機上的私人帳戶存取將保持鎖定，直到當前擁有者解鎖或重置。';

  @override
  String get accountLabel => '帳戶';

  @override
  String get identitiesLabel => '身份';

  @override
  String get switchIdentityTitle => '切換身份';

  @override
  String get switchIdentitySubtitle => '在此裝置上分開管理個人、公司、工作室和品牌身份。';

  @override
  String get identitySwitcherSecurityNote => '每個身份都有自己的金鑰對。請勿分享主要身份的恢復短語。';

  @override
  String get mainIdentityLabel => '主要身份';

  @override
  String get activeIdentityLabel => '使用中';

  @override
  String get addIdentityButton => '新增身份';

  @override
  String get addIdentityTitle => '新增身份';

  @override
  String get identityNameLabel => '身份名稱';

  @override
  String get identityNameHint => '個人、工作室、品牌…';

  @override
  String get identityTypeLabel => '類型';

  @override
  String get personalIdentityType => '個人';

  @override
  String get companyIdentityType => '公司';

  @override
  String get studioIdentityType => '工作室';

  @override
  String get brandIdentityType => '品牌';

  @override
  String get customIdentityType => '自訂';

  @override
  String removeIdentityTitle(String name) {
    return '移除$name？';
  }

  @override
  String get removeIdentityContent => '這會從此裝置移除身份及其恢復秘密。遠端資料不會被刪除。';

  @override
  String get removeIdentityButton => '移除身份';

  @override
  String get identityVaultUnavailable => '找不到本機身份保管庫。';

  @override
  String identitySwitchFailed(String error) {
    return '無法切換身份：$error';
  }

  @override
  String get createdLabel => '建立時間';

  @override
  String get unlockThisAccountButton => '解鎖此帳戶';

  @override
  String get unlockWithPhraseButton => '使用恢復短語解鎖';

  @override
  String get notMyAccountButton => '這不是我的帳戶';

  @override
  String get unlockCancelledError => '解鎖已取消或失敗。在此裝置擁有者確認存取之前，Spot將保持鎖定。';

  @override
  String failedResetAccount(String error) {
    return '重置已儲存帳戶失敗：$error';
  }

  @override
  String get unlockWithPhraseDialogTitle => '使用恢復短語解鎖';

  @override
  String get unlockPhraseDescription => '輸入此已儲存帳戶的12個單詞恢復短語。';

  @override
  String get enterExactPhraseError => '請輸入精確的12個單詞恢復短語。';

  @override
  String get phraseMismatchError => '恢復短語與此已儲存帳戶不符。';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsTooltip => '設定';

  @override
  String get termsOfUseTitle => '使用條款';

  @override
  String get privacyPolicyTitle => '隱私權政策';

  @override
  String get favoriteTopicsLabel => '最愛主題';

  @override
  String get assetTransportLabel => '資源傳輸';

  @override
  String get languageLabel => '語言';

  @override
  String get languageMenuMessage => '選擇整個應用程式要使用的語言。';

  @override
  String get systemDefaultLanguageOption => '跟隨系統';

  @override
  String get viewMyActivityLabel => '查看我的活動';

  @override
  String get privacySectionLabel => '隱私';

  @override
  String get footprintMapLabel => '足跡地圖';

  @override
  String get publicThreadsLabel => '公開討論串';

  @override
  String get publicRepliesLabel => '公開回覆';

  @override
  String get storageSectionLabel => '儲存空間';

  @override
  String get clearCacheLabel => '清除快取';

  @override
  String get clearLocalDataLabel => '清除本機資料';

  @override
  String get sessionSectionLabel => '工作階段';

  @override
  String get safeModeLabel => '安全模式';

  @override
  String get logOutLabel => '登出';

  @override
  String get signingOutLabel => '登出中…';

  @override
  String get clearCacheDialogContent => '這將刪除所有快取的媒體檔案。您的貼文和設定不會受到影響。';

  @override
  String get cacheClearedSnackbar => '快取已清除';

  @override
  String get clearLocalDataDialogContent =>
      '這將刪除所有本機資料，包括：\n• 快取媒體\n• 已儲存的貼文\n• 最愛標籤和偏好設定\n• 封鎖清單\n\n您的帳戶不會被刪除。遠端資料將從Supabase重新同步。';

  @override
  String get localDataClearedSnackbar => '本機資料已清除。請重新啟動應用程式以重新同步。';

  @override
  String get logOutDialogTitle => '確定要登出嗎？';

  @override
  String get logOutDialogContent =>
      '登出前，請確保您已儲存12個單詞的恢復短語。稍後恢復相同身份時需要用到它。登出將使您在此裝置上登出並清除本機應用程式資料。您的Supabase帳戶和遠端貼文將保持完整。';

  @override
  String get logOutConfirmButton => '登出';

  @override
  String failedLoadPrivacy(String error) {
    return '載入隱私設定失敗：$error';
  }

  @override
  String failedUpdatePrivacy(String error) {
    return '更新隱私設定失敗：$error';
  }

  @override
  String failedUpdateSafeMode(String error) {
    return '更新安全模式失敗：$error';
  }

  @override
  String failedUpdateLanguage(String error) {
    return '更新語言失敗：$error';
  }

  @override
  String failedLogOut(String error) {
    return '登出失敗：$error';
  }

  @override
  String get publicActivityTitle => '公開活動';

  @override
  String get publicActivityMessage => '選擇要開啟的公開貼文。';

  @override
  String get postedThreadsOption => '已發佈的討論串';

  @override
  String get repliedThreadsOption => '已回覆的討論串';

  @override
  String get walletAccountTitle => '帳戶';

  @override
  String get thisDeviceSectionTitle => '此裝置';

  @override
  String get deviceSectionDescription =>
      '個人資料名稱和頭像可在個人資料分頁中編輯。裝置簽名密鑰保留在應用程式內部。';

  @override
  String get deviceLabel => '裝置';

  @override
  String get postingLimitsSectionTitle => '發文限制';

  @override
  String get checkingDailyLimits => '正在確認您目前的每日限制…';

  @override
  String get postingLimitsLoadError => '目前無法載入您的發文限制。';

  @override
  String get recoveryPhraseWalletDescription => '這12個單詞是登出或移至新裝置後恢復此身份的唯一方法。';

  @override
  String get copyPhraseButton => '複製短語';

  @override
  String get recoveryPhraseCopied => '恢復短語已複製';

  @override
  String get dangerZoneSectionTitle => '危險區域';

  @override
  String get deleteAccountDescription => '從Supabase刪除此帳戶並清除此裝置上的本機應用程式資料。';

  @override
  String get deleteAccountButton => '刪除此帳戶';

  @override
  String get deleteAccountDialogTitle => '刪除此帳戶？';

  @override
  String get deleteAccountDialogContent =>
      '這將永久從Supabase移除您的Spot個人資料和貼文，然後清除此裝置上的本機應用程式資料。此操作無法復原。';

  @override
  String failedDeleteAccount(String error) {
    return '刪除帳戶失敗：$error';
  }

  @override
  String get postingBlocked => '此帳戶的發文目前已被封鎖。';

  @override
  String get postingQuotaDescription => '您可以在開啟編輯器前在此確認剩餘的討論串和回覆發布次數。';

  @override
  String get tierLabel => '等級';

  @override
  String get threadsLabel => '討論串';

  @override
  String get repliesLabel => '回覆';

  @override
  String get usedLabel => '已使用';

  @override
  String postingQuotaResetsAt(String resetTime) {
    return '將於$resetTime重置（下一個UTC午夜）。';
  }

  @override
  String postingRemainingOf(int remaining, int total) {
    return '$total個中剩餘$remaining個';
  }

  @override
  String postingUsedCount(int threads, int replies) {
    return '討論串$threads個，回覆$replies個';
  }

  @override
  String get latestTabLabel => '最新';

  @override
  String get followingTabLabel => '追蹤中';

  @override
  String get couldNotLoadPosts => '無法載入貼文';

  @override
  String get noPostsYet => '尚無貼文';

  @override
  String get beFirstToRecord => '成為第一個記錄者';

  @override
  String get noFollowingPosts => '沒有您追蹤的人的貼文';

  @override
  String get tapAvatarToFollow => '點擊頭像來追蹤某人';

  @override
  String get homeNavLabel => '首頁';

  @override
  String get discoverNavLabel => '探索';

  @override
  String get eventsNavLabel => '活動';

  @override
  String get profileNavLabel => '個人資料';

  @override
  String get eventsTabTitle => '活動';

  @override
  String get allEventsTabLabel => '全部';

  @override
  String get noEventsYet => '尚無活動';

  @override
  String get noFollowedEventsLive => '沒有正在進行的追蹤活動';

  @override
  String get noFollowedTagsYet => '尚未追蹤任何標籤';

  @override
  String get followedTagsDescription => '當有符合的直播活動出現時，追蹤的標籤將在此顯示。';

  @override
  String get followTagPrompt => '從探索或活動詳情畫面追蹤標籤以在此顯示。';

  @override
  String get profileTitle => '個人資料';

  @override
  String get editProfileTitle => '編輯個人資料';

  @override
  String get usernameFieldLabel => '用戶名';

  @override
  String get usernameFieldHint => '公民名稱';

  @override
  String get descriptionFieldLabel => '簡介';

  @override
  String get descriptionFieldHint => '關於您的簡單描述';

  @override
  String get tapAvatarHint => '點擊頭像選擇新圖片';

  @override
  String get saveProfileButton => '儲存個人資料';

  @override
  String get descriptionTooLongError => '請使用100個單詞或更少';

  @override
  String get captureAMomentHint => '記錄一個時刻以顯示在此';

  @override
  String get repliesPostedHint => '您發布的回覆將在此顯示';

  @override
  String get noThreadsYet => '尚無討論串';

  @override
  String get noRepliesYet => '尚無回覆';

  @override
  String get removedLocalPost => '已移除本機未發送的貼文';

  @override
  String get postDeleted => '貼文已刪除。群集參與者將收到移除本機副本的通知。';

  @override
  String get failedDeletePost => '刪除貼文失敗';

  @override
  String get postSent => '貼文已發送';

  @override
  String get retryFailed => '重試失敗。貼文仍儲存在本機。';

  @override
  String get profileUpdated => '個人資料已更新';

  @override
  String profileUpdatedWithWarning(String warning) {
    return '個人資料已更新。$warning';
  }

  @override
  String failedUpdateProfile(String error) {
    return '更新個人資料失敗：$error';
  }

  @override
  String get avatarNotUpdated => '頭像未更新。請再試一次。';

  @override
  String get avatarNotUpdatedTimeSync => '頭像未更新。請開啟自動日期和時間後再試。';

  @override
  String get takePhotoOption => '拍照';

  @override
  String get recordVideoOption => '錄影';

  @override
  String get maxMediaItemsWarning => '每則貼文最多4個媒體項目';

  @override
  String get categoryTagHint => '分類標籤（例如：AWSSummitTokyo2026）';

  @override
  String get addMoreTagsHint => '新增更多標籤…';

  @override
  String get createCategoryTagTooltip => '建立分類標籤';

  @override
  String get createTagTooltip => '建立標籤';

  @override
  String get postModeLabel => '發文模式';

  @override
  String get standardModeLabel => '標準';

  @override
  String get virtualModeLabel => '虛擬';

  @override
  String get checkInLabel => '在某個地點打卡';

  @override
  String get checkInSubtitle => '以地點名稱發布精確位置';

  @override
  String get blurFacesLabel => '模糊臉孔';

  @override
  String get blurFacesSubtitle => '自動模糊照片中偵測到的臉孔';

  @override
  String get aiGeneratedLabel => 'AI生成內容';

  @override
  String get aiGeneratedSubtitle => '內容由AI創建或輔助生成';

  @override
  String get secondhandLabel => '他人的故事';

  @override
  String get secondhandSubtitle => '您正在分享間接描述';

  @override
  String get publishFailedSaved => '發布失敗。已儲存至個人資料，您可以重試。';

  @override
  String publishFailedError(String error) {
    return '發布失敗：$error';
  }

  @override
  String get publishButton => '發布';

  @override
  String get confirmAndPostButton => '確認並發文';

  @override
  String get beforePostTitle => '發文前';

  @override
  String get yesLabel => '是';

  @override
  String get noLabel => '否';

  @override
  String get rightsConfirmation => '我擁有分享此內容的權利';

  @override
  String get defamationConfirmation => '此內容不誹謗任何個人或群體';

  @override
  String get lawsConfirmation => '我確認這符合我所在地區的適用法律';

  @override
  String captionHint(int limit) {
    return '新增說明… (選填，最多$limit個字元)';
  }

  @override
  String get addCategoryTagWarning => '發布新討論串前請先新增分類標籤。';

  @override
  String get tagFieldHint => '第一個標籤是活動分類 · 按空格或 , 新增更多';

  @override
  String get checkInSpotHint => '例如：台北101、中正紀念堂…';

  @override
  String get checkInSpotPlaceholder => '在某個地點打卡…';

  @override
  String publishNItems(int count) {
    return '發布$count個項目';
  }

  @override
  String get discoverSearchPlaceholder => '搜尋討論串或 #標籤';

  @override
  String get discoverTitle => '探索';

  @override
  String get removeFavoriteLabel => '移除最愛';

  @override
  String get addFavoriteLabel => '加入最愛';

  @override
  String get trendingTabLabel => '熱門';

  @override
  String get forYouTabLabel => '為你推薦';

  @override
  String get nearbyTabLabel => '附近';

  @override
  String get usersTabLabel => '用戶';

  @override
  String noThreadsFound(String search) {
    return '找不到「$search」的討論串';
  }

  @override
  String noUsersFound(String search) {
    return '找不到「$search」的用戶';
  }

  @override
  String get nothingTrending => '過去48小時沒有熱門內容';

  @override
  String get noRecommendedPosts => '目前還沒有推薦貼文';

  @override
  String get setInterestsPrompt => '設定您的興趣以查看個人化內容';

  @override
  String get noEventsNearby => '附近沒有活動';

  @override
  String get enableLocationPrompt => '啟用位置以查看附近活動';

  @override
  String get allowLocationButton => '允許位置存取';

  @override
  String get participantsLabel => '參與者';

  @override
  String get splashLoadingTitle => '載入Spot中';

  @override
  String get splashLoadingSubtitle => '正在獲取最新資料並儲存至本機…';

  @override
  String get splashRefreshingTitle => '更新資料中…';

  @override
  String get splashRefreshingSubtitle => '正在確認新貼文並儲存更新至本機…';

  @override
  String get assetTransportScreenTitle => '資源傳輸';

  @override
  String get peerTransportSection => '點對點傳輸';

  @override
  String get peerTransportDescription =>
      '控制Spot何時可以透過點對點傳輸共享和獲取完整圖片和影片，以避免意外使用行動數據。';

  @override
  String get cdnAccelerationSection => 'CDN加速';

  @override
  String get cdnAccelerationDescription =>
      '使用內容傳遞網路加快媒體載入速度。CDN擷取和上傳預設為啟用；在此停用以僅使用點對點傳輸。';

  @override
  String get cdnFetchLabel => 'CDN擷取與快取';

  @override
  String get cdnFetchDescription => '可用時從CDN下載媒體（更快）。';

  @override
  String get cdnUploadLabel => 'CDN上傳';

  @override
  String get cdnUploadDescription => '將您的媒體上傳至CDN，讓其他人可以更快速地獲取。';

  @override
  String get alwaysOption => '始終';

  @override
  String get wifiOnlyOption => '僅限Wi-Fi';

  @override
  String get offOption => '關閉';

  @override
  String get cdnUploadNotConfigured => '此版本未設定CDN上傳';

  @override
  String get threadTitle => '討論串';

  @override
  String get threadNotAvailable => '討論串無法使用';

  @override
  String get replyToPostUnavailable => '您正在回覆的貼文無法使用。';

  @override
  String get videoLabel => '影片';

  @override
  String get imageLabel => '圖片';

  @override
  String get loadingFullVideo => '載入完整影片中…';

  @override
  String get loadingFullImage => '載入完整圖片中…';

  @override
  String get loadingFullMedia => '載入完整媒體中…';

  @override
  String get mediaUnavailable => '完整媒體目前仍無法使用。目前僅顯示預覽。';

  @override
  String get couldNotLoadMedia => '目前無法載入完整媒體。';

  @override
  String get tapToPause => '點擊暫停';

  @override
  String get tapToPlay => '點擊播放';

  @override
  String get couldNotRenderImage => '無法渲染此圖片';

  @override
  String get couldNotRenderPreview => '無法渲染此預覽';

  @override
  String get tapRetryToLoad => '點擊重試以載入完整媒體';

  @override
  String get myPostedThreadsTitle => '已發佈的討論串';

  @override
  String get myRepliedThreadsTitle => '已回覆的討論串';

  @override
  String get threadsPublicHint => '您公開發布的討論串將在此顯示';

  @override
  String get repliesPublicHint => '您公開發布的回覆將在此顯示';

  @override
  String get muteUser => '靜音用戶';

  @override
  String get unmuteUser => '取消靜音';

  @override
  String get blockUser => '封鎖用戶';

  @override
  String get unblockUser => '解除封鎖';

  @override
  String get blockedUsersTitle => '已封鎖的用戶';

  @override
  String get blockedUsersEmpty => '您尚未封鎖任何人。';

  @override
  String get blockedUsersUnblockButton => '解除封鎖';

  @override
  String get blockedUsersUnblockConfirmTitle => '解除封鎖此用戶？';

  @override
  String get blockedUsersUnblockConfirmBody => '他們將能夠查看您的內容並再次與您互動。';

  @override
  String get reportUser => '檢舉用戶';

  @override
  String get userOptionsTitle => '用戶選項';

  @override
  String get threadsPrivate => '此帳戶未在其公開個人資料上分享頂層討論串。';

  @override
  String get repliesPrivate => '此帳戶未在其公開個人資料上分享回覆。';

  @override
  String get footprintMapPrivate => '此帳戶未與其他用戶分享足跡地圖。';

  @override
  String get userReported => '用戶已被檢舉。';

  @override
  String followUpdateFailed(String error) {
    return '追蹤更新失敗：$error';
  }

  @override
  String get favoriteTopicsTitle => '最愛主題';

  @override
  String get favoriteTopicsSubtitle => '選擇至少3個主題以個人化您的推薦動態。';

  @override
  String get addCustomHashtagHint => '新增自訂主題標籤';

  @override
  String get selectAtLeast3 => '請至少選擇3個';

  @override
  String get deletePost => '刪除貼文';

  @override
  String get reportContent => '檢舉內容';

  @override
  String get savedLocallyOnly => '僅儲存至本機。點擊重新整理以重新發送。';

  @override
  String get notPostedYet => '尚未發布。點擊重新整理以重新發送。';

  @override
  String get tapPhotoHoldVideo => '點擊 · 拍照   長按 · 錄影';

  @override
  String get writeReplyHint => '寫下回覆…';

  @override
  String replyingToUser(String pubkey) {
    return '正在回覆$pubkey';
  }

  @override
  String replyToEvent(String event) {
    return '回覆$event';
  }

  @override
  String get tapToLoadMedia => '點擊載入媒體';

  @override
  String get tapToLoadFull => '點擊載入完整版';

  @override
  String get downloadingFromCdn => '從CDN下載中…';

  @override
  String get preparingVideo => '準備影片中…';

  @override
  String get imageUnavailable => '目前無法使用圖片';

  @override
  String get noGps => '無GPS';

  @override
  String get locationHidden => '位置已隱藏';

  @override
  String get noLocation => '無位置資訊';

  @override
  String get pinnedPost => '置頂貼文';

  @override
  String videoNOfTotal(int n, int total) {
    return '影片 $n/$total';
  }

  @override
  String get openInDiscover => '在探索中開啟';

  @override
  String get openFullScreenMap => '開啟全螢幕地圖';

  @override
  String get zoomIn => '放大';

  @override
  String get zoomOut => '縮小';

  @override
  String get mapAttribution => '地圖圖塊：OpenStreetMap / CARTO';

  @override
  String get locationLabel => '位置';

  @override
  String get threadsTabLabel => '討論串';

  @override
  String get repliesTabLabel => '回覆';

  @override
  String get mapTabLabel => '地圖';

  @override
  String get footprintMapTitle => '足跡地圖';

  @override
  String get noLocations => '無位置資訊';

  @override
  String get unknownLabel => '未知';

  @override
  String get eventPostLabel => '貼文';

  @override
  String get eventReplyLabel => '回覆';

  @override
  String eventPostsContributors(int count, int contributors) {
    return '$count則貼文 · $contributors位貢獻者';
  }

  @override
  String mediaViewerPageTitle(String label, int n, int total) {
    return '$label $n/$total';
  }

  @override
  String get threadsArePrivateTitle => '討論串為私人';

  @override
  String get repliesArePrivateTitle => '回覆為私人';

  @override
  String get footprintMapIsPrivateTitle => '足跡地圖為私人';

  @override
  String get repliesFromAccountHint => '此帳號的回覆將顯示於此';

  @override
  String get noTopLevelThreadsHint => '此帳號尚無頂層討論串';

  @override
  String saveNInterests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '儲存 $count 個興趣',
    );
    return '$_temp0';
  }

  @override
  String get threadStatLabel => '討論串';

  @override
  String get replyStatLabel => '回覆';

  @override
  String footprintCountriesVisited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已造訪 $count 個國家',
    );
    return '$_temp0';
  }

  @override
  String get previewLabel => '預覽';

  @override
  String get mediaCheckBackLater => '稍後再查看';

  @override
  String get mediaDownloadViaCdnOrP2p => '透過 CDN 或 P2P 下載';

  @override
  String get protectedTooltip => '已保護';

  @override
  String get aiGeneratedTooltip => 'AI 生成';

  @override
  String get notSentTooltip => '未傳送';

  @override
  String get secondhandTooltip => '二手資訊';

  @override
  String descriptionWordCountHelper(int count, int max) {
    return '$count/$max 字';
  }

  @override
  String replyToShortKey(String key) {
    return '回覆 $key';
  }

  @override
  String get whatsHappeningHint => '現在發生什麼事？';

  @override
  String get postButton => '發布';

  @override
  String get beforePostSubtitle => '分享前請確認以下所有事項。';

  @override
  String get accuracyConfirmation => '我所分享的資訊在我所知範圍內是準確的';

  @override
  String get ugcTermsTitle => '同意社群使用條款';

  @override
  String get ugcTermsSubtitle => '#seen 含有使用者產生的貼文與個人檔案。您必須先同意這些條款，才能存取社群內容。';

  @override
  String get ugcTermsSafetyHeading => '對不當內容與濫用行為零容忍';

  @override
  String get ugcTermsBulletRespect => '請勿張貼令人反感的內容、騷擾、仇恨、威脅、性剝削或血腥暴力虐待內容。';

  @override
  String get ugcTermsBulletModeration => '被檢舉的貼文與帳號可能會被隱藏、審查、禁止發文或移除。';

  @override
  String get ugcTermsBulletReporting => '當您遇到不安全內容或濫用使用者時，請使用檢舉與封鎖工具。';

  @override
  String get ugcTermsBulletEnforcement => '違規行為可能導致內容刪除、發文限制或帳號停用。';

  @override
  String get ugcTermsAgreement =>
      '我同意 #seen 的使用條款與隱私權政策，並了解 #seen 對令人反感的內容或濫用使用者採取零容忍政策。';

  @override
  String get ugcTermsAgreeButton => '同意並繼續';

  @override
  String get ugcTermsViewTerms => '使用條款';

  @override
  String get ugcTermsViewPrivacy => '隱私權政策';

  @override
  String get reportUserTitle => '檢舉此使用者';

  @override
  String get reportUserSubtitle => '請告訴管理員此帳號的問題，以便他們進行審查。';

  @override
  String get reportReasonLabel => '原因';

  @override
  String get reportDetailsLabel => '詳細資訊';

  @override
  String get reportUserDetailsHint => '提供給管理員的選填說明';

  @override
  String get submitUserReportButton => '送出檢舉';

  @override
  String get reportReasonHarassment => '騷擾';

  @override
  String get reportReasonHate => '仇恨或極端主義';

  @override
  String get reportReasonSexualContent => '色情內容';

  @override
  String get reportReasonViolence => '暴力';

  @override
  String get reportReasonSpam => '垃圾訊息或詐騙';

  @override
  String get reportReasonImpersonation => '冒充他人';

  @override
  String get reportReasonOther => '其他';
}

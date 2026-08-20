// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => '#seen';

  @override
  String get cancelAction => 'キャンセル';

  @override
  String get retryButton => '再試行';

  @override
  String get backButton => '戻る';

  @override
  String get continueButton => '続ける';

  @override
  String get copiedSnackbar => 'コピーしました';

  @override
  String get loadingLabel => '読み込み中';

  @override
  String get savingLabel => '保存中…';

  @override
  String get updatingLabel => '更新中…';

  @override
  String get locatingLabel => '位置情報取得中…';

  @override
  String get verifyingStatus => '確認中…';

  @override
  String get verifiedStatus => '確認済み';

  @override
  String get verificationFailedStatus => '確認失敗';

  @override
  String get deleteButton => '削除';

  @override
  String get clearButton => 'クリア';

  @override
  String get clearAllButton => 'すべてクリア';

  @override
  String get hideButton => '隠す';

  @override
  String get unlockButton => 'ロック解除';

  @override
  String get followButton => 'フォロー';

  @override
  String get followingLabel => 'フォロー中';

  @override
  String get followersLabel => 'フォロワー';

  @override
  String get postsLabel => '投稿';

  @override
  String get joinedLabel => '参加日';

  @override
  String get notSetValue => '未設定';

  @override
  String get youLabel => 'あなた';

  @override
  String get citizenDefaultName => '市民';

  @override
  String get altchaAttribution => 'ALTCHAで保護済み';

  @override
  String get altchaVerificationFailed => 'ALTCHA認証に失敗しました';

  @override
  String get reportedContentHidden => '報告済み。コンテンツを非表示にしました。';

  @override
  String get welcomeTagline => '分散型メディア。\n撮影時に認証済み。';

  @override
  String get welcomeBullet1 => 'デバイスに紐付けられた暗号化アイデンティティ';

  @override
  String get welcomeBullet2 => '撮影時にGPSロック';

  @override
  String get welcomeBullet3 => 'プライバシーモード — 顔をぼかし、位置情報を非表示';

  @override
  String get welcomeBullet4 => 'ピアツーピア、中央サーバーなし';

  @override
  String get getStartedButton => 'はじめる';

  @override
  String get createIdentityTitle => 'アイデンティティを作成';

  @override
  String get importIdentityTitle => 'アイデンティティをインポート';

  @override
  String get createIdentitySubtitle => 'キーペアが生成され、このデバイスに安全に保存されます。';

  @override
  String get importIdentitySubtitle => '12単語のリカバリーフレーズを入力してください。';

  @override
  String get generateIdentityButton => '新しいアイデンティティを生成';

  @override
  String get importExistingButton => '既存のものをインポート';

  @override
  String get importIdentityButton => 'アイデンティティをインポート';

  @override
  String get importExactWordsError => '正確に12個のリカバリーワードを入力してください。';

  @override
  String invalidPhraseError(String error) {
    return '無効なフレーズ: $error';
  }

  @override
  String failedError(String error) {
    return '失敗: $error';
  }

  @override
  String get identityReadyTitle => 'アイデンティティの準備完了';

  @override
  String get yourPublicKeyLabel => 'あなたの公開鍵';

  @override
  String get recoveryPhraseLabel => 'リカバリーフレーズ';

  @override
  String get recoveryPhraseOnboardingDescription =>
      'このデバイスを紛失した場合にアイデンティティを復元する唯一の方法です。書き留めて安全な場所に保管してください。';

  @override
  String get showRecoveryPhraseButton => 'リカバリーフレーズを表示';

  @override
  String get showRecoveryQrButton => '復元QRコードを表示';

  @override
  String get recoveryQrTitle => '復元QRコード';

  @override
  String get recoveryQrDescription => '新しいデバイスでこのコードをスキャンすると、アイデンティティを復元できます。';

  @override
  String get recoveryQrWarning => 'このコードをスキャンできる人はアカウントを操作できます。安全に保管してください。';

  @override
  String get saveRecoveryQrButton => '復元QRコードを保存';

  @override
  String get recoveryQrSaved => '復元QRコードを写真に保存しました。';

  @override
  String get recoveryQrSaveFailed => '復元QRコードを保存できませんでした。';

  @override
  String get scanRecoveryQrButton => '復元QRコードをスキャン';

  @override
  String get recoveryQrScannerTitle => '復元QRコードをスキャン';

  @override
  String get recoveryQrScannerHint => 'カメラを復元QRコードに向けてください。';

  @override
  String get chooseRecoveryQrImageTooltip => 'QR画像を選択';

  @override
  String get recoveryQrNoCodeError => '画像に復元QRコードが見つかりません。';

  @override
  String get invalidRecoveryQrError => '有効な#seen復元QRコードではありません。';

  @override
  String get connectToDesktopLabel => 'デスクトップに接続';

  @override
  String get connectToDesktopValue => 'Web QRをスキャン';

  @override
  String get desktopLoginScannerTitle => 'デスクトップに接続';

  @override
  String get desktopLoginScannerHint => 'ブラウザに表示されたQRコードにカメラを向けてください。';

  @override
  String get chooseDesktopLoginQrImageTooltip => 'デスクトップQR画像を選択';

  @override
  String get desktopLoginApprovalTitle => 'デスクトップ接続を許可しますか？';

  @override
  String get desktopLoginApprovalDescription =>
      '選択中のアイデンティティでこのブラウザを使用できるようにします。';

  @override
  String get desktopLoginWebsiteLabel => 'Webサイト';

  @override
  String get desktopLoginBrowserLabel => 'ブラウザ';

  @override
  String get desktopLoginExpiryLabel => '有効期限';

  @override
  String get approveDesktopLoginButton => '許可';

  @override
  String get mobileIdentityLabel => 'モバイルのアイデンティティ';

  @override
  String get desktopLoginApproved => 'デスクトップ接続を許可しました。';

  @override
  String get desktopLoginApprovalFailed => 'デスクトップ接続を許可できませんでした。';

  @override
  String get desktopLoginInvalidQr => '有効な #seen デスクトップ接続コードではありません。';

  @override
  String get savedWordsButton => 'これらの単語を保存しました';

  @override
  String get confirmBackupFirst => '先にバックアップを確認してください';

  @override
  String get securingAccountTitle => 'アカウントを保護中';

  @override
  String get checkingOwnerSubtitle => 'このデバイスが保存されたオーナーを確認する方法を確認中…';

  @override
  String get savedAccountLockedTitle => '保存されたアカウントがロックされています';

  @override
  String get accountLockedDescription =>
      '公開スレッドは公開のままですが、このスマートフォンのプライベートアカウントアクセスは、現在のオーナーがロック解除またはリセットするまでロックされたままです。';

  @override
  String get accountLabel => 'アカウント';

  @override
  String get identitiesLabel => 'アイデンティティ';

  @override
  String get switchIdentityTitle => 'アイデンティティを切り替え';

  @override
  String get switchIdentitySubtitle =>
      '個人、会社、スタジオ、ブランドのアイデンティティをこのデバイスで分けて管理します。';

  @override
  String get identitySwitcherSecurityNote =>
      '各アイデンティティには固有のキーペアがあります。メインアイデンティティのリカバリーフレーズは共有しないでください。';

  @override
  String get mainIdentityLabel => 'メインアイデンティティ';

  @override
  String get activeIdentityLabel => '使用中';

  @override
  String get addIdentityButton => 'アイデンティティを追加';

  @override
  String get addIdentityTitle => 'アイデンティティを追加';

  @override
  String get identityNameLabel => 'アイデンティティ名';

  @override
  String get identityNameHint => '個人、スタジオ、ブランド…';

  @override
  String get identityTypeLabel => '種類';

  @override
  String get personalIdentityType => '個人';

  @override
  String get companyIdentityType => '会社';

  @override
  String get studioIdentityType => 'スタジオ';

  @override
  String get brandIdentityType => 'ブランド';

  @override
  String get customIdentityType => 'カスタム';

  @override
  String removeIdentityTitle(String name) {
    return '$nameを削除しますか？';
  }

  @override
  String get removeIdentityContent =>
      'このデバイスからアイデンティティと復元用秘密情報を削除します。リモートデータは削除されません。';

  @override
  String get removeIdentityButton => 'アイデンティティを削除';

  @override
  String get identityVaultUnavailable => 'ローカルのアイデンティティ保管庫がありません。';

  @override
  String identitySwitchFailed(String error) {
    return 'アイデンティティを切り替えられませんでした: $error';
  }

  @override
  String get createdLabel => '作成日';

  @override
  String get unlockThisAccountButton => 'このアカウントをロック解除';

  @override
  String get unlockWithPhraseButton => 'リカバリーフレーズでロック解除';

  @override
  String get notMyAccountButton => 'これは私のアカウントではありません';

  @override
  String get unlockCancelledError =>
      'ロック解除がキャンセルまたは失敗しました。このデバイスのオーナーがアクセスを確認するまで、Spotはロックされたままです。';

  @override
  String failedResetAccount(String error) {
    return '保存されたアカウントのリセットに失敗しました: $error';
  }

  @override
  String get unlockWithPhraseDialogTitle => 'リカバリーフレーズでロック解除';

  @override
  String get unlockPhraseDescription => 'この保存されたアカウントの12単語のリカバリーフレーズを入力してください。';

  @override
  String get enterExactPhraseError => '正確な12単語のリカバリーフレーズを入力してください。';

  @override
  String get phraseMismatchError => 'リカバリーフレーズがこの保存されたアカウントと一致しません。';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsTooltip => '設定';

  @override
  String get termsOfUseTitle => '利用規約';

  @override
  String get privacyPolicyTitle => 'プライバシーポリシー';

  @override
  String get favoriteTopicsLabel => 'お気に入りトピック';

  @override
  String get assetTransportLabel => 'アセット転送';

  @override
  String get languageLabel => '言語';

  @override
  String get languageMenuMessage => 'アプリ全体で使用する言語を選択してください。';

  @override
  String get systemDefaultLanguageOption => 'システム設定に従う';

  @override
  String get viewMyActivityLabel => 'マイアクティビティを表示';

  @override
  String get privacySectionLabel => 'プライバシー';

  @override
  String get footprintMapLabel => 'フットプリントマップ';

  @override
  String get publicThreadsLabel => '公開スレッド';

  @override
  String get publicRepliesLabel => '公開返信';

  @override
  String get storageSectionLabel => 'ストレージ';

  @override
  String get clearCacheLabel => 'キャッシュをクリア';

  @override
  String get clearLocalDataLabel => 'ローカルデータをクリア';

  @override
  String get sessionSectionLabel => 'セッション';

  @override
  String get safeModeLabel => 'セーフモード';

  @override
  String get logOutLabel => 'ログアウト';

  @override
  String get signingOutLabel => 'サインアウト中…';

  @override
  String get clearCacheDialogContent =>
      'すべてのキャッシュされたメディアファイルが削除されます。投稿と設定には影響しません。';

  @override
  String get cacheClearedSnackbar => 'キャッシュをクリアしました';

  @override
  String get clearLocalDataDialogContent =>
      '以下を含むすべてのローカルデータが削除されます:\n• キャッシュされたメディア\n• 保存された投稿\n• お気に入りタグと設定\n• ブロックリスト\n\nアカウントは削除されません。リモートデータはSupabaseから再同期されます。';

  @override
  String get localDataClearedSnackbar =>
      'ローカルデータをクリアしました。再同期するにはアプリを再起動してください。';

  @override
  String get logOutDialogTitle => 'ログアウトしますか？';

  @override
  String get logOutDialogContent =>
      'ログアウトする前に、12単語のリカバリーフレーズを保存していることを確認してください。後でこのアイデンティティを復元するために必要です。ログアウトするとこのデバイスからサインアウトし、ローカルアプリデータが消去されます。Supabaseアカウントとリモート投稿はそのまま残ります。';

  @override
  String get logOutConfirmButton => 'ログアウト';

  @override
  String failedLoadPrivacy(String error) {
    return 'プライバシー設定の読み込みに失敗しました: $error';
  }

  @override
  String failedUpdatePrivacy(String error) {
    return 'プライバシー設定の更新に失敗しました: $error';
  }

  @override
  String failedUpdateSafeMode(String error) {
    return 'セーフモードの更新に失敗しました: $error';
  }

  @override
  String failedUpdateLanguage(String error) {
    return '言語の更新に失敗しました: $error';
  }

  @override
  String failedLogOut(String error) {
    return 'ログアウトに失敗しました: $error';
  }

  @override
  String get publicActivityTitle => '公開アクティビティ';

  @override
  String get publicActivityMessage => '開く公開投稿を選択してください。';

  @override
  String get postedThreadsOption => '投稿したスレッド';

  @override
  String get repliedThreadsOption => '返信したスレッド';

  @override
  String get walletAccountTitle => 'アカウント';

  @override
  String get thisDeviceSectionTitle => 'このデバイス';

  @override
  String get deviceSectionDescription =>
      'プロフィール名とアバターはプロフィールタブで編集します。デバイスの署名鍵はアプリ内部に保持されます。';

  @override
  String get deviceLabel => 'デバイス';

  @override
  String get postingLimitsSectionTitle => '投稿制限';

  @override
  String get checkingDailyLimits => '現在の1日の制限を確認中…';

  @override
  String get postingLimitsLoadError => '現在、投稿制限を読み込めません。';

  @override
  String get recoveryPhraseWalletDescription =>
      'これら12単語は、ログアウトまたは新しいデバイスに移行した後、このアイデンティティを復元する唯一の方法です。';

  @override
  String get copyPhraseButton => 'フレーズをコピー';

  @override
  String get recoveryPhraseCopied => 'リカバリーフレーズをコピーしました';

  @override
  String get dangerZoneSectionTitle => '危険ゾーン';

  @override
  String get deleteAccountDescription =>
      'Supabaseからこのアカウントをとこのデバイスからローカルアプリデータを削除します。';

  @override
  String get deleteAccountButton => 'このアカウントを削除';

  @override
  String get deleteAccountDialogTitle => 'このアカウントを削除しますか？';

  @override
  String get deleteAccountDialogContent =>
      'これによりSupabaseからあなたのSpotプロフィールと投稿が永久に削除され、このデバイスからローカルアプリデータが消去されます。この操作は元に戻せません。';

  @override
  String failedDeleteAccount(String error) {
    return 'アカウントの削除に失敗しました: $error';
  }

  @override
  String get postingBlocked => 'このアカウントの投稿は現在ブロックされています。';

  @override
  String get postingQuotaDescription => 'コンポーザーを開く前に、残りのスレッドと返信の公開数をここで確認できます。';

  @override
  String get tierLabel => 'ティア';

  @override
  String get threadsLabel => 'スレッド';

  @override
  String get repliesLabel => '返信';

  @override
  String get usedLabel => '使用済み';

  @override
  String postingQuotaResetsAt(String resetTime) {
    return '$resetTimeにリセット（次のUTC深夜）。';
  }

  @override
  String postingRemainingOf(int remaining, int total) {
    return '$total件中$remaining件残り';
  }

  @override
  String postingUsedCount(int threads, int replies) {
    return 'スレッド$threads件、返信$replies件';
  }

  @override
  String get latestTabLabel => '最新';

  @override
  String get followingTabLabel => 'フォロー中';

  @override
  String get couldNotLoadPosts => '投稿を読み込めませんでした';

  @override
  String get noPostsYet => 'まだ投稿がありません';

  @override
  String get beFirstToRecord => '最初に記録してみましょう';

  @override
  String get noFollowingPosts => 'フォロー中の人からの投稿がありません';

  @override
  String get tapAvatarToFollow => 'アバターをタップしてフォローしましょう';

  @override
  String get homeNavLabel => 'ホーム';

  @override
  String get discoverNavLabel => '探索';

  @override
  String get eventsNavLabel => 'イベント';

  @override
  String get profileNavLabel => 'プロフィール';

  @override
  String get eventsTabTitle => 'イベント';

  @override
  String get allEventsTabLabel => 'すべて';

  @override
  String get noEventsYet => 'まだイベントがありません';

  @override
  String get noFollowedEventsLive => 'フォロー中のイベントはありません';

  @override
  String get noFollowedTagsYet => 'まだフォローしているタグがありません';

  @override
  String get followedTagsDescription => 'フォローしているタグに一致するライブイベントが表示されます。';

  @override
  String get followTagPrompt => '探索またはイベント詳細画面からタグをフォローすると、ここに表示されます。';

  @override
  String get profileTitle => 'プロフィール';

  @override
  String get editProfileTitle => 'プロフィールを編集';

  @override
  String get usernameFieldLabel => 'ユーザー名';

  @override
  String get usernameFieldHint => '市民名';

  @override
  String get descriptionFieldLabel => '説明';

  @override
  String get descriptionFieldHint => '簡単な自己紹介';

  @override
  String get tapAvatarHint => 'アバターをタップして新しい画像を選択';

  @override
  String get saveProfileButton => 'プロフィールを保存';

  @override
  String get descriptionTooLongError => '100語以内で入力してください';

  @override
  String get captureAMomentHint => '瞬間を記録してここに表示しましょう';

  @override
  String get repliesPostedHint => '投稿した返信がここに表示されます';

  @override
  String get noThreadsYet => 'まだスレッドがありません';

  @override
  String get noRepliesYet => 'まだ返信がありません';

  @override
  String get removedLocalPost => 'ローカルの未送信投稿を削除しました';

  @override
  String get postDeleted => '投稿を削除しました。スワームの参加者にローカルコピーの削除が通知されます。';

  @override
  String get failedDeletePost => '投稿の削除に失敗しました';

  @override
  String get postSent => '投稿を送信しました';

  @override
  String get retryFailed => '再試行に失敗しました。投稿はまだローカルに保存されています。';

  @override
  String get profileUpdated => 'プロフィールを更新しました';

  @override
  String profileUpdatedWithWarning(String warning) {
    return 'プロフィールを更新しました。$warning';
  }

  @override
  String failedUpdateProfile(String error) {
    return 'プロフィールの更新に失敗しました: $error';
  }

  @override
  String get avatarNotUpdated => 'アバターが更新されませんでした。もう一度お試しください。';

  @override
  String get avatarNotUpdatedTimeSync =>
      'アバターが更新されませんでした。日付と時刻の自動設定をオンにして再試行してください。';

  @override
  String get takePhotoOption => '写真を撮る';

  @override
  String get recordVideoOption => '動画を録画';

  @override
  String get maxMediaItemsWarning => '1投稿につき最大4つのメディアアイテム';

  @override
  String get categoryTagHint => 'カテゴリタグ（例：AWSSummitTokyo2026）';

  @override
  String get addMoreTagsHint => 'タグをさらに追加…';

  @override
  String get createCategoryTagTooltip => 'カテゴリタグを作成';

  @override
  String get createTagTooltip => 'タグを作成';

  @override
  String get postModeLabel => '投稿モード';

  @override
  String get standardModeLabel => 'スタンダード';

  @override
  String get virtualModeLabel => 'バーチャル';

  @override
  String get checkInLabel => 'スポットにチェックイン';

  @override
  String get checkInSubtitle => '場所名と共に正確な位置情報を公開';

  @override
  String get blurFacesLabel => '顔をぼかす';

  @override
  String get blurFacesSubtitle => '写真内の顔を自動的にぼかす';

  @override
  String get aiGeneratedLabel => 'AI生成コンテンツ';

  @override
  String get aiGeneratedSubtitle => 'コンテンツはAIによって作成または補助されました';

  @override
  String get secondhandLabel => '他の人のストーリー';

  @override
  String get secondhandSubtitle => '間接的な情報を共有しています';

  @override
  String get publishFailedSaved => '公開に失敗しました。プロフィールに保存されたので再試行できます。';

  @override
  String publishFailedError(String error) {
    return '公開に失敗しました: $error';
  }

  @override
  String get publishButton => '公開';

  @override
  String get confirmAndPostButton => '確認して投稿';

  @override
  String get beforePostTitle => '投稿前に';

  @override
  String get yesLabel => 'はい';

  @override
  String get noLabel => 'いいえ';

  @override
  String get rightsConfirmation => 'このコンテンツを共有する権利があります';

  @override
  String get defamationConfirmation => 'このコンテンツは個人やグループを誹謗中傷するものではありません';

  @override
  String get lawsConfirmation => 'これが私の管轄区域の適用法に準拠していることを確認します';

  @override
  String captionHint(int limit) {
    return 'キャプションを追加… (任意、最大$limit文字)';
  }

  @override
  String get addCategoryTagWarning => '新しいスレッドを投稿する前にカテゴリタグを追加してください。';

  @override
  String get tagFieldHint => '最初のタグがイベントカテゴリです · スペースまたは , を押してさらに追加';

  @override
  String get checkInSpotHint => '例：東京タワー、代々木公園…';

  @override
  String get checkInSpotPlaceholder => 'スポットにチェックイン…';

  @override
  String publishNItems(int count) {
    return '$count件を公開';
  }

  @override
  String get discoverSearchPlaceholder => 'スレッドまたは#タグを検索';

  @override
  String get discoverTitle => '探索';

  @override
  String get removeFavoriteLabel => 'お気に入りから削除';

  @override
  String get addFavoriteLabel => 'お気に入りに追加';

  @override
  String get trendingTabLabel => 'トレンド';

  @override
  String get forYouTabLabel => 'おすすめ';

  @override
  String get nearbyTabLabel => '近く';

  @override
  String get usersTabLabel => 'ユーザー';

  @override
  String noThreadsFound(String search) {
    return '「$search」のスレッドが見つかりません';
  }

  @override
  String noUsersFound(String search) {
    return '「$search」のユーザーが見つかりません';
  }

  @override
  String get nothingTrending => '過去48時間のトレンドはありません';

  @override
  String get noRecommendedPosts => 'おすすめ投稿はまだありません';

  @override
  String get setInterestsPrompt => '興味を設定してパーソナライズされたコンテンツを見る';

  @override
  String get noEventsNearby => '近くにイベントがありません';

  @override
  String get enableLocationPrompt => '近くのイベントを表示するには位置情報を有効にしてください';

  @override
  String get allowLocationButton => '位置情報を許可';

  @override
  String get participantsLabel => '参加者';

  @override
  String get splashLoadingTitle => 'Spotを読み込み中';

  @override
  String get splashLoadingSubtitle => '最新データを取得してローカルに保存中…';

  @override
  String get splashRefreshingTitle => 'データを更新中…';

  @override
  String get splashRefreshingSubtitle => '新しい投稿を確認してローカルに更新を保存中…';

  @override
  String get assetTransportScreenTitle => 'アセット転送';

  @override
  String get peerTransportSection => 'ピア転送';

  @override
  String get peerTransportDescription =>
      '予期しないモバイルデータ使用を避けるため、Spotがピア転送で完全な画像や動画を共有・取得するタイミングを制御します。';

  @override
  String get cdnAccelerationSection => 'CDN加速';

  @override
  String get cdnAccelerationDescription =>
      'コンテンツデリバリーネットワークを使用してメディアの読み込みを高速化します。CDNのフェッチとアップロードはデフォルトで有効になっています。ここで無効にしてP2P転送のみを使用することができます。';

  @override
  String get cdnFetchLabel => 'CDNフェッチとキャッシュ';

  @override
  String get cdnFetchDescription => '利用可能な場合はCDNからメディアをダウンロードします（高速）。';

  @override
  String get cdnUploadLabel => 'CDNアップロード';

  @override
  String get cdnUploadDescription => '他のユーザーが高速に取得できるようメディアをCDNにアップロードします。';

  @override
  String get alwaysOption => '常に';

  @override
  String get wifiOnlyOption => 'Wi-Fiのみ';

  @override
  String get offOption => 'オフ';

  @override
  String get cdnUploadNotConfigured => 'このビルドではCDNアップロードは設定されていません';

  @override
  String get threadTitle => 'スレッド';

  @override
  String get threadNotAvailable => 'スレッドを利用できません';

  @override
  String get replyToPostUnavailable => '返信対象の投稿は利用できません。';

  @override
  String get videoLabel => '動画';

  @override
  String get imageLabel => '画像';

  @override
  String get loadingFullVideo => '完全な動画を読み込み中…';

  @override
  String get loadingFullImage => '完全な画像を読み込み中…';

  @override
  String get loadingFullMedia => '完全なメディアを読み込み中…';

  @override
  String get mediaUnavailable => '完全なメディアはまだ利用できません。現在はプレビューのみです。';

  @override
  String get couldNotLoadMedia => '現在、完全なメディアを読み込めません。';

  @override
  String get tapToPause => 'タップして一時停止';

  @override
  String get tapToPlay => 'タップして再生';

  @override
  String get couldNotRenderImage => 'この画像をレンダリングできませんでした';

  @override
  String get couldNotRenderPreview => 'このプレビューをレンダリングできませんでした';

  @override
  String get tapRetryToLoad => 'タップして再試行し完全なメディアを読み込む';

  @override
  String get myPostedThreadsTitle => '投稿したスレッド';

  @override
  String get myRepliedThreadsTitle => '返信したスレッド';

  @override
  String get threadsPublicHint => '公開で投稿したスレッドがここに表示されます';

  @override
  String get repliesPublicHint => '公開で投稿した返信がここに表示されます';

  @override
  String get muteUser => 'ユーザーをミュート';

  @override
  String get unmuteUser => 'ミュートを解除';

  @override
  String get blockUser => 'ユーザーをブロック';

  @override
  String get unblockUser => 'ブロックを解除';

  @override
  String get blockedUsersTitle => 'ブロックしたユーザー';

  @override
  String get blockedUsersEmpty => 'ブロックしているユーザーはいません。';

  @override
  String get blockedUsersUnblockButton => '解除';

  @override
  String get blockedUsersUnblockConfirmTitle => 'ブロックを解除しますか？';

  @override
  String get blockedUsersUnblockConfirmBody =>
      'このユーザーはあなたのコンテンツを閲覧し、再びやり取りできるようになります。';

  @override
  String get reportUser => 'ユーザーを報告';

  @override
  String get userOptionsTitle => 'ユーザーオプション';

  @override
  String get threadsPrivate => 'このアカウントはトップレベルのスレッドを公開プロフィールで共有していません。';

  @override
  String get repliesPrivate => 'このアカウントは返信を公開プロフィールで共有していません。';

  @override
  String get footprintMapPrivate => 'このアカウントはフットプリントマップを他のユーザーと共有していません。';

  @override
  String get userReported => 'ユーザーを報告しました。';

  @override
  String followUpdateFailed(String error) {
    return 'フォロー更新に失敗しました: $error';
  }

  @override
  String get favoriteTopicsTitle => 'お気に入りトピック';

  @override
  String get favoriteTopicsSubtitle =>
      'おすすめフィードをパーソナライズするために、少なくとも3つのトピックを選択してください。';

  @override
  String get addCustomHashtagHint => 'カスタムハッシュタグを追加';

  @override
  String get selectAtLeast3 => '少なくとも3つ選択';

  @override
  String get deletePost => '投稿を削除';

  @override
  String get reportContent => 'コンテンツを報告';

  @override
  String get savedLocallyOnly => 'ローカルのみに保存済み。更新をタップして再送信。';

  @override
  String get notPostedYet => 'まだ投稿されていません。更新をタップして再送信。';

  @override
  String get tapPhotoHoldVideo => 'タップ · 写真   長押し · 動画';

  @override
  String get writeReplyHint => '返信を書く…';

  @override
  String replyingToUser(String pubkey) {
    return '$pubkeyに返信中';
  }

  @override
  String replyToEvent(String event) {
    return '$eventに返信';
  }

  @override
  String get tapToLoadMedia => 'タップしてメディアを読み込む';

  @override
  String get tapToLoadFull => 'タップして完全版を読み込む';

  @override
  String get downloadingFromCdn => 'CDNからダウンロード中…';

  @override
  String get preparingVideo => '動画を準備中…';

  @override
  String get imageUnavailable => '現在画像を利用できません';

  @override
  String get noGps => 'GPS なし';

  @override
  String get locationHidden => '位置情報を非表示';

  @override
  String get noLocation => '位置情報なし';

  @override
  String get pinnedPost => 'ピン留めされた投稿';

  @override
  String videoNOfTotal(int n, int total) {
    return '動画 $n/$total';
  }

  @override
  String get openInDiscover => '探索で開く';

  @override
  String get openFullScreenMap => '全画面マップを開く';

  @override
  String get zoomIn => 'ズームイン';

  @override
  String get zoomOut => 'ズームアウト';

  @override
  String get mapAttribution => '地図タイル: OpenStreetMap / CARTO';

  @override
  String get locationLabel => '位置情報';

  @override
  String get threadsTabLabel => 'スレッド';

  @override
  String get repliesTabLabel => '返信';

  @override
  String get mapTabLabel => 'マップ';

  @override
  String get footprintMapTitle => 'フットプリントマップ';

  @override
  String get noLocations => '位置情報なし';

  @override
  String get unknownLabel => '不明';

  @override
  String get eventPostLabel => '投稿';

  @override
  String get eventReplyLabel => '返信';

  @override
  String eventPostsContributors(int count, int contributors) {
    return '$count件の投稿 · $contributors人の投稿者';
  }

  @override
  String mediaViewerPageTitle(String label, int n, int total) {
    return '$label $n/$total';
  }

  @override
  String get threadsArePrivateTitle => 'スレッドは非公開です';

  @override
  String get repliesArePrivateTitle => '返信は非公開です';

  @override
  String get footprintMapIsPrivateTitle => 'フットプリントマップは非公開です';

  @override
  String get repliesFromAccountHint => 'このアカウントの返信がここに表示されます';

  @override
  String get noTopLevelThreadsHint => 'このアカウントからのトップレベルスレッドはまだありません';

  @override
  String saveNInterests(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の興味を保存',
    );
    return '$_temp0';
  }

  @override
  String get threadStatLabel => 'スレッド';

  @override
  String get replyStatLabel => '返信';

  @override
  String footprintCountriesVisited(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countか国を訪問',
    );
    return '$_temp0';
  }

  @override
  String get previewLabel => 'プレビュー';

  @override
  String get mediaCheckBackLater => '後でもう一度確認してください';

  @override
  String get mediaDownloadViaCdnOrP2p => 'CDNまたはP2P経由でダウンロード';

  @override
  String get protectedTooltip => '保護済み';

  @override
  String get aiGeneratedTooltip => 'AI生成';

  @override
  String get notSentTooltip => '未送信';

  @override
  String get secondhandTooltip => '二次情報';

  @override
  String descriptionWordCountHelper(int count, int max) {
    return '$count/$max語';
  }

  @override
  String replyToShortKey(String key) {
    return '$keyに返信';
  }

  @override
  String get whatsHappeningHint => '今何が起きていますか？';

  @override
  String get postButton => '投稿';

  @override
  String get beforePostSubtitle => 'シェアする前に以下のすべてを確認してください。';

  @override
  String get accuracyConfirmation => '私が共有する情報は私の知る限り正確です';

  @override
  String get ugcTermsTitle => 'コミュニティ利用規約への同意';

  @override
  String get ugcTermsSubtitle =>
      '#seen にはユーザー生成の投稿とプロフィールが含まれます。コミュニティコンテンツにアクセスする前に、これらの規約へ同意する必要があります。';

  @override
  String get ugcTermsSafetyHeading => '不適切なコンテンツや濫用行為は許容しません';

  @override
  String get ugcTermsBulletRespect =>
      '不適切なコンテンツ、嫌がらせ、ヘイト、脅迫、性的搾取、または暴力的な虐待表現を投稿しないでください。';

  @override
  String get ugcTermsBulletModeration =>
      '報告された投稿やアカウントは、非表示、審査、投稿停止、または削除の対象となる場合があります。';

  @override
  String get ugcTermsBulletReporting =>
      '危険なコンテンツや濫用するユーザーを見つけた場合は、報告機能とブロック機能を使用してください。';

  @override
  String get ugcTermsBulletEnforcement =>
      '違反行為はコンテンツの削除、投稿制限、またはアカウント停止につながる場合があります。';

  @override
  String get ugcTermsAgreement =>
      '私は #seen の利用規約とプライバシーポリシーに同意し、不適切なコンテンツや濫用するユーザーに対して一切の許容がないことを理解しています。';

  @override
  String get ugcTermsAgreeButton => '同意して続行';

  @override
  String get ugcTermsViewTerms => '利用規約';

  @override
  String get ugcTermsViewPrivacy => 'プライバシーポリシー';

  @override
  String get reportUserTitle => 'このユーザーを報告';

  @override
  String get reportUserSubtitle => 'モデレーターが審査できるよう、このアカウントの問題を知らせてください。';

  @override
  String get reportReasonLabel => '理由';

  @override
  String get reportDetailsLabel => '詳細';

  @override
  String get reportUserDetailsHint => 'モデレーター向けの任意の詳細';

  @override
  String get submitUserReportButton => '報告を送信';

  @override
  String get reportReasonHarassment => '嫌がらせ';

  @override
  String get reportReasonHate => 'ヘイト・過激主義';

  @override
  String get reportReasonSexualContent => '性的コンテンツ';

  @override
  String get reportReasonViolence => '暴力';

  @override
  String get reportReasonSpam => 'スパム・詐欺';

  @override
  String get reportReasonImpersonation => 'なりすまし';

  @override
  String get reportReasonOther => 'その他';
}

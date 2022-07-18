//
//  Constants.swift
//  PockeTalk
//

import UIKit
import SwiftKeychainWrapper

enum MenuItemType: Int {
    case settings
    case camera
    case favorite
}

let SIZE_WIDTH: CGFloat                  = UIScreen.main.bounds.size.width
let SIZE_HEIGHT: CGFloat                 = UIScreen.main.bounds.size.height

let DISPLAY_SCALE: CGFloat               = SIZE_WIDTH / 375.0

let DIALOG_CORNER_RADIUS: CGFloat = 15.0
let kSettingsScreenTransitionDuration = 0.5
let kTtsAvailableTrailingConstant : CGFloat = 85.0
let kTtsNotAvailableTrailingConstant : CGFloat = 50.0
let kUnselectedLanguageTrailingConstant : CGFloat = 10.0
let kMarqueeLabelTrailingBufferForLanguageScreen : CGFloat = 50.0
let kMarqueeLabelScrollingSpeenForLanguageScreen : CGFloat = 30.0
let CameraCropControllerMargin: CGFloat = 12.5
let kScreenTransitionTime: Double = 0.5
let kFadeAnimationTransitionTime: TimeInterval = 0.35
let viewsAlphaValue: CGFloat = 0.0
let speechViewTransitionTime = 0.15
let languageMappingTotalRowCount = 1495


//MARK: - Link
let REVIEW_SUPPORT_URL = "https://rd.snxt.jp/PA010"

let PRODUCTION_SUPPORT_URL = "https://rd.snxt.jp/PA002"
//let PRODUCTION_USER_MANUEL_URL = "https://rd.snxt.jp/PA003"
let PRODUCTION_TERMS_AND_CONDITIONS_URL = "https://rd.snxt.jp/PA001"
let STAGING_SUPPORT_URL = "https://rd.snxt.jp/PA002"
//let STAGING_USER_MANUEL_URL = "https://rd.snxt.jp/PA003"
let STAGING_TERMS_AND_CONDITIONS_URL = "https://rd.snxt.jp/PA001"

let USER_MANUAL_URL_en = "https://rd.snxt.jp/PA014"
let USER_MANUAL_URL_ja = "https://rd.snxt.jp/PA003"
let USER_MANUAL_URL_zhHans = "https://rd.snxt.jp/PA015"
let USER_MANUAL_URL_zhHant = "https://rd.snxt.jp/PA016"
let USER_MANUAL_URL_es = "https://rd.snxt.jp/PA017"
let USER_MANUAL_URL_ptPT = "https://rd.snxt.jp/PA018"
let USER_MANUAL_URL_ru = "https://rd.snxt.jp/PA019"
let USER_MANUAL_URL_fr = "https://rd.snxt.jp/PA020"
let USER_MANUAL_URL_de = "https://rd.snxt.jp/PA021"
let USER_MANUAL_URL_ko = "https://rd.snxt.jp/PA022"
let USER_MANUAL_URL_it = "https://rd.snxt.jp/PA023"
let USER_MANUAL_URL_th = "https://rd.snxt.jp/PA024"
let USER_MANUAL_URL_ms = "https://rd.snxt.jp/PA025"



//MARK: - Notification Name



//MARK: - UserDefault Name

let kUserDefaultAccessToken = "kUserDefaultAccessToken"
let KSelectedLanguage = "KSelectedLanguage"
let KFirstInitialized = "KFirstInitialized"
let kUserDefaultIsMenuFavorite = "kUserDefaultIsMenuFavorite"
let kUserDefaultIsTutorialDisplayed = "kUserDefaultIsTutorialDisplayed"
let kIsShownLanguageSettings = "kIsShownLanguageSettings"
let kIsAlreadyFavorite = "kIsAlreadyFavorite"
let kLastSavedChatID = "lastSavedChatID"
let kUserDefaultDatabaseOldVersion = "databaseOldVersion"
let kTempoControlSpeed = "kTempoControlSpeed"
let kUserDefaultIsSpeechProcessingDisplayedFirstTime = "kUserDefaultIsSpeechProcessingDisplayedFirstTime"
let kUserDefaultIsUserPurchasedThePlan = "kUserDefaultIsUserPurchasedThePlan"
let licenseTokenUserDefaultKey = "licenseToken"
let tokenCreationTime = "tokenCreationTime"
let kCouponCode = "kCouponCode"
let kLicenseConfirmationCalledTime = "kLicenseConfirmationCalledTime"
let kInitialFlowCompletedForCoupon = "kInitialFlowCompletedForCoupon"
let kIsFromUniverslaLink = "kIsFromUniverslaLink"
let kFreeTrialStatus = "kFreeTrialStatus"
let kPermissionCompleted = "kPermissionCompleted"

//MARK: - Toast Message Title
let kMenuActionToastMessage = "Navigate to menu screen"
let kTopLanguageButtonActionToastMessage = "Navigate to top language selection screen screen"
let kBottomLanguageButtonActionToastMessage = "Navigate to language selection screen"
let kReverseTranslationUnderDevelopment = "Reverse translatioin module is under development"
let kShareTranslationUnderDevelopment = "Share module is under development"
let kTranslateIntoOtherLanguageUnderDevelopment = "Translate into other language module is under development"

// Alert message, title and action for app specific permission

let kActionAllowAccess = "kActionAllowAccess"
let kActionCancel = "kActionCancel"
let kMicrophoneUsageTitle = "kMicrophoneUsageTitle"
let kMicrophoneUsageMessage = "kMicrophoneUsageMessage"
let kPhotosUsageTitle = "kPhotosUsageTitle"
let kPhotosUsageMessage = "kPhotosUsageMessage"
let kCameraUsageTitle = "kCameraUsageTitle"
let kCameraUsageMessage = "kCameraUsageMessage"
let kTitleOk = "kTitleOk"
let kNotAllow = "kNotAllow"


// Language selection voice
let kCameraToLanguageSelectionIndex = "camera_to_language_selection_index"
let kCameraFromLanguageSelectionIndex = "camera_from_language_selection_index"
let kTopLanguageSelectionIndex = "top_language_selection_index"
let kBottomLanguageSelectionIndex = "bottom_language_selection_index"
let KSelectedLanguageVoice = "KSelectedLanguageVoice"
let KSelectedLanguageCamera = "KSelectedLanguageCamera"
let KSelectedCountryLanguageVoice = "KSelectedCountryLanguageVoice"
let nativeLanguageCode = "nativeLanguageCode"
let countrySearchTutorialTitle = "Language Settings"
let countrySearchTutorialDescription = "Hold down the button and say the country you want to search for."
let countrySearchExampleText = "Please say the country name.\nEx: \"Germany\""
let KCameraNativeLanguageCode = "KCameraNativeLanguageCode"
let translatedLanguageCode = "translatedLanguageCode"
let tempSrcLanguageCode = "tempSrcLanguageCode"
let KisBottomLanguageChanged = "isBottomLanguageChanged"
let KisTopLanguageChanged = "isTopLanguageChanged"
let KCameraTargetLanguageCode = "KCameraTargetLanguageCode"
let kIsArrowUp = "isArrowUpKey"
let directionIsUp = "directionIsUp"
let kIsNative = "kIsNative"
let KCameraLanguageFrom = "KCameraLanguagelistShowing"
let kLanguageSelectVoice = "LangSelectVoiceVC"
let languageConversationFileNamePrefix = "conversation_languages_"
let countryConversationFileNamePrefix = "country_selection_list_"
let systemLanguageCodeJP = "ja"
let systemLanguageCodeEN = "en"
let cameraLanguageDetectionCodeJsonFile = "language_detection_codes"
let KIsAppLaunchedPreviously = "KisAppFirstTimeLanuced"

// Storyboard identifier
let KTutorialViewController = "TutorialViewController"
let KTtsAlertController = "TtsAlertController"
let KSpeechProcessingViewController = "SpeechProcessingViewController"
let KLanguageListVoice = "LanguageListVoice"
let LHistoryListVoice = "HistoryListVoice"
let KLanguageListCamera = "LanguageListCamera"
let KHistoryListCamera = "LanguageHistoryListCamera"
let KiDLangSelectCamera = "LanguageSelectCameraVC"

// Storyboard Name
let KStoryBoardCamera = "LanguageSelectCamera"
let KStoryboardInitialFlow = "InitialFlow"
let KStoryboardMain = "Main"
let KBoarding = "Boarding"

// Pronunciation Practice
let DIFF_STRING_MATCHED = "Matched"
let DIFF_STRING_NOT_MATCHED = "Not Matched"

//TableView Cell identifier
let KAlertTableViewCell = "AlertTableViewCell"
let KNoInternetAlertTableViewCell = "NoInternetAlertTableViewCell"
let KPermissionTableViewCell = "PermissionTableViewCell"
let kPlanTableViewThreeDaysTrialCell = "PlanTableViewThreeDaysTrialCell"
let KPlanTableViewCell = "PlanTableViewCell"
let KInfoLabelTableViewCell = "InfoLabelTableViewCell"
let KSingleButtonTableViewCell = "SingleButtonTableViewCell"
let KFreePlanTableViewCell = "FreePlanTableViewCell"

//Keychain for udid
let kUniqueUdidKey = "com.sourcenext.pocketalk.ios.udid"

//Nib name
let KAlertReusable = "AlertReusableViewController"

//MARK: - Camera Constants

//let ITTServerURL = URL(string: "server url")! //TODO set server url
let IMAGE_WIDTH:Int = 640
let IMAGE_HEIGHT:Int = 860
let EXCEPTION_LANGUAGE_CODES: [String] = ["pt-PT"]
let FILIPINO_FIL_LANGUAGE_CODE: String = "fil"
let FILIPINO_TL_LANGUAGE_CODE: String = "tl"
let BURMESE_MY_LANGUAGE_CODE: String = "my"
let KAlertTempoControlSelectionAlert = "TempoControlSelectionAlert"
let BLOCK_DIRECTION:Int = -1
let CAMERA_HISTORY_DATA_LOAD_LIMIT = 10
let flashDisabledBatteryPercentage: Float = 15
let cameraDisableBatteryPercentage: Float = 5
let batteryMaxPercent: Float = 100
let LANGUAGE_CODE_UND: String = "und"
let CHINESE_LANGUAGE_CODE_ZH = "zh"
let CameraDefaultLang = "Automatic Recognition"
let isCameraFlashOn = "isCameraFlashOn"
let isTransLationSuccessful = "isTransLateSuccessful"
let cameraHistoryImageLimit: Int = 100
let LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE : CGFloat = 8.0
let LABEL_LINE_HEIGHT_FOR_OTHERS_LANGUAGE : CGFloat = 1.0

//MARK: - Database Constants
let rowFetchPerScroll = 500
let MAX_HISTORY_ROW = 10000

// Selection of font
let KFontSelection = "KFontSelection"

// Mode Switching for camera image
let modeSwitchType = "modeSwitchType"
let blockMode = "blockMode"
let lineMode = "lineMode"

//FontSizes [range (11-22) ]
let FONTSIZE: [CGFloat] = [0.8, 0.9, 1.0, 1.1, 1.2, 1.3]
let DEFAULT_FONTSIZE: CGFloat = 22.0
let DEFAULT_FONTSIZE_INDEX: Int = 2
let DEFAULT_FONT_MULTIPLYER: CGFloat = 0.1
let FONT_SIZE_KEY: String = "FontSize"

// Socket url connection
let AUDIO_STREAM_URL =  getAudioStremUrl("AudioStremBaseUrl") + "/handsfree/ws/pub/stream"
//"wss://test.pt-v.com/handsfree/ws/pub/stream"
//let AUDIO_STREAM_URL_ORIGIN = "https://test.pt-v.com"
let access_token_key = "X-Access-Key"
let origin = "Origin"
let imei = "imei"
let codec_param = "codec"
let srclang = "srclang"
let destlang = "destlang"
let access_key = "access_key"
let authentication_key = "authentication_key"
let license_token = "license_token"
let language_token = "token"
let response_ok = "OK"
let base_url = infoForKey("BaseUrl")
let stream_auth_key_url = "/handsfree/api/pub/create"
let language_channge_url = "/handsfree/api/pub/lang"
let tts_url = "/handsfree/api/pub/tts"
let liscense_token_url = "/handsfree/api/pub/token"
let license_confirmation_url = "/handsfree/api/pub/license"
let image_annotate_url = "/handsfree/api/pub/images_annotate"
let detect_lang_url = "/handsfree/api/pub/detect_lang"

//TTS dialog
let KMultipleTtsValueSeparator = "#"
let KVoiceAndTempoSeparator = "_"
let iosListener = "iosListener"
let speakingListener = "speakingListener"
let multipartUrlListener = "multipartUrlListener"
let KEngineSeparator = ","

// api key
// TO DO : This will update/change in future
let queryItemApiKey = "AIzaSyDkcqaRwuQ_fy0_Vr8kHoBjKHRkemuw6Ho"
let googleOCRKey = "AIzaSyD6B2VKm2eZbQgT_bwSNiYpEUHujadh_FE"
let imeiCode = "862793051345020"
let imeiNumber = getIMEINumber("ImeiNumber")
let udid = getUUID()  //"Abfaa4d5-a045-4784-9208-088ac8ec0192"

//View Tag
let floatingMikeButtonTag = 1101
let ttsAlertViewTag = 11223
let activityIndictorViewTag = 1201
let multipartPlayerViewTag = 1102

// TTS API
let licenseToken = "license_token"
let language = "language"
let text = "text"
let tempo = "tempo"
let engineName = "google"
let normal = "normal"
let isNetworkAvailable = "isNetworkAvailable"

// Error Response
let WARN_INPUT_PARAM = "WARN_INPUT_PARAM"
let WARN_NO_DEVICE = "WARN_NO_DEVICE"
let ERR_CREATE_FAILED = "ERR_CREATE_FAILED"
let ERR_UNKNOWN = "ERR_UNKNOWN"
let EMPTY_RESPONSE = "00000"
let WARN_INVALID_KEY = "WARN_INVALID_KEY"
let WARN_INVALID_LANG = "WARN_INVALID_LANG"
let ERR_SETTING_FAILED = "ERR_SETTING_FAILED"
let WARN_INVALID_AUTH = "WARN_INVALID_AUTH"
let ERR_TTS_FAILED = "ERR_TTS_FAILED"
let INFO_INVALID_AUTH = "INFO_INVALID_AUTH"
let INFO_INVALID_LICENSE = "INFO_INVALID_LICENSE"
let INFO_EXPIRED_LICENSE = "INFO_EXPIRED_LICENSE"
let WARN_FAILED_CALL = "WARN_FAILED_CALL"
let ERR_API_FAILED = "ERR_API_FAILED"
let INFO_LICENSE_OVER = "INFO_LICENSE_OVER"
let BURMESE_LANG_CODE = "my"
let LanguageEngineFileName = "language_engine.xml"
let KLanguageEngineFileCreationTime = "kLanguageEngineFileCreationTime"
let LanguageEngineUrlForProductionBuild = "https://www.sourcenext.com/produce/app/pocketalkios/language_engine.xml"
let LanguageEngineUrlForStageBuild = "https://www.sourcenext.com/produce/app/pocketalkios-test/language_engine.xml"

// Activity Indicator
let loaderWidth: CGFloat = 50.0
let loaderPadding: CGFloat = 80.0
let loaderLineWidth: CGFloat = 10.0

///Set base url depending of different build configuration
func infoForKey(_ key: String) -> String {
    return (Bundle.main.infoDictionary?[key] as? String)?
        .replacingOccurrences(of: "\\", with: "") ?? "https://test.pt-v.com"
}

///Set IMEI number based on different build configuration
func getIMEINumber(_ key: String) -> String {
    return (Bundle.main.infoDictionary?[key] as? String)
        ??  imeiCode
}

///get Audio Stream Url based on different build configuration
func getAudioStremUrl(_ key: String) -> String {
    return (Bundle.main.infoDictionary?[key] as? String)?
        .replacingOccurrences(of: "\\", with: "") ?? "wss://test.pt-v.com"
}

func getUUID() -> String? {

    if let uuid = KeychainWrapper.standard.string(forKey: kUniqueUdidKey) {
        return uuid
    }

    guard let newId = UIDevice.current.identifierForVendor?.uuidString else {
        return nil
    }
    KeychainWrapper.standard.set(newId, forKey: kUniqueUdidKey)

    return newId
}

//IAP
//TODO: Need to update with https://buy.itunes.apple.com/verifyReceipt before submitting to App Store
//let verifyReceiptURL = "https://sandbox.itunes.apple.com/verifyReceipt"
var verifyReceiptURL: String{
    #if PRODUCTION_WITH_LIVE_URL
    return "https://buy.itunes.apple.com/verifyReceipt"
    #else
    return "https://sandbox.itunes.apple.com/verifyReceipt"
    #endif
}

let appSpecificSharedSecret = "7c24e4a7aed04857a2213c6f99c1104d"
let productionIAPSharedSecret = "44a85d85406d4980b33c4da329af53b3"
let stagingIAPSharedSecret = "1421641f2e084686b6dca783fc2394c1"
let IAP_ProductIDs = "IAP_ProductIDs"
let productionIAPProduts = "Production_IAP_Products"
let productionIAPProductsForNonJapaneseAppStoreRegion = "Production_IAP_Products_For_NonJapanese_AppStore_Region"
let stagingIAPProduts = "Staging_IAP_Products"

//IAP JSON Parsing
let IAPreceiptData = "receipt-data"
let IAPPassword = "password"
let expires_date = "expires_date"
let latest_receipt_info = "latest_receipt_info"
let latest_receipt = "latest_receipt"
let cancellation_date = "cancellation_date"
let product_id = "product_id"
let is_in_intro_offer_period = "is_in_intro_offer_period"
let IAPLocaleIdentifier = "en_US_POSIX"
let is_trial_period = "is_trial_period"
let IAPDateFormat = "yyyy-MM-dd HH:mm:ss VV"
let kIsClearedDataAll = "kIsClearedDataAll"
let kApple_dot_com = "https://www.apple.com"
let kDate = "Date"
let kServerTimeDateFormatter = "EEE, dd MMM yyyy HH:mm:ss z"
let kIAPTimeoutInterval = 60.0
let receiptValidationAllow = "receiptValidationAllow"
let receiptValidationAllowFromPurchase = "receiptValidationAllowFromPurchase"
let kiOSReceipt = "ios_receipt"
let kiOSOriginalTransactionID = "ios_original_transaction_id"
let kUserPassedSubscription = "kUserPassedSubscription"
let IAPJsonResponseStatus = "status"

let FAVORITE_MAX_LIMIT: Int = 500
let FAVORITE_LIMIT_FLAG_KEY: String = "FAVORITE_LIMIT_FLAG_KEY"

//FileUtility
let kTTSAudioFolderName = "TtsAudioFiles"
let kTTSAudioFileNameExtenstion = ".wav"

let kInAppPurchaseStatus = "inAppPurchaseStatus"
let KIsAppAlreadyLaunchedOnce = "isAppAlreadyLaunchedOnce"
// SCHEME
let currentSelectedSceme = "CURRENT_SCHEME_NAME"
//Language History List
let kSelectedHistoryLanguageVoice: String = "kSelectedHistoryLanguageVoice"
let kTempSelectedLanguageVoice: String = "kTempSelectedLanguageVoice"
let kSelectedHistoryLanguageCamera: String = "kSelectedHistoryLanguageCamera"
let kTempSelectedLanguageCamrea: String = "kTempSelectedLanguageCamrea"

let ENGLISH_SLOW_LANG_CODE: String = "en-SO"
let ENGLISH_SLOW_DEFAULT_PITCH_RATE: String = "0.7"
let TEMPO_STANDARD: String = "normal"
let languageListFromTTSServer:[String]=["af","ar","th","fr","zh-CN","zh-TW", "yue","am", "kn", "ml", "te"]

// SB Authentication
let couponCodeParamName = "coupon_code"

// License Token Paramer with Coupon & Purchase Parameter
let kPocketalk_app_ios = "Pocketalk_app_ios"
let kClientInfo = "client_info"
let kAppUdid = "udid"
let kIosReceipt = "ios_receipt"
let kOriginalTransactionID = "ios_original_transaction_id"
let kImei = "imei"
let kTrialKey = "trial_key"
let kTrialType = "trial_type"
let kIosTrialType = "app"
let kTempo_param = "tempo"

let KCameraTempTargetLanguage = "KCameraTempTargetLanguage"

let kAlpha3CountryCodeJapan = "JPN"
let kUserPassedTc = "kUserPassedTc"





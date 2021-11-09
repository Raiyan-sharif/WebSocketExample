//
//  Constants.swift
//  PockeTalk
//

import UIKit

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


//MARK: - Link
let SUPPORT_URL = "https://www.sourcenext.com/" // TODO: Need to change
let PROMOTION_URL = "https://www.sourcenext.com/" // TODO: Need to change
let USER_MANUAL_URL = "https://www.sourcenext.com/" // TODO: Need to change


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


//MARK: - Toast Message Title
let kMenuActionToastMessage = "Navigate to menu screen"
let kTopLanguageButtonActionToastMessage = "Navigate to top language selection screen screen"
let kBottomLanguageButtonActionToastMessage = "Navigate to language selection screen"
let kReverseTranslationUnderDevelopment = "Reverse translatioin module is under development"
let kShareTranslationUnderDevelopment = "Share module is under development"
let kTranslateIntoOtherLanguageUnderDevelopment = "Translate into other language module is under development"

// Alert message, title and action for app specific permission

let kActionAllowAccess = "Allow access"
let kActionCancel = "Cancel"
let kMicrophoneUsageTitle = #""PockeTalk" Would Like to Access the Microphone"#
let kMicrophoneUsageMessage = "PockeTalk needs permission to use the microphone"
let kPhotosUsageTitle = "Can't use photos"
let kPhotosUsageMessage = "PockeTalk needs permission to access the photo library"
let kCameraUsageTitle = #""PockeTalk" Would Like to Access the Camera"#
let kCameraUsageMessage = "PockeTalk needs permission to use the camera"
let kTitleOk = "OK"
let kNotAllow = "Don't Allow"




// Language selection voice
let KSelectedLanguageVoice = "KSelectedLanguageVoice"
let KSelectedLanguageCamera = "KSelectedLanguageCamera"
let KSelectedCountryLanguageVoice = "KSelectedCountryLanguageVoice"
let nativeLanguageCode = "nativeLanguageCode"
let KCameraNativeLanguageCode = "KCameraNativeLanguageCode"
let translatedLanguageCode = "translatedLanguageCode"
let tempSrcLanguageCode = "tempSrcLanguageCode"
let KisBottomLanguageChanged = "isBottomLanguageChanged"
let KisTopLanguageChanged = "isTopLanguageChanged"
let KCameraTargetLanguageCode = "KCameraTargetLanguageCode"
let kIsArrowUp = "isArrowUpKey"
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

// Pronunciation Practice
let DIFF_STRING_MATCHED = "Matched"
let DIFF_STRING_NOT_MATCHED = "Not Matched"

//TableView Cell identifier
let KAlertTableViewCell = "AlertTableViewCell"
let KNoInternetAlertTableViewCell = "NoInternetAlertTableViewCell";

//Nib name
let KAlertReusable = "AlertReusableViewController"

//MARK: - Camera Constants

//let ITTServerURL = URL(string: "server url")! //TODO set server url
let IMAGE_WIDTH:Int = 640
let IMAGE_HEIGHT:Int = 860
let EXCEPTION_LANGUAGE_CODES: [String] = ["pt-PT"]
let FILIPINO_FIL_LANGUAGE_CODE: String = "fil"
let FILIPINO_TL_LANGUAGE_CODE: String = "tl"
let KAlertTempoControlSelectionAlert = "TempoControlSelectionAlert"
let BLOCK_DIRECTION:Int = -1


//MARK: - Database Constants
let rowFetchPerScroll = 500

// Selection of font
let KFontSelection = "KFontSelection"

// Mode Switching for camera image
let modeSwitchType = "modeSwitchType"
let blockMode = "blockMode"
let lineMode = "lineMode"

//FontSizes [range (11-22) ]
let FONTSIZE: [CGFloat] = [0.7, 0.85, 1.0, 1.15, 1.3, 1.45]
let DEFAULT_FONTSIZE: CGFloat = 17.0
let DEFAULT_FONTSIZE_INDEX: Int = 2
let FONT_SIZE_KEY: String = "FontSize"

// Socket url connection
let AUDIO_STREAM_URL = "wss://test.pt-v.com/handsfree/ws/pub/stream"
let AUDIO_STREAM_URL_ORIGIN = "https://test.pt-v.com"
let STREAM_ID_ISSURANCE_URL = "https://test.pt-v.com/handsfree/api/pub/create"
let access_token_key = "X-Access-Key"
let origin = "Origin"
let imei = "imei"
let codec_param = "codec"
let srclang = "srclang"
let destlang = "destlang"
let access_key = "access_key"
let authentication_key = "authentication_key"
let response_ok = "OK"
let base_url = "https://test.pt-v.com"
let stream_auth_key_url = "/handsfree/api/pub/create"
let language_channge_url = "/handsfree/api/pub/lang"

//TTS dialog
let KMultipleTtsValueSeparator = "#"
let KVoiceAndTempoSeparator = "_"
let iosListener = "iosListener"
let speakingListener = "speakingListener"

// api key
// TO DO : This will update/change in future
let queryItemApiKey = "AIzaSyDkcqaRwuQ_fy0_Vr8kHoBjKHRkemuw6Ho"
let googleOCRKey = "AIzaSyD6B2VKm2eZbQgT_bwSNiYpEUHujadh_FE"

//View Tag
let languageSelectVoiceFloatingbtnTag = 1101
let countrySelectVoiceFloatingbtnTag = 1102
let languageSelectVoiceCameraFloatingBtnTag = 1103

//
//  Constants.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/1/21.
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


//MARK: - Toast Message Title
let kMenuActionToastMessage = "Navigate to menu screen"
let kTopLanguageButtonActionToastMessage = "Navigate to top language selection screen screen"
let kBottomLanguageButtonActionToastMessage = "Navigate to language selection screen"


// Language selection voice
let KSelectedLanguageVoice = "KSelectedLanguageVoice"
let KSelectedLanguageCamera = "KSelectedLanguageCamera"
let KSelectedCountryLanguageVoice = "KSelectedCountryLanguageVoice"
let nativeLanguageCode = "nativeLanguageCode"
let KCameraNativeLanguageCode = "KCameraNativeLanguageCode"
let translatedLanguageCode = "translatedLanguageCode"
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

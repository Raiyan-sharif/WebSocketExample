//
//  Constants.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/1/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
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

//Camera Constants
//let ITTServerURL = URL(string: "http://test.elsecode.com/json/VisionAPIResponse10.php")! //TODO set server url
let IMAGE_WIDTH:Int = 640
let IMAGE_HEIGHT:Int = 853
let EXCEPTION_LANGUAGE_CODES: [String] = ["pt-PT"]
let FILIPINO_FIL_LANGUAGE_CODE: String = "fil"
let FILIPINO_TL_LANGUAGE_CODE: String = "tl"
let KAlertTempoControlSelectionAlert = "TempoControlSelectionAlert"

// Socket url
let SOCKET_CONNECTION_URL = "ws://localhost:3000" // TODO: Need to change


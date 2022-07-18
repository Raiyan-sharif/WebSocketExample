//
//  GoogleAnalytics.swift
//  PockeTalk
//

import Foundation
import FirebaseAnalytics

enum GoogleAnalyticEvent: String {
    case pressButton = "press_btn"
    case swipe = "swipe"
    case select = "select"
    case longTap = "longtap"
    case voiceInput = "voice_input"
    case translate = "translate"
    case takePicture = "take_pic"
}

struct GoogleAnalytics {
    let userProperty = GoogleAnalyticsUserProperty()
    let serviceInfo = GoogleAnalyticsServiceInfo()

    //MARK: - Screen parameter key-value properties
    private let mainScreenName = "mainScreenName"
    let firstAgreement = "first_agreement"
    let firstTutorialOne = "first_tutorial_1"
    let firstTutorialTwo = "first_tutorial_2"

    let firstTutorialThree = "first_tutorial_3"
    let firstPlanSelect = "first_plan_select"
    let firstStart = "first_start"
    let firstHowToUse = "first_howtouse"

    let firstMicPermission = "first_mic_permission"
    let firstCamPermission = "first_cam_permission"
    let firstPermissionConfirm = "first_permission_confirm"
    let firstPurchaseComplete = "first_purchase_complete"

    let firstPurchaseCancel = "first_purchase_cancel"
    let setting = "setting"
    let settingTextSize = "setting_text_size"
    let settingSysLang = "setting_sys_lang"

    let settingInfo = "setting_info"
    let settingReset = "setting_reset"
    let settingResetHistory = "setting_reset_history"
    let settingResetCam = "setting_reset_cam"

    let settingResetFav = "setting_reset_favo"
    let settingResetAll = "setting_reset_all"
    let home = "main"
    let mainSourceLanguage = "main_select_src_lang"

    let mainDestinationLanguage = "main_select_dst_lang"
    let mainResult = "main_result"
    let mainResultMenu = "main_result_menu"
    let mainResultMenuSelectDestinationLang = "main_result_menu_select_dst_lang"

    let mainResultMenuPracticeCheck = "main_result_menu_practice_check"
    let mainResultMenuPracticeCheckSpeed = "main_result_menu_practice_check_speed"
    let mainResultMenuPracticeWrong = "main_result_menu_practice_wrong"
    let mainResultMenuPracticeWrongSpeed = "main_result_menu_practice_wrong_speed"

    let mainResultMenuPractice = "main_result_menu_practice"
    let history = "history"
    let historyLongTapMenu = "history_longtap_menu"
    let historyLongTapMenuSelectDesLang = "history_longtap_menu_select_dst_lang"

    let historyLongTapMenuPractice = "history_longtap_menu_practice"
    let historyLongTapMenuPracticeCheck = "history_longtap_menu_practice_check"
    let historyLongTapMenuPracticeCheckSpeed = "history_longtap_menu_practice_check_speed"
    let historyLongTapMenuPracticeWrong = "history_longtap_menu_practice_wrong"

    let historyLongTapMenuPracticeWrongSpeed = "history_longtap_menu_practice_wrong_speed"
    let historyCard = "history_card"
    let historyCardMenu = "history_card_menu"
    let historyCardMenuSelectDesLang = "history_card_menu_select_dst_lang"

    let historyCardMenuPractice = "history_card_menu_practice"
    let historyCardMenuPracticeCheck = "history_card_menu_practice_check"
    let historyCardMenuPracticeCheckSpeed = "history_card_menu_practice_check_speed"
    let historyCardMenuPracticeWrong = "history_card_menu_practice_wrong"

    let camTranslate = "cam_translate"
    let camTranslateSelectSrcLang = "cam_translate_select_src_lang"
    let camTranslateSelectDesLang = "cam_translate_select_dst_lang"
    let camTranslateHistory = "cam_translate_history"

    let camTranslateConfirm = "cam_translate_confirm"
    let camTranslateResultDetail = "cam_translate_result_detail"
    let camTranslateResult = "cam_translate_result"
    let camTranslateResultDetailMenu = "cam_translate_result_detail_menu"

    let camTranslateResultDetailMenuShare = "cam_translate_result_detail_menu_share"
    let historyCardMenuPracticeWrongSpeed = "history_card_menu_practice_wrong_speed"
    let historyCardMenuShare = "history_card_menu_share"
    let cameraTranslationResultDetailsMenuShare = "cam_translate_result_detail_menu_share"

    //MARK: - Event parameter key properties
    private let buttonParamName = "btn_name"
    private let userID = "user_id"
    private let permissionStatus = "permission_status"
    private let purchasePlan = "plan"

    let selectMenu = "select_menu"
    private let textSize = "text_size"
    private let beforeSysLanguage = "before_sys_lang"
    private let afterSysLanguage = "after_sys_lang"

    private let favoriteStatus = "favo_status"
    private let speed = "speed"
    private let voiceInputMenu = "voice_input_menu"
    private let count = "count"

    private let takePic = "take_pic"
    private let expansion = "expansion"
    private let camSourceLangName = "cam_src_lang_name"
    private let camDestinationLangName = "cam_dst_lang_name"

    private let srcLangName = "src_lang_name"
    private let desLangName = "dst_lang_name"
    private let trimming = "trimming"
    private let displayStatus = "display_status"

    let swipeMenu = "swipe_menu"
    let longTapMenu = "longtap_menu"

    //MARK: - Event parameter value properties
    let buttonAgree = "agree"
    let buttonConfirm = "confirm"
    let sourceLanguageName = "src_lang_name"
    let destinationLanguageName = "dst_lang_name"

    let userId = "user_id"
    let buttonNext = "next"
    let buttonReturn = "return"
    let buttonClose = "close"

    let buttonTextSize = "text_size"
    let buttonSysLang = "sys_lang"
    let buttonManual = "manual"
    let buttonInfo = "info"

    let buttonSupport = "support"
    let buttonReset = "reset"
    let buttonBack = "back"
    let buttonVersion = "version"

    let buttonLicense = "license"
    let buttonCam = "cam"
    let buttonFav = "favo"
    let buttonAll = "all"

    let buttonDelete = "delete"
    let buttonOK = "ok"
    let buttonSourceLang = "select_src_lang"
    let buttonDestinationLang = "select_dst_lang"

    let buttonCamera = "cam_translate"
    let buttonHistory = "history"
    let buttonSettings = "setting"
    let buttonExchangeLang = "exchange_lang"

    let buttonSelectRegion = "select_region"
    let buttonVoiceInput = "voice_input"
    let buttonWeek = "week"
    let buttonMonth = "month"

    let buttonYear = "year"
    let buttonRestore = "restore"
    let buttonStart = "start"
    let buttonCancel = "cancel"

    let buttonON = "on"
    let buttonOFF = "off"
    let buttonTapCard = "tap_card"
    let buttonMenu = "menu"

    let favoriteStatusOn = "ON"
    let favoriteStatusOff = "OFF"
    let buttonReverseTranslate = "reverse_translate"
    let buttonPractice = "practice"

    let nameOfTargetLanguage = "Name of Target Language"
    let buttonShare = "share"
    let buttonSpeed = "speed"
    let sharedApp = "share_app"

    let app = "app"
    let buttonCard = "card"
    let buttonLongTap = "longtap"
    let buttonHistoryMenu = "menu"

    let buttonCameraSourceLang = "select_cam_src_lang"
    let buttonCameraDestinationLang = "select_cam_dst_lang"
    let buttonCamHistory = "cam_history"
    let buttonDisplayHistory = "display_history"
    let translate = "translate"

    enum PronunciationPlayBackSpeed: String {
        case normal = "Normal"
        case slow = "Slow"
        case verySlow = "Very Slow"
    }


    //MARK: - UserProperty key-value properties
    private let operatingSystem = "os"
    private let systemLanguage = "system_language"
    private let subscriptionPlanInfo = "plan"
    private let threeDaysTrialInfo = "free"

    private let sbCouponUsesInfo = "sb"
    private let userUniqueId = "udid"
    private let firebaseGeneratedUniqueId = "uuid"
    private let deviceUniqueId = "dvid"
    private let iOSOperatingSystemName = "ios"

    //MARK: - Set UserProperty
    private func setDefaultUserProperty() {
        Analytics.setUserProperty(iOSOperatingSystemName, forName: operatingSystem)
        Analytics.setUserProperty(userProperty.getSystemLanguageName(), forName: systemLanguage)

        Analytics.setUserProperty(userProperty.getSubscriptionPlanInfo(), forName: subscriptionPlanInfo)
        //Analytics.setUserProperty(userProperty.getSubscriptionPlanInfo(), forName: threeDaysTrialInfo)
        Analytics.setUserProperty(userProperty.getSBCouponUsesInfo(), forName: sbCouponUsesInfo)
        Analytics.setUserProperty(userProperty.getUDID(), forName: userUniqueId)
        Analytics.setUserProperty(userProperty.getFirebaseUserPseudoID(), forName: firebaseGeneratedUniqueId)
        Analytics.setUserProperty(userProperty.getUDID(), forName: deviceUniqueId)
    }

    private func logUserProperty() {
        let userPropertyList: [String: String] = [
            operatingSystem: iOSOperatingSystemName,
            systemLanguage: userProperty.getSystemLanguageName(),
            subscriptionPlanInfo: userProperty.getSubscriptionPlanInfo(),
            sbCouponUsesInfo: userProperty.getSBCouponUsesInfo(),
            userUniqueId: userProperty.getUDID(),
            firebaseGeneratedUniqueId: userProperty.getFirebaseUserPseudoID(),
            deviceUniqueId: userProperty.getUDID()
        ]

        PrintUtility.printLog(tag: TagUtility.sharedInstance.googleAnalyticsTag, text: "User Properties: \(userPropertyList)")
    }

    //MARK: - Base logEvent function
    func logEvent(event: GoogleAnalyticEvent, parameters: [String: String]) {
        Analytics.logEvent(event.rawValue, parameters: parameters)
        PrintUtility.printLog(tag: TagUtility.sharedInstance.googleAnalyticsTag, text: "Event name:[\(event.rawValue)] & Parameters: \(parameters)")

        setDefaultUserProperty()
        logUserProperty()
    }

    //MARK: - Button tap logEvent function
    func buttonTap(screenName: String,  buttonName: String) {
        let parameter = [mainScreenName: screenName, buttonParamName: buttonName]
        logEvent(event: .pressButton, parameters: parameter)
    }

    //MARK: - Initial flow logEvent functions
    func purchasePlanButtonTap(screenName: String,  buttonName: String, plan: String) {
        let parameter = [mainScreenName: screenName, buttonParamName: buttonName]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func permission(screenName: String, permissionStatus: Bool) {
        let status = permissionStatus ? buttonON : buttonOFF
        let parameter = [mainScreenName: screenName, buttonParamName: status]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func permissionConfirm(screenName: String, buttonName: String, micPermissionStatus: Bool, camPermissionStatus: Bool) {
        let micStatus = micPermissionStatus ? buttonON : buttonOFF
        let camStatus = camPermissionStatus ? buttonON : buttonOFF

        let status = micStatus + "/" + camStatus
        let parameter = [mainScreenName: screenName,
                        userID: getUUID() ?? "",
                        buttonParamName: buttonName,
                        permissionStatus: status]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func purchasePlan(screenName: String, buttonName: String, selectedPlan: String) {
        let parameter = [mainScreenName: screenName,
                        buttonParamName: buttonName,
                        purchasePlan: selectedPlan]
        logEvent(event: .pressButton, parameters: parameter)
    }

    //MARK: - Setting logEvent functions
    func settingTextSize(screenName: String, menu: String, size: String) {
        let parameter = [mainScreenName: screenName,
                        selectMenu: menu,
                        textSize: size]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func settingSystemLanguage(screenName: String, button: String, beforeSysLang: String, afterSysLang: String) {
        let parameter = [mainScreenName: screenName,
                        buttonParamName: button,
                        beforeSysLanguage: beforeSysLang,
                        afterSysLanguage: afterSysLang]
        logEvent(event: .pressButton, parameters: parameter)
    }

    //MARK: - Translation flow logEvent functions
    func mainTalkButton(screenName: String, srcLanguageName: String, desLanguageName: String){
        let parameter = [mainScreenName: screenName,
                        userID: getUUID() ?? "",
                        voiceInputMenu: translate,
                        sourceLanguageName: srcLanguageName,
                        destinationLanguageName: desLanguageName]
        logEvent(event: .translate, parameters: parameter)
    }

    func changeLanguage(screenName: String, buttonName: String, srcLanguageName: String, desLanguageName: String) {
        let parameter = [mainScreenName: screenName,
                        buttonParamName: buttonName,
                        sourceLanguageName: srcLanguageName,
                        destinationLanguageName: desLanguageName]
        logEvent(event: .pressButton, parameters: parameter)
    }


    func updateSourceLanguage(screenName: String, buttonName: String, srcLanguageName: String) {
        let parameter = [mainScreenName: screenName,
                        buttonParamName: buttonName,
                        sourceLanguageName: srcLanguageName]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func updateDestinationLanguage(screenName: String, buttonName: String, desLanguageName: String) {
        let parameter = [mainScreenName: screenName,
                        buttonParamName: buttonName,
                        destinationLanguageName: desLanguageName]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func addToFavorite(screenName: String, buttonName: String, isLiked: Bool) {
        let parameter = [mainScreenName: screenName,
                        buttonParamName: buttonName,
                        favoriteStatus: isLiked ? (favoriteStatusOn) : (favoriteStatusOff)]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func pronunciationPlayBack(screenName: String, playBackType: PronunciationPlayBackSpeed) {
        let parameter = [mainScreenName: screenName,
                        selectMenu: speed,
                        speed: playBackType.rawValue]
        logEvent(event: .select, parameters: parameter)
    }

    func destinationLanguageSelect(screenName: String,  buttonName: String, desLanguageName: String) {
        let parameter = [mainScreenName: screenName,
                        buttonParamName: buttonName,
                        destinationLanguageName: desLanguageName]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func pronunciationPractice(screenName: String, eventParamName: String, practiceCount: Int) {
        let parameter = [mainScreenName: screenName,
                        voiceInputMenu: eventParamName,
                        count: "\(practiceCount) of tries performed against current practice"]
        logEvent(event: .voiceInput, parameters: parameter)
    }

    //MARK: - History logEvent functions
    func historyItemSelect(screenName: String,  buttonName: String, srcLanguageName: String, desLanguageName: String, buttonParam: String, event: GoogleAnalyticEvent) {
        let parameter = [mainScreenName: screenName,
                            buttonParam: buttonName,
                        sourceLanguageName: srcLanguageName,
                        destinationLanguageName: desLanguageName]
        logEvent(event: event, parameters: parameter)
    }

    func historyTalkButton(screenName: String, srcLanguageName: String, desLanguageName: String) {
        let parameter = [mainScreenName: screenName,
                        voiceInputMenu: translate,
                        sourceLanguageName: srcLanguageName,
                        destinationLanguageName: desLanguageName]
        logEvent(event: .translate, parameters: parameter)
    }

    func historyCardMenuDelete(screenName: String, srcLanguageName: String, desLanguageName: String) {
        let parameter = [mainScreenName: screenName,
                        buttonParamName: buttonDelete,
                        sourceLanguageName: srcLanguageName,
                        destinationLanguageName: desLanguageName]
        logEvent(event: .pressButton, parameters: parameter)
    }

    //MARK: - Camera logEvent functions
    func takePicture(screenName: String, zoom: String, source: String, destination: String) {
        let parameter = [mainScreenName: screenName,
                        expansion: "Zoom \(zoom)x when taking picture",
                        camSourceLangName: source,
                        camDestinationLangName: destination]
        logEvent(event: .takePicture, parameters: parameter)
    }

    func cameraLanguageSelect(screenName: String, button: String, langName: String, fromSrc: Bool) {
        let param = fromSrc ? srcLangName : desLangName
        let parameter = [mainScreenName: screenName,
                        buttonParamName: button,
                        param: langName]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func cameraCrop(screenName: String, button: String, crop: Bool) {
        let status = crop ? "ON" : "OFF"
        let parameter = [mainScreenName: screenName,
                        buttonParamName: button,
                        trimming: status]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func cameraResult(screenName: String, button: String, mode: String) {
        let parameter = [mainScreenName: screenName,
                        buttonParamName: button,
                        displayStatus: mode]
        logEvent(event: .pressButton, parameters: parameter)
    }

    //MARK: - Common logEvent functions
    func translateResultMenuShare(screenName: String, eventParamName: String, sharedAppName: String) {
        let parameter = [mainScreenName: screenName,
                        selectMenu: eventParamName,
                        sharedApp: sharedAppName]
        logEvent(event: .select, parameters: parameter)
    }
}

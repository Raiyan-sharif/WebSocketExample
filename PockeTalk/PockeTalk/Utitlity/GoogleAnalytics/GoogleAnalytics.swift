//
//  GoogleAnalytics.swift
//  PockeTalk
//

import Foundation
import FirebaseAnalytics

enum GoogleAnalyticEvent: String {
    case pressButton = "press_btn"
}

struct GoogleAnalytics {

    //Screen property
    private let mainScreenName = "mainScreenName"
    let firstAgreement = "first_agreement"
    let firstTutorialOne = "first_turorial_1"
    let firstTutorialTwo = "first_turorial_2"
    let firstTutorialThree = "first_turorial_3"
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
    let settingResetFavo = "setting_reset_favo"
    let settingResetAll = "setting_reset_all"

    //Parameter key property
    private let buttonParamName = "btn_name"
    let userID = "user_id"
    let permissionStatus = "permission_status"
    let purchasePlan = "plan"
    let selectMenu = "select_menu"
    let textSize = "text_size"
    let beforeSysLang = "before_sys_lang"
    let afterSysLang = "after_sys_lang"

    //Parameter value property
    let buttonAgree = "agree"
    let buttonConfirm = "confirm"

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
    let buttonHistory = "history"
    let buttonCam = "cam"
    let buttonFavo = "favo"
    let buttonAll = "all"
    let buttonDelete = "delete"

    let buttonWeek = "week"
    let buttonMonth = "month"
    let buttonYear = "year"
    let buttonRestore = "restore"

    let buttonStart = "start"
    let buttonCancel = "cancel"

    let buttonON = "on"
    let buttonOFF = "off"

    let buttonOK = "ok"

    //Log event
    func logEvent(event: GoogleAnalyticEvent, parameters: [String: String]) {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.googleAnalyticsTag, text: "Log event name:[\(event.rawValue)] & Parameter: \(parameters)")
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }

    //Button tap log event
    func buttonTap(screenName: String, buttonName: String) {
        let parameter = [mainScreenName: screenName, buttonParamName: buttonName]
        logEvent(event: .pressButton, parameters: parameter)
    }

    //Initial flow log event
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
                        userID: "\(getUUID() ?? "nil")",
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

    func settingTextSize(screenName: String, menu: String, size: String) {
        let parameter = [mainScreenName: screenName,
                        selectMenu: menu,
                        textSize: size]
        logEvent(event: .pressButton, parameters: parameter)
    }

    func settingSystemLanguage(screenName: String, button: String, before: String, after: String) {
        let parameter = [mainScreenName: screenName,
                        buttonParamName: button,
                        beforeSysLang: before,
                        afterSysLang: after]
        logEvent(event: .pressButton, parameters: parameter)
    }
}

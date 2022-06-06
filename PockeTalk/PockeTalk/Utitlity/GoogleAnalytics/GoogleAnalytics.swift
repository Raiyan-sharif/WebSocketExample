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

    //Parameter property
    private let buttonParamName = "btn_name"
    let buttonAgree = "agree"
    let buttonConfirm = "confirm"

    let buttonNext = "next"
    let buttonReturn = "return"
    let buttonClose = "close"

    //Log event
    func logEvent(event: GoogleAnalyticEvent, parameters: [String: String]) {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.googleAnalyticsTag, text: "Log event name:[\(event.rawValue)] & Parameter: \(parameters)")
        Analytics.logEvent(event.rawValue, parameters: parameters)
    }

    //Custom functions
    func buttonTap(screenName: String,  buttonName: String) {
        let parameter = [mainScreenName: screenName, buttonParamName: buttonName]
        logEvent(event: .pressButton, parameters: parameter)
    }
}

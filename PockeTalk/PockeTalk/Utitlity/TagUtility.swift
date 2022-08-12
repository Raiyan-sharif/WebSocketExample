//
//  TagUtility.swift
//  PockeTalk
//

import UIKit

public class TagUtility: NSObject{
    public static let sharedInstance = TagUtility()

    private override init() {
        super.init()
    }

    let cameraScreenPurpose = "cameraScreenPurpose"
    let sbAuthTag = "sbAuthTag"
    let iapTag = "IAPTAG"
    let localNotificationTag = "localNotificationTag"
    let trialTag = "free_trial"
    let googleAnalyticsTag = "googleAnalyticsTag"
}

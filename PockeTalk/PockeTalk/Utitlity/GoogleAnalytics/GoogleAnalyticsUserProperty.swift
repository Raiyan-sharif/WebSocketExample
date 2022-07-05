//
//  GoogleAnalyticsUserProperty.swift
//  PockeTalk
//

import Foundation
import SwiftKeychainWrapper
import FirebaseAnalytics

struct GoogleAnalyticsUserProperty {
    enum UserSubscriptionType: String {
        case iAP = "subsc"
        case coupon = "sb"
        case none = "none"
    }

    func getSystemLanguageName() -> String {
        return LanguageManager.shared.currentLanguage.rawValue
    }

    /*
    subsc：User is using under paid subscription
    sb：User is using under SB coupon
    none：None of subsc or sb
    */

    func getSubscriptionPlanInfo() -> String {
        //Check for coupon
        if let _ =  UserDefaults.standard.string(forKey: kCouponCode) {
            return UserSubscriptionType.coupon.rawValue
        }

        //Check for IAP
        if KeychainWrapper.standard.bool(forKey: kInAppPurchaseStatus) == true {
            return UserSubscriptionType.iAP.rawValue
        }

        //User unsubscribe
        return UserSubscriptionType.none.rawValue
    }

    /*
    on: User has used SB coupon before
    off: User has never used SB coupon before
    */

    func getSBCouponUsesInfo() -> String {
        if let couponUsesInfoExist = KeychainWrapper.standard.bool(forKey: kIsCouponAlreadyUsedOnce), couponUsesInfoExist == true {
            return "on"
        }

        return "off"
    }

    func getUDID() -> String {
        return getUUID() ?? ""
    }

    func getFirebaseUserPseudoID() -> String {
        return Analytics.appInstanceID() ?? ""
    }
}

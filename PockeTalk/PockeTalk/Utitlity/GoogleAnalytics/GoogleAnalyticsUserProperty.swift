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
        case serial = "serial"
        case none = "none"
    }

    func getSystemLanguageName() -> String {
        let sysLangCode = LanguageManager.shared.currentLanguage.rawValue
        let alternativeSystemLangCode = GlobalMethod.getSystemLanguageCodeForAnalytics(sysLangCode: sysLangCode)

        let sysLangName = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: alternativeSystemLangCode)?.name ?? ""
        return sysLangName

    }

    /*
     on：User hasn't signed up for subscription but is under free trial period
     off：State other than on
     */

    func getFreeTrialInfo() -> String {
        if let _ = UserDefaults.standard.string(forKey: kFreeTrialStatus) {
            return "on"
        }
        return "off"
    }

    /*
    subsc：User is using under paid subscription
    sb：User is using under SB coupon
    serial：User is using under serial
    none：None of subsc or sb
    */

    func getSubscriptionPlanInfo() -> String {
        //Check for coupon
        if let _ =  UserDefaults.standard.string(forKey: kCouponCode) {
            return UserSubscriptionType.coupon.rawValue
        }

        //Check for serial auth
        if let _ = UserDefaults.standard.string(forKey: kSerialCodeKey) {
            return UserSubscriptionType.serial.rawValue
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

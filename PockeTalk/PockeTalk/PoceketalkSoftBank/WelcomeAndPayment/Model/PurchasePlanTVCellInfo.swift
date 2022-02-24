//
//  PurchasePlanTVCellInfo.swift
//  PockeTalk
//

import UIKit

enum PurchasePlanTVCellInfo: Int {
    case selectPlan
    case weeklyPlan
    case monthlyPlan
    case annualPlan
    case cancle
    case restorePurchase

    var title: String {
        get {
            switch self {
            case .selectPlan: return "kPaidPlanVCRestorePurchaseButtonAlertTitle".localiz()
            case .weeklyPlan: return "Weekly Plan"
            case .monthlyPlan: return "Monthly Plan"
            case .annualPlan: return "Annual Plan"
            case .cancle: return "cancel".localiz()
            case .restorePurchase: return "kPaidPlanVCRestorePurchaseHistoryButton".localiz()
            }
        }
    }

    var subTitle: String {
        get {
            switch self {
            case .selectPlan, .cancle, .restorePurchase: return ""
            case .weeklyPlan: return "120 yen / week"
            case .monthlyPlan: return "370 yen / month"
            case .annualPlan: return "3680 yen / year"
            }
        }
    }

    var freePromotionText: String {
        get {
            switch self {
            case .selectPlan, .weeklyPlan, .monthlyPlan, .annualPlan, .cancle, .restorePurchase: return ""
            }
        }
    }

    var height: CGFloat {
        get {
            switch self {
            case .selectPlan:
                return 80
            case .weeklyPlan, .monthlyPlan, .annualPlan:
                return 90
            case .cancle, .restorePurchase:
                return 50
            }
        }
    }
}

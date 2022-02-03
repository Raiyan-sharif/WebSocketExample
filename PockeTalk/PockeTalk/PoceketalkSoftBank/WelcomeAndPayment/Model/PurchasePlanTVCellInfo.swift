//
//  PurchasePlanTVCellInfo.swift
//  PockeTalk
//

import UIKit

enum PurchasePlanTVCellInfo: Int {
    case selectPlan
    case dailyPlan
    case weeklyPlan
    case monthlyPlan
    case annualPlan
    case cancle
    case restorePurchase

    var unitType: String {
        get {
            switch self {
            case .selectPlan, .cancle, .restorePurchase: return ""
            case .dailyPlan:
                return PeriodUnitType.day.rawValue
            case .weeklyPlan:
                return PeriodUnitType.week.rawValue
            case .monthlyPlan:
                return PeriodUnitType.month.rawValue
            case .annualPlan:
                return PeriodUnitType.year.rawValue
            }
        }
    }

    var planTitleText: String{
        get {
            switch self {
            case .selectPlan, .cancle, .restorePurchase: return ""
            case .dailyPlan:
                return "Daily Plan".localiz()
            case .weeklyPlan:
                return "Weekly Plan".localiz()
            case .monthlyPlan:
                return "Monthly Plan".localiz()
            case .annualPlan:
                return "Yearly Plan".localiz()
            }
        }
    }

    var title: String {
        get {
            switch self {
            case .selectPlan: return "kPaidPlanVCRestorePurchaseButtonAlertTitle".localiz()
            case .dailyPlan, .weeklyPlan, .monthlyPlan, .annualPlan: return ""
            case .cancle: return "cancel".localiz()
            case .restorePurchase: return "kPaidPlanVCRestorePurchaseHistoryButton".localiz()
            }
        }
    }

    var height: CGFloat {
        get {
            switch self {
            case .selectPlan:
                return 80
            case .dailyPlan, .weeklyPlan, .monthlyPlan, .annualPlan:
                return 90
            case .cancle, .restorePurchase:
                return 50
            }
        }
    }
}

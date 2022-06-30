//
//  PurchasePlanTVCellInfo.swift
//  PockeTalk
//

import UIKit

enum PurchasePlanTVCellInfo: Int {
    case selectPlan
    case freeUses
    case threeDaysTrial
    case dailyPlan
    case weeklyPlan
    case monthlyPlan
    case annualPlan
    case restorePurchase

    var unitType: String {
        get {
            switch self {
            case .selectPlan, .freeUses, .threeDaysTrial, .restorePurchase: return ""
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
            case .selectPlan, .freeUses, .threeDaysTrial, .restorePurchase: return ""
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
            case .threeDaysTrial: return "kThreeDaysTrial".localiz()
            case .selectPlan: return "kPaidPlanVCRestorePurchaseButtonAlertTitle".localiz()
            case .dailyPlan, .weeklyPlan, .monthlyPlan, .annualPlan: return ""
            case .restorePurchase: return "kPaidPlanVCRestorePurchaseHistoryButton".localiz()
            case .freeUses: return "kIAPFreePeriodCancellationDescription".localiz() + "kIAPFreePeriodSubscriptionDescription".localiz()
            }
        }
    }

    var height: CGFloat {
        get {
            switch self {
            case .selectPlan:
                return 70
            case .freeUses:
                return UITableView.automaticDimension
            case .monthlyPlan, .annualPlan:
                return 120
            case .dailyPlan, .weeklyPlan, .threeDaysTrial:
                return 110
            case .restorePurchase:
                return 100
            }
        }
    }
}

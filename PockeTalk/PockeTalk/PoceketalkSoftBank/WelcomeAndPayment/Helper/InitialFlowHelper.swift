//
//  InitialFlowHelper.swift
//  PockeTalk
//

import UIKit

class InitialFlowHelper{

    var nextButtonCornerRadius: CGFloat {
        return 8.0
    }

    var planTypeLabelTopLayoutConstrain: CGFloat {
        return 16.0
    }

    var weeklyProductImage: String {
        return "plan_week"
    }

    var monthlyProductImage: String {
        return "plan_month"
    }

    var annualProductImage: String {
        return "plan_year_withlabel"
    }

    func getTermAndConditionBtnAttributedString() -> NSMutableAttributedString {
        let termAndConditionBtnTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.white
        ]

        return NSMutableAttributedString(
            string: "kTermsAndConditionsVCAcceptTermsButtonButtonTitle".localiz(),
            attributes: termAndConditionBtnTextAttributes
        )
    }

    func getAcceptAndStartBtnAttributedString() -> NSMutableAttributedString {
        let acceptBtnTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]

        return NSMutableAttributedString(
            string: "kTermsAndConditionsVCCheckTermsButtonTitle".localiz(),
            attributes: acceptBtnTextAttributes
        )
    }

    func showSingleAlert(message: String) -> UIAlertController {
        let alertController = UIAlertController(title: "kPockeTalk".localiz(), message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor.black
        alertController.addAction(UIAlertAction(title: "OK".localiz(), style: .default, handler: nil))
        return alertController
    }

    func showNoInternetAlert(on vc: UIViewController) {
        vc.popupAlert(title: "internet_connection_error".localiz(), message: "", actionTitles: ["connect_via_wifi".localiz(), "Cancel".localiz()], actionStyle: [.default, .cancel], action: [
            { connectViaWifi in
                DispatchQueue.main.async {
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            },{ cancel in
                PrintUtility.printLog(tag: "initialFlow", text: "Tap on no internet cancle")
                if ScreenTracker.sharedInstance.screenPurpose != .WalkThroughViewController{
                    exit(0)
                }
            }
        ])
    }
}

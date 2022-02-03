//
//  InitialFlowHelper.swift
//  PockeTalk
//

import UIKit

class InitialFlowHelper{

    var nextButtonCornerRadius: CGFloat {
        return 8.0
    }

    func getTermAndConditionBtnAttributedString() -> NSMutableAttributedString {
        let termAndConditionBtnTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18),
            .foregroundColor: UIColor.white
        ]

        return NSMutableAttributedString(
            string: "kTermsAndConditionsVCCheckTermsButtonTitle".localiz(),
            attributes: termAndConditionBtnTextAttributes
        )
    }

    func getAcceptAndStartBtnAttributedString() -> NSMutableAttributedString {
        let acceptBtnTextAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]

        return NSMutableAttributedString(
            string: "kTermsAndConditionsVCAcceptTermsButtonButtonTitle".localiz(),
            attributes: acceptBtnTextAttributes
        )
    }

    func showSingleAlert(message: String) -> UIAlertController {
        let alertController = UIAlertController(title: "kPockeTalk".localiz(), message: message, preferredStyle: .alert)
        alertController.view.tintColor = UIColor.black
        alertController.addAction(UIAlertAction(title: "OK".localiz(), style: .default, handler: nil))
        return alertController

    }
}

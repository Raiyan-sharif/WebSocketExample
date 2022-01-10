//
//  PaidPlanViewController.swift
//  PockeTalk
//
//  Created by BJIT on 4/1/22.
//

import UIKit

class PaidPlanViewController: UIViewController {
    let TAG = "\(PaidPlanViewController.self)"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bulletPointOneLabel: UILabel!
    @IBOutlet weak var bulletPointTwoLabel: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var restorePurchaseHistoryButton: UIButton!
    
    func restorePurchaseHistoryButtonUI() {
        restorePurchaseHistoryButton.layer.cornerRadius = 10
        restorePurchaseHistoryButton.layer.borderColor = UIColor.black.cgColor
        restorePurchaseHistoryButton.layer.borderWidth = 1.0
    }
    
    func initialUISetUp() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        restorePurchaseHistoryButtonUI()
        titleLabel.text = "kPaidPlanVCTitleLabel".localiz()
        bulletPointOneLabel.text = "kPaidPlanVCBulletPointOneLabel".localiz()
        bulletPointTwoLabel.text = "kPaidPlanVCBulletPointTwoLabel".localiz()
        purchaseButton.setTitle("kPaidPlanVCPurchaseButtonTitle".localiz(), for: .normal)
        restorePurchaseHistoryButton.setTitle("kPaidPlanVCRestorePurchaseHistoryButton".localiz(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetUp()
    }
    
    @IBAction func purchaseButtonAction(_ sender: Any) {
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).numberOfLines = 2
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).lineBreakMode = .byWordWrapping
        self.popupAlert(title: "kPaidPlanVCRestorePurchaseButtonAlertTitle".localiz(), message: "", actionTitles: ["kPaidPlanVCRestorePurchaseButtonAlertButtonOneTitle".localiz(), "kPaidPlanVCRestorePurchaseButtonAlertButtonTwoTitle".localiz(), "cancel".localiz()], actionStyle: [.default, .default, .cancel], action: [
            { perMonth in
                self.fourHundredYenPermonth()
            },{ perYear in
                self.twoThousandYenPermonth()
            },{ cancel in
                PrintUtility.printLog(tag: self.TAG, text: "Cancel button tapped.")
            }
        ])
    }
    
    func fourHundredYenPermonth() {
        self.popupAlert(title: "kPaidPlanVCRestorePurchaseButtonAlertButtonOneTitle".localiz(), message: "", actionTitles: ["OK", "cancel".localiz()], actionStyle: [.default, .cancel], action: [
            { ok in
                self.goToWelcomeViewController(isUserPurchased: true)
            },{ cancel in
                PrintUtility.printLog(tag: self.TAG, text: "Cancel button tapped.")
            }
        ])
    }
    
    func twoThousandYenPermonth() {
        self.popupAlert(title: "kPaidPlanVCRestorePurchaseButtonAlertButtonTwoTitle".localiz(), message: "", actionTitles: ["OK".localiz(), "cancel".localiz()], actionStyle: [.default, .cancel], action: [
            { ok in
                self.goToWelcomeViewController(isUserPurchased: true)
            },{ cancel in
                PrintUtility.printLog(tag: self.TAG, text: "Cancel button tapped.")
            }
        ])
    }
    
    func goToWelcomeViewController(isUserPurchased: Bool) {
        UserDefaultsProperty<Bool>(kUserDefaultIsUserPurchasedThePlan).value = isUserPurchased
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let welcomeViewController = mainStoryBoard.instantiateViewController(withIdentifier: String(describing: WelcomeViewController.self)) as? WelcomeViewController {
            let transition = CATransition()
            transition.duration = kSettingsScreenTransitionDuration
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(welcomeViewController, animated: false)
        }
    }
    
    @IBAction func restoreButtonAction(_ sender: Any) {
        self.goToWelcomeViewController(isUserPurchased: true)
    }
}

//
//  IAPStatusCheckDummyLoadingViewController.swift
//  PockeTalk
//

import UIKit
import SwiftKeychainWrapper

class IAPStatusCheckDummyLoadingViewController: UIViewController {
    var couponCode: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCouponStatus()
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func checkCouponStatus() {
        if let couponCode = self.couponCode {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "checkCouponStatus [+], CouponCode: \(couponCode)")
            checkInAppPurchaseStatus()
        }
    }

    private func checkInAppPurchaseStatus() {
        if KeychainWrapper.standard.bool(forKey: kInAppPurchaseStatus) == true {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "checkInAppPurchaseStatus [+]")
            showAlertAndRedirectToHomeVC()
        } else {
            //TODO: Call licence confirmation API from here
            ///Call api from here and start processing
        }
    }

    private func showAlertAndRedirectToHomeVC(){
        PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "showAlertAndRedirectToHomeVC [+]")

        let alertService = CustomAlertViewModel()
        let alert = alertService.alertDialogSoftbank(message: "KSubscriptionErrorMessage".localiz()) {
            GlobalMethod.appdelegate().navigateToViewController(.home)
        }
        present(alert, animated: true, completion: nil)
    }
}

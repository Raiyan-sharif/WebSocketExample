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
            //Show dialog and redirect to home
        }
    }
}

//
//  IAPStatusCheckDummyLoadingViewController.swift
//  PockeTalk
//

import UIKit
import SwiftKeychainWrapper
import Kronos

class IAPStatusCheckDummyLoadingViewController: UIViewController {
    var couponCode: String?
    @IBOutlet weak var noInternetLabel: UILabel!
    private var connectivity = Connectivity()
    private var shouldCallApi = false
    private var alert: UIAlertController?
    override func viewDidLoad() {
        super.viewDidLoad()
        checkCouponStatus()
        self.navigationController?.navigationBar.isHidden = true
        noInternetLabel.isHidden = true
        noInternetLabel.text = "internet_connection_error".localiz()
        self.connectivity.startMonitoring { [weak self] connection, reachable in
            guard let self = self else { return }
            PrintUtility.printLog(tag: "SB_AUTH", text:" \(connection) Is reachable: \(reachable)")
            if UserDefaultsProperty<Bool>(isNetworkAvailable).value == nil && reachable == .yes {
                DispatchQueue.main.async {
                    self.noInternetLabel.isHidden = true
                    self.hideNoInternetAlert()
                    if(self.shouldCallApi){
                        if let couponCode = self.couponCode {
                            self.callLicenseConfirmationApi(coupon: couponCode)
                        }
                    }
                }
            }
        }
    }

    deinit{
        self.connectivity.cancel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func checkCouponStatus() {
        if let couponCode = self.couponCode {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "checkCouponStatus [+], CouponCode: \(couponCode)")
            checkInAppPurchaseStatus(coupon: couponCode)
        }
    }

    private func checkInAppPurchaseStatus(coupon: String) {
        if KeychainWrapper.standard.bool(forKey: kInAppPurchaseStatus) == true {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "checkInAppPurchaseStatus [+]")
            showAlertAndRedirectToHomeVC()
        } else {
           callLicenseConfirmationApi(coupon: coupon)
        }
    }

    private func callLicenseConfirmationApi(coupon: String){
        IAPManager.shared.stopObserving()
        PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text:"callLicenseConfirmationApi")
        if Reachability.isConnectedToNetwork() == true{
            shouldCallApi = false
            NetworkManager.shareInstance.getLicenseConfirmation(coupon: coupon) { [weak self] data  in
                guard let data = data, let self = self else { return }
                PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text:"callLicenseConfirmationApi>>> response")
                do {
                    let result = try JSONDecoder().decode(LicenseConfirmationModel.self, from: data)
                    UserDefaults.standard.set(Date(), forKey: kLicenseConfirmationCalledTime)
                    let alertService = CustomAlertViewModel()
                    if let result_code = result.result_code {
                        if result_code == response_ok {
                                var isFromUniversalLink = false
                                if let isUniversalNav =  UserDefaults.standard.bool(forKey: kIsFromUniverslaLink) as? Bool {
                                    isFromUniversalLink = isUniversalNav
                                }
                                if isFromUniversalLink == true {
                                    UserDefaults.standard.set(false, forKey: kIsFromUniverslaLink)
                                    UserDefaults.standard.set(coupon, forKey: kCouponCode)
                                    PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Coupon saved: \(coupon)")
                                    let alert = alertService.alertDialogSoftbank(message: "kCouponActivatedMesage".localiz()) {
                                        var couponInitialFlowCompleted = false
                                        if let flowCompleted =  UserDefaults.standard.bool(forKey: kInitialFlowCompletedForCoupon) as? Bool {
                                            couponInitialFlowCompleted = flowCompleted
                                        }
                                        if couponInitialFlowCompleted == true{
                                            GlobalMethod.appdelegate().navigateToViewController(.home)
                                        }else{
                                            GlobalMethod.appdelegate().navigateToViewController(.termAndCondition)
                                        }
                                    }
                                    self.present(alert, animated: true, completion: nil)
                                }else{
                                    var couponInitialFlowCompleted = false
                                    if let flowCompleted =  UserDefaults.standard.bool(forKey: kInitialFlowCompletedForCoupon) as? Bool {
                                        couponInitialFlowCompleted = flowCompleted
                                    }
                                    if couponInitialFlowCompleted == true{
                                        GlobalMethod.appdelegate().navigateToViewController(.home)
                                    }else{
                                        GlobalMethod.appdelegate().navigateToViewController(.termAndCondition)
                                    }
                                }
                            
                        } else if result_code == INFO_EXPIRED_LICENSE{
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "INFO_EXPIRED_LICENSE")
                            IAPManager.shared.startObserving()
                            var savedCoupon = ""
                            if let coupon =  UserDefaults.standard.string(forKey: kCouponCode) {
                                savedCoupon = coupon
                            }
                            if savedCoupon.isEmpty {
                                let alert = alertService.alertDialogSoftbank(message: "KInfoExpiredLiscnseErrorMessage".localiz()) {
                                    GlobalMethod.appdelegate().navigateToViewController(.termAndCondition)
                                }
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                UserDefaults.standard.removeObject(forKey: kCouponCode)
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Coupon removed: \(savedCoupon)")
                                let alert = alertService.alertDialogSoftbank(message: "KInfoExpiredLiscnseErrorMessage".localiz()) {
                                    GlobalMethod.appdelegate().navigateToViewController(.purchasePlan)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else if result_code == INFO_INVALID_LICENSE {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "INFO_INVALID_LICENSE")
                            let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz() , errorMessage: "KErrorCode2Message".localiz()) {
                                self.callLicenseConfirmationApi(coupon: coupon)
                            }
                            self.present(alert, animated: true, completion: nil)
                        } else if result_code == WARN_INPUT_PARAM {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "WARN_INPUT_PARAM")
                            let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz() , errorMessage: "KErrorCode1Message".localiz()) {
                                self.callLicenseConfirmationApi(coupon: coupon)
                            }
                            self.present(alert, animated: true, completion: nil)
                        } else if result_code == WARN_FAILED_CALL {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "WARN_FAILED_CALL")
                            let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz() , errorMessage: "KErrorCode4Message".localiz()) {
                                self.callLicenseConfirmationApi(coupon: coupon)
                            }
                            self.present(alert, animated: true, completion: nil)
                        } else if result_code == ERR_UNKNOWN {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "ERR_UNKNOWN")
                            let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz() , errorMessage: "KErrorCode5Message".localiz()) {
                                self.callLicenseConfirmationApi(coupon: coupon)
                            }
                            self.present(alert, animated: true, completion: nil)
                        }else {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Other cases")
                            let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz() , errorMessage: "KErrorCode5Message".localiz()) {
                                self.callLicenseConfirmationApi(coupon: coupon)
                            }
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                } catch let err {}
            }
        }else{
            showNoInternetAlert()
            shouldCallApi = true
        }
    }

    func hideNoInternetAlert() {
        if let alert = self.alert{
            alert.dismiss(animated: false, completion: nil)
        }
    }

    func showNoInternetAlert() {
        self.popupNoIntenetAlert(title: "internet_connection_error".localiz(), message: "", actionTitles: ["connect_via_wifi".localiz(), "Cancel".localiz()], actionStyle: [.default, .cancel], action: [
            { connectViaWifi in
                DispatchQueue.main.async {
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            self.noInternetLabel.isHidden = false
                        }
                    }
                }
            },{ cancel in
                PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Tap on no internet cancle")
                DispatchQueue.main.async {
                    self.noInternetLabel.isHidden = false
                }
            }
        ])
    }

    func popupNoIntenetAlert(title: String, message: String, actionTitles:[String], actionStyle: [UIAlertAction.Style], action:[((UIAlertAction) -> Void)]) {
        DispatchQueue.main.async {
            self.alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if let alert = self.alert{
                alert.view.tintColor = UIColor.black
                for (index, title) in actionTitles.enumerated() {
                    let action = UIAlertAction(title: title, style: actionStyle[index], handler: action[index])
                    alert.addAction(action)
                }
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    private func showAlertAndRedirectToHomeVC(){
        PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "showAlertAndRedirectToHomeVC [+]")

        let alertService = CustomAlertViewModel()
        let alert = alertService.alertDialogSoftbank(message: "KSubscriptionErrorMessage".localiz()) {
            if UserDefaultsUtility.getBoolValue(forKey: kIsClearedDataAll) == true {
                GlobalMethod.appdelegate().navigateToViewController(.termAndCondition)
            } else {
                GlobalMethod.appdelegate().navigateToViewController(.home)
            }
        }
        present(alert, animated: true, completion: nil)
    }
}

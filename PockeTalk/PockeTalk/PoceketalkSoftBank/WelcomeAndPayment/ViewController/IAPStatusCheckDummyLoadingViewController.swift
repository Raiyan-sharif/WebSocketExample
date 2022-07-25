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
    private var shouldCallIapApi = false
    private var alert: UIAlertController?
    private var shouldShowLoader = false
    private var statusCodeText = ""
    private var shouldCheckFreeTrialStatus = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        noInternetLabel.isHidden = true
        noInternetLabel.text = "internet_connection_error".localiz()
        registerNotification()
        registerInAppPurchaseStatusCheck()
        checkCouponStatus()
        self.connectivity.startMonitoring { [weak self] connection, reachable in
            guard let self = self else { return }
            PrintUtility.printLog(tag: "SB_AUTH", text:" \(connection) Is reachable: \(reachable)")
            if UserDefaultsProperty<Bool>(isNetworkAvailable).value == nil && reachable == .yes {
                DispatchQueue.main.async {
                    self.noInternetLabel.isHidden = true
                    self.hideNoInternetAlert()
                    if(self.shouldCallApi){
                        if let couponCode = self.couponCode {
                            if self.shouldCallIapApi == true{
                                self.checkInAppPurchaseStatus(coupon: couponCode)
                            }else{
                                self.callLicenseConfirmationApi(coupon: couponCode)
                            }
                        }
                        
                    }else if(self.shouldCheckFreeTrialStatus){
                        self.checkFreeTrialStatus()
                    }
                }
            }
        }
    }

    private func unregisterNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func applicationWillResignActive(notification: Notification) {
        ActivityIndicator.sharedInstance.hide()
    }

    @objc func applicationDidBecomeActive(notification: Notification) {
        if shouldShowLoader == true {
            ActivityIndicator.sharedInstance.show()
        }else{
            ActivityIndicator.sharedInstance.hide()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.connectivity.cancel()
        IAPManager.shared.shouldBypassPurchasePlan = false
        unregisterNotification()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func registerInAppPurchaseStatusCheck() {
        IAPManager.shared.statusBlock = { [weak self] (success, error, statusCode) in
            guard let `self` = self else {return}

            if let statusCode = statusCode, statusCode != 0 {
                self.statusCodeText = "[\(statusCode)]"
            } else {
                if let errorMsg = error{
                    if errorMsg.localizedDescription == EMPTY_RESPONSE{
                        self.statusCodeText = "[\(errorMsg.localizedDescription)]"
                    }
                }
            }

            if let couponCode = self.couponCode {
                if success {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "checkInAppPurchaseStatus [+]")
                    self.hideLoader()
                    self.showAlertAndRedirectToVC("KSubscriptionErrorMessage".localiz())
                } else {
                    self.callLicenseConfirmationApi(coupon: couponCode)
                }
            }
        }
    }

    private func checkCouponStatus() {
        if let couponCode = self.couponCode {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "checkCouponStatus [+], CouponCode: \(couponCode)")
            if let isFromUniversalLink = UserDefaults.standard.bool(forKey: kIsFromUniverslaLink) as? Bool {
                if isFromUniversalLink == true {
                    checkFreeTrialStatus()
                } else {
                    self.callLicenseConfirmationApi(coupon: couponCode)
                }
            }
        }
    }

//    private func iAPStatusCheckAlert(message: String, coupon: String) {
//        let alertService = CustomAlertViewModel()
//        DispatchQueue.main.async {
//            let alert = alertService.alertDialogSoftbank(message: message) {
//                self.checkInAppPurchaseStatus(coupon: coupon)
//            }
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
    
    private func checkFreeTrialStatus(){
        if Reachability.isConnectedToNetwork() == true{
            self.shouldCheckFreeTrialStatus = false
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => Has internet => Calling license conformation API")
            NetworkManager.shareInstance.callLicenseConfirmationForFreeTrial { [weak self] data  in
                guard let data = data, let self = self else {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => Data => nill => API FAILED")
                    self?.hideLoader()
                    return
                }
                do {
                    let result = try JSONDecoder().decode(LicenseConfirmationModel.self, from: data)
                    self.hideLoader()
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => result_code => \(result.result_code)")
                    if let result_code = result.result_code {
                        if result_code == response_ok {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"====== Trial is Active =====")
                            self.showAlertAndRedirectToVC("KFreeTrialErrorMessage".localiz())
                        }else {
                            if let couponCode = self.couponCode {
                                self.checkInAppPurchaseStatus(coupon: couponCode)
                            }
                        }
                    }else{
                        UserDefaults.standard.set(false, forKey: kFreeTrialStatus)
                        if let couponCode = self.couponCode {
                            self.checkInAppPurchaseStatus(coupon: couponCode)
                        }
                    }
                } catch let err {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => Error => \(err.localizedDescription)")
                    self.hideLoader()
                    UserDefaults.standard.set(false, forKey: kFreeTrialStatus)
                    if let couponCode = self.couponCode {
                        self.checkInAppPurchaseStatus(coupon: couponCode)
                    }
                }
            }
        }else{
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => No internet ")
            self.hideLoader()
            self.showNoInternetAlert()
            self.shouldCheckFreeTrialStatus = true
        }
    }

    private func checkInAppPurchaseStatus(coupon: String) {
        if Reachability.isConnectedToNetwork() == true{
            self.showLoader()
            self.noInternetLabel.isHidden = true
            shouldCallApi = false
            shouldCallIapApi = false
            IAPManager.shared.receiptValidationForCouponCode()
        }else{
            self.hideLoader()
            shouldCallApi = true
            shouldCallIapApi = true
            showNoInternetAlert()
        }
    }

    private func callLicenseConfirmationApi(coupon: String){
        IAPManager.shared.stopObserving()
        shouldCallIapApi = false
        PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text:"callLicenseConfirmationApi")
        if Reachability.isConnectedToNetwork() == true{
            self.showLoader()
            shouldCallApi = false
            NetworkManager.shareInstance.getLicenseConfirmation(coupon: coupon) { [weak self] data  in
                guard let data = data, let self = self else {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text:"Unknown Error")
                    self?.hideLoader()
                    self?.showUnknownErrorDialog()
                    return
                }
                PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text:"callLicenseConfirmationApi>>> response")
                do {
                    let result = try JSONDecoder().decode(LicenseConfirmationModel.self, from: data)
                    UserDefaults.standard.set(Date(), forKey: kLicenseConfirmationCalledTime)
                    self.hideLoader()
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
                                    DispatchQueue.main.async {
                                        let alert = alertService.alertDialogSoftbankWithError(message: "kCouponActivatedMesage".localiz(), errorMessage: self.statusCodeText) {
                                            GlobalMethod.appdelegate().gotoNextVcForCoupon()
                                        }
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }else{
                                    GlobalMethod.appdelegate().gotoNextVcForCoupon()
                                }
                            
                        } else if result_code == INFO_EXPIRED_LICENSE{
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "INFO_EXPIRED_LICENSE")
                            IAPManager.shared.startObserving()
                            var savedCoupon = ""
                            if let coupon =  UserDefaults.standard.string(forKey: kCouponCode) {
                                savedCoupon = coupon
                            }
                            if savedCoupon.isEmpty {
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Coupon not found!")
                            } else {
                                UserDefaults.standard.removeObject(forKey: kCouponCode)
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Coupon removed: \(savedCoupon)")
                            }
                            
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogSoftbank(message: "KInfoExpiredLiscnseErrorMessage".localiz()) {
                                    GlobalMethod.appdelegate().gotoNextVcForAuth()
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else if result_code == INFO_INVALID_LICENSE {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "INFO_INVALID_LICENSE")
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz(), errorMessage: "KErrorCode2Message".localiz()) {
                                    self.callLicenseConfirmationApi(coupon: coupon)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else if result_code == WARN_INPUT_PARAM {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "WARN_INPUT_PARAM")
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz(), errorMessage: "KErrorCode1Message".localiz()) {
                                    self.callLicenseConfirmationApi(coupon: coupon)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else if result_code == WARN_FAILED_CALL {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "WARN_FAILED_CALL")
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz(), errorMessage: "KErrorCode4Message".localiz()) {
                                    self.callLicenseConfirmationApi(coupon: coupon)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else if result_code == ERR_UNKNOWN {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "ERR_UNKNOWN")
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz(), errorMessage: "KErrorCode5Message".localiz()) {
                                    self.callLicenseConfirmationApi(coupon: coupon)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        }else {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Other cases")
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz(), errorMessage: "KErrorCode5Message".localiz()) {
                                    self.callLicenseConfirmationApi(coupon: coupon)
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } catch let err {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text:"Unknown Error: \(err.localizedDescription)")
                    self.hideLoader()
                    self.showUnknownErrorDialog()
                }
            }
        }else{
            self.hideLoader()
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

    private func showAlertAndRedirectToVC(_ msg: String){
        PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "showAlertAndRedirectToHomeVC [+]")
        DispatchQueue.main.async {
            let alertService = CustomAlertViewModel()
            let alert = alertService.alertDialogSoftbank(message: msg) {
                if UserDefaults.standard.bool(forKey: kFreeTrialStatus) == true || KeychainWrapper.standard.bool(forKey: kInAppPurchaseStatus) == true{
                    GlobalMethod.appdelegate().gotoNextVc(false)
                } else {
                    GlobalMethod.appdelegate().gotoNextVcForAuth()
                }
            }
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func showUnknownErrorDialog(){
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            let alertService = CustomAlertViewModel()
            let alert = alertService.alertDialogSoftbank(message: ERR_UNKNOWN) {
                exit(0)
            }
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func showLoader(){
        DispatchQueue.main.async {
            ActivityIndicator.sharedInstance.show()
            self.shouldShowLoader = true
        }
    }

    private func hideLoader(){
        DispatchQueue.main.async {
            ActivityIndicator.sharedInstance.hide()
            self.shouldShowLoader = false
        }
    }
}

//
//  IAPStatusCheckDummyLoadingViewController.swift
//  PockeTalk
//

import UIKit
import SwiftKeychainWrapper
import Kronos
import UserNotifications

class IAPStatusCheckDummyLoadingViewController: UIViewController {
    var couponCode: String?
    var serial: String?
    @IBOutlet weak var noInternetLabel: UILabel!
    private var connectivity = Connectivity()
    private var shouldCallApi = false
    private var shouldCallIapApi = false
    private var alert: UIAlertController?
    private var shouldShowLoader = false
    private var statusCodeText = ""
    let TAG: String = "SB_AUTH"
    private var shouldCheckFreeTrialStatus = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        noInternetLabel.isHidden = true
        noInternetLabel.text = "internet_connection_error".localiz()
        registerNotification()
        registerInAppPurchaseStatusCheck()
        if let serialToCheck = serial, !serialToCheck.isEmpty{
            PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text: "IAPDUMMY.viewDidLoad >>> Serial Recieved: \(serialToCheck)")
            checkCouponStatusForSerial()
        }else if let couponToCheck = couponCode, !couponToCheck.isEmpty{
            PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text: "IAPDUMMY.viewDidLoad >>> Coupon Recieved: \(couponToCheck)")
            checkSerialAuthStausForCoupon()
        }
        self.connectivity.startMonitoring { [weak self] connection, reachable in
            guard let self = self else { return }
            PrintUtility.printLog(tag: "SB_AUTH", text:" \(connection) Is reachable: \(reachable)")
            if UserDefaultsProperty<Bool>(isNetworkAvailable).value == nil && reachable == .yes {
                DispatchQueue.main.async {
                    self.noInternetLabel.isHidden = true
                    self.hideNoInternetAlert()
                    if(self.shouldCallApi){
                        if self.shouldCallIapApi == true{
                            self.checkInAppPurchaseStatus()
                        }else{
                            self.callLicenseConfirmationApi()
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
            if success {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"registerInAppPurchaseStatusCheck >>> IAP is currently active")
                self.hideLoader()
                if let serialToCheck = self.serial, !serialToCheck.isEmpty{
                    self.showAlertAndRedirectToVC("kSerialActivationErrorMessageForSubscription".localiz())
                }else if let couponToCheck = self.couponCode, !couponToCheck.isEmpty{
                    self.showAlertAndRedirectToVC("KSubscriptionErrorMessage".localiz())
                }
            } else {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"registerInAppPurchaseStatusCheck >>> IAP is not active")
                self.callLicenseConfirmationApi()
            }
        }
    }

    private func checkSerialAuthStausForCoupon(){
        PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag + " " + TagUtility.sharedInstance.sbAuthTag, text: "IAPDUMMY.checkSerialAuthStausForCoupon >>> ")
        if UserDefaults.standard.bool(forKey: kIsFromUniverslaLink) {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text: "IAPDUMMY.checkSerialAuthStausForCoupon >>> kIsFromUniverslaLink: TRUE >>> Checking Serial Auth Status...")
            if let serial = UserDefaults.standard.string(forKey: kSerialCodeKey), !serial.isEmpty {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag + " " + TagUtility.sharedInstance.sbAuthTag, text: "IAPDUMMY.checkSerialAuthStausForCoupon >>> Serial auth is currently active with serial code: \(serial)");
                self.showAlertAndRedirectToVC("KFreeTrialErrorMessage".localiz())
            }else{
                PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag + " " + TagUtility.sharedInstance.sbAuthTag, text: "IAPDUMMY.checkSerialAuthStausForCoupon >>> kIsFromUniverslaLink >>> TRUE>>>  Checking Free Trial Auth Status...")
                checkFreeTrialStatus()
            }
        }else{
            PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag + " " + TagUtility.sharedInstance.sbAuthTag, text: "IAPDUMMY.checkSerialAuthStausForCoupon >>> kIsFromUniverslaLink: FALSE >>> callLicenseConfirmationApi for daily check")
            self.callLicenseConfirmationApi()
        }
    }

    private func checkCouponStatusForSerial() {
        if UserDefaults.standard.bool(forKey: kIsFromUniverslaLink){
            PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text: "IAPDUMMY.checkCouponStatusForSerial >>> kIsFromUniverslaLink: TRUE >>> Checking Coupon Auth Status...")
            if let couponCode = UserDefaults.standard.string(forKey: kCouponCode), !couponCode.isEmpty {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag + " " + TagUtility.sharedInstance.sbAuthTag, text: "IAPDUMMY.checkCouponStatusForSerial >>> Coupon auth is currently active with coupon code: \(couponCode)");
                self.showAlertAndRedirectToVC("kSerialActivationErrorMessageExceptSubscription".localiz())
            }else{
                PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag + " " + TagUtility.sharedInstance.sbAuthTag, text: "IAPDUMMY.checkCouponStatusForSerial >>> kIsFromUniverslaLink >>> TRUE>>>  Checking Free Trial Auth Status...")
                checkFreeTrialStatus()
            }
        }else {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag + " " + TagUtility.sharedInstance.sbAuthTag, text: "IAPDUMMY.checkCouponStatusForSerial >>> kIsFromUniverslaLink >>> FALSE>>> callLicenseConfirmationApi for daily check ")
            self.callLicenseConfirmationApi()
        }
    }

    private func checkFreeTrialStatus(){
        if Reachability.isConnectedToNetwork() == true{
            self.showLoader()
            self.shouldCheckFreeTrialStatus = false
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi => Has internet => Calling license conformation API")
            NetworkManager.shareInstance.callLicenseConfirmationForFreeTrial { [weak self] data  in
                guard let data = data, let self = self else {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi => Data => nill => API FAILED")
                    self?.hideLoader()
                    self?.showUnknownErrorDialog()
                    return
                }
                do {
                    let result = try JSONDecoder().decode(LicenseConfirmationModel.self, from: data)
                    self.hideLoader()
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi => result_code => \(result.result_code)")
                    if let result_code = result.result_code {
                        if result_code == response_ok {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi >>> Free trial is currently active")
                            if let serialToCheck = self.serial, !serialToCheck.isEmpty{
                                self.showAlertAndRedirectToVC("kSerialActivationErrorMessageExceptSubscription".localiz())
                            }else if let couponToCheck = self.couponCode, !couponToCheck.isEmpty{
                                self.showAlertAndRedirectToVC("KFreeTrialErrorMessage".localiz())
                            }
                        }else {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi >>> Free trial is not active")
                            self.checkInAppPurchaseStatus()
                        }
                    }else{
                        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi >>> result_code is nil >>> Free trial is not active")
                        UserDefaults.standard.set(false, forKey: kFreeTrialStatus)
                        self.checkInAppPurchaseStatus()
                    }
                } catch let err {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi => Error => \(err.localizedDescription)")
                    self.hideLoader()
                    UserDefaults.standard.set(false, forKey: kFreeTrialStatus)
                    self.checkInAppPurchaseStatus()
                }
            }
        }else{
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi => No internet ")
            self.hideLoader()
            self.showNoInternetAlert()
            self.shouldCheckFreeTrialStatus = true
        }
    }

    private func checkInAppPurchaseStatus() {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"checkInAppPurchaseStatus >>> ")
        if Reachability.isConnectedToNetwork() == true{
            self.showLoader()
            self.noInternetLabel.isHidden = true
            shouldCallApi = false
            shouldCallIapApi = false
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"checkInAppPurchaseStatus >>> HAS INTERNET >>> checking iap status")
            IAPManager.shared.receiptValidationForCouponCode()
        }else{
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"checkInAppPurchaseStatus >>> NO INTERNET")
            self.hideLoader()
            shouldCallApi = true
            shouldCallIapApi = true
            showNoInternetAlert()
        }
    }

    private func callLicenseConfirmationApi(){
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi >>>")
        IAPManager.shared.stopObserving()
        shouldCallIapApi = false
        if Reachability.isConnectedToNetwork() == true{
            self.showLoader()
            shouldCallApi = false
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag + " " + TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi >>> HAS INTERNET >>> Calling license confirmation API")
            NetworkManager.shareInstance.getLicenseConfirmation(coupon: self.couponCode, serial: self.serial) { [weak self] data  in
                guard let data = data, let self = self else {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text:"Unknown Error")
                    self?.hideLoader()
                    self?.showUnknownErrorDialog()
                    return
                }
                do {
                    let result = try JSONDecoder().decode(LicenseConfirmationModel.self, from: data)
                    UserDefaults.standard.set(Date(), forKey: kLicenseConfirmationCalledTime)
                    self.hideLoader()
                    let alertService = CustomAlertViewModel()
                    if let result_code = result.result_code {
                        PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi>>> result_code: \(result_code)")
                        if result_code == response_ok {
                            if let expiryDate = result.license_exp {
                                PrintUtility.printLog(tag: self.TAG, text: "CouponExpiryDate: \(expiryDate)")
                                let date = expiryDate.getISO_8601FormattedDateString(from: expiryDate)
                                PrintUtility.printLog(tag: self.TAG, text: "Date coupon: \(date)")
                                if let date = date {
                                    UserDefaults.standard.set(date, forKey: kCouponExpiryDate)
                                    PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Removing scheduled Notification from callLicenseConfirmationApi()")
                                    LocalNotificationManager.sharedInstance.removeScheduledNotification { _ in }
                                    LocalNotificationManager.sharedInstance.getLocalNotificationURLData { _ in }
                                }
                            }
                            if UserDefaults.standard.bool(forKey: kIsFromUniverslaLink) {
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi>>> kIsFromUniverslaLink: TRUE")
                                UserDefaults.standard.set(false, forKey: kIsFromUniverslaLink)
                                if let coupon = self.couponCode, !coupon.isEmpty{
                                    PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi>>> activating coupon auth...")
                                    UserDefaults.standard.set(coupon, forKey: kCouponCode)
                                    KeychainWrapper.standard.set(true, forKey: kIsCouponAlreadyUsedOnce)
                                    UserDefaults.standard.removeObject(forKey: kSerialCodeKey) //Ensure single auth
                                    PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Coupon saved: \(coupon)")
                                    DispatchQueue.main.async {
                                        let alert = alertService.alertDialogSoftbankWithError(message: "kCouponActivatedMesage".localiz(), errorMessage: self.statusCodeText) {
                                            GlobalMethod.appdelegate().gotoNextVcForCoupon()
                                        }
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }else if let serial = self.serial, !serial.isEmpty{
                                    PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi>>> activating serial auth...")
                                    UserDefaults.standard.set(serial, forKey: kSerialCodeKey)
                                    UserDefaults.standard.removeObject(forKey: kCouponCode) //Ensure single auth
                                    PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text: "Serial saved: \(serial)")
                                    DispatchQueue.main.async {
                                        let alert = alertService.alertDialogSoftbankWithError(message: "kSerialActivationSuccessMessage".localiz(), errorMessage: self.statusCodeText) {
                                            GlobalMethod.appdelegate().gotoNextVcForCoupon()
                                        }
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            }else{
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text:"callLicenseConfirmationApi>>> kIsFromUniverslaLink: FALSE")
                                GlobalMethod.appdelegate().gotoNextVcForCoupon()
                            }
                        } else if result_code == INFO_EXPIRED_LICENSE{
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "INFO_EXPIRED_LICENSE")
                            IAPManager.shared.startObserving()
                            if let coupon = UserDefaults.standard.string(forKey: kCouponCode), !coupon.isEmpty{
                                UserDefaults.standard.removeObject(forKey: kCouponCode)
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "Coupon removed: \(coupon)")
                                DispatchQueue.main.async {
                                    let alert = alertService.alertDialogSoftbank(message: "KInfoExpiredLiscnseErrorMessage".localiz()) {
                                        GlobalMethod.appdelegate().gotoNextVcForAuth()
                                    }
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }else if let serial = UserDefaults.standard.string(forKey: kSerialCodeKey), !serial.isEmpty{
                                UserDefaults.standard.removeObject(forKey: kSerialCodeKey)
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "Serial removed: \(serial)")
                                DispatchQueue.main.async {
                                    let alert = alertService.alertDialogSoftbank(message: "KInfoExpiredLiscnseErrorMessage".localiz()) {
                                        GlobalMethod.appdelegate().gotoNextVcForAuth()
                                    }
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }
                        } else if result_code == INFO_INVALID_LICENSE {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "INFO_INVALID_LICENSE")
                            if let couponToCheck = self.couponCode, !couponToCheck.isEmpty{
                                DispatchQueue.main.async {
                                    let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz(), errorMessage: "KErrorCode2Message".localiz()) {
                                        self.callLicenseConfirmationApi()
                                    }
                                    self.present(alert, animated: true, completion: nil)
                                }
                            }else if let serialToCheck = self.serial, !serialToCheck.isEmpty{
                                UserDefaults.standard.removeObject(forKey: kSerialCodeKey)
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "Serial removed: \(serialToCheck)")
                                GlobalMethod.appdelegate().gotoNextVcForAuth()
                            }
                        } else if result_code == WARN_INPUT_PARAM {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "WARN_INPUT_PARAM")
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz(), errorMessage: "KErrorCode1Message".localiz()) {
                                    self.callLicenseConfirmationApi()
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else if result_code == WARN_FAILED_CALL {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "WARN_FAILED_CALL")
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz(), errorMessage: "KErrorCode4Message".localiz()) {
                                    self.callLicenseConfirmationApi()
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        } else if result_code == ERR_UNKNOWN {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "ERR_UNKNOWN")
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz(), errorMessage: "KErrorCode5Message".localiz()) {
                                    self.callLicenseConfirmationApi()
                                }
                                self.present(alert, animated: true, completion: nil)
                            }
                        }else {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "Other cases")
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogSoftbankWithError(message: "KErrorMessage".localiz(), errorMessage: "KErrorCode5Message".localiz()) {
                                    self.callLicenseConfirmationApi()
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
        PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "showAlertAndRedirectToVC")
        DispatchQueue.main.async {
            let alertService = CustomAlertViewModel()
            let alert = alertService.alertDialogSoftbank(message: msg) {
                var savedCoupon = ""
                if let coupon =  UserDefaults.standard.string(forKey: kCouponCode) {
                    savedCoupon = coupon
                }
                var serialCode = ""
                if let serial = UserDefaults.standard.string(forKey: kSerialCodeKey){
                    serialCode = serial
                }
                if !serialCode.isEmpty || !savedCoupon.isEmpty{
                    GlobalMethod.appdelegate().gotoNextVcForCoupon()
                }else if UserDefaults.standard.bool(forKey: kFreeTrialStatus) == true || KeychainWrapper.standard.bool(forKey: kInAppPurchaseStatus) == true{
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

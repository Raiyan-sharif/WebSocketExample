//
//  AppDelegate+Extension.swift
//  PockeTalk
//

import UIKit
import Kronos
import SwiftKeychainWrapper

extension AppDelegate{
    func navigateToViewController(_ type: ViewControllerType, couponCode: String = "", showNotification: Bool = false) {
        var viewController = UIViewController()

        DispatchQueue.main.async {
            self.window?.rootViewController = nil
            self.window = UIWindow(frame: UIScreen.main.bounds)

            switch type {
            case .home:
                if let homeVC = UIStoryboard.init(name: KStoryboardMain, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeViewController.self)) as? HomeViewController {
                    viewController = homeVC
                }
            case .termAndCondition:
                if let termAndConditionVC = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: AppFirstLaunchViewController.self)) as? AppFirstLaunchViewController {
                    viewController = termAndConditionVC
                }
            case .purchasePlan:
                IAPManager.shared.startObserving()
                if let purchasePlanVC = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PurchasePlanViewController.self)) as? PurchasePlanViewController {
                    viewController = purchasePlanVC
                }
            case .statusCheck:
                if let statusCheckVC = UIStoryboard(name: KStoryboardMain, bundle: nil).instantiateViewController(withIdentifier: String(describing: IAPStatusCheckDummyLoadingViewController.self)) as? IAPStatusCheckDummyLoadingViewController {
                    statusCheckVC.couponCode = couponCode
                    viewController = statusCheckVC
                }
            case .permission:
                if let permisionVC = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PermissionViewController.self)) as? PermissionViewController {
                    viewController = permisionVC
                }
            case .walkthrough:
                if let walkthroughVc = UIStoryboard(name: KBoarding, bundle: nil).instantiateViewController(withIdentifier: String(describing: WalkThroughViewController.self)) as? WalkThroughViewController{
                    viewController = walkthroughVc
                }
            case .welcome:
                if let welcomeVC = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: WelcomesViewController.self)) as? WelcomesViewController {
                    viewController = welcomeVC
                }
            }

            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            self.setWindow()

            if showNotification {
                CustomLocalNotification.sharedInstance.addView()
            }
        }
    }
    
    func gotoNextVc(_ purchaseStatus: Bool){
        var savedCoupon = ""
        if let coupon =  UserDefaults.standard.string(forKey: kCouponCode) {
            savedCoupon = coupon
        }
        if let _ = UserDefaultsProperty<Bool>(kUserDefaultIsTutorialDisplayed).value{
            GlobalMethod.appdelegate().navigateToViewController(.home)
        }else if let _ = UserDefaultsProperty<Bool>(kPermissionCompleted).value{
            GlobalMethod.appdelegate().navigateToViewController(.welcome)
        }else if UserDefaultsUtility.getBoolValue(forKey: kUserPassedSubscription) == true{
            GlobalMethod.appdelegate().navigateToViewController(.permission)
        }else if UserDefaultsUtility.getBoolValue(forKey: kInitialFlowCompletedForCoupon) == true && savedCoupon.isEmpty && purchaseStatus == false{
            GlobalMethod.appdelegate().navigateToViewController(.purchasePlan)
        }else if UserDefaultsUtility.getBoolValue(forKey: kUserPassedTc) == true{
            GlobalMethod.appdelegate().navigateToViewController(.walkthrough)
        }else{
            GlobalMethod.appdelegate().navigateToViewController(.termAndCondition)
        }
    }
    
    func gotoNextVcForCoupon(){
        if let _ = UserDefaultsProperty<Bool>(kUserDefaultIsTutorialDisplayed).value{
            GlobalMethod.appdelegate().navigateToViewController(.home)
        }else if let _ = UserDefaultsProperty<Bool>(kPermissionCompleted).value{
            GlobalMethod.appdelegate().navigateToViewController(.welcome)
        }else if UserDefaultsUtility.getBoolValue(forKey: kInitialFlowCompletedForCoupon) == true{
            GlobalMethod.appdelegate().navigateToViewController(.permission)
        }else if UserDefaultsUtility.getBoolValue(forKey: kUserPassedTc) == true{
            GlobalMethod.appdelegate().navigateToViewController(.walkthrough)
        }else{
            GlobalMethod.appdelegate().navigateToViewController(.termAndCondition)
        }
    }
    
    func gotoNextVcForAuth(){
        if UserDefaultsUtility.getBoolValue(forKey: kInitialFlowCompletedForCoupon) == true {
            GlobalMethod.appdelegate().navigateToViewController(.purchasePlan)
        }else if UserDefaultsUtility.getBoolValue(forKey: kUserPassedTc) == true{
            GlobalMethod.appdelegate().navigateToViewController(.walkthrough)
        }else{
            GlobalMethod.appdelegate().navigateToViewController(.termAndCondition)
        }
    }

    private func setWindow() {
        ActivityIndicator.sharedInstance.window = self.window ?? UIWindow()
        CustomLocalNotification.sharedInstance.window = self.window ?? UIWindow()
    }

    //MARK: -  Set device language as default language
    func setInitialLanguage () {
        ///Getting the actual device language code. Ex: zh-Hans-BD, es-BD
        let deviceLanguageCode = NSLocale.preferredLanguages[0]

        ///Remove "-" and country code. Ex: es-BD to es
        let deviceLanguageCodeWithoutPunctuations = NSLocale.preferredLanguages[0].contains("-") ? NSLocale.preferredLanguages[0].components(separatedBy: "-")[0] : NSLocale.preferredLanguages[0]

        //var languageCode = Languages(rawValue: deviceLanguageCodeWithoutPunctuations) ?? .en
        
        if let langCode = Languages(rawValue: (SystemLanguageCode(rawValue: deviceLanguageCodeWithoutPunctuations) ?? .en) .rawValue) {
            var languageCode = langCode

            // If device system language is japanese then first launch and reset both shows japanese otherwise english
            if deviceLanguageCode.contains(SystemLanguageCode.ja.rawValue) {
                languageCode = Languages.ja
            } else {
                languageCode = Languages.en
            }
            LanguageManager.shared.setLanguage(language: languageCode)
        }
    }

    //MARK: - AccessKey and Licence token functionalities
    class func generateAccessKey(completion : @escaping (Bool)->Void){
        NetworkManager.shareInstance.getAuthkey { data  in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(ResultModel.self, from: data)
                if result.resultCode == response_ok{
                    TokenApiStateObserver.shared.updateState(state: .success)
                    UserDefaultsProperty<String>(authentication_key).value = result.access_key
                    SocketManager.sharedInstance.updateRequestKey()

                    UserDefaultsProperty<Bool>(isNetworkAvailable).value = nil
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "AppDelegate >> generateAccessKey")
                    AppDelegate.executeLicenseTokenRefreshFunctionality(){_ in}
                    completion(true)
                }
                else {
                    PrintUtility.printLog(tag: "AppDelegate", text: "generate access key failed")
                    TokenApiStateObserver.shared.updateState(state: .failed)
                }
            }catch{
                PrintUtility.printLog(tag: "AppDelegate", text: "Didn't get auth key")
                TokenApiStateObserver.shared.updateState(state: .failed)
                completion(false)
            }
        }
    }

    class func executeLicenseTokenRefreshFunctionality(completion : @escaping (Bool)->Void) {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "executeLicenseTokenRefreshFunctionality")

        let tokenCreationTime: Int64? = UserDefaults.standard.value(forKey: tokenCreationTime) as? Int64

        if tokenCreationTime != nil {
            let tokenExpiryTime = tokenCreationTime! + 1500000 // 25 min   //(30*1000)  for 30 sec delay
            let currentTime = Date().millisecondsSince1970
            let scheduleRefreshTime = (tokenExpiryTime - currentTime)/1000
            PrintUtility.printLog(tag: "REFRESH TOKEN", text: "REFRESH TOKEN EXECUTED AFTER \(scheduleRefreshTime) SEC")
            if tokenExpiryTime > currentTime {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "executeLicenseTokenRefreshFunctionality>> tokenExpiryTime > currentTime")
                PrintUtility.printLog(tag: "REFRESH TOKEN", text: "TOKEN REFRESHED CALLED AFTER \(scheduleRefreshTime) SEC")
                
                RunAsyncFunc.shared.cancelRunningAsyncTask()
                //if RunAsyncFunc.shared.isAlreadyScheduled == false {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "executeLicenseTokenRefreshFunctionality>> tokenExpiryTime > currentTime >> false")
                RunAsyncFunc.shared.executeScheduleCall(scheduleTime: TimeInterval(scheduleRefreshTime))
                //}
                completion(true)

            } else if (currentTime > tokenExpiryTime) {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "executeLicenseTokenRefreshFunctionality>> else if")
                //expired
                PrintUtility.printLog(tag: "REFRESH TOKEN", text: "TOKEN REFRESHED RIGHT NOW")
                //RunAsyncFunc.shared.addAsyncTask()
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "e >> call token api")
                NetworkManager.shareInstance.handleLicenseToken { result in
                    if result {
                        AppDelegate.generateAccessKey{ result in
                            if result == true {
                                //SocketManager.sharedInstance.connect()
                            }
                            completion(result)
                        }
                    } else {
                        completion(false)
                    }
                }
            } else {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "executeLicenseTokenRefreshFunctionality>> else")
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "e >> call token api")
                NetworkManager.shareInstance.handleLicenseToken { result in
                    if result {
                        AppDelegate.generateAccessKey{ result in
                            if result == true {
                                //SocketManager.sharedInstance.connect()
                            }
                            completion(result)
                        }
                    } else {
                        completion(false)
                    }
                }
                //NetworkManager.shareInstance.startTokenRefreshProcedure()
            }
        } else {
            //NetworkManager.shareInstance.startTokenRefreshProcedure()
            NetworkManager.shareInstance.handleLicenseToken { result in
                if result {
                    AppDelegate.generateAccessKey{ result in
                        if result == true {
                            //SocketManager.sharedInstance.connect()
                        }
                        completion(result)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }


}

//MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    private func configureUserNotifications() {
        UNUserNotificationCenter.current().delegate = self
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "AppDelegate -> didReceive()[+]")

        if let urlString = response.notification.request.content.userInfo["URL"] {
            if let expiryDate = UserDefaults.standard.string(forKey: kCouponExpiryDate) {
                UserDefaults.standard.set("\(urlString)/?coupon_timelimit=\(expiryDate)", forKey: kNotificationURL)
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "kNotificationURL key saved. URL: \(urlString)/?coupon_timelimit=\(expiryDate)")
            }
            let id = response.notification.request.identifier
            UserDefaults.standard.set("\(id)", forKey: "NotificationID")
        }

        CustomLocalNotification.sharedInstance.removeView()
        DispatchQueue.main.async {
            guard let _ = UserDefaults.standard.string(forKey: kNotificationURL) else{
                return
            }
            if let _ =  UserDefaults.standard.string(forKey: kCouponCode) {
                GlobalMethod.appdelegate().navigateToViewController(.home, showNotification: true)

                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Coupon Exist. Navigating to HomeVC & adding local notification view")

            } else {
                CustomLocalNotification.sharedInstance.addView()
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Coupon didn't Exist. Showing local notification view on top of the existing view")
            }
        }

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
    }
}

class RunAsyncFunc {

    static let shared = RunAsyncFunc()
    //var isAlreadyScheduled = false

    var queues = DispatchQueue(label: "com.dispatch.workItem")
    //  Create a work item
    var workItems = DispatchWorkItem { }
    func executeScheduleCall(scheduleTime: TimeInterval) {
        //isAlreadyScheduled = true
        workItems = DispatchWorkItem() {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "RunAsyncFunc >> call token api")
            NetworkManager.shareInstance.handleLicenseToken { result in
                if result {
                    AppDelegate.generateAccessKey{ result in
                        //
                    }
                }
            }
        }
        queues.asyncAfter(deadline: .now() + Double(scheduleTime), execute: workItems)
    }

    func addAsyncTask() {
        queues.async(execute: workItems)
    }

    func cancelRunningAsyncTask() {
        //isAlreadyScheduled = false
        workItems.cancel()
    }

}

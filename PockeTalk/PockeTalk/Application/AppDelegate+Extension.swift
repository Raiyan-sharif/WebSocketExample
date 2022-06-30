//
//  AppDelegate+Extension.swift
//  PockeTalk
//

import UIKit
import Kronos
import SwiftKeychainWrapper

extension AppDelegate{
    func navigateToViewController(_ type: ViewControllerType, couponCode: String = "", initAppWindow: Bool = false) {
        var viewController = UIViewController()

        DispatchQueue.main.async {
            self.window?.rootViewController = nil

            ///Set app window when app launch only
            if initAppWindow {
                self.window = UIWindow(frame: UIScreen.main.bounds)
            }

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
            }

            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            //self.setActivityIndicatorWindow()
        }
    }

    private func setActivityIndicatorWindow() {
        ActivityIndicator.sharedInstance.window = self.window ?? UIWindow()
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
                    UserDefaultsProperty<String>(authentication_key).value = result.access_key
                    SocketManager.sharedInstance.updateRequestKey()

                    UserDefaultsProperty<Bool>(isNetworkAvailable).value = nil
                    AppDelegate.executeLicenseTokenRefreshFunctionality(){_ in}
                    completion(true)
                }
            }catch{
                PrintUtility.printLog(tag: "AppDelegate", text: "Didn't get auth key")
                completion(false)
            }
        }
    }

    class func executeLicenseTokenRefreshFunctionality(completion : @escaping (Bool)->Void) {
        let tokenCreationTime: Int64? = UserDefaults.standard.value(forKey: tokenCreationTime) as? Int64

        if tokenCreationTime != nil {
            let tokenExpiryTime = tokenCreationTime! + 1500000 // 25 min   //(30*1000)  for 30 sec delay
            let currentTime = Date().millisecondsSince1970
            let scheduleRefreshTime = (tokenExpiryTime - currentTime)/1000
            PrintUtility.printLog(tag: "REFRESH TOKEN", text: "REFRESH TOKEN EXECUTED AFTER \(scheduleRefreshTime) SEC")
            if tokenExpiryTime > currentTime {
                PrintUtility.printLog(tag: "REFRESH TOKEN", text: "TOKEN REFRESHED CALLED AFTER \(scheduleRefreshTime) SEC")

                if RunAsyncFunc.shared.isAlreadyScheduled == false {
                    RunAsyncFunc.shared.executeScheduleCall(scheduleTime: TimeInterval(scheduleRefreshTime))
                }
                completion(true)

            } else if (currentTime > tokenExpiryTime) {
                //expired
                PrintUtility.printLog(tag: "REFRESH TOKEN", text: "TOKEN REFRESHED RIGHT NOW")
                //RunAsyncFunc.shared.addAsyncTask()
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

        //Remove local notification view if exist
        CustomLocalNotification().removeView()

        DispatchQueue.main.async {
            guard let _ = UserDefaults.standard.string(forKey: kNotificationURL) else{
                return
            }
            if let _ =  UserDefaults.standard.string(forKey: kCouponCode) {
                GlobalMethod.appdelegate().navigateToViewController(.home)
                CustomLocalNotification().addView()
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Coupon Exist. Navigating to HomeVC & adding local notification view")

            } else {
                CustomLocalNotification().addView()
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Coupon didn't Exist. Showing local notification view on top of the existing view")
            }
        }

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
    }

    func checkAndResetLocalNotification() {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "AppDelegate -> checkAndResetLocalNotification()[+]")

        if let _ = UserDefaults.standard.string(forKey: kCouponExpiryDate) {
            LocalNotificationManager.sharedInstance.setUpLocalNotification()
        }

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "AppDelegate -> checkAndResetLocalNotification()[-]")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
    }
}

class RunAsyncFunc {

    static let shared = RunAsyncFunc()
    var isAlreadyScheduled = false

    var queues = DispatchQueue(label: "com.dispatch.workItem")
    //  Create a work item
    var workItems = DispatchWorkItem { }
    func executeScheduleCall(scheduleTime: TimeInterval) {
        //isAlreadyScheduled = true
        workItems = DispatchWorkItem() {
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
        isAlreadyScheduled = false
        workItems.cancel()
    }

}

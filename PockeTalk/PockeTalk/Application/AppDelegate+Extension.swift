//
//  AppDelegate+Extension.swift
//  PockeTalk
//

import UIKit
import Kronos

extension AppDelegate{
    func navigateToViewController(_ type: ViewControllerType, couponCode: String = "") {
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
            }

            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
            self.setActivityIndicatorWindow()
        }
    }
    
    func gotoNextVc(){
        var savedCoupon = ""
        if let coupon =  UserDefaults.standard.string(forKey: kCouponCode) {
            savedCoupon = coupon
        }
        if UserDefaultsUtility.getBoolValue(forKey: kIsAllPermissionGranted) == true{
            GlobalMethod.appdelegate().navigateToViewController(.home)
        }else if UserDefaultsUtility.getBoolValue(forKey: kUserPassedSubscription) == true{
            GlobalMethod.appdelegate().navigateToViewController(.permission)
        }else if UserDefaultsUtility.getBoolValue(forKey: kInitialFlowCompletedForCoupon) == true && savedCoupon.isEmpty{
            GlobalMethod.appdelegate().navigateToViewController(.purchasePlan)
        }else if UserDefaultsUtility.getBoolValue(forKey: kUserPassedTc) == true{
            GlobalMethod.appdelegate().navigateToViewController(.walkthrough)
        }else{
            GlobalMethod.appdelegate().navigateToViewController(.termAndCondition)
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

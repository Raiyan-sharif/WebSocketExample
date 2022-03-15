//
//  AppDelegate+Extension.swift
//  PockeTalk
//

import UIKit
import Kronos

extension AppDelegate{
    func navigateToHomeViewController() {
        DispatchQueue.main.async {
            self.window?.rootViewController = nil
            self.window = UIWindow(frame: UIScreen.main.bounds)

            if let viewController = UIStoryboard.init(name: KStoryboardMain, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeViewController.self)) as? HomeViewController {
                let navigationController = UINavigationController.init(rootViewController: viewController)

                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
                self.setActivityIndicatorWindow()
            }
        }
    }

    func goTopermissionVC(){
        DispatchQueue.main.async {
            self.window?.rootViewController = nil
            self.window = UIWindow(frame: UIScreen.main.bounds)

            if let viewController = UIStoryboard.init(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PermissionViewController.self)) as? PermissionViewController {
                let navigationController = UINavigationController.init(rootViewController: viewController)


                let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)

                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()

                self.window?.layer.add(transition, forKey: nil)
                self.setActivityIndicatorWindow()
            }
        }
    }

    func navigateToTermsAndConditionsViewController() {
        DispatchQueue.main.async {
            self.window?.rootViewController = nil
            self.window = UIWindow(frame: UIScreen.main.bounds)

            if let viewController = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: AppFirstLaunchViewController.self)) as? AppFirstLaunchViewController{
                let navigationController = UINavigationController.init(rootViewController: viewController)

                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
                self.setActivityIndicatorWindow()

            }
        }
    }

    func navigateToPaidPlanViewController() {
        DispatchQueue.main.async {
            self.window?.rootViewController = nil
            self.window = UIWindow(frame: UIScreen.main.bounds)

            if let viewController = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PurchasePlanViewController.self)) as? PurchasePlanViewController{
                let navigationController = UINavigationController.init(rootViewController: viewController)

                self.window?.rootViewController = navigationController
                self.window?.makeKeyAndVisible()
                self.setActivityIndicatorWindow()
            }
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

        var languageCode = Languages(rawValue: deviceLanguageCodeWithoutPunctuations) ?? .en

        if deviceLanguageCode.contains(Languages.zhHans.rawValue) {
            languageCode = Languages.zhHans
        } else if deviceLanguageCode.contains(Languages.zhHant.rawValue) {
            languageCode = Languages.zhHant
        } else if deviceLanguageCode == Languages.ptPT.rawValue {
            languageCode = Languages.ptPT
        }

        LanguageManager.shared.setLanguage(language: languageCode)
    }

    //MARK: - AccessKey and Licence token functionalities
    class func generateAccessKey(){
        NetworkManager.shareInstance.getAuthkey { data  in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(ResultModel.self, from: data)
                if result.resultCode == response_ok{
                    UserDefaultsProperty<String>(authentication_key).value = result.accessKey
                    SocketManager.sharedInstance.updateRequestKey()

                    UserDefaultsProperty<Bool>(isNetworkAvailable).value = nil
                    AppDelegate().executeLicenseTokenRefreshFunctionality()
                }
            }catch{
                PrintUtility.printLog(tag: "AppDelegate", text: "Didn't get auth key")
            }
        }
    }

    func executeLicenseTokenRefreshFunctionality() {
        let tokenCreationTime: Int64? = UserDefaults.standard.value(forKey: tokenCreationTime) as? Int64

        if tokenCreationTime != nil {

            let tokenExpiryTime = tokenCreationTime! + 84600000   //(30*1000)  for 30 sec delay

            Clock.sync(completion:  { date, offset in
                if let getResDate = date {
                    PrintUtility.printLog(tag: "get Response Date", text: "\(getResDate)")
                    let currentTime = getResDate.millisecondsSince1970

                    let scheduleRefreshTime = (tokenExpiryTime - currentTime)/1000

                    if tokenExpiryTime > currentTime {

                        DispatchQueue.main.asyncAfter(deadline: .now() + Double(scheduleRefreshTime)) {
                            PrintUtility.printLog(tag: "REFRESH TOKEN", text: "REFRESH TOKEN EXECUTED AFTER \(scheduleRefreshTime) SEC")
                            NetworkManager.shareInstance.handleLicenseToken { result in
                                if result {
                                    AppDelegate.generateAccessKey()
                                }
                            }
                        }
                    } else if  (currentTime > tokenExpiryTime) {
                        //expired
                        PrintUtility.printLog(tag: "REFRESH TOKEN", text: "TOKEN REFRESHED RIGHT NOW")
                        NetworkManager.shareInstance.handleLicenseToken { result in
                            if result {
                                AppDelegate.generateAccessKey()
                            }
                        }
                    } else {
                        NetworkManager.shareInstance.startTokenRefreshProcedure()
                    }
                }
            })

        } else {
            NetworkManager.shareInstance.startTokenRefreshProcedure()
        }
    }
}

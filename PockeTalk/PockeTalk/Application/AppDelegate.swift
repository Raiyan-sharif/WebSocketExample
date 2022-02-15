//
//  AppDelegate.swift
//  PockeTalk
//

import UIKit
import Kronos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let TAG = "\(AppDelegate.self)"
    var window: UIWindow?
    //var isAppRelaunch = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Database create tables
        _ = try?  ConfiguraitonFactory().getConfiguraitonFactory(oldVersion: UserDefaultsProperty<Int>(kUserDefaultDatabaseOldVersion).value, newVersion: DataBaseConstant.DATABASE_VERSION)?.execute()
        //Initial UI setup
        UIDevice.current.isBatteryMonitoringEnabled = true
        setUpInitialLaunch()
        return true
    }
    
    /// Initial launch setup
    func setUpInitialLaunch() {
        // Set initial language of the application
        // Dont change bellow code without discussing with PM/AR
        if UserDefaultsProperty<Bool>(KIsAppLaunchedPreviously).value == nil{
            UserDefaultsProperty<Bool>(KIsAppLaunchedPreviously).value = true
            setUpAppFirstLaunch(isUpdateArrow: true)
        }else{
            LanguageSelectionManager.shared.loadLanguageListData()
        }
        
        setUpWelcomeViewController ()
        
        if  UserDefaultsProperty<String>(KFontSelection).value == nil{
            UserDefaultsProperty<String>(KFontSelection).value = "Medium"
            FontUtility.setInitialFontSize()
        }
        
        NetworkManager.shareInstance.handleLicenseToken { result in
            if result {
                AppDelegate.generateAccessKey()
            }
        }
    }
    
    private func setUpWelcomeViewController() {
        self.window?.rootViewController = nil
        if UserDefaultsProperty<Bool>(kUserDefaultIsUserPurchasedThePlan).value == true {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        } else {
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "TermsAndConditionsViewController") as! TermsAndConditionsViewController
            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
    }
    
    func setUpAppFirstLaunch(isUpdateArrow: Bool){
        PrintUtility.printLog(tag: TAG, text: "App first launch called.")
        setInitialLanguage()
        LanguageSelectionManager.shared.loadLanguageListData()
        LanguageMapViewModel.sharedInstance.storeLanguageMapDataToDB()
        LanguageSelectionManager.shared.isArrowUp = true
        
        LanguageSelectionManager.shared.setLanguageAccordingToSystemLanguage()
        CameraLanguageSelectionViewModel.shared.setDefaultLanguage()
    }
    
    class func generateAccessKey(){
        // if UserDefaultsProperty<String>(authentication_key).value == nil{
        NetworkManager.shareInstance.getAuthkey { data  in
            guard let data = data else { return }
            do {
                let result = try JSONDecoder().decode(ResultModel.self, from: data)
                if result.resultCode == response_ok{
                    UserDefaultsProperty<String>(authentication_key).value = result.accessKey
                    //if self.isAppRelaunch {
                    SocketManager.sharedInstance.updateRequestKey()
                    UserDefaultsProperty<Bool>(isNetworkAvailable).value = nil
                    AppDelegate().executeLicenseTokenRefreshFunctionality()
                    //self.isAppRelaunch = false
                    //}
                }
            }catch{
            }
        }
        // }
    }

    // Set device language as default language
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
    
    // Relaunch Application upon deleting all data
    func relaunchApplication() {
        //isAppRelaunch = true
        setUpInitialLaunch()
    }
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        executeLicenseTokenRefreshFunctionality()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        SocketManager.sharedInstance.connect()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketManager.sharedInstance.disconnect()
        ActivityIndicator.sharedInstance.hide()
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



//
//  AppDelegate.swift
//  PockeTalk
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let TAG = "\(AppDelegate.self)"
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Database create tables
        _ = try?  ConfiguraitonFactory().getConfiguraitonFactory(oldVersion: UserDefaultsProperty<Int>(kUserDefaultDatabaseOldVersion).value, newVersion: DataBaseConstant.DATABASE_VERSION)?.execute()
        //Initial UI setup
        setUpinitialLaucnh()
        return true
    }

    /// Initial launch setup
    func setUpinitialLaucnh() {
        // Set initial language of the application
        // Dont change bellow code without discussing with PM/AR
        if UserDefaultsProperty<Bool>(KIsAppLaunchedPreviously).value == nil{
            UserDefaultsProperty<Bool>(KIsAppLaunchedPreviously).value = true
            setUpAppFirstLaunch()
        }else{
            LanguageSelectionManager.shared.loadLanguageListData()
        }
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        let navigationController = UINavigationController.init(rootViewController: viewController)
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
        if  UserDefaultsProperty<String>(KFontSelection).value == nil{
            UserDefaultsProperty<String>(KFontSelection).value = "Medium"
            FontUtility.setInitialFontSize()
        }
        generateAccessKey()
    }

    func setUpAppFirstLaunch(){
        PrintUtility.printLog(tag: TAG, text: "App first launch called.")
        setInitialLanguage()
        LanguageSelectionManager.shared.loadLanguageListData()
        LanguageMapViewModel.sharedInstance.storeLanguageMapDataToDB()
        LanguageSelectionManager.shared.isArrowUp = true
        LanguageSelectionManager.shared.setLanguageAccordingToSystemLanguage()
        CameraLanguageSelectionViewModel.shared.setDefaultLanguage()
    }

    func generateAccessKey(){
       // if UserDefaultsProperty<String>(authentication_key).value == nil{
            NetworkManager.shareInstance.getAuthkey {  data  in
                guard let data = data else { return }
                do {
                    let result = try JSONDecoder().decode(ResultModel.self, from: data)
                    if result.resultCode == response_ok{
                        UserDefaultsProperty<String>(authentication_key).value = result.accessKey
                    }
                }catch{
                }
            }
       // }
    }

    /// Set device language as default language. If device language is different from Japanese or English, English will be set as default language.
    func setInitialLanguage () {
        var locale = NSLocale.preferredLanguages[0].contains("-") ? NSLocale.preferredLanguages[0].components(separatedBy: "-")[0] : NSLocale.preferredLanguages[0]
        if (locale != systemLanguageCodeEN) && (locale != systemLanguageCodeJP) {
            locale = systemLanguageCodeEN
        }
        LanguageManager.shared.setLanguage(language: Languages(rawValue: locale) ?? .en)
    }

    // Relaunch Application upon deleting all data
    func relaunchApplication() {
        setUpinitialLaucnh()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        SocketManager.sharedInstance.connect()
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketManager.sharedInstance.disconnect()
    }
}



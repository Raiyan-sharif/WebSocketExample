//
//  AppDelegate.swift
//  PockeTalk
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Database create tables
        _ = try? SQLiteDataStore.sharedInstance.createTables()

        //Initial UI setup
        setUpinitialLaucnh()
        return true
    }

    /// Initial launch setup
    func setUpinitialLaucnh() {
        /// Set initial language of the application
        
        setInitialLangue()
        LanguageMapViewModel.sharedInstance.storeLanguageMapDataToDB()
        LanguageSelectionManager.shared.getLanguageSelectionData()
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
    }

    /// Set device language as default language. If device language is different from Japanese or English, English will be set as default language.
    func setInitialLangue () {
        var locale = NSLocale.preferredLanguages[0].contains("-") ? NSLocale.preferredLanguages[0].components(separatedBy: "-")[0] : NSLocale.preferredLanguages[0]
        if (locale != systemLanguageCodeEN) && (locale != systemLanguageCodeJP) {
            locale = systemLanguageCodeEN
        }
        LanguageManager.shared.setLanguage(language: Languages(rawValue: locale) ?? .en)
        LanguageSelectionManager.shared.setLanguageAccordingToSystemLanguage()
    }

    // Relaunch Application upon deleting all data
    func relaunchApplication() {
        setUpinitialLaucnh()
    }
}


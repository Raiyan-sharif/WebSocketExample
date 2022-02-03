//
//  AppDelegate.swift
//  PockeTalk
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let TAG = "\(AppDelegate.self)"
    var window: UIWindow?
    private var connectivity = Connectivity()
    //var isAppRelaunch = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Database create tables
        _ = try?  ConfiguraitonFactory().getConfiguraitonFactory(oldVersion: UserDefaultsProperty<Int>(kUserDefaultDatabaseOldVersion).value, newVersion: DataBaseConstant.DATABASE_VERSION)?.execute()
        //Initial UI setup
        UIDevice.current.isBatteryMonitoringEnabled = true
        setUpInitialLaunch()
        IAPManager.shared.startObserving()
        IAPManager.shared.receiptValidationAllow = true
        IAPManager.shared.IAPResponseCheck(iapReceiptValidationFrom: .didFinishLaunchingWithOptions)
        return true
    }

    /// Initial launch setup
    func setUpInitialLaunch() {
        LanguageEngineDownloader.shared.checkTimeAndDownloadLanguageEngineFile()
        // Set initial language of the application
        // Dont change bellow code without discussing with PM/AR
        if UserDefaultsProperty<Bool>(KIsAppLaunchedPreviously).value == nil {
            UserDefaultsProperty<Bool>(KIsAppLaunchedPreviously).value = true
            setUpAppFirstLaunch(isUpdateArrow: true)
        } else {
            LanguageSelectionManager.shared.loadLanguageListData()
        }
        
        if  UserDefaultsProperty<String>(KFontSelection).value == nil {
            UserDefaultsProperty<String>(KFontSelection).value = "Medium"
            FontUtility.setInitialFontSize()
        }

        NetworkManager.shareInstance.handleLicenseToken { result in
            if result {
                AppDelegate.generateAccessKey()
            }
        }
        self.connectivity.startMonitoring { [weak self] connection, reachable in
            guard let self = self else { return }
            PrintUtility.printLog(tag: self.TAG, text:" \(connection) Is reachable: \(reachable)")
            if UserDefaultsProperty<Bool>(isNetworkAvailable).value == nil && reachable == .yes {
                LanguageEngineDownloader.shared.checkTimeAndDownloadLanguageEngineFile()
            }
        }
    }

    func setUpAppFirstLaunch(isUpdateArrow: Bool){
        PrintUtility.printLog(tag: TAG, text: "App first launch called.")
        setInitialLanguage()
        LanguageSelectionManager.shared.loadLanguageListData()
        LanguageMapViewModel.sharedInstance.storeLanguageMapDataToDB()
        LanguageSelectionManager.shared.isArrowUp = true
        LanguageSelectionManager.shared.directionisUp = false
        LanguageSelectionManager.shared.setLanguageAccordingToSystemLanguage()
        CameraLanguageSelectionViewModel.shared.setDefaultLanguage()
    }

    // Relaunch Application upon deleting all data
    func relaunchApplication() {
        //isAppRelaunch = true
        UserDefaultsUtility.setBoolValue(true, forKey: kIsClearedDataAll)
        self.navigateToTermsAndConditionsViewController()
        setUpInitialLaunch()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        executeLicenseTokenRefreshFunctionality()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        SocketManager.sharedInstance.connect()
        LanguageEngineDownloader.shared.checkTimeAndDownloadLanguageEngineFile()

        IAPManager.shared.receiptValidationAllow = true
        IAPManager.shared.IAPResponseCheck(iapReceiptValidationFrom: .applicationWillEnterForeground)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketManager.sharedInstance.disconnect()
        ActivityIndicator.sharedInstance.hide()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        IAPManager.shared.stopObserving()
    }
}



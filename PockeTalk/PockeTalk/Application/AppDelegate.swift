//
//  AppDelegate.swift
//  PockeTalk
//

import UIKit
import SwiftKeychainWrapper

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
        if UserDefaultsProperty<Bool>(KIsAppLaunchedForFirstTime).value == nil {
            UserDefaultsProperty<Bool>(KIsAppLaunchedForFirstTime).value = true
            KeychainWrapper.standard.set(false, forKey: kInAppPurchaseStatus)
        }
        KeychainWrapper.standard.set(true, forKey: receiptValidationAllow)
        IAPManager.shared.IAPResponseCheck(iapReceiptValidationFrom: .didFinishLaunchingWithOptions)
        return true
    }

    /// Initial launch setup
    func setUpInitialLaunch() {
        //LanguageEngineDownloader.shared.checkTimeAndDownloadLanguageEngineFile()
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

//        NetworkManager.shareInstance.handleLicenseToken { result in
//            if result {
//                AppDelegate.generateAccessKey()
//            }
//        }
//        self.connectivity.startMonitoring { [weak self] connection, reachable in
//            guard let self = self else { return }
//            PrintUtility.printLog(tag: self.TAG, text:" \(connection) Is reachable: \(reachable)")
//            if UserDefaultsProperty<Bool>(isNetworkAvailable).value == nil && reachable == .yes {
//                LanguageEngineDownloader.shared.checkTimeAndDownloadLanguageEngineFile()
//            }
//        }
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
        self.navigateToViewController(.termAndCondition)
        setUpInitialLaunch()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //executeLicenseTokenRefreshFunctionality()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        //SocketManager.sharedInstance.connect()
        //LanguageEngineDownloader.shared.checkTimeAndDownloadLanguageEngineFile()

        KeychainWrapper.standard.set(true, forKey: receiptValidationAllow)
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

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool
    {
        // Get URL components from the incoming user activity.
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else {
                  PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Wrong URL/component received")
                  return false
              }

        // Check for specific URL components that you need.
        guard let params = components.queryItems else {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "No params received")
                  return false
              }



        if let couponCode = params.first(where: { $0.name == couponCodeParamName } )?.value {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Coupon Code = \(couponCode)")
            GlobalMethod.appdelegate().navigateToViewController(.statusCheck, couponCode: couponCode)
            return true
        } else {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Coupon code missing missing")
            return false
        }
    }
}



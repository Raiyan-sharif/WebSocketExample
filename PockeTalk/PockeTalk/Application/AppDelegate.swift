//
//  AppDelegate.swift
//  PockeTalk
//

import UIKit
import SwiftKeychainWrapper
import FirebaseCore
import FirebaseAnalytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let TAG = "\(AppDelegate.self)"
    var window: UIWindow?
    private var connectivity = Connectivity()
    //var isAppRelaunch = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        UNUserNotificationCenter.current().delegate = self
        //Start firebase & Log info
        FirebaseApp.configure()
        GoogleAnalytics().serviceInfo.logGoogleServiceInfo()

        //Database create tables
        _ = try?  ConfiguraitonFactory().getConfiguraitonFactory(oldVersion: UserDefaultsProperty<Int>(kUserDefaultDatabaseOldVersion).value, newVersion: DataBaseConstant.DATABASE_VERSION)?.execute()
        //Initial UI setup
        UIDevice.current.isBatteryMonitoringEnabled = true
        setUpInitialLaunch()

        ///Enable exclusive touch for all the buttons across the app
        UIButton.appearance().isExclusiveTouch = true
        
        //Update licenseOver dialog showing status
        GlobalMethod.isLicenseOverDialogShowing = false

        //Detect app store region
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "didFinishLaunchingWithOptions")
        IAPManager.shared.iSAppStoreRegionJapan()

        var savedCoupon = ""
        if let coupon =  UserDefaults.standard.string(forKey: kCouponCode) {
            savedCoupon = coupon
        }
        var serialCode = ""
        if let serial = UserDefaults.standard.string(forKey: kSerialCodeKey){
            serialCode = serial
        }
        if !serialCode.isEmpty || !savedCoupon.isEmpty{
            if shouldCallLicenseConfirmationApi() == true{
                PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "application>> shouldCallLicenseConfirmationApi")
                UserDefaults.standard.set(false, forKey: kIsFromUniverslaLink)
                GlobalMethod.appdelegate().navigateToViewController(.statusCheck, couponCode: savedCoupon, serial: serialCode)
            }else{
                GlobalMethod.appdelegate().gotoNextVcForCoupon()
            }
            
            //Update coupon already uses once status
            KeychainWrapper.standard.set(true, forKey: kIsCouponAlreadyUsedOnce)
        }else{
            if UserDefaults.standard.bool(forKey: kFreeTrialStatus) == true{
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "========In Free Trial==========")
                GlobalMethod.appdelegate().gotoNextVc(true)
            }else {
                IAPManager.shared.startObserving()
                if UserDefaultsProperty<Bool>(KIsAppAlreadyLaunchedOnce).value == nil {
                    UserDefaultsProperty<Bool>(KIsAppAlreadyLaunchedOnce).value = true
                    KeychainWrapper.standard.set(false, forKey: kInAppPurchaseStatus)
                }
                KeychainWrapper.standard.set(true, forKey: receiptValidationAllow)
                IAPManager.shared.IAPResponseCheck(iapReceiptValidationFrom: .didFinishLaunchingWithOptions)
            }
        }
        return true
    }

    /// Initial launch setup
    func setUpInitialLaunch() {
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
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "relaunchApplication")
        IAPManager.shared.iSAppStoreRegionJapan()
        //isAppRelaunch = true
        IAPManager.shared.startObserving()
        UserDefaultsUtility.setBoolValue(true, forKey: KIsAppAlreadyLaunchedOnce)
        KeychainWrapper.standard.set(false, forKey: kInAppPurchaseStatus)
        UserDefaultsUtility.setBoolValue(true, forKey: kIsClearedDataAll)
        self.navigateToViewController(.termAndCondition)
        setUpInitialLaunch()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //executeLicenseTokenRefreshFunctionality()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "applicationWillEnterForeground")
        IAPManager.shared.iSAppStoreRegionJapan()
        var savedCoupon = ""
        if let coupon =  UserDefaults.standard.string(forKey: kCouponCode) {
            savedCoupon = coupon
        }
        var serialCode = ""
        if let serial = UserDefaults.standard.string(forKey: kSerialCodeKey){
            serialCode = serial
        }
        PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + " " + TagUtility.sharedInstance.serialTag, text: "applicationWillEnterForeground")
        if serialCode.isEmpty && savedCoupon.isEmpty && UserDefaults.standard.bool(forKey: kFreeTrialStatus) == false{
            PrintUtility.printLog(tag: "IAPTAG: APP FG from: ", text: "\(ScreenTracker.sharedInstance.screenPurpose)")
            if ScreenTracker.sharedInstance.screenPurpose != .PurchasePlanScreen &&
                ScreenTracker.sharedInstance.screenPurpose != .InitialFlow &&  ScreenTracker.sharedInstance.screenPurpose != .WalkThroughViewController{
                KeychainWrapper.standard.set(true, forKey: receiptValidationAllow)
                IAPManager.shared.IAPResponseCheck(iapReceiptValidationFrom: .applicationWillEnterForeground)
            }
        }
        LocalNotificationManager.sharedInstance.callNotificationFetchUrl()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        RunAsyncFunc.shared.cancelRunningAsyncTask()
        SocketManager.sharedInstance.disconnect()
        ActivityIndicator.sharedInstance.hide()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.removeObject(forKey: kNotificationURL)
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
                  PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "AppDelegate.application >>> Wrong URL/component received: \(userActivity.webpageURL)")
                  showAlertFromAppDelegates(msg: "kCouponCodeParseError".localiz())
                  return false
              }

        // Check for specific URL components that you need.
        guard let params = components.queryItems else {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + TagUtility.sharedInstance.serialTag, text: "AppDelegate.application >>> No params received")
            showAlertFromAppDelegates(msg: "kCouponCodeParseError".localiz())
                  return false
              }

        if let couponCode = params.first(where: { $0.name == couponCodeParamName } )?.value {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "Coupon Code = \(couponCode)")
            if couponCode.isEmpty{
                showAlertFromAppDelegates(msg: "kCouponCodeParseError".localiz())
                return false
            }
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag, text: "calling api")
            UserDefaults.standard.set(true, forKey: kIsFromUniverslaLink)
            IAPManager.shared.shouldBypassPurchasePlan = true
            GlobalMethod.appdelegate().navigateToViewController(.statusCheck, couponCode: couponCode, serial: "")
            return true
        }else if let serial = params.first(where: { $0.name == kSerialParamKey } )?.value {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.serialTag, text: "AppDelegate.application >>> serial = \(serial)")
            if serial.isEmpty{
                showAlertFromAppDelegates(msg: "kSerialParseError".localiz())
                return false
            }
            UserDefaults.standard.set(true, forKey: kIsFromUniverslaLink)
            IAPManager.shared.shouldBypassPurchasePlan = true
            GlobalMethod.appdelegate().navigateToViewController(.statusCheck, couponCode: "", serial: serial)
            return true
        } else {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.sbAuthTag + TagUtility.sharedInstance.serialTag, text: "AppDelegate.application >>> serial and coupon is both missing in uri!")
            showAlertFromAppDelegates(msg: "KErrorMessage".localiz())
            return false
        }
    }

    func showAlertFromAppDelegates(msg: String) {
            DispatchQueue.main.async {
                let alert = CustomAlertViewModel().alertDialogSoftbank(message: msg){}
                DispatchQueue.main.async {
                    self.getTopVisibleViewController { topViewController in
                        if let viewController = topViewController {
                            var presentVC = viewController
                            while let next = presentVC.presentedViewController {
                                presentVC = next
                            }
                            presentVC.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }

    func getTopVisibleViewController(complition: @escaping(_ topViewController: UIViewController?) -> ()) {
            DispatchQueue.main.async {
                if let window = UIApplication.shared.delegate?.window {
                    if var viewController = window?.rootViewController {
                        if(viewController is UINavigationController) {
                            viewController = (viewController as! UINavigationController).visibleViewController!
                            complition(viewController)
                        }
                    }
                }
            }
        }

    func shouldCallLicenseConfirmationApi() -> Bool{
        var lastCalledDate = UserDefaults.standard.object(forKey: kLicenseConfirmationCalledTime) as? Date
        var couponExpiryDate = UserDefaults.standard.string(forKey: kCouponExpiryDate)

        if lastCalledDate == nil || couponExpiryDate == nil {
            return true
        }else{
            if !Calendar.current.isDateInToday(lastCalledDate!) {
                return true
            }
        }
        return false
    }
}



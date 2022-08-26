//
//  CustomLocalNotificationContainer.swift
//  PockeTalk
//

import UIKit

open class CustomLocalNotification: NSObject {
    public static let sharedInstance = CustomLocalNotification()
    private var customLocalNotificationView: CustomLocalNotificationView!
    var window = UIApplication.shared.keyWindow ?? UIWindow()

    private override init() {
        super.init()
        customLocalNotificationView = CustomLocalNotificationView()
        customLocalNotificationView.notificationDelegate = self
    }

    private func addLocalNotificationViewOnWindow() {
        self.customLocalNotificationView.frame = UIScreen.main.bounds
        self.customLocalNotificationView.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        self.customLocalNotificationView.backgroundColor =  UIColor._loaderBackgroundColor()

        self.customLocalNotificationView.tag = customNotificationViewTag
        self.window.addSubview(self.customLocalNotificationView)
    }

    private func removeLocalNotificationViewFromWindow() {
        let customLocalNotificationViewTagView = window.viewWithTag(customNotificationViewTag) ?? UIView()
        if window.subviews.contains(customLocalNotificationViewTagView) {
            window.viewWithTag(customNotificationViewTag)?.removeFromSuperview()
        }

        if let notificationID = UserDefaults.standard.string(forKey: "NotificationID"), notificationID == NotificationStatus.scheduleNotification2.rawValue {
            LocalNotificationManager.sharedInstance.removeLocalNotificationSavedData()
        }
    }

    func addView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: { [weak self] in
            guard let `self` = self else {return}
            self.addLocalNotificationViewOnWindow()
            self.loadWebView()
        })
    }

    func removeView() {
        DispatchQueue.main.async {
            self.removeLocalNotificationViewFromWindow()
        }
    }

    private func loadWebView() {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "loadWebView()[+]")

        if let notificationURL = UserDefaults.standard.value(forKey: kNotificationURL) as? String {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Loading notification URL: \(notificationURL)")
            if Reachability.isConnectedToNetwork() {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "")
                customLocalNotificationView.viewWebContainer(isHidden: false)
                customLocalNotificationView.loadWebViewUsing(urlString: notificationURL)
            } else {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Loading notification URL: \(notificationURL)")
                customLocalNotificationView.viewWebContainer(isHidden: true)
            }
        }

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "loadWebView()[-]")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
    }
}

//MARK: - CustomLocalNotificationViewDelegate
extension CustomLocalNotification: CustomLocalNotificationViewDelegate {
    func dismiss() {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        ScreenTracker.sharedInstance.screenPurpose == .InitialFlow ? (PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Dismiss from AppFirstLaunch")) : (PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Dismiss from Home"))

        //Removing view from window
        removeLocalNotificationViewFromWindow()
        UserDefaults.standard.removeObject(forKey: kNotificationURL)

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
    }

    func cancel() {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        ScreenTracker.sharedInstance.screenPurpose == .InitialFlow ? (PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Cancel from AppFirstLaunch")) : (PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Cancel from Home"))

        //Removing view from window
        removeLocalNotificationViewFromWindow()
        UserDefaults.standard.removeObject(forKey: kNotificationURL)

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
    }

    func retry() {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        ScreenTracker.sharedInstance.screenPurpose == .InitialFlow ? (PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Retry from AppFirstLaunch")) : (PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Retry from Home"))

        //Reloading web view
        loadWebView()

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
    }
}


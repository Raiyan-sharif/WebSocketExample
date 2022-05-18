//
//  AppRater.swift
//  PockeTalk
//

import Foundation
import StoreKit
import SwiftKeychainWrapper

class AppRater: NSObject {
    public static let shared = AppRater()
    let TAG = "\(AppRater.self)"

    private let thresholdDayForAppRating = 3
    private let translationCountThreshold = 10
    private let translationCountKey = "kTranslationCount"
    private let appLaunchTimeKey = "kAppLaunchTime"
    private let appReviewDoneKey = "kAppReviewDone"

    private override init() {
        super.init()
    }

    public func rateApp() -> Bool {
        guard Reachability.isConnectedToNetwork() else {
            PrintUtility.printLog(tag: self.TAG, text: "No internet connection to review app")
            return false
        }
        guard !isAppReviewDone() else {
            return false
        }
        guard isTranslationCountMeetThresholdValue() else {
            return false
        }
        PrintUtility.printLog(tag: TAG, text: "Show review confirmation dialog")
        self.showReviewConfirmationDialog()
        return true
    }

    private func showReviewConfirmationDialog() {
        let alert = UIAlertController(title: nil, message: "user_satisfaction_message".localiz(), preferredStyle: .alert)
        alert.view.tintColor = UIColor.black
        let okAction = UIAlertAction(title: "yes".localiz(), style: .default) { _ in
            PrintUtility.printLog(tag: self.TAG, text: "User satisfied. Request for app review")
            SKStoreReviewController.requestReview()
        }
        alert.addAction(okAction)
        let cancelAction = UIAlertAction(title: "no".localiz(), style: .default) { _ in
            PrintUtility.printLog(tag: self.TAG, text: "User disatisfied. Open support url")
            GlobalMethod.openUrlInBrowser(url: REVIEW_SUPPORT_URL)
        }
        alert.addAction(cancelAction)
        if let topVC = UIApplication.getTopViewController() {
            topVC.present(alert, animated: true) {
                PrintUtility.printLog(tag: self.TAG, text: "Save app review done state")
                KeychainWrapper.standard.set(true, forKey: self.appReviewDoneKey)
            }
        }
    }

    public func saveAppLaunchTimeOnce() {
        guard !isAppReviewDone() else {
            return
        }
        guard KeychainWrapper.standard.double(forKey: appLaunchTimeKey) == nil else {
            PrintUtility.printLog(tag: TAG, text: "app launch time once saved.")
            return
        }
        let currentTimeInMilliSecond = Double(Date().millisecondsSince1970)
        PrintUtility.printLog(tag: self.TAG, text: "Save app launch time")
        KeychainWrapper.standard.set(currentTimeInMilliSecond, forKey: self.appLaunchTimeKey)
    }

    public func incrementTranslationCount() {
        guard !isAppReviewDone() else {
            return
        }
        hasThresholdTimePassed(completionHandler: { [weak self] hasPassed in
            guard let self = self, hasPassed else { return }

            var count = KeychainWrapper.standard.integer(forKey: self.translationCountKey) ?? 0
            count += 1
            KeychainWrapper.standard.set(count, forKey: self.translationCountKey)
            PrintUtility.printLog(tag: self.TAG, text: "Increment translation count - \(count)")
        })
    }

    private func isAppReviewDone() -> Bool {
        if (KeychainWrapper.standard.bool(forKey: appReviewDoneKey) == true) {
            PrintUtility.printLog(tag: TAG, text: "App review once done")
            return true
        }
        return false
    }

    private func hasThresholdTimePassed(completionHandler: @escaping (_ hasPassed: Bool) -> Void) {

        guard let savedTimeInMilliSecond = KeychainWrapper.standard.double(forKey: appLaunchTimeKey) else {
            PrintUtility.printLog(tag: TAG, text: "app launch time yet to save")
            return completionHandler(false)
        }
        let savedDateTime = Date(timeIntervalSince1970: savedTimeInMilliSecond/1000)
        if let thresholdDate = Calendar.current.date(byAdding: .day, value: self.thresholdDayForAppRating, to: savedDateTime) {
            let hasPassed = Date() > thresholdDate
            PrintUtility.printLog(tag: self.TAG, text: "hasThresholdTimePassed - \(hasPassed)")
            return completionHandler(hasPassed)
        }
        return completionHandler(false)
    }

    private func isTranslationCountMeetThresholdValue() -> Bool {
        let count = KeychainWrapper.standard.integer(forKey: self.translationCountKey) ?? 0
        PrintUtility.printLog(tag: TAG, text: "Translation count - \(count)")
        return count >= translationCountThreshold
    }
}

//
//  NotificationManagers.swift
//  PockeTalk
//

import Foundation
import UserNotifications
import SwiftKeychainWrapper

class LocalNotificationManager: NSObject {
    public static let sharedInstance = LocalNotificationManager()
    private let notificationCenter = UNUserNotificationCenter.current()
    private var localNotificationURLModel: LocalNotificationURLModel!
    private let thresholdTimeInMilliSecondForFileDownload : Double = 86400000 //24hrs = 24*60*60*1000

    var contentStrings = ["kSevenDayBeforeExpiration".localiz(), "kCouponAfterExpiration".localiz(), "kCouponAfterExpiration".localiz()]
    private var appName = "kPockeTalk".localiz()
    private let numberOfNotification = 3
    private let couponScheduleDay = [-7, 1, 7]

    private override init() {
        super.init()
    }

    private func requestAuthorization(completion: @escaping (Bool) -> Void) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, _ in
            guard let `self` = self else {return}

            self.notificationCenter.getNotificationSettings { [weak self] settings in
                guard let _ = self else {return}

                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "requestAuthorization()[+]")
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Local notification settings retrieve successfully")
            }
            completion(granted)
        }
    }

    private func setScheduleNotification() {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "setScheduleNotification()[+]")

        removeScheduledNotification { [weak self] removeSuccessful in
            guard let self = `self` else { return }
            if removeSuccessful {
                let appName = self.appName // Bundle.main.infoDictionary!["CFBundleName"] as! String
                if let expiryDate = UserDefaults.standard.string(forKey: kCouponExpiryDate) {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "---> Token expiration date: \(expiryDate)")
                }

                for i in 0..<self.numberOfNotification {
                    var date: Date?
                    let content = UNMutableNotificationContent()
                    content.sound = UNNotificationSound.default
                    content.title = appName
                    content.body = self.contentStrings[i]
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "---> Notification Content Body: \(self.contentStrings[i])")

                    // For testing purpose use getDummyNotificationDate() method
                    if i == 0 {
                        if let notificationDate = self.getNotificationDate(using: self.couponScheduleDay[0]) {
                            date = notificationDate
                            content.userInfo = [Knotification_Url: UserDefaults.standard.string(forKey: KSevenDaysBeforeURL) ?? ""]
                        }
                    } else if i == 1 {
                        if let notificationDate = self.getNotificationDate(using: self.couponScheduleDay[1]) {
                            date = notificationDate
                            content.userInfo = [Knotification_Url: UserDefaults.standard.string(forKey: KOneDayAfterURL) ?? ""]
                        }
                    }else if i == 2 {
                        if let notificationDate = self.getNotificationDate(using: self.couponScheduleDay[2]) {
                            UserDefaults.standard.set("\(notificationDate)", forKey: KThirdLocalNotificationDate)
                            date = notificationDate
                            content.userInfo = [Knotification_Url: UserDefaults.standard.string(forKey: KSevenDaysAfterURL) ?? ""]
                        }
                    }

                    if let date = date {
                        let dateComponent = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)

                        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
                        let request = UNNotificationRequest(identifier: "scheduleNotification\(i)", content: content, trigger: trigger)
                        self.showNotificationContentDetails(content: content, number: i)

                        self.notificationCenter.add(request) {[weak self] error in
                            guard let _ = self else {return}

                            if let error = error {
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Error while adding notification: \(error.localizedDescription)")
                            }
                        }
                    }
                }

                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "setScheduleNotification()[-]")
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
            }
        }

    }

    private func hasScheduledLocalNotification(completion: @escaping(_ scheduleExist: Bool)-> Void){
        var pendingNotificationCount = 0
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            pendingNotificationCount = requests.count

            if pendingNotificationCount > 0 {
                completion(true)
            } else {
                completion(false)
            }
        })

    }

    func checkTimeForNotificationSchedule() -> Bool{
        let savedTimeInMilliSecond = UserDefaults.standard.double(forKey: KLocalNotificationURLDownloadTime)

        //Fetch URL and set notification for the first time
        if (savedTimeInMilliSecond == 0) {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Saved time is nil")
            return false
        }

        //Fetch URL and set notification for the 24 hour time period
        let expiryTime = savedTimeInMilliSecond + self.thresholdTimeInMilliSecondForFileDownload
        let curTimeInMilliSecond = Double(Date().millisecondsSince1970)
        if (curTimeInMilliSecond >= expiryTime) {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Threshold time passed, downloading file from server")
            return true
        }
        return false
    }

    func checkAuthorizationAndScheduleLocalNotification() {
        requestAuthorization {status in
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Authorization Status : \(status), checkNotificationURLDataExistence \(self.checkNotificationURLDataExistence())")

            if status && self.checkNotificationURLDataExistence() {
                self.setScheduleNotification()
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Notification scheduled successfully")
            }
        }
    }

    func setUpLocalNotification() {
        hasScheduledLocalNotification(completion: { scheduleExist in
            if scheduleExist == true {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Already have scheduled notifications")
            } else {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Didn't have any scheduled notification. New notification scheduling.")
                self.checkAuthorizationAndScheduleLocalNotification()
            }
        })
    }

    func updateLocalNotifications() {
        hasScheduledLocalNotification { scheduleExist in
            if scheduleExist == true {
                self.appName = "kPockeTalk".localiz()
                self.contentStrings = ["kSevenDayBeforeExpiration".localiz(), "kCouponAfterExpiration".localiz(), "kCouponAfterExpiration".localiz()]

                self.checkAuthorizationAndScheduleLocalNotification()
            } else {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "There is No Scheduled Notifications to update()[+]")
            }
        }
    }

    func removeScheduledNotification(completion: @escaping(_ removeSuccessful: Bool)-> Void) {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "removeScheduledNotification()[+]")
        hasScheduledLocalNotification(completion: { scheduleExist in
            if scheduleExist {
                self.notificationCenter.removeAllPendingNotificationRequests()
            } else {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "There is No Scheduled Notifications()[+]")
            }
            completion(true)
        })
    }

    private func getNotificationDate(using day: Int) -> Date? {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "getNotificationTime()[+]")

        if let expiryDate = UserDefaults.standard.string(forKey: kCouponExpiryDate) {
            let couponExpireDate = expiryDate.getISO_8601FormattedDate(from: expiryDate)
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "---> couponExpireDate:  \(couponExpireDate)")

            if let trialShowDate = Calendar.current.date(byAdding: .day, value: day, to: couponExpireDate) {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "---> trialShowDate:  \(trialShowDate)")

                if let trialShowTime = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: trialShowDate) {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "---> trialShowTime:  \(trialShowTime)")

                    if validateDate(trialShowTime) {
                        showScheduleLogInfo(using: day, and: trialShowTime)
                        return trialShowTime
                    }
                }
            }
        }

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "getNotificationTime()[-]")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        return nil
    }

    //Testing method to perform coupon local notification 
    private func getDummyNotificationDate(using minute: Int) -> Date? {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "getNotificationTime()[+]")

        if let _ = UserDefaults.standard.string(forKey: kCouponExpiryDate) {
            //Update following property while testing
            let todayDate = "2022-06-20"
            let couponExpiryHour = 15 // Hour in 24 format
            let couponExpiryMinute = 25

            let expiryDate = todayDate.getISO_8601FormattedDate(from: todayDate)
            let couponExpireHour = Calendar.current.date(byAdding: .hour, value: couponExpiryHour, to: expiryDate)!
            let couponExpireDate = Calendar.current.date(byAdding: .minute, value: couponExpiryMinute, to: couponExpireHour)!
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "---> couponExpireDate:  \(couponExpireDate)")

            if let trialShowTime = Calendar.current.date(byAdding: .minute, value: minute, to: couponExpireDate) {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "---> trialShowTime:  \(trialShowTime)")

                if validateDate(trialShowTime) {
                    showScheduleLogInfo(using: minute, and: trialShowTime)
                    return trialShowTime
                }
            }
        }

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "getNotificationTime()[-]")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        return nil
    }

    private func validateDate(_ trialShowTime: Date) -> Bool {
        return trialShowTime > Date()
    }

    private func showNotificationContentDetails(content: UNMutableNotificationContent, number: Int) {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Notification content details")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Title -> \(content.title), Body: \(content.body), UserInfo: \(content.userInfo)")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
    }

    private func showScheduleLogInfo(using day: Int, and trialShowTime: Date) {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "trialShowTime validated successfully")

        if couponScheduleDay[0] == day {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "1st notification schedule time: \(trialShowTime)")
        } else if couponScheduleDay[1] == day {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "2nd notification schedule time: \(trialShowTime)")
        } else if couponScheduleDay[2] == day {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "3rd notification schedule time: \(trialShowTime)")
        }
    }

    func getLocalNotificationUrlPath() -> String {
        let schemeName = Bundle.main.infoDictionary![currentSelectedSceme] as! String
        if schemeName == BuildVarientScheme.PRODUCTION_WITH_PRODUCTION_URL.rawValue || schemeName == BuildVarientScheme.PRODUCTION_WITH_LIVE_URL.rawValue {
            return local_notification_production_url
        } else {
            return local_notification_stage_url
        }
    }

    func callNotificationFetchUrl() {
        if let couponExpiryDate = UserDefaults.standard.string(forKey: kCouponExpiryDate) {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Coupon ExpiryDate: \(couponExpiryDate) \n")
            if let lastCalledDate = UserDefaults.standard.object(forKey: KLocalNotificationURLDownloadTime) as? Date {

                if !Calendar.current.isDateInToday(lastCalledDate){
                    requestAuthorization { status in
                        if status {
                            self.scheduleNotificationAfterUrlUpdate()
                        }
                    }
                }
                if let thirdNotificationDate = UserDefaults.standard.string(forKey: KThirdLocalNotificationDate) {
                    let thirdNotificationShowDate = thirdNotificationDate.getISO_8601FormattedNotificationDate(from: thirdNotificationDate)
                    if thirdNotificationShowDate < Date() {
                        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Removed  all saved notification data\n")
                        removeLocalNotificationSavedData()
                    }
                }
            }

        }
    }


    func scheduleNotificationAfterUrlUpdate() {
        LocalNotificationManager.sharedInstance.getLocalNotificationURLData { success in
            if success {
                self.checkAuthorizationAndScheduleLocalNotification()
            } else {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "NO Notification set due to URL fetching issue \n")
            }
        }
    }

    func getLocalNotificationURLData(completion: @escaping (Bool) -> Void) {
        NetworkManager.shareInstance.getLocalNotificationURL { (result, error) in
            if let err = error {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Local notification fetch error: \(err)")
                completion(false)
                return
            }

            if let notificationURLData = result {
                self.localNotificationURLModel = notificationURLData
                self.saveLocalNotificationData()
                //self.logNotificationURLData()  // Used for development log purpose
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Local notification url fetch successfully")
                completion(true)
            }
        }
    }

    private func saveLocalNotificationData() {
        //Save URL data to UserDefault
        UserDefaults.standard.set(localNotificationURLModel?.sevenDaysBeforeUrl, forKey: KSevenDaysBeforeURL)
        UserDefaults.standard.set(localNotificationURLModel?.oneDayAfterUrl, forKey: KOneDayAfterURL)
        UserDefaults.standard.set(localNotificationURLModel?.sevenDaysAfterUrl, forKey: KSevenDaysAfterURL)

        //Save current time data to UserDefault
        UserDefaults.standard.set(Date(), forKey: KLocalNotificationURLDownloadTime)
    }

    private func removeLocalNotificationSavedData() {
        UserDefaults.standard.removeObject(forKey: kCouponExpiryDate)
        UserDefaults.standard.removeObject(forKey: KThirdLocalNotificationDate)
        UserDefaults.standard.removeObject(forKey: KLocalNotificationURLDownloadTime)
        UserDefaults.standard.removeObject(forKey: KSevenDaysBeforeURL)
        UserDefaults.standard.removeObject(forKey: KOneDayAfterURL)
        UserDefaults.standard.removeObject(forKey: KSevenDaysAfterURL)
    }

    private func logNotificationURLData() {
        let urlData = [
            "sevenDaysBeforeUrl": self.localNotificationURLModel?.sevenDaysBeforeUrl ?? "",
            "oneDayAfterUrl": self.localNotificationURLModel?.oneDayAfterUrl ?? "",
            "sevenDaysAfterUrl": self.localNotificationURLModel?.sevenDaysAfterUrl ?? ""
        ]

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Local notification urls: \(urlData)")
    }

    func checkNotificationURLDataExistence() -> Bool {

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\(UserDefaults.standard.string(forKey: KSevenDaysBeforeURL))")
        if let _ = UserDefaults.standard.string(forKey: KSevenDaysBeforeURL), let _ = UserDefaults.standard.string(forKey: KOneDayAfterURL), let _ = UserDefaults.standard.string(forKey: KSevenDaysAfterURL) {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "URL data exists")
            return true
        }
        return false
    }

}

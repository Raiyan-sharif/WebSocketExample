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

    let notificationUrlStrings = [kNotificationURL1, kNotificationURL2, kNotificationURL3]
    let contentStrings = ["kSevenDayBeforeExpiration".localiz(), "kCouponAfterExpiration".localiz(), "kCouponAfterExpiration".localiz()]
    private let appName = "kPockeTalk".localiz()
    private let url = "URL"
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

                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "requestAuthorization()[+]")

                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Local notification settings retrieve successfully")

                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "requestAuthorization()[-]")
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
            }
            completion(granted)
        }
    }

    private func setScheduleNotification() {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "setScheduleNotification()[+]")

        removeScheduledNotification()

        let appName = appName // Bundle.main.infoDictionary!["CFBundleName"] as! String
        if let expiryDate = UserDefaults.standard.string(forKey: kCouponExpiryDate) {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "---> Token expiration date: \(expiryDate)")
        }

        for i in 0..<numberOfNotification {
            var date: Date?
            let content = UNMutableNotificationContent()
            content.sound = UNNotificationSound.default
            content.title = appName
            content.body = contentStrings[i]
            content.userInfo = [url: notificationUrlStrings[i]]

            // For testing purpose use getDummyNotificationDate() method
            if i == 0 {
                if let notificationDate = getNotificationDate(using: couponScheduleDay[0]) {
                    date = notificationDate
                }
            } else if i == 1 {
                if let notificationDate = getNotificationDate(using: couponScheduleDay[1]) {
                    date = notificationDate
                }
            }else if i == 2 {
                if let notificationDate = getNotificationDate(using: couponScheduleDay[2]) {
                    date = notificationDate
                }
            }

            if let date = date {
                let dateComponent = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
                let request = UNNotificationRequest(identifier: "scheduleNotification\(i)", content: content, trigger: trigger)
                showNotificationContentDetails(content: content, number: i)

                notificationCenter.add(request) {[weak self] error in
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

    private func hasScheduledLocalNotification() -> Bool{
        var pendingNotificationCount = 0
        notificationCenter.getPendingNotificationRequests(completionHandler: { requests in
            pendingNotificationCount = requests.count
        })

        return pendingNotificationCount > 0 ? (true) : (false)
    }

    private func checkAuthorizationAndScheduleLocalNotification() {
        requestAuthorization { status in
            if status == true {
                self.setScheduleNotification()
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Notification scheduled successfully")
            }
        }
    }

    func setUpLocalNotification() {
        if hasScheduledLocalNotification(){
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Already have scheduled notifications")
        } else {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Didn't have any scheduled notification. New notification scheduling.")
            checkAuthorizationAndScheduleLocalNotification()
        }
    }

    func removeScheduledNotification() {
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "removeScheduledNotification()[+]")

        notificationCenter.removeAllPendingNotificationRequests()
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "All pending notification requests removed")

        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "removeScheduledNotification()[-]")
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "\n")
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
}



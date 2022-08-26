//
//  NetworkServiceModel.swift
//  PockeTalk
//

import Foundation

struct LocalNotificationURLModel: Codable {
    let sevenDaysBeforeUrl: String?
    let oneDayAfterUrl: String?
    let sevenDaysAfterUrl: String?

    enum CodingKeys: String, CodingKey {
        case sevenDaysBeforeUrl = "7 day before link"
        case oneDayAfterUrl = "1 day after link"
        case sevenDaysAfterUrl = "7 days after link"
    }
}

enum NotificationStatus: String {
    
    case scheduleNotification0
    case scheduleNotification1
    case scheduleNotification2
    
    init(type:String){
        
        switch type {
        case NotificationStatus.scheduleNotification0.rawValue:
             self = .scheduleNotification0
        case NotificationStatus.scheduleNotification1.rawValue:
             self = .scheduleNotification1
        case NotificationStatus.scheduleNotification2.rawValue:
             self = .scheduleNotification2
        default:
            self = .scheduleNotification2
        }
    }
    
    var getValue:String{
        switch self {
        case .scheduleNotification0:
            return "7 days before coupon expires"
        case .scheduleNotification1:
            return "1 day after coupon expires"
        case .scheduleNotification2:
            return "7 days after coupon expires"
        }

    }
}

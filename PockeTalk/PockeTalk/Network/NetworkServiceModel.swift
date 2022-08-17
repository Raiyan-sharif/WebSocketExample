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
    case Sevendaysbefore = "7 days before coupon expires"
    case Onedaybefore = "1 day after coupon expires"
    case Sevendaysafter = "7 days after coupon expires"
}

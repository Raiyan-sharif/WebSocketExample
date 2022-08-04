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


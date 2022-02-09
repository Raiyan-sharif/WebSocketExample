//
//  CountryListItem.swift
//  PockeTalk
//

import Foundation
// MARK: - CountryList
struct CountryList: Codable {
    let countryList: [CountryListItemElement]

    enum CodingKeys: String, CodingKey {
        case countryList = "country_list"
    }
}

// MARK: - CountryListElement
struct CountryListItemElement: Codable {
    let countryName: CountryName
    let languageList: [String]

    enum CodingKeys: String, CodingKey {
        case countryName = "country_name"
        case languageList = "language_list"
    }
}

// MARK: - CountryName
struct CountryName: Codable {
    let en, es, fr, zh, ja, zhTW: String?
    let ko, de, it, ru, ms, th, pt: String?
    
    enum CodingKeys: String, CodingKey {
        case en, es, fr, zh, ja, ko, de, it, ru, ms, th, pt
        case zhTW = "zh-TW"
    }
}

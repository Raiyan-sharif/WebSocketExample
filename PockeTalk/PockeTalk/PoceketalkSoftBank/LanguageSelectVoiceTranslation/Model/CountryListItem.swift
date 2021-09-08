//
//  CountryListItem.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 8/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
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
    let de, en, es, fr: String
    let it, ja, ko, zh: String
}

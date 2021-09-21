//
//  SettingItems.swift
//  PockeTalk
//
//  Created by BJIT LTD on 6/9/21.
//

import UIKit

enum SettingsItemType: String, CaseIterable {
    case textSize = "font_size"
    case languageChange = "Language Change"
    case softBank = "SoftBank"
    case support = "Support"
    case userManual = "User Manual"
    case promotion = "Pocketalk Promotion"
    case reset = "Reset"

    static var settingsItems: [String] {
        return SettingsItemType.allCases.map { $0.rawValue }
      }
}

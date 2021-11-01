//
//  SettingItems.swift
//  PockeTalk
//

import UIKit

enum SettingsItemType: String, CaseIterable {
    case textSize = "font_size"
    case languageChange = "Language Settings"
    case userManual = "license_info"
    case promotion = "Pocketalk Promotion"
    case support = "Support"
    case reset = "Reset"
    //    case softBank = "SoftBank"

    static var settingsItems: [String] {
        return SettingsItemType.allCases.map { $0.rawValue }
      }
}

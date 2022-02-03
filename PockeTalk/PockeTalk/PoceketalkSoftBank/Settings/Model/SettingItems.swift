//
//  SettingItems.swift
//  PockeTalk
//

import UIKit

enum SettingsItemType: String, CaseIterable {
    case textSize = "font_size"
    case languageChange = "Language Settings"
    case userManual = "manual"
    case information = "information"
    case support = "Support"
    case reset = "Reset"
    //    case softBank = "SoftBank"

    static var settingsItems: [String] {
        return SettingsItemType.allCases.map { $0.rawValue }
      }
}

enum InformationSettingsItemType: String, CaseIterable {
    case appVersion = "application_version"
    case licenseInfo = "license_info"

    static var settingItems: [String] {
        return InformationSettingsItemType.allCases.map { $0.rawValue }
    }
}

//
//  SettingItems.swift
//  PockeTalk
//
//  Created by BJIT LTD on 6/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit

enum SettingsItemType: String, CaseIterable {
    case languageChange = "Language Change"
    case softBank = "SoftBank"
    case support = "Support"
    case userManual = "User Manual"
    case promotion = "Pocketalk Promotion"
    
    static var settingsItems: [String] {
        return SettingsItemType.allCases.map { $0.rawValue }
      }
}

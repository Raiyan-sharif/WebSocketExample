//
// HomeViewModel.swift
// PockeTalk
//
// Created by Shymosree on 9/2/21.
// Copyright © 2021 BJIT Inc. All rights reserved.
//

import UIKit

class HomeViewModel: NSObject {

    //Get Language Name from language code
    func getLanguageName() -> String? {
        let deviceLan = NSLocale.preferredLanguages[0] as String
        let current = Locale.current
        return current.localizedString(forLanguageCode : deviceLan)
    }
}

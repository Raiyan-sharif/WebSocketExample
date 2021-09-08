//
// TtsAlertViewModel.swift
// PockeTalk
//
// Created by Shymosree on 9/8/21.
// Copyright © 2021 BJIT Inc. All rights reserved.
//

import UIKit

class TtsAlertViewModel: NSObject {

     func getLanguage() -> (nativaLanguage : LanguageItem?, targetLanguage : LanguageItem? ) {
        print("\(HomeViewController.self) updateLanguageNames method called")
        let languageManager = LanguageSelectionManager.shared
        let nativeLangCode = languageManager.nativeLanguage
        let targetLangCode = languageManager.targetLanguage

        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        print("\(HomeViewController.self) updateLanguageNames nativeLanguage \(String(describing: nativeLanguage)) targetLanguage \(String(describing: targetLanguage))")
        return (nativeLanguage, targetLanguage)
    }

}

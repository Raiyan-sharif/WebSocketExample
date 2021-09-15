//
// TtsAlertViewModel.swift
// PockeTalk
//

import UIKit

class TtsAlertViewModel: BaseModel {

     func getLanguage() -> (nativaLanguage : LanguageItem?, targetLanguage : LanguageItem? ) {
        print("\(HomeViewController.self) updateLanguageNames method called")
        let languageManager = LanguageSelectionManager.shared
        let nativeLangCode = languageManager.nativeLanguage
        let targetLangCode = languageManager.targetLanguage

        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        PrintUtility.printLog(tag: "Update Language Names: ", text: "\(HomeViewController.self) updateLanguageNames nativeLanguage \(String(describing: nativeLanguage)) targetLanguage \(String(describing: targetLanguage))")
        return (nativeLanguage, targetLanguage)
    }

}

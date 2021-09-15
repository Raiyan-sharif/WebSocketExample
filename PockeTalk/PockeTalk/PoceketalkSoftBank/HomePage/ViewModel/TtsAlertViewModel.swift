//
// TtsAlertViewModel.swift
// PockeTalk
//

import UIKit

class TtsAlertViewModel: BaseModel {

    var speechTexts: [String : String] = [
        "en":"Hello, how are you?",
        "ja":"こんにちは元気ですか？",
        "bn": "হ্যালো, আপনি কেমন আছেন?",
        "zh": "你好吗？",
        "ar": "مرحبا كيف حالك؟",
        "de": "Hallo, wie geht's dir?",
        "es": "¿Hola como estas?",
        "it": "Ciao, come stai?",
        "ko": "안녕하세요. 어떻게 지내세요?"
    ]
    
    //Todo: using sample chat data for now
    func getTranslationData() -> (nativeText: String?, targetText: String?){
        let languageManager = LanguageSelectionManager.shared
        let nativeLangCode = languageManager.nativeLanguage
        let targetLangCode = languageManager.targetLanguage
        var nativeText = ""
        var targetText = ""
        if UserDefaultsProperty<Bool>(kIsArrowUp).value == false{
            nativeText = speechTexts[targetLangCode] ?? "TtsToLanguage".localiz()
            targetText = speechTexts[nativeLangCode] ?? "TtsFromLanguage".localiz()
        }else{
            nativeText = speechTexts[nativeLangCode] ?? "TtsFromLanguage".localiz()
            targetText = speechTexts[targetLangCode] ?? "TtsToLanguage".localiz()
        }
        saveChatData(nativeText: nativeText, nativeLangCode: nativeLangCode, targetText: targetText, targetLangCode: targetLangCode)
        return (nativeText, targetText)
    }
    
    func saveChatData(nativeText: String?, nativeLangCode: String?, targetText:String?, targetLangCode: String?){
        let isArrowUp = LanguageSelectionManager.shared.isArrowUp ?? true
        do {
            _ = try ChatTableDBHelper.init().insert(item: ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangCode, textNativeLanguage: nativeLangCode!, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isArrowUp ? IsTop.noTop.rawValue : IsTop.top.rawValue, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue))
        } catch _ {}
    }
    
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

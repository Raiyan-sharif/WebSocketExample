//
// TtsAlertViewModel.swift
// PockeTalk
//

import UIKit

class TtsAlertViewModel: BaseModel {
    var savedDataID : Int64?
    var chatEntity : ChatEntity?
//    var speechTexts: [String : String] = [
//        "en":"Hello, how are you?",
//        "ja":"こんにちは元気ですか？",
//        "bn": "হ্যালো, আপনি কেমন আছেন?",
//        "zh": "你好吗？",
//        "ar": "مرحبا كيف حالك؟",
//        "de": "Hallo, wie geht's dir?",
//        "es": "¿Hola como estas?",
//        "it": "Ciao, come stai?",
//        "ko": "안녕하세요. 어떻게 지내세요?"
//    ]
    
    //Todo: using sample chat data for now
    func getTranslationData(nativeCode : String, targetCode : String) -> (nativeText: String?, targetText: String?){
        let languageManager = LanguageSelectionManager.shared

        var nativeText = ""
        var targetText = ""
//        if UserDefaultsProperty<Bool>(kIsArrowUp).value == false{
//            nativeText = speechTexts[targetCode] ?? "TtsToLanguage".localiz()
//            targetText = speechTexts[nativeCode] ?? "TtsFromLanguage".localiz()
//        }else{
//            nativeText = speechTexts[nativeCode] ?? "TtsFromLanguage".localiz()
//            targetText = speechTexts[targetCode] ?? "TtsToLanguage".localiz()
//        }
//        let isArrowUp = languageManager.isArrowUp ?? true
//        let isTop = isArrowUp ? IsTop.noTop.rawValue : IsTop.top.rawValue

//        saveChatData(nativeText: nativeText, nativeLangCode: nativeCode, targetText: targetText, targetLangCode: targetCode, isTop: isTop)

        ///Save last chat id to user defaults
        UserDefaultsProperty<Int64>(kLastSavedChatID).value = savedDataID

        return (nativeText, targetText)
    }
    
    func saveChatData(nativeText: String?, nativeLangCode: String?, targetText:String?, targetLangCode: String?, isTop : Int64?){
        do {
            savedDataID = try ChatDBModel.init().insert(item: ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangCode, textNativeLanguage: nativeLangCode!, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isTop, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue))
        } catch _ {}
    }

    /// this method takes the id of last saved chat and returns respective ChatEntity
    func findLastSavedChat (id : Int64) -> ChatEntity?{
        do {
            let baseEntity = try ChatDBModel.init().find(idToFind: id)
            return baseEntity as? ChatEntity
        } catch _ { return nil}
    }
    
    func getLanguage(nativeLangCode : String, targetLangCode : String) -> (nativaLanguage : LanguageItem?, targetLanguage : LanguageItem? ) {
        print("\(TtsAlertViewModel.self) updateLanguageNames method called")
        let languageManager = LanguageSelectionManager.shared

        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        PrintUtility.printLog(tag: "Update Language Names: ", text: "\(HomeViewController.self) updateLanguageNames nativeLanguage \(String(describing: nativeLanguage)) targetLanguage \(String(describing: targetLanguage))")
        return (nativeLanguage, targetLanguage)
    }
}

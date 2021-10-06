//
//  LanguageSelectionManager.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 6/9/21.
//

import UIKit
import SwiftyXMLParser

enum LanguageName: Int{
    case topLang
    case bottomLang
}

public class LanguageSelectionManager{
    public static let shared: LanguageSelectionManager = LanguageSelectionManager()
    let TAG = "\(LanguageSelectionManager.self)"
    var languageItems = [LanguageItem]()
    var mDefaultLanguageFile = "default_languages"
    //var systemLanguageCode = "en"
    public var bottomLanguage: String {
      get {
        guard let langCode = UserDefaults.standard.string(forKey: nativeLanguageCode) else {
          fatalError("Did you set the default language for the app?")
        }
        return langCode
      }
      set {
        UserDefaults.standard.set(newValue, forKey: nativeLanguageCode)
      }
    }

    public var topLanguage: String {
      get {
        guard let langCode = UserDefaults.standard.string(forKey: translatedLanguageCode) else {
          fatalError("Did you set the default language for the app?")
        }
        return langCode
      }
      set {
        UserDefaults.standard.set(newValue, forKey: translatedLanguageCode)
      }
    }

    public var tempSourceLanguage: String? {
      get {
        return UserDefaults.standard.string(forKey: tempSrcLanguageCode)
      }
      set {
        UserDefaults.standard.set(newValue, forKey: tempSrcLanguageCode)
      }
    }

    public var isArrowUp: Bool {
      get {
        return UserDefaults.standard.bool(forKey: kIsArrowUp)
      }
      set {
        UserDefaults.standard.set(newValue, forKey: kIsArrowUp)
      }
    }

    func  getLanguageInfoByCode(langCode: String) -> LanguageItem? {
        for item in languageItems{
            if(langCode == item.code){
                return item
            }
        }
        return nil
    }

    func  getLanguageCodeByName(langName: String) -> LanguageItem? {
        for item in languageItems{
            if(langName == item.name){
                return item
            }
        }
        return nil
    }

    ///Get data from XML
    public func getLanguageSelectionData(){
        let systemLanguageCode = LanguageManager.shared.currentLanguage.rawValue
        let mLanguageFile = "\(languageConversationFileNamePrefix)\(systemLanguageCode)"
        PrintUtility.printLog(tag: TAG,text: "\(LanguageSelectionManager.self) getdata for \(mLanguageFile)")
        if let path = Bundle.main.path(forResource: mLanguageFile, ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: path)
                let xml =  try XML.parse(contents)
                
                // enumerate child Elements in the parent Element
                languageItems.removeAll()
                for item in xml["language", "item"] {
                    let attributes = item.attributes
                    languageItems.append(LanguageItem(name: attributes["name"] ?? "", code: attributes["code"] ?? "", englishName: attributes["en"] ?? "", sysLangName: attributes[systemLanguageCode] ?? ""))
                }
                PrintUtility.printLog(tag: TAG,text: "\(LanguageSelectionManager.self) final call \(languageItems.count)")
                } catch {
                    PrintUtility.printLog(tag: TAG,text: "\(LanguageSelectionManager.self) Parse Error")
                }
        }
    }

    fileprivate func insertDefaultDataToDb(_ attributes: [String : String]) {
        let nativeLangItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: attributes["native"]!)
        let targetLangItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: attributes["translate"]!)
        _ = insertIntoDb(entity: LanguageSelectionEntity(id: 0, textLanguageCode: nativeLangItem?.code, cameraOrVoice: LanguageType.voice.rawValue))
        _ = insertIntoDb(entity: LanguageSelectionEntity(id: 0, textLanguageCode: targetLangItem?.code, cameraOrVoice: LanguageType.voice.rawValue))
    }
    
    ///Get data from XML
    public func setDefaultLanguageSettings(systemLanguageCode: String){
        PrintUtility.printLog(tag: TAG, text: "setDefaultLanguageSettings for \(mDefaultLanguageFile)  systemlang \(systemLanguageCode)")
        if let path = Bundle.main.path(forResource: mDefaultLanguageFile, ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: path)
                let xml =  try XML.parse(contents)
                
                // enumerate child Elements in the parent Element
                for item in xml["language", "item"] {
                    let attributes = item.attributes
                    PrintUtility.printLog(tag: TAG,text: "\(LanguageSelectionManager.self) lang default data \(attributes.description)")
                    if systemLanguageCode == attributes["code"]{
                        PrintUtility.printLog(tag: TAG,text: "\(LanguageSelectionManager.self) lang default data \(String(describing: attributes["native"])) \(attributes["translate"])")
                        LanguageSelectionManager.shared.bottomLanguage = attributes["native"]!
                        LanguageSelectionManager.shared.topLanguage = attributes["translate"]!
                        insertDefaultDataToDb(attributes)
                        return
                    }
                }
                //NotificationCenter.default.post(name: .languageSelectionVoiceNotification, object: nil)
                PrintUtility.printLog(tag: TAG,text: "final call \(languageItems.count)")
                } catch {
                    PrintUtility.printLog(tag: TAG, text: "Parse Error")
                }
        }
    }

    func setLanguageAccordingToSystemLanguage(){
        let sysLangCode = LanguageManager.shared.currentLanguage.rawValue
        PrintUtility.printLog(tag: TAG,text: "\(LanguageManager.self) sysLangCode \(sysLangCode)")
        LanguageSelectionManager.shared.getLanguageSelectionData()
        LanguageSelectionManager.shared.setDefaultLanguageSettings(systemLanguageCode: sysLangCode)
    }

    func insertIntoDb(entity: LanguageSelectionEntity) -> Int{
        if let rowid = try? LanguageSelectionDBModel().insert(item: entity){
            PrintUtility.printLog(tag: TAG, text: "LanguageListFromDb row-id \(String(describing: rowid))")
            return Int(rowid)
        }
        return -1
    }

    func getSelectedLanguageListFromDb(cameraOrVoice: Int64) -> [LanguageItem]{
        PrintUtility.printLog(tag: TAG,text: "\(LanguageSelectionManager.self) LanguageListFromDb getSelectedLanguageListFromDb \(cameraOrVoice)")
        var langList = [LanguageItem]()
        guard let langListFromDb = try? LanguageSelectionDBModel().findAll(findFor: cameraOrVoice) as? [LanguageSelectionEntity] else {
            return langList
        }
        for item in langListFromDb {
            PrintUtility.printLog(tag: TAG,text: "LanguageListFromDb cameraOrVocie \(String(describing: item.cameraOrVoice))")
            if let code = item.textLanguageCode{
                let langItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: code)
                    PrintUtility.printLog(tag: TAG,text: "LanguageListFromDb code \(String(describing: code)) langItem = \(String(describing: langItem?.name))")
                    langList.append(langItem!)
            }
        }
        return langList
    }

    func findLanugageCodeAndSelect(_ text: String) {
        PrintUtility.printLog(tag: TAG, text: "delegate SpeechProcessingVCDelegates called text = \(text)")
        let systemLanguage = LanguageManager.shared.currentLanguage.rawValue
        let stringFromSpeech = text.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
        let codeFromLanguageMap = LanguageMapViewModel.sharedInstance.findTextFromDb(languageCode: systemLanguage, text: stringFromSpeech) as? LanguageMapEntity
        PrintUtility.printLog(tag: TAG, text: "delegate SpeechProcessingVCDelegates stringFromSpeech \(stringFromSpeech) codeFromLanguageMap = \(String(describing: codeFromLanguageMap?.textCodeTr))")
        if let langCode = codeFromLanguageMap?.textCodeTr{
            let langItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: langCode)
            UserDefaultsProperty<String>(KSelectedLanguageVoice).value = langItem?.code
        }
    }
}

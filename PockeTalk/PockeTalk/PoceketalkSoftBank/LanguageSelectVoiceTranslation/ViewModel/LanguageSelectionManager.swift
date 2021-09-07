//
//  LanguageSelectionManager.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 6/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit
import SwiftyXMLParser

public class LanguageSelectionManager{
    public static let shared: LanguageSelectionManager = LanguageSelectionManager()
    
    var languageItems = [LanguageItem]()
    var mDefaultLanguageFile = "default_languages"
    //var systemLanguageCode = "en"
    public var nativeLanguage: String {
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
    
    public var targetLanguage: String {
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
    
    
    public var isArrowUp: Bool? {
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
    
    ///Get data from XML
    public func getLanguageSelectionData(systemLanguageCode: String){
        let mLanguageFile = "\(languageConversationFileNamePrefix)\(systemLanguageCode)"
        print("\(LanguageSelectionManager.self) getdata for \(mLanguageFile)")
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
                print("\(LanguageSelectionManager.self) final call \(languageItems.count)")
                } catch {
                    print("\(LanguageSelectionManager.self) Parse Error")
                }
        }
    }
    
    ///Get data from XML
    public func setDefaultLanguageSettings(systemLanguageCode: String){
        print("\(LanguageSelectionManager.self) setDefaultLanguageSettings for \(mDefaultLanguageFile)  systemlang \(systemLanguageCode)")
        if let path = Bundle.main.path(forResource: mDefaultLanguageFile, ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: path)
                let xml =  try XML.parse(contents)
                
                // enumerate child Elements in the parent Element
                for item in xml["language", "item"] {
                    let attributes = item.attributes
                    print("\(LanguageSelectionManager.self) lang default data \(attributes.description)")
                    if systemLanguageCode == attributes["code"]{
                        print("\(LanguageSelectionManager.self) lang default data \(attributes["native"]) \(attributes["translate"])")
                        LanguageSelectionManager.shared.nativeLanguage = attributes["native"]!
                        LanguageSelectionManager.shared.targetLanguage = attributes["translate"]!
                        return
                    }
                }
                //NotificationCenter.default.post(name: .languageSelectionVoiceNotification, object: nil)
                print("final call \(languageItems.count)")
                } catch {
                    print("Parse Error")
                }
        }
    }
    
    func setLanguageAccordingToSystemLanguage(){
        let sysLangCode = LanguageManager.shared.currentLanguage.rawValue
        print("\(LanguageManager.self) sysLangCode \(sysLangCode)")
        LanguageSelectionManager.shared.getLanguageSelectionData(systemLanguageCode: sysLangCode)
        LanguageSelectionManager.shared.setDefaultLanguageSettings(systemLanguageCode: sysLangCode)
    }
}

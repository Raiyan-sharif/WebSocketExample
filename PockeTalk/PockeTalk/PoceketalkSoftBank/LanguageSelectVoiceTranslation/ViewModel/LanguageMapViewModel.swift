//
//  LanguageMapViewModel.swift
//  PockeTalk
//

import SwiftyXMLParser

public class LanguageMapViewModel{
    public static let sharedInstance: LanguageMapViewModel = LanguageMapViewModel()
    private let TAG = "\(LanguageMapViewModel.self)"
    private let fileName = "language_mapping_by_voice"

    fileprivate func parseXmlAndStoreToDb() {
        if let row = try? LanguageMapDBModel().getRowCount(){
            if row > 0{
                PrintUtility.printLog(tag: TAG,text: "LanguageMapDBModel number of rows: \(row)")
                return
            }
        }
        storeLanguageMappingDataToDB()
        if let row = try? LanguageMapDBModel().getRowCount(){
            if row > 0{
                PrintUtility.printLog(tag: TAG,text: "LanguageMapDBModel number of rows: \(row)")
            }
        }
        
    }

    func storeLanguageMappingDataToDB(){
        if let path = Bundle.main.path(forResource: fileName, ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: path)
                let xml =  try XML.parse(contents)
                for item in xml["language", "item"] {
                    let attributes = item.attributes
                    let item = LanguageMapEntity(
                        id: 0,
                        textCode: attributes["code"] ?? "",
                        textCodeTr: attributes["code_tr"] ?? "",
                        textValueOne: attributes["val1"] ?? "",
                        textValueTwo: attributes["val2"] ?? "",
                        textValueThree: attributes["val3"] ?? "",
                        textValueFour: attributes["val4"] ?? "",
                        textValueFive: attributes["val5"] ?? "",
                        textValueSix: attributes["val6"] ?? "",
                        textValueSeven: attributes["val7"] ?? "")
                    _ = insertIntoDb(entity: item)
                    PrintUtility.printLog(tag: TAG,text: "language_map sysLangCode: \(attributes["code"] ?? ""), targetCode: \(attributes["code_tr"] ?? ""), values: \(attributes["val1"] ?? "")")
                }
            } catch {
                PrintUtility.printLog(tag: TAG,text: "\(LanguageSelectionManager.self) Parse Error")
            }
        }
    }

    func parseXmlAndStoreNewlyAddedLanguageMappingToDb() {
        try? LanguageMapDBModel().deleteAll()
        storeLanguageMappingDataToDB()
        if let row = try? LanguageMapDBModel().getRowCount(){
            if row > 0{
                PrintUtility.printLog(tag: TAG,text: "LanguageMapDBModel number of rows after version \(DataBaseConstant.DATABASE_VERSION): \(row)")
            }
        }
        
    }

    public func storeLanguageMapDataToDB(){
        PrintUtility.printLog(tag: TAG,text: "getdata for \(fileName)")
        DispatchQueue.global(qos: .background).async {
            self.parseXmlAndStoreToDb()
            DispatchQueue.main.async { [self] in
                PrintUtility.printLog(tag: TAG,text: "data storing is completed for \(self.fileName)")
            }
        }

    }

    func insertIntoDb(entity: LanguageMapEntity) -> Int{
        if let rowid = try? LanguageMapDBModel().insert(item: entity){
            PrintUtility.printLog(tag: TAG, text: "LanguageMapFromDb row-id \(String(describing: rowid))")
            return Int(rowid)
        }
        return -1
    }


    /// Finds and returns selected language from Database
    /// If app language is Russian, we do not perform in database search.
    /// In-database search for russian text do not work for texts like: Французский Канада, Шотландский гаэльский and Гаитянский креольский язык
    /// Due to some reason, the cyrillic alphabets are not lowercases during database search and needs to be done in memory
    /// - Parameters:
    ///   - languageCode: ISO language code (2 characters)
    ///   - text: text retured from voice search
    /// - Returns: language map item if text matches any language name
    func findTextFromDb(languageCode: String, text: String) -> BaseEntity?{
        let srcLanguageCode = GlobalMethod.getAlternativeSystemLanguageCode(of: languageCode)
        PrintUtility.printLog(tag: TAG, text: "findTextFromDb Searching for languageCode \(String(describing: srcLanguageCode)) text \(String(describing: text))")
        var item : LanguageMapEntity?
        if srcLanguageCode == SystemLanguageCode.ru.rawValue
            || srcLanguageCode == SystemLanguageCode.ko.rawValue
            || srcLanguageCode == SystemLanguageCode.es.rawValue
            || srcLanguageCode == SystemLanguageCode.fr.rawValue
            || srcLanguageCode == SystemLanguageCode.it.rawValue
            || srcLanguageCode == AlternativeSystemLanguageCode.pt.rawValue {
            let langaugeMapArray = try? LanguageMapDBModel().findAllEntities(languageCode: srcLanguageCode)
            for langaugeMapRow in langaugeMapArray ?? [] {
                guard let langaugeMapItem = langaugeMapRow as? LanguageMapEntity else {
                    return item
                }
                if languageNameMatches(text, langaugeMapItem.textValueOne, removeSpaceInBetween:srcLanguageCode == SystemLanguageCode.ko.rawValue ? true  : false) ||
                    languageNameMatches(text, langaugeMapItem.textValueTwo, removeSpaceInBetween:srcLanguageCode == SystemLanguageCode.ko.rawValue ? true  : false) ||
                    languageNameMatches(text, langaugeMapItem.textValueThree, removeSpaceInBetween:srcLanguageCode == SystemLanguageCode.ko.rawValue ? true  : false) ||
                    languageNameMatches(text, langaugeMapItem.textValueFour, removeSpaceInBetween:srcLanguageCode == SystemLanguageCode.ko.rawValue ? true  : false) ||
                    languageNameMatches(text, langaugeMapItem.textValueFive, removeSpaceInBetween:srcLanguageCode == SystemLanguageCode.ko.rawValue ? true  : false) ||
                    languageNameMatches(text, langaugeMapItem.textValueSix, removeSpaceInBetween:srcLanguageCode == SystemLanguageCode.ko.rawValue ? true  : false) ||
                    languageNameMatches(text, langaugeMapItem.textValueSeven, removeSpaceInBetween:srcLanguageCode == SystemLanguageCode.ko.rawValue ? true  : false) {
                    item = langaugeMapItem
                    PrintUtility.printLog(tag: TAG, text: "findTextFromDb Found item.code \(String(describing: langaugeMapItem.textCode)) target \(String(describing: langaugeMapItem.textCodeTr))")
                }
            }
        } else {

            guard let languageItem = try? LanguageMapDBModel().find(languageCode: srcLanguageCode, text: text) as? LanguageMapEntity else {
                return item
            }
            item = languageItem
            PrintUtility.printLog(tag: TAG, text: "findTextFromDb Found item.code \(String(describing: item?.textCode)) target \(String(describing: item?.textCodeTr))")
        }
        return item
    }

    /// Check if provided language name matches langauge name from mapping file
    /// - Parameters:
    ///   - text: test from STT language name input
    ///   - langaugeMapValue: language name from mapping file
    ///   - removeSpaceInBetween: if true, all whitespace will be removed from both strings before comparing, needed for Korean language
    /// - Returns: true if strings match, false otherwise
    func languageNameMatches( _ text: String,_ langaugeMapValue: String?, removeSpaceInBetween: Bool = false) -> Bool{
        let langaugeNameFromMap = removeSpaceInBetween ? GlobalMethod.removeAllWhitespace(of: langaugeMapValue ?? "") : langaugeMapValue
        let langaugeNameFromStt = removeSpaceInBetween ? GlobalMethod.removeAllWhitespace(of: text ) : text
        return langaugeNameFromMap?.compare(langaugeNameFromStt, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) == .orderedSame
    }
}


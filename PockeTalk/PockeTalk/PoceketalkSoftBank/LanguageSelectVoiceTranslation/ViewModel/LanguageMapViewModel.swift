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
        
        if let row = try? LanguageMapDBModel().getRowCount(){
            if row > 0{
                PrintUtility.printLog(tag: TAG,text: "LanguageMapDBModel number of rows: \(row)")
            }
        }
        
    }
    
    func parseXmlAndStoreNewlyAddedLanguageMappingToDb() {
        var rowCount = 0
        if let row = try? LanguageMapDBModel().getRowCount(){
            if row > 0{
                PrintUtility.printLog(tag: TAG,text: "LanguageMapDBModel number of rows before version 2: \(row)")
                rowCount = row
            }
        }
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: path)
                let xml =  try XML.parse(contents)
                for item in xml["language", "item"] {
                    let attributes = item.attributes
                    let languageCode =  attributes["code"] ?? ""
                    
                    if languageCode != Languages.en.rawValue && languageCode != Languages.ja.rawValue &&  rowCount != languageMappingTotalRowCount{
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
                }
            } catch {
                PrintUtility.printLog(tag: TAG,text: "\(LanguageSelectionManager.self) Parse Error")
            }
        }
        
        if let row = try? LanguageMapDBModel().getRowCount(){
            if row > 0{
                PrintUtility.printLog(tag: TAG,text: "LanguageMapDBModel number of rows after version 2: \(row)")
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

    func findTextFromDb(languageCode: String, text: String) -> BaseEntity?{
        PrintUtility.printLog(tag: TAG, text: "Searching for languageCode \(String(describing: languageCode)) text \(String(describing: text))")
        let srcLanguageCode = GlobalMethod.getAlternativeSystemLanguageCode(of: languageCode)
        let item = try? LanguageMapDBModel().find(languageCode: srcLanguageCode, text: text) as? LanguageMapEntity
        PrintUtility.printLog(tag: TAG, text: "Found item.code \(String(describing: item?.textCode)) target \(String(describing: item?.textCodeTr))")
        return item
    }
}


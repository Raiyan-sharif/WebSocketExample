//
//  LanguageMapViewModel.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 23/9/21.
//
import SwiftyXMLParser

public class LanguageMapViewModel{
    public static let sharedInstance: LanguageMapViewModel = LanguageMapViewModel()
    let TAG = "\(LanguageMapViewModel.self)"
    var fileName = "language_mapping_by_voice"
    //var systemLanguageCode = "en"

    fileprivate func parseXmlAndStoreToDb() {
        if let row = try? LanguageMapDBModel().getRowCount(){
            if row > 0{
                PrintUtility.printLog(tag: TAG,text: "number of rows \(row)")
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
                    PrintUtility.printLog(tag: TAG,text: "language_map sysLangCode\(attributes["code"] ?? "")  targetCode\(attributes["code_tr"] ?? "") values\(attributes["val1"] ?? "")")
                }
            } catch {
                PrintUtility.printLog(tag: TAG,text: "\(LanguageSelectionManager.self) Parse Error")
            }
        }
    }

    ///Get data from XML
    public func storeLanguageMapDataToDB(){

        PrintUtility.printLog(tag: TAG,text: "getdata for \(fileName)")
        DispatchQueue.global(qos: .background).async {
            //background code
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
        let item = try? LanguageMapDBModel().find(languageCode: languageCode, text: text) as? LanguageMapEntity
        PrintUtility.printLog(tag: TAG, text: "Found item.code \(String(describing: item?.textCode)) target \(String(describing: item?.textCodeTr))")
        return item
    }
}


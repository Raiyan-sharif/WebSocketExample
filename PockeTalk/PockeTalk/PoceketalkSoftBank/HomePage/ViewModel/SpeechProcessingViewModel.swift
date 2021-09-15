//
// SpeechProcessingViewModel.swift
// PockeTalk
//

import UIKit
import SwiftyXMLParser

class SpeechProcessingViewModel: BaseModel {
    var speechProcessingLanList = [SpeechProcessingLanguages]()

    override init() {
        super.init()
        self.getData()
    }
    ///Get data from XML
    func getData () {
        if let path = Bundle.main.path(forResource: "hello_mapping_new", ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: path)
                let xml =  try XML.parse(contents)

                // enumerate child Elements in the parent Element
                for item in xml["mapping","item"] {
                    let attributes = item.attributes
                    speechProcessingLanList.append(SpeechProcessingLanguages(code: attributes["code"]!, initText: attributes["init_text"]!, exampleText : attributes["ex_text"]!, secText : attributes["sec_text"]!) )
                }
            } catch {
                PrintUtility.printLog(tag: "LanguageChage: ", text: "Parse Error")
            }
        }
    }

    func  getSpeechLanguageInfoByCode(langCode: String) -> SpeechProcessingLanguages? {
        for item in speechProcessingLanList{
            if(langCode == item.code){
                return item
            }
        }
        return nil
    }

}

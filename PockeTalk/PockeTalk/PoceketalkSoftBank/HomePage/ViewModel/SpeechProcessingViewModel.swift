//
// SpeechProcessingViewModel.swift
// PockeTalk
//
// Created by Shymosree on 9/7/21.
// Copyright © 2021 BJIT Inc. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class SpeechProcessingViewModel: NSObject {
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
                print("Parse Error")
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

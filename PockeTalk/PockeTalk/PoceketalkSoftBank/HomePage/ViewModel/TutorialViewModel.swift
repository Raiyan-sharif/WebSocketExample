//
// TutorialViewModel.swift
// PockeTalk
//
// Created by Shymosree on 9/6/21.
// Copyright © 2021 BJIT Inc. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class TutorialViewModel: NSObject {
    var tutorialLanguageList = [TutorialLanguages]()

    override init() {
        super.init()
        self.getData()
    }

    ///Get data from XML
    func getData () {
        if let path = Bundle.main.path(forResource: "tutorial_mapping", ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: path)
                let xml =  try XML.parse(contents)

                // enumerate child Elements in the parent Element
                for item in xml["mapping","item"] {
                    let attributes = item.attributes
                    tutorialLanguageList.append(TutorialLanguages(code: attributes["code"]!, lineOne: attributes["line_1"]!, lineTwo : attributes["line_2"]!) )
                }
            } catch {
                print("Parse Error")
            }
        }
    }

    func  getTutorialLanguageInfoByCode(langCode: String) -> TutorialLanguages? {
        for item in tutorialLanguageList{
            if(langCode == item.code){
                return item
            }
        }
        return nil
    }

}

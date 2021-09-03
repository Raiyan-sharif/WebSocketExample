//
//  Demo1ViewController.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 3/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class LanguageListVC: UIViewController {

    @IBOutlet weak var langListTableView: UITableView!
    var pageIndex: Int!
    let languages = [
        Language(langNativeName: "English",langTranslateName: "English",langCode: "EN"),
        Language(langNativeName: "Japanese",langTranslateName: "Japanese",langCode: "JP"),
        Language(langNativeName: "Bangla",langTranslateName: "Bengali",langCode: "BN"),
    ]
    var languageItems = [LanguageItem]()
    var mLanguageFile = "conversation_languages_"
    let langListArray:NSMutableArray = NSMutableArray()
    var systemLanguageCode = "en"
    var selectedIndexPath: IndexPath?
    struct Language {
        var langNativeName:String
        var langTranslateName:String
        var langCode:String
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //systemLanguageCode = LanguageManager.shared.currentLanguage.rawValue
        mLanguageFile = mLanguageFile.appending(systemLanguageCode)
        print("systemLanguageCode \(systemLanguageCode) mLanguageFile \(mLanguageFile)")
        getData()
        langListTableView.delegate = self
        langListTableView.dataSource = self
        let nib = UINib(nibName: "LangListCell", bundle: nil)
        langListTableView.register(nib, forCellReuseIdentifier: "LangListCell")
        self.langListTableView.backgroundColor = UIColor.clear
    }
    
    ///Get data from XML
    private func getData(){
        print("getdata method called")
        if let path = Bundle.main.path(forResource: mLanguageFile, ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: path)
                let xml =  try XML.parse(contents)
                
                // enumerate child Elements in the parent Element
                for item in xml["language", "item"] {
                    let attributes = item.attributes
                    languageItems.append(LanguageItem(name: attributes["name"] ?? "", code: attributes["code"] ?? "", englishName: attributes["en"] ?? "", sysLangName: attributes[systemLanguageCode] ?? ""))
                }
                //print("final array \(objectToJson(from: languageItems))")
                } catch {
                    print("Parse Error")
                }
        }
    
    }
    
    func objectToJson(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}


extension LanguageListVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LangListCell",for: indexPath) as! LangListCell
        
        let languageItem = languageItems[indexPath.row]
        cell.lableLangName.text = "\(languageItem.sysLangName) (\(languageItem.name))"
        if UserDefaultsProperty<String>(KSelectedLanguageVoice).value == languageItem.code{
            cell.imageLangItemSelector.isHidden = false
            cell.langListCellContainer.backgroundColor = UIColor(hex: "#008FE8")
        }else{
            cell.imageLangItemSelector.isHidden = true
            cell.langListCellContainer.backgroundColor = .black
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: false)
        let languageItem = languageItems[indexPath.row]
        UserDefaultsProperty<String>(KSelectedLanguageVoice).value = languageItem.code
        self.langListTableView.reloadData()
    }

}

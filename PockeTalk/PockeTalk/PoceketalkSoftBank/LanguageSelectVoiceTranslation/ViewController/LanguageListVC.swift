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
    var languageItems = [LanguageItem]()
    var mLanguageFile = "conversation_languages_"
    let langListArray:NSMutableArray = NSMutableArray()
    var selectedIndexPath: IndexPath?
    var isNative: Int = 0
    //let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
    override func viewDidLoad() {
        super.viewDidLoad()
        isNative = UserDefaultsProperty<Int>(kIsNative).value!
        if isNative == 1{
            UserDefaultsProperty<String>(KSelectedLanguageVoice).value = LanguageSelectionManager.shared.nativeLanguage
        }else{
            UserDefaultsProperty<String>(KSelectedLanguageVoice).value = LanguageSelectionManager.shared.targetLanguage
        }
        print("\(LanguageListVC.self) isnative \(isNative) selectedLanguage \(String(describing: UserDefaultsProperty<String>(KSelectedLanguageVoice).value))")
        
        print("\(LanguageListVC.self) LanguageSelectionManager.shared.nativeLanguage \(LanguageSelectionManager.shared.nativeLanguage) LanguageSelectionManager.shared.targetLanguage \(LanguageSelectionManager.shared.targetLanguage)")
        languageItems = LanguageSelectionManager.shared.languageItems
        langListTableView.delegate = self
        langListTableView.dataSource = self
        let nib = UINib(nibName: "LangListCell", bundle: nil)
        langListTableView.register(nib, forCellReuseIdentifier: "LangListCell")
        self.langListTableView.backgroundColor = UIColor.clear
    }
    
    ///Get data from XML
    private func getData(){
//        print("getdata method called")
//        if let path = Bundle.main.path(forResource: mLanguageFile, ofType: "xml") {
//            do {
//                let contents = try String(contentsOfFile: path)
//                let xml =  try XML.parse(contents)
//
//                // enumerate child Elements in the parent Element
//                for item in xml["language", "item"] {
//                    let attributes = item.attributes
//                    languageItems.append(LanguageItem(name: attributes["name"] ?? "", code: attributes["code"] ?? "", englishName: attributes["en"] ?? "", sysLangName: attributes[systemLanguageCode] ?? ""))
//                }
//                //print("final array \(objectToJson(from: languageItems))")
//                } catch {
//                    print("Parse Error")
//                }
//        }
    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let selectedItemPosition = getSelectedItemPosition
        print("\(LanguageListVC.self) position \(selectedItemPosition)")
        selectedIndexPath = IndexPath(row: getSelectedItemPosition(), section: 0)
        self.langListTableView.scrollToRow(at: selectedIndexPath!, at: .middle, animated: true)
    }
    
    func objectToJson(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    func getSelectedItemPosition() -> Int{
        let selectedLangCode = UserDefaultsProperty<String>(KSelectedLanguageVoice).value
        for i in 0...languageItems.count{
            let item = languageItems[i]
            if  selectedLangCode == item.code{
                return i
            }
        }
        return 0
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
        print("\(LanguageListVC.self) value \(UserDefaultsProperty<String>(KSelectedLanguageVoice).value) languageItem.code \(languageItem.code)")
        if UserDefaultsProperty<String>(KSelectedLanguageVoice).value == languageItem.code{
            cell.imageLangItemSelector.isHidden = false
            cell.langListCellContainer.backgroundColor = UIColor(hex: "#008FE8")
            print("\(LanguageListVC.self) matched lang \(UserDefaultsProperty<String>(KSelectedLanguageVoice).value) languageItem.code \(languageItem.code)")
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

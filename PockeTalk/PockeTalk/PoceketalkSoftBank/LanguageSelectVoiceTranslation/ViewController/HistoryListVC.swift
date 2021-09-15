//
//  Demo2ViewController.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 3/9/21.
//

import UIKit

class HistoryListVC: BaseViewController {
    let TAG = "\(HistoryListVC.self)"
    @IBOutlet weak var historyListTableView: UITableView!
    var pageIndex: Int!
    var languages = [LanguageItem]()
    var isNative: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        isNative = UserDefaultsProperty<Int>(kIsNative).value!
        if isNative == 1{
            UserDefaultsProperty<String>(KSelectedLanguageVoice).value = LanguageSelectionManager.shared.nativeLanguage
        }else{
            UserDefaultsProperty<String>(KSelectedLanguageVoice).value = LanguageSelectionManager.shared.targetLanguage
        }
        historyListTableView.delegate = self
        historyListTableView.dataSource = self
        let nib = UINib(nibName: "LangListCell", bundle: nil)
        historyListTableView.register(nib, forCellReuseIdentifier: "LangListCell")
        self.historyListTableView.backgroundColor = UIColor.clear
        languages = LanguageSelectionManager.shared.getSelectedLanguageListFromDb(cameraOrVoice: LanguageType.voice.rawValue)
    }

}

    extension HistoryListVC: UITableViewDataSource,UITableViewDelegate{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return languages.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LangListCell",for: indexPath) as! LangListCell
            let languageItem = languages[indexPath.row]
            cell.lableLangName.text = "\(languageItem.sysLangName) (\(languageItem.name))"
            PrintUtility.printLog(tag: TAG, text: " value \(String(describing: UserDefaultsProperty<String>(KSelectedLanguageVoice).value)) languageItem.code \(languageItem.code)")
            if UserDefaultsProperty<String>(KSelectedLanguageVoice).value == languageItem.code{
                cell.imageLangItemSelector.isHidden = false
                cell.langListCellContainer.backgroundColor = UIColor(hex: "#008FE8")
                PrintUtility.printLog(tag: TAG, text: " matched lang \(String(describing: UserDefaultsProperty<String>(KSelectedLanguageVoice).value)) languageItem.code \(languageItem.code)")
            }else{
                cell.imageLangItemSelector.isHidden = true
                cell.langListCellContainer.backgroundColor = .black
            }
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let languageItem = languages[indexPath.row]
            UserDefaultsProperty<String>(KSelectedLanguageVoice).value = languageItem.code
            self.historyListTableView.reloadData()
        }
    }

//
//  LanguageHistoryListCamera.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 10/9/21.
//

import UIKit

class LanguageHistoryListCameraVC: BaseViewController {
    let TAG = "\(LanguageHistoryListCameraVC.self)"
    @IBOutlet weak var historyListTableView: UITableView!
    var pageIndex: Int!
    var languages = [LanguageItem]()
    var listShowingForFromLanguage = true

    override func viewDidLoad() {
        super.viewDidLoad()
        listShowingForFromLanguage = UserDefaultsProperty<Bool>(KCameraLanguageFrom).value!
        if listShowingForFromLanguage{
            UserDefaultsProperty<String>(KSelectedLanguageCamera).value = CameraLanguageSelectionViewModel.shared.fromLanguage
        }else{
            UserDefaultsProperty<String>(KSelectedLanguageCamera).value = CameraLanguageSelectionViewModel.shared.targetLanguage
        }
        historyListTableView.delegate = self
        historyListTableView.dataSource = self
        let nib = UINib(nibName: "LangListCell", bundle: nil)
        historyListTableView.register(nib, forCellReuseIdentifier: "LangListCell")
        self.historyListTableView.backgroundColor = UIColor.clear
        languages = CameraLanguageSelectionViewModel.shared.getSelectedLanguageListFromDb()
        PrintUtility.printLog(tag: TAG, text: "LanguageListFromDb languagelist \(languages.count)")
    }

}

    extension LanguageHistoryListCameraVC: UITableViewDataSource,UITableViewDelegate{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return languages.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LangListCell",for: indexPath) as! LangListCell
            let languageItem = languages[indexPath.row]
            cell.lableLangName.text = "\(languageItem.sysLangName) (\(languageItem.name))"
            PrintUtility.printLog(tag: TAG, text: "value \(UserDefaultsProperty<String>(KSelectedLanguageCamera).value) languageItem.code \(languageItem.code)")
            if UserDefaultsProperty<String>(KSelectedLanguageCamera).value == languageItem.code{
                let languageManager = LanguageSelectionManager.shared
                if(languageManager.hasTtsSupport(languageCode: languageItem.code)){
                    cell.imageNoVoice.isHidden = true
                }else{
                    cell.imageNoVoice.isHidden = false
                }
                cell.imageLangItemSelector.isHidden = false
                cell.langListCellContainer.backgroundColor = UIColor(hex: "#008FE8")
                PrintUtility.printLog(tag: TAG, text: "\(LanguageListVC.self) matched lang \(UserDefaultsProperty<String>(KSelectedLanguageCamera).value) languageItem.code \(languageItem.code)")
            }else{
                cell.imageLangItemSelector.isHidden = true
                cell.imageNoVoice.isHidden = true
                cell.langListCellContainer.backgroundColor = .black
            }
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let languageItem = languages[indexPath.row]
            UserDefaultsProperty<String>(KSelectedLanguageCamera).value = languageItem.code
            PrintUtility.printLog(tag: TAG, text: "lang \(languageItem.code)")
            self.historyListTableView.reloadData()
        }
    }

//
//  HistoryListCameraVC.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 10/9/21.
//

import UIKit

class HistoryListCameraVC: BaseViewController {

    @IBOutlet weak var historyListTableView: UITableView!
    var pageIndex: Int!
    let languages = [
        Language(langNativeName: "English",langTranslateName: "English",langCode: "EN"),
        Language(langNativeName: "Japanese",langTranslateName: "Japanese",langCode: "JP"),
        Language(langNativeName: "Bangla",langTranslateName: "Bengali",langCode: "BN"),
    ]

    struct Language {
        var langNativeName:String
        var langTranslateName:String
        var langCode:String
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        historyListTableView.delegate = self
        historyListTableView.dataSource = self
        let nib = UINib(nibName: "LangListCell", bundle: nil)
        historyListTableView.register(nib, forCellReuseIdentifier: "LangListCell")
        self.historyListTableView.backgroundColor = UIColor.clear
        // Do any additional setup after loading the view.
    }

}

    extension HistoryListCameraVC: UITableViewDataSource,UITableViewDelegate{
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return languages.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LangListCell",for: indexPath) as! LangListCell
            cell.lableLangName.text = ("\(languages[indexPath.row].langNativeName)  \(languages[indexPath.row].langTranslateName)")
            cell.imageLangItemSelector.isHidden = true
            return cell
        }

        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            //tableView.deselectRow(at: indexPath, animated: false)
            let cell = historyListTableView.cellForRow(at: indexPath) as! LangListCell
            cell.langListCellContainer.backgroundColor = ._skyBlueColor()
            cell.imageLangItemSelector.isHidden = false
        }

        func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            let cell = historyListTableView.cellForRow(at: indexPath) as! LangListCell
            cell.langListCellContainer.backgroundColor = .black
            cell.imageLangItemSelector.isHidden = true
        }

    }

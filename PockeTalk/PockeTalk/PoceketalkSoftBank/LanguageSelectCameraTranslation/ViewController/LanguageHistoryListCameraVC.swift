//
//  LanguageHistoryListCamera.swift
//  PockeTalk
//

import UIKit

class LanguageHistoryListCameraVC: BaseViewController {
    @IBOutlet weak private var historyListTableView: UITableView!
    let TAG = "\(LanguageHistoryListCameraVC.self)"
    var pageIndex: Int!
    var languages = [LanguageItem]()
    var listShowingForFromLanguage = true
    var selectedIndexPath: IndexPath?
    var isSlecetedItemExist: Bool = false
    private let languageManager = LanguageSelectionManager.shared
    var index = Int()

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLanguageProperty()
        setupTableView()
    }
    
    //MARK: - Initial setup
    private func setupLanguageProperty(){
        languages = CameraLanguageSelectionViewModel.shared.getSelectedLanguageListFromDb()
        guard let selectedLanguageVoice =  UserDefaultsProperty<String>(KSelectedLanguageCamera).value else {return}
        
        for item in 0..<languages.count {
            if languages[item].code == selectedLanguageVoice {
                isSlecetedItemExist = true
            }
        }
        
        let langSelectFor = UserDefaultsProperty<Bool>(KCameraLanguageFrom).value
        if langSelectFor == false {
            for (index, _) in languages.enumerated() {
                if (languages[index].name == CameraDefaultLang) {
                    self.index = index
                    break
                }
            }
            languages.remove(at: self.index)
        }
        
    }
    
    private func setupTableView(){
        historyListTableView.delegate = self
        historyListTableView.dataSource = self
        let nib = UINib(nibName: "LangListCell", bundle: nil)
        historyListTableView.register(nib, forCellReuseIdentifier: "LangListCell")
        self.historyListTableView.backgroundColor = UIColor.clear
    }
    
    //MARK: - Utils
    private func setSelectedCellProperty(using cell: LangListCell, and languageCode: String){
        if(languageManager.hasTtsSupport(languageCode: languageCode)){
            cell.unselectedLabelTrailingConstraint.constant = kTtsNotAvailableTrailingConstant
            cell.selectedLabelTrailingConstraint.constant = kTtsNotAvailableTrailingConstant
            cell.imageNoVoice.isHidden = true
        }else{
            cell.unselectedLabelTrailingConstraint.constant = kTtsAvailableTrailingConstant
            cell.selectedLabelTrailingConstraint.constant = kTtsAvailableTrailingConstant
            cell.imageNoVoice.isHidden = false
        }
        cell.lableLangName.isHidden = false
        cell.langNameUnSelecteLabel.isHidden = true
        cell.lableLangName.holdScrolling = false
        cell.lableLangName.type = .continuous
        cell.lableLangName.trailingBuffer = kMarqueeLabelTrailingBufferForLanguageScreen
        cell.lableLangName.speed = .rate(kMarqueeLabelScrollingSpeenForLanguageScreen)
        cell.imageLangItemSelector.isHidden = false
        cell.langListCellContainer.backgroundColor = UIColor(hex: "#008FE8")
    }
    
    private func setDeselectedCellProperty(using cell: LangListCell){
        cell.unselectedLabelTrailingConstraint.constant = kUnselectedLanguageTrailingConstant
        cell.lableLangName.isHidden = true
        cell.langNameUnSelecteLabel.isHidden = false
        cell.lableLangName.holdScrolling = true
        cell.imageLangItemSelector.isHidden = true
        cell.imageNoVoice.isHidden = true
        cell.langListCellContainer.backgroundColor = .black
    }
}

//MARK: - UITableViewDataSource
extension LanguageHistoryListCameraVC: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LangListCell",for: indexPath) as! LangListCell
        let languageItem = languages[indexPath.row]
        cell.lableLangName.text = "\(languageItem.sysLangName) (\(languageItem.name))"
        cell.langNameUnSelecteLabel.text = "\(languageItem.sysLangName) (\(languageItem.name))"
        cell.langNameUnSelecteLabel.adjustsFontSizeToFitWidth = false
        cell.langNameUnSelecteLabel.lineBreakMode = .byTruncatingTail
        
        PrintUtility.printLog(tag: TAG, text: "value \(String(describing: UserDefaultsProperty<String>(KSelectedLanguageCamera).value)) languageItem.code \(languageItem.code)")
        
        if isSlecetedItemExist {
            if UserDefaultsProperty<String>(KSelectedLanguageCamera).value == languageItem.code{
                setSelectedCellProperty(using: cell, and: languageItem.code)
            }else{
                setDeselectedCellProperty(using: cell)
            }
        } else {
            if indexPath.row == 0 {
                setSelectedCellProperty(using: cell, and: languageItem.code)
            } else {
                setDeselectedCellProperty(using: cell)
            }
        }
        return cell
    }
}

//MARK: - UITableViewDelegate
extension LanguageHistoryListCameraVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let languageItem = languages[indexPath.row]
        UserDefaultsProperty<String>(KSelectedLanguageCamera).value = languageItem.code
        self.historyListTableView.reloadData()
    }
}

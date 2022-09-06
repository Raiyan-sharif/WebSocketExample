//
//  LanguageListVC.swift
//  PockeTalk
//

import UIKit
import SwiftyXMLParser

class LanguageListVC: BaseViewController {
    @IBOutlet weak var langListTableView: UITableView!
    
    let TAG = "\(LanguageListVC.self)"
    var pageIndex: Int!
    var languageItems = [LanguageItem]()
    var mLanguageFile = "conversation_languages_"
    let langListArray: NSMutableArray = NSMutableArray()
    var selectedIndexPath: IndexPath?
    var isNative: Int = 0
    var isFirstTimeLoad: Bool!
    var fromRetranslation: Bool = false
    private let languageManager = LanguageSelectionManager.shared
    var tabsHeight:CGFloat = 0
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        registerNotification()
    }

    override func viewWillAppear(_ animated: Bool) {
        if(!fromRetranslation){
            setupLanguageProperty()
        }
        languageItems = LanguageSelectionManager.shared.languageItems
        UserDefaultsProperty<String>(kTempSelectedLanguageVoice).value = UserDefaultsProperty<String>(KSelectedLanguageVoice).value
        updateTableView(false)
    }
    
    deinit {
        unregisterNotification()
    }
    
    //MARK: - Initial setup
    private func setupLanguageProperty(){
        if isFirstTimeLoad {
            isNative = UserDefaultsProperty<Int>(kIsNative).value!
            if isNative == LanguageName.bottomLang.rawValue{
                UserDefaultsProperty<String>(KSelectedLanguageVoice).value = LanguageSelectionManager.shared.bottomLanguage
            }else{
                UserDefaultsProperty<String>(KSelectedLanguageVoice).value = LanguageSelectionManager.shared.topLanguage
            }
        }
    }
    
    private func setupTableView(){
        langListTableView.delegate = self
        langListTableView.dataSource = self
        langListTableView.contentInset = view.getCustomViewEdgetInsect()
        let nib = UINib(nibName: "LangListCell", bundle: nil)
        langListTableView.register(nib, forCellReuseIdentifier: "LangListCell")
        self.langListTableView.backgroundColor = UIColor.clear
    }
    
    /*
     TableView Scroll to the point of Selected Item
     flag -> true if reload tableview data required
     */
    private func updateTableView(_ flag: Bool){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2, execute: {
            [weak self] in
            self?.selectedIndexPath = IndexPath(row: (self?.getSelectedItemPosition())!, section: 0)
            self?.langListTableView.scrollToRow(at: (self?.selectedIndexPath)!, at: .top, animated: false)
        })
        if(flag){
            self.langListTableView.reloadData()
        }
    }
    
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguageSelection(notification:)), name: .languageListNotofication, object: nil)
    }

    //MARK: - Utils
    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name:.languageListNotofication, object: nil)
    }

    @objc private func updateLanguageSelection(notification: Notification) {
        updateTableView(true)
    }
    
    private func getSelectedItemPosition() -> Int{
        let selectedLangCode = UserDefaultsProperty<String>(kTempSelectedLanguageVoice).value
        for i in 0...languageItems.count - 1{
            let item = languageItems[i]
            if  selectedLangCode == item.code{
                return i
            }
        }
        return 0
    }
    
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

//MARK: - UITableview Datasource
extension LanguageListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LangListCell",for: indexPath) as! LangListCell
        
        let languageItem = languageItems[indexPath.row]
        cell.lableLangName.text = "\(languageItem.sysLangName) (\(languageItem.name))"
        cell.langNameUnSelecteLabel.text = "\(languageItem.sysLangName) (\(languageItem.name))"
        cell.langNameUnSelecteLabel.adjustsFontSizeToFitWidth = false
        cell.langNameUnSelecteLabel.lineBreakMode = .byTruncatingTail
        
        if UserDefaultsProperty<String>(kTempSelectedLanguageVoice).value == languageItem.code{
            setSelectedCellProperty(using: cell, and: languageItem.code)
        }else{
            setDeselectedCellProperty(using: cell)
        }
        return cell
    }
}

//MARK: - UITableview Delegate
extension LanguageListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let languageItem = languageItems[indexPath.row]
        UserDefaultsProperty<String>(kTempSelectedLanguageVoice).value = languageItem.code
        self.langListTableView.reloadData()
    }
    
}

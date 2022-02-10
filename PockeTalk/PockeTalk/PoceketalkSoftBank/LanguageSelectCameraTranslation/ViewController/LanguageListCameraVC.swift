//
//  LanguageListCamera.swift
//  PockeTalk
//

import UIKit
import SwiftyXMLParser

class LanguageListCameraVC: BaseViewController {
    @IBOutlet weak private var langListTableView: UITableView!
    let TAG = "\(LanguageListCameraVC.self)"
    var isFirstTimeLoad = Bool()
    var pageIndex = Int()
    var languageItems = [LanguageItem]()
    let langListArray:NSMutableArray = NSMutableArray()
    var selectedIndexPath: IndexPath?
    var listShowingForFromLanguage = true
    private let languageManager = LanguageSelectionManager.shared
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLanguageProperty()
        setupTableView()
        registerNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let selectedItemPosition = getSelectedItemPosition
        PrintUtility.printLog(tag: TAG , text: " position \(String(describing: selectedItemPosition))")
        selectedIndexPath = IndexPath(row: getSelectedItemPosition(), section: 0)
        self.langListTableView.scrollToRow(at: selectedIndexPath!, at: .middle, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        PrintUtility.printLog(tag: TagUtility.sharedInstance.cameraScreenPurpose, text: "\(ScreenTracker.sharedInstance.screenPurpose)")
    }
    
    deinit {
        unregisterNotification()
    }
    
    //MARK: - Initial setup
    private func setupLanguageProperty(){
        listShowingForFromLanguage = UserDefaultsProperty<Bool>(KCameraLanguageFrom).value!
        languageItems.removeAll()
        
        if listShowingForFromLanguage{
            languageItems = CameraLanguageSelectionViewModel.shared.getFromLanguageLanguageList()
            if isFirstTimeLoad {
                UserDefaultsProperty<String>(KSelectedLanguageCamera).value = CameraLanguageSelectionViewModel.shared.fromLanguage
            }
            
        }else{
            languageItems = CameraLanguageSelectionViewModel.shared.targetLanguageItemsCamera
            if isFirstTimeLoad {
                UserDefaultsProperty<String>(KSelectedLanguageCamera).value = CameraLanguageSelectionViewModel.shared.targetLanguage
            }
        }
    }
    
    private func setupTableView(){
        langListTableView.dataSource = self
        langListTableView.delegate = self
        let nib = UINib(nibName: "LangListCell", bundle: nil)
        langListTableView.register(nib, forCellReuseIdentifier: "LangListCell")
        self.langListTableView.backgroundColor = UIColor.clear
    }
    
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCameralanguageSelection(notification:)), name: .cameraSelectionLanguage, object: nil)
    }
    
    //MARK: - Utils
    private func getSelectedItemPosition() -> Int{
        let selectedLangCode = UserDefaultsProperty<String>(KSelectedLanguageCamera).value
        for i in 0...languageItems.count - 1{
            let item = languageItems[i]
            if  selectedLangCode == item.code{
                return i
            }
        }
        return 0
    }
    
    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name: .cameraSelectionLanguage, object: nil)
    }
    
    @objc func updateCameralanguageSelection (notification:Notification) {
        selectedIndexPath = IndexPath(row: getSelectedItemPosition(), section: 0)
        self.langListTableView.scrollToRow(at: selectedIndexPath!, at: .middle, animated: true)
        self.langListTableView.reloadData()
    }
}

//MARK: - UITableViewDataSource
extension LanguageListCameraVC: UITableViewDataSource{
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
        
        PrintUtility.printLog(tag: TAG , text: " value \(String(describing: UserDefaultsProperty<String>(KSelectedLanguageCamera).value)) languageItem.code \(languageItem.code)")
        
        if UserDefaultsProperty<String>(KSelectedLanguageCamera).value == languageItem.code{
            let languageManager = LanguageSelectionManager.shared
            if(languageManager.hasTtsSupport(languageCode: languageItem.code)){
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
            
            PrintUtility.printLog(tag: TAG , text: " matched lang \(String(describing: UserDefaultsProperty<String>(KSelectedLanguageCamera).value)) languageItem.code \(languageItem.code)")
        }else{
            cell.unselectedLabelTrailingConstraint.constant = kUnselectedLanguageTrailingConstant
            cell.lableLangName.isHidden = true
            cell.langNameUnSelecteLabel.isHidden = false
            cell.lableLangName.holdScrolling = true
            cell.imageLangItemSelector.isHidden = true
            cell.imageNoVoice.isHidden = true
            cell.langListCellContainer.backgroundColor = .black
        }
        return cell
    }
}

//MARK: - UITableViewDelegate
extension LanguageListCameraVC: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let languageItem = languageItems[indexPath.row]
        UserDefaultsProperty<String>(KSelectedLanguageCamera).value = languageItem.code
        self.langListTableView.reloadData()
    }
    
//    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: self.view.bounds.height / 4))
//        footerView.backgroundColor = .clear
//        return footerView
//    }
//    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return self.view.bounds.height / 4
//    }
    
}

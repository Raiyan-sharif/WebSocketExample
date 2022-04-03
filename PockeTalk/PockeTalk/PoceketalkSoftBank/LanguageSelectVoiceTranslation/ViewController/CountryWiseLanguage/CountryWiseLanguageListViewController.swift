//
//  CountryWiseLanguageListViewController.swift
//  PockeTalk
//

import UIKit

class CountryWiseLanguageListViewController: BaseViewController {
    @IBOutlet weak private var languageListCollectionView: UICollectionView!
    @IBOutlet weak private var buttonOk: UIButton!
    @IBOutlet weak private var countryNameLabel: UILabel!
    
    let TAG = "\(CountryWiseLanguageListViewController.self)"
    var selectedLanguageCode = ""
    var dataShowingLanguageCode = ""
    var countryName = ""
    var selectedIndexPath: IndexPath?
    var isNative: Int = 0
    var isFromTranslation = false
    let INVALID_SELECTION = -1
    
    var countryListItem: CountryListItemElement?
    var languageList = [LanguageItem]()
    private let window :UIWindow = UIApplication.shared.keyWindow!
    var talkButtonImageView: UIImageView!
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        ScreenTracker.sharedInstance.screenPurpose = .countryWiseLanguageList
        talkButtonImageView = window.viewWithTag(109) as! UIImageView
        talkButtonImageView.isHidden = true
        super.viewDidLoad()
        UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value = UserDefaultsProperty<String>(KSelectedLanguageVoice).value
        setupUI()
        configureCollectionView()
        getLanugageList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let selectedItemPosition = getSelectedItemPosition
        PrintUtility.printLog(tag: TAG, text: "position \(String(describing: selectedItemPosition))")
        selectedIndexPath = IndexPath(row: getSelectedItemPosition(), section: 0)
        self.languageListCollectionView.scrollToItem(at: selectedIndexPath!, at: .centeredVertically, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        talkButtonImageView.isHidden = false
    }
    
    //MARK: - Initial setup
    private func setupUI(){
        buttonOk.layer.cornerRadius = 15
        let countryCode = GlobalMethod.getCountryCodeFrom(countryListItem, and: dataShowingLanguageCode)
        countryNameLabel.text = countryCode
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        languageListCollectionView.collectionViewLayout = layout
        languageListCollectionView.register(langListCollectionViewCell.nib(), forCellWithReuseIdentifier: langListCollectionViewCell.identifier)
        
        languageListCollectionView.delegate = self
        languageListCollectionView.dataSource = self
    }
    
    private func getSelectedItemPosition() -> Int{
        let selectedLangCode = UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value
        PrintUtility.printLog(tag: TAG, text: "searching for  \(selectedLangCode ?? "")")
        
        for i in 0...languageList.count - 1 {
            let item = languageList[i]
            if  selectedLangCode == item.code{
                return i
            }
        }
        return INVALID_SELECTION
    }
    
    private func getLanugageList(){
        PrintUtility.printLog(tag: TAG, text: "getLanugageList \(String(describing: countryListItem?.languageList.count))")
        let languageManager = LanguageSelectionManager.shared
        
        for item in countryListItem!.languageList{
            PrintUtility.printLog(tag: TAG, text: "lang-code \(item)")
            let language = languageManager.getLanguageInfoByCode(langCode: item)
            languageList.append(language!)
            PrintUtility.printLog(tag: TAG, text: "lang-name \(String(describing: language?.name)) size \(String(describing: languageList.count))")
        }
    }
    
    //MARK: - IBActions
    @IBAction private func onOkButtonPressed(_ sender: Any) {
        if getSelectedItemPosition() == INVALID_SELECTION {
            PrintUtility.printLog(tag: TAG, text: "ok_button nothing to change")
            return
        } else {
            removeFloatingBtn()
        }
        selectedLanguageCode = UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value!
        
        if isFromTranslation{
            let entity = LanguageSelectionEntity(id: 0, textLanguageCode: selectedLanguageCode, cameraOrVoice: 0)
            //Update lnaguage history list database
            if let _ = try? LanguageSelectionDBModel().find(entity: entity) {
                let languages = LanguageSelectionManager.shared.getSelectedLanguageListFromDb(cameraOrVoice: LanguageType.voice.rawValue)
                for item in languages {
                    if item.code == selectedLanguageCode {
                        if let _ = try? LanguageSelectionDBModel().delete(idToDelte: item.id) {
                        }
                    }
                }
            }
            _ = LanguageSelectionManager.shared.insertIntoDb(entity: entity)
            NotificationCenter.default.post(name: .updateTranlationNotification, object: nil)
        }else{
            if isNative == LanguageName.bottomLang.rawValue{
                LanguageSelectionManager.shared.bottomLanguage = selectedLanguageCode
            }else{
                LanguageSelectionManager.shared.topLanguage = selectedLanguageCode
            }
            let entity = LanguageSelectionEntity(id: 0, textLanguageCode: selectedLanguageCode, cameraOrVoice: 0)
            //Update lnaguage history list database
            if let _ = try? LanguageSelectionDBModel().find(entity: entity) {
                let languages = LanguageSelectionManager.shared.getSelectedLanguageListFromDb(cameraOrVoice: LanguageType.voice.rawValue)
                for item in languages {
                    if item.code == selectedLanguageCode {
                        if let _ = try? LanguageSelectionDBModel().delete(idToDelte: item.id) {
                        }
                    }
                }
            }
            _ = LanguageSelectionManager.shared.insertIntoDb(entity: entity)
            
            NotificationCenter.default.post(name: .languageSelectionVoiceNotification, object: nil)
            NotificationCenter.default.post(name:.containerViewSelection, object: nil)
        }
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction private func onBackButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func removeFloatingBtn(){
        FloatingMikeButton.sharedInstance.isHidden(true)
    }
}

//MARK: - UICollectionViewDelegate
extension CountryWiseLanguageListViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let languageItem = languageList[indexPath.row]
        UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value = languageItem.code
        self.languageListCollectionView.reloadData()
    }
}

//MARK: - UICollectionViewDataSource
extension CountryWiseLanguageListViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = languageList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: langListCollectionViewCell.identifier, for: indexPath) as! langListCollectionViewCell
        PrintUtility.printLog(tag: TAG, text: "showing as \(dataShowingLanguageCode)")
        
        if dataShowingLanguageCode == systemLanguageCodeEN {
            cell.languageNameLabel.text = "\(item.englishName) (\(item.name))"
            cell.languageNameLableSelected.text = "\(item.englishName) (\(item.name))"
        } else {
            cell.languageNameLabel.text = "\(item.sysLangName) (\(item.name))"
            cell.languageNameLableSelected.text = "\(item.sysLangName) (\(item.name))"
        }
        
        if UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value == item.code{
            let languageManager = LanguageSelectionManager.shared
            if(languageManager.hasTtsSupport(languageCode: item.code)){
                cell.imageviewNoVoice.isHidden = true
                cell.unselectedLabelTrailingConstraint.constant = kTtsNotAvailableTrailingConstant
                cell.selectedLabelTrailingConstraint.constant = kTtsNotAvailableTrailingConstant
            }else{
                cell.imageviewNoVoice.isHidden = false
                cell.unselectedLabelTrailingConstraint.constant = kTtsAvailableTrailingConstant
                cell.selectedLabelTrailingConstraint.constant = kTtsAvailableTrailingConstant
            }
            cell.imageLanguageSelection.isHidden = false
            cell.languageNameLableSelected.isHidden = false
            cell.languageNameLabel.isHidden = true
            cell.languageNameLableSelected.holdScrolling = false
            cell.languageNameLableSelected.type = .continuous
            cell.languageNameLableSelected.trailingBuffer = kMarqueeLabelTrailingBufferForLanguageScreen
            cell.languageNameLableSelected.speed = .rate(kMarqueeLabelScrollingSpeenForLanguageScreen)
            cell.langListItemContainer.backgroundColor = UIColor(hex: "#008FE8")
            PrintUtility.printLog(tag: TAG, text: "matched lang \(String(describing: UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value)) languageItem.code \(item.code)")
        }else{
            cell.unselectedLabelTrailingConstraint.constant = kUnselectedLanguageTrailingConstant
            cell.languageNameLableSelected.isHidden = true
            cell.languageNameLabel.isHidden = false
            cell.imageLanguageSelection.isHidden = true
            cell.languageNameLableSelected.holdScrolling = true
            cell.imageviewNoVoice.isHidden = true
            cell.langListItemContainer.backgroundColor = .black
        }
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension CountryWiseLanguageListViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

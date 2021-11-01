//
//  CountryWiseLanguageListViewController.swift
//  PockeTalk
//

import UIKit

class CountryWiseLanguageListViewController: BaseViewController {
    let TAG = "\(CountryWiseLanguageListViewController.self)"
    @IBOutlet weak var languageListCollectionView: UICollectionView!
    @IBOutlet weak var buttonOk: UIButton!
    @IBOutlet weak var countryNameLabel: UILabel!
    var selectedLanguageCode = ""
    var dataShowingLanguageCode = ""
    var countryName = ""
    var selectedIndexPath: IndexPath?
    var isNative: Int = 0

    var countryListItem: CountryListItemElement?
    var languageList = [LanguageItem]()

    @IBAction func onOkButtonPressed(_ sender: Any) {
        selectedLanguageCode = UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value!
        PrintUtility.printLog(tag: TAG, text: "code \(selectedLanguageCode) isnativeval \(isNative)")
        if isNative == LanguageName.bottomLang.rawValue{
            LanguageSelectionManager.shared.bottomLanguage = selectedLanguageCode
        }else{
            LanguageSelectionManager.shared.topLanguage = selectedLanguageCode
        }
        let entity = LanguageSelectionEntity(id: 0, textLanguageCode: selectedLanguageCode, cameraOrVoice: 0)
        LanguageSelectionManager.shared.insertIntoDb(entity: entity)
        PrintUtility.printLog(tag: TAG, text: "\(CountryWiseLanguageListViewController.self) changed language to \(selectedLanguageCode)")
        NotificationCenter.default.post(name: .languageSelectionVoiceNotification, object: nil)
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: HomeViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                       break
            }
        }
    }

    @IBAction func onBackButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //buttonOk.backgroundColor = .clear
        PrintUtility.printLog(tag: TAG, text: " isNative \(isNative)")
        if isNative == LanguageName.bottomLang.rawValue{
            UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value = LanguageSelectionManager.shared.bottomLanguage
        }else{
            UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value = LanguageSelectionManager.shared.topLanguage
        }
        buttonOk.layer.cornerRadius = 15
        if dataShowingLanguageCode == systemLanguageCodeEN{
            countryNameLabel.text = countryListItem?.countryName.en
        }else if dataShowingLanguageCode == systemLanguageCodeJP{
            countryNameLabel.text = countryListItem?.countryName.ja
        }
        //buttonOk.layer.borderWidth = 1
        getLanugageList()
        configureCollectionView()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        let selectedItemPosition = getSelectedItemPosition
        PrintUtility.printLog(tag: TAG, text: "position \(selectedItemPosition)")
        selectedIndexPath = IndexPath(row: getSelectedItemPosition(), section: 0)
        self.languageListCollectionView.scrollToItem(at: selectedIndexPath!, at: .centeredVertically, animated: true)
    }

    fileprivate func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        languageListCollectionView.collectionViewLayout = layout
        languageListCollectionView.register(langListCollectionViewCell.nib(), forCellWithReuseIdentifier: langListCollectionViewCell.identifier)

        languageListCollectionView.delegate = self
        languageListCollectionView.dataSource = self
    }

    func getSelectedItemPosition() -> Int{
        let selectedLangCode = UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value
        PrintUtility.printLog(tag: TAG, text: "searching for  \(selectedLangCode)")
        for i in 0...languageList.count - 1 {
            let item = languageList[i]
            if  selectedLangCode == item.code{
                return i
            }
        }
        return 0
    }

    func getLanugageList(){
        PrintUtility.printLog(tag: TAG, text: "getLanugageList \(String(describing: countryListItem?.languageList.count))")
        let languageManager = LanguageSelectionManager.shared
        for item in countryListItem!.languageList{
            PrintUtility.printLog(tag: TAG, text: "lang-code \(item)")
            let language = languageManager.getLanguageInfoByCode(langCode: item)
            languageList.append(language!)
            PrintUtility.printLog(tag: TAG, text: "lang-name \(String(describing: language?.name)) size \(String(describing: languageList.count))")
        }
    }
}

extension CountryWiseLanguageListViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: false)
        let languageItem = languageList[indexPath.row]
        UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value = languageItem.code
        self.languageListCollectionView.reloadData()
    }
}

extension CountryWiseLanguageListViewController : UICollectionViewDataSource{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languageList.count 
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = languageList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: langListCollectionViewCell.identifier, for: indexPath) as! langListCollectionViewCell
        PrintUtility.printLog(tag: TAG, text: "showing as \(dataShowingLanguageCode)")
        if dataShowingLanguageCode == systemLanguageCodeEN{
            cell.languageNameLabel.text = "\(item.englishName) (\(item.name))"
        }else if dataShowingLanguageCode == systemLanguageCodeJP{
            cell.languageNameLabel.text = "\(item.sysLangName) (\(item.name))"
        }

        if UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value == item.code{
            let languageManager = LanguageSelectionManager.shared
            if(languageManager.hasTtsSupport(languageCode: item.code)){
                cell.imageviewNoVoice.isHidden = true
            }else{
                cell.imageviewNoVoice.isHidden = false
            }
            cell.imageLanguageSelection.isHidden = false
            cell.langListItemContainer.backgroundColor = UIColor(hex: "#008FE8")
            PrintUtility.printLog(tag: TAG, text: "matched lang \(String(describing: UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value)) languageItem.code \(item.code)")
        }else{
            cell.imageLanguageSelection.isHidden = true
            cell.imageviewNoVoice.isHidden = true
            cell.langListItemContainer.backgroundColor = .black
        }
        return cell
    }

}

extension CountryWiseLanguageListViewController : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: 60)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

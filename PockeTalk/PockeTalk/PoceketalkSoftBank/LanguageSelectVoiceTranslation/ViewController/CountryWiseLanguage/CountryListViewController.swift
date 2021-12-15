//
//  CountryListViewController.swift
//  PockeTalk
//

import UIKit

class CountryListViewController: BaseViewController {
    @IBOutlet weak private var viewEnglishName: UIView!
    @IBOutlet weak private var countryNameLabel: UILabel!
    @IBOutlet weak private var countryListCollectionView: UICollectionView!
   
    let TAG = "\(CountryListViewController.self)"
    var countryList = [CountryListItemElement]()
    var dataShowingAsEnlish = false
    var dataShowingLanguageCode = LanguageManager.shared.currentLanguage.rawValue
    let sysLangCode = LanguageManager.shared.currentLanguage.rawValue
    var isNative: Int = 0
    let width : CGFloat = 50
    let speechBtnWidth : CGFloat = 100
    let trailing : CGFloat = -20
    let toastVisibleTime : Double = 2.0
    var isFromTranslation = false
    let window :UIWindow = UIApplication.shared.keyWindow!

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureCollectionView()
        registerNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //setUpMicroPhoneIcon()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        //removeFloatingBtn()
    }
    
    deinit {
        unregisterNotification()
    }
    
    //MARK: - Initial setup
    private func setupUI() {
        countryNameLabel.text = "Region".localiz()
        viewEnglishName.layer.cornerRadius = 15
        viewEnglishName.backgroundColor = .clear
        setViewBorder()
        
        if sysLangCode == systemLanguageCodeEN{
            dataShowingAsEnlish = true
            viewEnglishName.isHidden = true
        }else{
            dataShowingAsEnlish = false
            viewEnglishName.isHidden = false
        }
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.clickOnEnglishButton(_:)))
        self.viewEnglishName.addGestureRecognizer(gesture)
    }
    private func configureCollectionView() {
        countryList.removeAll()
        countryList = CountryFlagListViewModel.shared.loadCountryDataFromJsonbyCode(countryCode: sysLangCode)!.countryList
        let layout = UICollectionViewFlowLayout()
        countryListCollectionView.collectionViewLayout = layout
        
        countryListCollectionView.register(
            CountryListCollectionViewCell.nib(),
            forCellWithReuseIdentifier: CountryListCollectionViewCell.identifier)
        
        countryListCollectionView.register(
            FooterCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: FooterCollectionReusableView.identifier)
        
        countryListCollectionView.delegate = self
        countryListCollectionView.dataSource = self
    }
    
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateCountrySelection(notification:)), name: .countySlectionByVoiceNotofication, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideMicrophoneButton(notification:)), name:.tapOnMicrophoneCountrySelectionVoice, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showMicrophoneButton(notification:)), name: .tapOffMicrophoneCountrySelectionVoice, object: nil)
    }
    
    //MARK: - View Transactions
    private func showLanguageListScreen(item: CountryListItemElement){
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CountryWiseLanguageListViewController")as! CountryWiseLanguageListViewController
        controller.countryListItem = item
        controller.dataShowingLanguageCode = dataShowingLanguageCode
        controller.isNative = isNative
        controller.isFromTranslation = isFromTranslation
        self.navigationController?.pushViewController(controller, animated: true);
    }
    
    //MARK: - IBActions
    @IBAction func onBackButtonPressed(_ sender: Any) {
        remove(asChildViewController: self)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionVoice
        NotificationCenter.default.post(name: .popFromCountrySelectionVoice, object: nil)
    }
    
    @objc func clickOnEnglishButton(_ sender:UITapGestureRecognizer){
        PrintUtility.printLog(tag: TAG, text: " Clickedn on english button")
        if dataShowingAsEnlish{
            dataShowingLanguageCode = sysLangCode
            countryList.removeAll()
            countryList = CountryFlagListViewModel.shared.loadCountryDataFromJsonbyCode(countryCode: dataShowingLanguageCode)!.countryList
            countryNameLabel.textColor = UIColor.white.color
            setViewBorder()
            viewEnglishName.backgroundColor = .clear
            dataShowingAsEnlish = false
            countryNameLabel.text = "Region".localiz()
        }else{
            dataShowingLanguageCode = systemLanguageCodeEN
            countryList.removeAll()
            countryList = CountryFlagListViewModel.shared.loadCountryDataFromJsonbyCode(countryCode: dataShowingLanguageCode)!.countryList
            dataShowingAsEnlish = true
            countryNameLabel.text = "Region"
            countryNameLabel.textColor = UIColor.white.color
            viewEnglishName.backgroundColor = ._skyBlueColor()
            viewEnglishName.layer.borderWidth = 0
        }
        countryListCollectionView.reloadData()
    }

    //MARK: - Utils
    private func setViewBorder() {
        viewEnglishName.layer.borderWidth = 2
        viewEnglishName.layer.borderColor = UIColor.gray.cgColor
    }

    @objc func hideMicrophoneButton(notification: Notification) {
        //removeFloatingBtn()
    }
    
    @objc func showMicrophoneButton(notification: Notification) {
       //setUpMicroPhoneIcon()
    }

    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name:.countySlectionByVoiceNotofication, object: nil)
        NotificationCenter.default.removeObserver(self, name:.tapOnMicrophoneCountrySelectionVoice, object: nil)
        NotificationCenter.default.removeObserver(self, name:.tapOffMicrophoneCountrySelectionVoice, object: nil)
    }

    @objc func updateCountrySelection(notification: Notification) {
        if let country = notification.userInfo!["country"] as? String{
            searchCountry(text: country)
        }
    }

    // TODO: Remove micrphone functionality as per current requirement. Will modify after final confirmation.
    /*
    private func setUpMicroPhoneIcon() {
        let bottomMergin = (self.window.frame.maxY / 4) / 2 + width / 2
        
        let floatingButton = UIButton(frame: CGRect(
            x: self.window.frame.maxX - 60,
            y: self.window.frame.maxY - bottomMergin,
            width: width,
            height: width)
        )
        
        floatingButton.setImage(UIImage(named: "mic"), for: .normal)
        floatingButton.backgroundColor = UIColor._buttonBackgroundColor()
        floatingButton.layer.cornerRadius = width/2
        floatingButton.clipsToBounds = true
        floatingButton.tag = countrySelectVoiceFloatingbtnTag
        self.window.addSubview(floatingButton)
        
        floatingButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }

    @objc func microphoneTapAction (sender:UIButton) {
        LanguageSettingsTutorialVC.openShowViewController(navigationController: self.navigationController)
        //self.showToast(message: "Navigate to Speech Controller", seconds: toastVisibleTime)
    }
    
    private func removeFloatingBtn() {
        window.viewWithTag(countrySelectVoiceFloatingbtnTag)?.removeFromSuperview()
        window.viewWithTag(languageSelectVoiceFloatingbtnTag)?.removeFromSuperview()
    }
    */
}

//MARK: - UICollectionViewDelegate
extension CountryListViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        PrintUtility.printLog(tag: TAG, text: " didSelectItemAt clicked")
        let countryItem = countryList[indexPath.row] as CountryListItemElement
    
        //removeFloatingBtn()
        showLanguageListScreen(item: countryItem)
    }
}

//MARK: - UICollectionViewDataSource
extension CountryListViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let countryItem = countryList[indexPath.row] as CountryListItemElement
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountryListCollectionViewCell", for: indexPath) as! CountryListCollectionViewCell
        var countryName = ""
        switch dataShowingLanguageCode {
            case systemLanguageCodeJP:
                countryName = countryItem.countryName.ja
            default:
                countryName = countryItem.countryName.en
        }
        cell.countryNameLabel.text = countryName
        cell.configureFlagImage(with: UIImage(named: countryItem.countryName.en)!)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: FooterCollectionReusableView.identifier,
                for: indexPath)
            return footerView
        default:
            PrintUtility.printLog(tag: TAG, text: "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension CountryListViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 5
        return CGSize(width: width, height: 140)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: self.view.bounds.height / 4)
    }
}

//MARK: - SpeechProcessingVCDelegates
extension CountryListViewController: SpeechProcessingVCDelegates{
    func searchCountry(text: String) {
        PrintUtility.printLog(tag: TAG, text: "speech text \(text)")
        let seconds = 0.2
        // Without DispatchQueue CountryWiseLanguageListViewController is opening and closing immediately. After using DispatchQueue the problem is not happening
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            if let countryItem = self.findCountryName(text){
                let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "CountryWiseLanguageListViewController")as! CountryWiseLanguageListViewController
                controller.countryListItem = countryItem
                controller.dataShowingLanguageCode = self.dataShowingLanguageCode
                controller.isFromTranslation = self.isFromTranslation
                controller.isNative = self.isNative
                self.navigationController?.pushViewController(controller, animated: true);
            }
        }
    }

    func findCountryName(_ text: String) -> CountryListItemElement?{
        let stringFromSpeech = text.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
        for item in countryList{
            PrintUtility.printLog(tag: TAG, text: "countryname \(item.countryName.en) search for \(stringFromSpeech)")
            var countryName = ""
            switch dataShowingLanguageCode {
                case systemLanguageCodeJP:
                    countryName = item.countryName.ja
                default:
                    countryName = item.countryName.en
            }
            if countryName == stringFromSpeech{
                return item
            }
        }
        return nil
    }
}

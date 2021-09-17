//
//  CountryListViewController.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 8/9/21.
//

import UIKit

class CountryListViewController: BaseViewController {
    let TAG = "\(CountryListViewController.self)"
    @IBOutlet weak var viewEnglishName: UIView!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var countryListCollectionView: UICollectionView!
    @IBOutlet weak var layoutBottomButtonContainer: UIView!
    var countryList = [CountryListItemElement]()
    var dataShowingAsEnlish = false
    var dataShowingLanguageCode = LanguageManager.shared.currentLanguage.rawValue
    let sysLangCode = LanguageManager.shared.currentLanguage.rawValue
    var isNative: Int = 0
    let width : CGFloat = 50
    let speechBtnWidth : CGFloat = 100
    let trailing : CGFloat = -20
    let toastVisibleTime : Double = 2.0
    @IBAction func onBackButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    fileprivate func setViewBorder() {
        viewEnglishName.layer.borderWidth = 2
        viewEnglishName.layer.borderColor = UIColor.gray.cgColor
    }

    @objc func clickOnEnglishButton(_ sender:UITapGestureRecognizer){
        PrintUtility.printLog(tag: TAG, text: " Clickedn on english button")
        if dataShowingAsEnlish{
            dataShowingLanguageCode = sysLangCode
            countryList.removeAll()
            countryList = CountryFlagListViewModel.shared.loadCountryDataFromJsonbyCode(countryCode: dataShowingLanguageCode)!.countryList
            countryNameLabel.textColor = .white.color
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
            countryNameLabel.textColor = .white.color
            viewEnglishName.backgroundColor = ._skyBlueColor()
            viewEnglishName.layer.borderWidth = 0
        }
        countryListCollectionView.reloadData()
    }

    fileprivate func configureCollectionView() {
        countryList.removeAll()
        countryList = CountryFlagListViewModel.shared.loadCountryDataFromJsonbyCode(countryCode: sysLangCode)!.countryList
        let layout = UICollectionViewFlowLayout()
        countryListCollectionView.collectionViewLayout = layout
        countryListCollectionView.register(CountryListCollectionViewCell.nib(), forCellWithReuseIdentifier: CountryListCollectionViewCell.identifier)
        countryListCollectionView.delegate = self
        countryListCollectionView.dataSource = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMicroPhoneIcon()
        setUpSpeechButton()
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
        configureCollectionView()

        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.clickOnEnglishButton(_:)))
        self.viewEnglishName.addGestureRecognizer(gesture)
    }


    func setUpSpeechButton(){
        let floatingButton = GlobalMethod.setUpMicroPhoneIcon(view: self.view, width: speechBtnWidth, height: speechBtnWidth, trailing: trailing, bottom: trailing)
        floatingButton.addTarget(self, action: #selector(speechButtonTapAction(sender:)), for: .touchUpInside)
    }

    // TODO microphone tap event
    @objc func speechButtonTapAction (sender:UIButton) {
        if Reachability.isConnectedToNetwork() {
        let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
            controller.homeMicTapTimeStamp = currentTS
            controller.screenOpeningPurpose = SpeechProcessingScreenOpeningPurpose.CountrySelectionByVoice
            self.navigationController?.pushViewController(controller, animated: true);
        } else {
            GlobalMethod.showNoInternetAlert()
        }
    }

    // floating microphone button
    func setUpMicroPhoneIcon () {
        let floatingButton = UIButton()
        floatingButton.setImage(UIImage(named: "mic"), for: .normal)
        floatingButton.backgroundColor = UIColor._buttonBackgroundColor()
        floatingButton.layer.cornerRadius = width/2
        floatingButton.clipsToBounds = true
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: width).isActive = true
        floatingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: trailing).isActive = true
        floatingButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: trailing).isActive = true
        floatingButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        LanguageSettingsTutorialVC.openShowViewController(navigationController: self.navigationController)
        //self.showToast(message: "Navigate to Speech Controller", seconds: toastVisibleTime)
    }
}

extension CountryListViewController : UICollectionViewDelegate{


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        PrintUtility.printLog(tag: TAG, text: " didSelectItemAt clicked")
        let countryItem = countryList[indexPath.row] as CountryListItemElement
        showLanguageListScreen(item: countryItem)
    }

    func showLanguageListScreen(item: CountryListItemElement){
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CountryWiseLanguageListViewController")as! CountryWiseLanguageListViewController
        controller.countryListItem = item
        controller.dataShowingLanguageCode = dataShowingLanguageCode
        controller.isNative = isNative
        self.navigationController?.pushViewController(controller, animated: true);
    }
}

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

}

extension CountryListViewController : UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - 5
        return CGSize(width: width, height: 140)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

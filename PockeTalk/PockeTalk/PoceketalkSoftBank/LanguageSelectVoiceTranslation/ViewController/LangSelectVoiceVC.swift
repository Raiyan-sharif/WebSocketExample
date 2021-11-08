//
//  LangSelectVoiceVC.swift
//  PockeTalk
//

import UIKit
import SwiftyXMLParser
protocol RetranslationDelegate {
    func showRetranslation (selectedLanguage : String)
}

class LangSelectVoiceVC: BaseViewController {
    let TAG = "\(LangSelectVoiceVC.self)"
    @IBOutlet weak var tabsView: UIView!
    @IBOutlet weak var btnHistoryList: UIButton!
    @IBOutlet weak var btnLangList: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    var languageHasUpdated:(()->())?

    @IBOutlet weak var layoutBottomBtnContainer: UIView!
    var currentIndex: Int = 0
    let tagLanguageListVC = "LanguageListVC"
    let tagHistoryListVC = "HistoryListVC"
    let tabsPageViewController = "TabsPageViewController"

    let iconGlobalSelect = "icon_language_global_select.png"
    let iconGlobalUnSelect = "icon_language_global_unselect.png"
    let iconHistorySelect = "icon_language_history_select.png"
    let iconHistoryUnSelect = "icon_language_history_unselect.png"
    var languageItems = [LanguageItem]()
    var mLanguageFile = "conversation_languages_en"
    var pageController: UIPageViewController!
    let langListArray:NSMutableArray = NSMutableArray()
    var selectedLanguageCode = ""
    var isNative: Int = 0
    let trailing : CGFloat = -20
    let width : CGFloat = 100
    let widthMicrophone : CGFloat = 50
    let toastVisibleTime : Double = 2.0
    /// retranslation delegate
    var retranslationDelegate : RetranslationDelegate?

    /// check if navigation from Retranslation
    var fromRetranslation : Bool = false
    @IBOutlet weak var toolbarTitleLabel: UILabel!

    @IBAction func onLangSelectButton(_ sender: Any) {
        updateButton(index: 0)
        tabsViewDidSelectItemAt(position: 0)
    }

    @IBAction func onHistoryButtonTapped(_ sender: Any) {
        updateButton(index: 1)
        tabsViewDidSelectItemAt(position: 1)
    }

    @IBAction func onCountryButtonTapped(_ sender: Any) {
        //self.showToast(message: "Show country selection screen", seconds: toastVisibleTime)
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CountryListViewController")as! CountryListViewController
        controller.isFromTranslation = fromRetranslation
        controller.isNative = isNative
        //self.navigationController?.pushViewController(controller, animated: true);
        add(asChildViewController: controller, containerView: view)
        ScreenTracker.sharedInstance.screenPurpose = .CountrySelectionByVoice
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaultsProperty<Int>(kIsNative).value = isNative
        setButtonTopCornerRadius(btnLangList)
        setButtonTopCornerRadius(btnHistoryList)
        toolbarTitleLabel.text = "Language".localiz()
        toolbarTitleLabel.textColor = UIColor.white
        updateButton(index:0)
        setupPageViewController()
        setUpMicroPhoneIcon()
        setUpSpeechButton()
        //let item = LanguageMapViewModel.sharedInstance.findTextFromDb(languageCode: LanguageManager.shared.currentLanguage.rawValue,text: "イディッシュ語")
    }

    func setButtonTopCornerRadius(_ button: UIButton){
        if #available(iOS 11.0, *) {
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }

    func setupPageViewController() {
        // PageViewController
      self.pageController = storyboard?.instantiateViewController(withIdentifier: tabsPageViewController) as! TabsPageViewController
      self.addChild(self.pageController)
      self.view.addSubview(self.pageController.view)

      // Set PageViewController Delegate & DataSource
      pageController.delegate = self
      pageController.dataSource = self

      // Set the selected ViewController in the PageViewController when the app starts
      pageController.setViewControllers([showViewController(0)!], direction: .forward, animated: true, completion: nil)

      // PageViewController Constraints
      self.pageController.view.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint.activate([
        self.pageController.view.topAnchor.constraint(equalTo: self.tabsView.bottomAnchor),
        self.pageController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        self.pageController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        self.pageController.view.bottomAnchor.constraint(equalTo: layoutBottomBtnContainer.topAnchor)
        ])
        self.pageController.didMove(toParent: self)
    }
    // floating microphone button
    func setUpMicroPhoneIcon () {
        let floatingButton = UIButton()
        floatingButton.setImage(UIImage(named: "mic"), for: .normal)
        floatingButton.backgroundColor = UIColor._buttonBackgroundColor()
        floatingButton.layer.cornerRadius = widthMicrophone/2
        floatingButton.clipsToBounds = true
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.widthAnchor.constraint(equalToConstant: widthMicrophone).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: widthMicrophone).isActive = true
        floatingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: trailing).isActive = true
        floatingButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: trailing).isActive = true
        floatingButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }

    func setUpSpeechButton(){
//        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.layoutBottomBtnContainer, width: width, height: width)
//        talkButton.addTarget(self, action: #selector(speechButtonTapAction(sender:)), for: .touchUpInside)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Refresh CollectionView Layout when you rotate the device
//            tabsView.collectionView.collectionViewLayout.invalidateLayout()
    }

    func updateButton(index:Int){
        PrintUtility.printLog(tag: TAG, text: "Index position \(index)")
        if index == 0{
            btnLangList.backgroundColor = .black
            btnHistoryList.backgroundColor = .darkGray
            btnLangList.setImage(UIImage(named: iconGlobalSelect), for: UIControl.State.normal)
            btnHistoryList.setImage(UIImage(named: iconHistoryUnSelect), for: UIControl.State.normal)
        }else{
            btnLangList.backgroundColor = .darkGray
            btnHistoryList.backgroundColor = .black
            btnLangList.setImage(UIImage(named: iconGlobalUnSelect), for: UIControl.State.normal)
            btnHistoryList.setImage(UIImage(named: iconHistorySelect), for: UIControl.State.normal)
        }
    }

    func tabsViewDidSelectItemAt(position: Int) {

        PrintUtility.printLog(tag: TAG, text: "current-index \(currentIndex) position \(position)")
        // Check if the selected tab cell position is the same with the current position in pageController, if not, then go forward or backward
        if position != currentIndex {
            if position > currentIndex {
                self.pageController.setViewControllers([showViewController(position)!], direction: .forward, animated: true, completion: nil)
            } else {
                self.pageController.setViewControllers([showViewController(position)!], direction: .reverse, animated: true, completion: nil)
            }
        }
    }
        // Show ViewController for the current position
    func showViewController(_ index: Int) -> UIViewController? {
        currentIndex = index
        if index == 0 {
            let contentVC = storyboard?.instantiateViewController(withIdentifier:tagLanguageListVC) as! LanguageListVC
            contentVC.pageIndex = index
            return contentVC
        } else if index == 1 {
            let contentVC = storyboard?.instantiateViewController(withIdentifier: tagHistoryListVC) as! HistoryListVC
                //contentVC.name = tabsView.tabs[index].title
            contentVC.pageIndex = index
            return contentVC
        }else {
            let contentVC = storyboard?.instantiateViewController(withIdentifier: tagLanguageListVC) as! LanguageListVC
                //contentVC.name = tabsView.tabs[index].title
            contentVC.pageIndex = index
            return contentVC
        }
    }


    func objectToJson(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }


    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        LanguageSettingsTutorialVC.openShowViewController(navigationController: self.navigationController)
        //self.showToast(message: "Navigate to Speech Controller", seconds: toastVisibleTime)
    }


    // TODO microphone tap event
    @objc func speechButtonTapAction (sender:UIButton) {
        if Reachability.isConnectedToNetwork() {
            RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
                if isGranted {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
                    controller.screenOpeningPurpose = SpeechProcessingScreenOpeningPurpose.LanguageSelectionVoice
                    self.navigationController?.pushViewController(controller, animated: true);
                } else {
                    GlobalMethod.showPermissionAlert(viewController: self, title : kMicrophoneUsageTitle, message : kMicrophoneUsageMessage)
                }
            }
        } else {
            GlobalMethod.showNoInternetAlert()
        }
    }


    @IBAction func onBackButtonPressed(_ sender: Any) {
        selectedLanguageCode = UserDefaultsProperty<String>(KSelectedLanguageVoice).value!
        PrintUtility.printLog(tag: TAG, text: "code \(selectedLanguageCode) isnativeval \(isNative)")
        if !fromRetranslation {
            if isNative == LanguageName.bottomLang.rawValue{
                if LanguageSelectionManager.shared.bottomLanguage != selectedLanguageCode{
                    LanguageSelectionManager.shared.isBottomLanguageChanged = true
                    LanguageSelectionManager.shared.bottomLanguage = selectedLanguageCode
                    self.languageHasUpdated?()
                }
            }else{
                if LanguageSelectionManager.shared.topLanguage != selectedLanguageCode{
                    LanguageSelectionManager.shared.isTopLanguageChanged = true
                    LanguageSelectionManager.shared.topLanguage = selectedLanguageCode
                    self.languageHasUpdated?()
                }
            }
            let entity = LanguageSelectionEntity(id: 0, textLanguageCode: selectedLanguageCode, cameraOrVoice: LanguageType.voice.rawValue)
            _ = LanguageSelectionManager.shared.insertIntoDb(entity: entity)
            //btnBack.setTitleColor(._skyBlueColor(), for: .selected)
            NotificationCenter.default.post(name: .languageSelectionVoiceNotification, object: nil)
        }

        if fromRetranslation == true {
            self.retranslationDelegate?.showRetranslation(selectedLanguage: selectedLanguageCode)
            self.remove(asChildViewController: self)
        }else{
            NotificationCenter.default.post(name: .containerViewSelection, object: nil)
        }

    }

}


    extension LangSelectVoiceVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        // return ViewController when go forward
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            let vc = pageViewController.viewControllers?.first
            var index: Int
            index = getVCPageIndex(vc)
            // Don't do anything when viewpager reach the number of tabs
            if index == 1 {
                return nil
            } else {
                index += 1
                return self.showViewController(index)
            }
        }

        // return ViewController when go backward
        func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            let vc = pageViewController.viewControllers?.first
            var index: Int
            index = getVCPageIndex(vc)

            if index == 0 {
                return nil
            } else {
                index -= 1
                return self.showViewController(index)
            }
        }

        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if finished {
                if completed {
                    guard let vc = pageViewController.viewControllers?.first else { return }
                    let index: Int

                    index = getVCPageIndex(vc)

                    updateButton(index: index)
                }
            }
        }

        // Return the current position that is saved in the UIViewControllers we have in the UIPageViewController
        func getVCPageIndex(_ viewController: UIViewController?) -> Int {
            switch viewController {
            case is LanguageListVC:
                let vc = viewController as! LanguageListVC
                return vc.pageIndex
            case is HistoryListVC:
                let vc = viewController as! HistoryListVC
                return vc.pageIndex
            default:
                let vc = viewController as! LanguageListVC
                return vc.pageIndex
            }
        }
    }

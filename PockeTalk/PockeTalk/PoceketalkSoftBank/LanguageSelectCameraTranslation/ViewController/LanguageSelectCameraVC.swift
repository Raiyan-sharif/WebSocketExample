//
//  LanguageSelectCameraVC.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 10/9/21.
//

import UIKit

class LanguageSelectCameraVC: BaseViewController {
    let TAG = "\(LanguageSelectCameraVC.self)"
    @IBOutlet weak var tabsView: UIView!
    @IBOutlet weak var btnHistoryList: UIButton!
    @IBOutlet weak var btnLangList: UIButton!
    @IBOutlet weak var layoutBottomBtnContainer: UIView!
    var currentIndex: Int = 0
    let tabsPageViewController = "TabsPageViewController"

    let iconGlobalSelect = "icon_language_global_select.png"
    let iconGlobalUnSelect = "icon_language_global_unselect.png"
    let iconHistorySelect = "icon_language_history_select.png"
    let iconHistoryUnSelect = "icon_language_history_unselect.png"
    var mLanguageFile = "conversation_languages_en"
    var pageController: UIPageViewController!
    let langListArray:NSMutableArray = NSMutableArray()
    var selectedLanguageCode = ""
    let width : CGFloat = 50
    let speechButtonWidth : CGFloat = 100
    let trailing : CGFloat = -20
    let toastVisibleTime : Double = 2.0

    @IBOutlet weak var toolbarTitleLabel: UILabel!

    @IBAction func onLangSelectButton(_ sender: Any) {
        updateButton(index: 0)
        tabsViewDidSelectItemAt(position: 0)
    }

    @IBAction func onHistoryButtonTapped(_ sender: Any) {
        updateButton(index: 1)
        tabsViewDidSelectItemAt(position: 1)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonTopCornerRadius(btnLangList)
        setButtonTopCornerRadius(btnHistoryList)
        toolbarTitleLabel.text = "Language".localiz()
        updateButton(index:0)
        setupPageViewController()
        setUpMicroPhoneIcon()
        setUpSpeechButton()
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

    func setUpSpeechButton(){
        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.layoutBottomBtnContainer, width: speechButtonWidth, height: speechButtonWidth)
        talkButton.addTarget(self, action: #selector(speechButtonTapAction(sender:)), for: .touchUpInside)
    }

    // TODO microphone tap event
    @objc func speechButtonTapAction (sender:UIButton) {
        if Reachability.isConnectedToNetwork() {
            RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
                if isGranted {
                    let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
                    controller.homeMicTapTimeStamp = currentTS
                    controller.screenOpeningPurpose = SpeechProcessingScreenOpeningPurpose.LanguageSelectionCamera
                    self.navigationController?.pushViewController(controller, animated: true);
                } else {
                    GlobalMethod.showAlert(title: kMicrophoneUsageTitle, message: kMicrophoneUsageMessage, in: self) {
                        GlobalMethod.openSettingsApplication()
                    }
                }
            }
        } else {
            GlobalMethod.showNoInternetAlert()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Refresh CollectionView Layout when you rotate the device
//            tabsView.collectionView.collectionViewLayout.invalidateLayout()
    }

    func updateButton(index:Int){
        PrintUtility.printLog(tag: TAG , text: "Index position \(index)")
        if index == 0{
            btnLangList.backgroundColor = .black
            btnHistoryList.backgroundColor = .gray
            btnLangList.setImage(UIImage(named: iconGlobalSelect), for: UIControl.State.normal)
            btnHistoryList.setImage(UIImage(named: iconHistoryUnSelect), for: UIControl.State.normal)
        }else{
            btnLangList.backgroundColor = .gray
            btnHistoryList.backgroundColor = .black
            btnLangList.setImage(UIImage(named: iconGlobalUnSelect), for: UIControl.State.normal)
            btnHistoryList.setImage(UIImage(named: iconHistorySelect), for: UIControl.State.normal)
        }
    }

    func tabsViewDidSelectItemAt(position: Int) {

        PrintUtility.printLog(tag: TAG , text: "current-index \(currentIndex) position \(position)")
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
            let contentVC = storyboard?.instantiateViewController(withIdentifier:KLanguageListCamera) as! LanguageListCameraVC
            contentVC.pageIndex = index
            return contentVC
        } else if index == 1 {
            let contentVC = storyboard?.instantiateViewController(withIdentifier: KHistoryListCamera) as! LanguageHistoryListCameraVC
                //contentVC.name = tabsView.tabs[index].title
            contentVC.pageIndex = index
            return contentVC
        }else {
            let contentVC = storyboard?.instantiateViewController(withIdentifier: KLanguageListCamera) as! LanguageListCameraVC
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


    @IBAction func onBackButtonPressed(_ sender: Any) {
        selectedLanguageCode = UserDefaultsProperty<String>(KSelectedLanguageCamera).value!
        let langSelectFor = UserDefaultsProperty<Bool>(KCameraLanguageFrom).value
        PrintUtility.printLog(tag: TAG , text: " isnativeval \(langSelectFor)")
        if langSelectFor! {
            if isLanguageSupportRecognition(code: selectedLanguageCode){
                PrintUtility.printLog(tag: TAG, text: "code \(selectedLanguageCode) has recognition support")
                CameraLanguageSelectionViewModel.shared.fromLanguage = selectedLanguageCode
            }
        }else{
            CameraLanguageSelectionViewModel.shared.targetLanguage = selectedLanguageCode
        }
        let entity = LanguageSelectionEntity(id: 0, textLanguageCode: selectedLanguageCode, cameraOrVoice: LanguageType.camera.rawValue)
        CameraLanguageSelectionViewModel.shared.insertIntoDb(entity: entity)
        NotificationCenter.default.post(name: .languageSelectionCameraNotification, object: nil)
        self.navigationController?.popViewController(animated: true)
    }

    func isLanguageSupportRecognition(code: String?) -> Bool{
        let recogLangList = CameraLanguageSelectionViewModel.shared.getFromLanguageLanguageList()
        for item in recogLangList{
            if code == item.code{
                return true
            }
        }
        return false
    }
}


    extension LanguageSelectCameraVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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
//                    tabsView.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: true, scrollPosition: .centeredVertically)
                    // Animate the tab in the TabsView to be centered when you are scrolling using .scrollable
//                    tabsView.collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
                }
            }
        }

        // Return the current position that is saved in the UIViewControllers we have in the UIPageViewController
        func getVCPageIndex(_ viewController: UIViewController?) -> Int {
            switch viewController {
            case is LanguageListVC:
                let vc = viewController as! LanguageListCameraVC
                return vc.pageIndex
            case is HistoryListVC:
                let vc = viewController as! LanguageHistoryListCameraVC
                return vc.pageIndex
            default:
                let vc = viewController as! LanguageListCameraVC
                return vc.pageIndex
            }
        }
    }

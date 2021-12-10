//
//  LanguageSelectCameraVC.swift
//  PockeTalk
//

import UIKit

class LanguageSelectCameraVC: BaseViewController {
    @IBOutlet weak private var tabsView: UIView!
    @IBOutlet weak private var btnHistoryList: UIButton!
    @IBOutlet weak private var btnLangList: UIButton!
    @IBOutlet weak private var back_btn: UIButton!
    @IBOutlet weak private var toolbarTitleLabel: UILabel!
    
    let TAG = "\(LanguageSelectCameraVC.self)"
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
    var updateHomeContainer:(()->())?
    let window :UIWindow = UIApplication.shared.keyWindow!
    var isFirstTimeLoad = true
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonTopCornerRadius(btnLangList)
        setButtonTopCornerRadius(btnHistoryList)
        navigationViewCustomization()
        updateButton(index:0)
        setupPageViewController()
        registerNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // TODO: Remove micrphone functionality as per current requirement. Will modify after final confirmation.
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
    private func navigationViewCustomization(){
        toolbarTitleLabel.text = "Language".localiz()
        toolbarTitleLabel.textColor = UIColor.white
        
        back_btn.setTitleColor(UIColor.white, for: .selected)
        back_btn.setImage(UIImage(named: "icon_arrow_left.9"), for: .selected)
    }
    
    private func setButtonTopCornerRadius(_ button: UIButton){
        if #available(iOS 11.0, *) {
            button.layer.cornerRadius = 8
            button.layer.masksToBounds = true
            button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
    }
    
    private func setupPageViewController() {
        self.pageController = storyboard?.instantiateViewController(withIdentifier: tabsPageViewController) as! TabsPageViewController
        self.addChild(self.pageController)
        self.view.addSubview(self.pageController.view)
        
        pageController.delegate = self
        pageController.dataSource = self
        pageController.setViewControllers([showViewController(0)!], direction: .forward, animated: true, completion: nil)
        
        self.pageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.pageController.view.topAnchor.constraint(equalTo: self.tabsView.bottomAnchor),
            self.pageController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pageController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pageController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        self.pageController.didMove(toParent: self)
    }
    
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(hideMicrophoneButton(notification:)), name:.tapOnMicrophoneCountrySelectionVoiceCamera, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.showMicrophoneButton(notification:)), name: .tapOffMicrophoneCountrySelectionVoiceCamera, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCameralanguageSelection(notification:)), name: .cameraHistorySelectionLanguage, object: nil)
    }
    
    // TODO: Remove micrphone functionality as per current requirement. Will modify after final confirmation.
    /*
     func setUpMicroPhoneIcon () {
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
     floatingButton.tag = languageSelectVoiceCameraFloatingBtnTag
     self.window.addSubview(floatingButton)
     
     floatingButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
     }
     */
    
    //MARK: - IBActions
    @IBAction func onLangSelectButton(_ sender: Any) {
        isFirstTimeLoad = false
        updateButton(index: 0)
        tabsViewDidSelectItemAt(position: 0)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionCamera
    }
    
    @IBAction func onHistoryButtonTapped(_ sender: Any) {
        isFirstTimeLoad = false
        updateButton(index: 1)
        tabsViewDidSelectItemAt(position: 1)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageHistorySelectionCamera
    }
    
    @IBAction func onBackButtonPressed(_ sender: Any) {
        selectedLanguageCode = UserDefaultsProperty<String>(KSelectedLanguageCamera).value!
        let langSelectFor = UserDefaultsProperty<Bool>(KCameraLanguageFrom).value
        PrintUtility.printLog(tag: TAG , text: " isnativeval \(String(describing: langSelectFor))")
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
        self.updateHomeContainer?()
        remove(asChildViewController: self)
    }
    
    // TODO: Remove micrphone functionality as per current requirement. Will modify after final confirmation.
    /*
     @objc func microphoneTapAction (sender:UIButton) {
     LnaguageSettingsTutorialCameraVC.openShowViewController(navigationController: self.navigationController)
     //self.showToast(message: "Navigate to Speech Controller", seconds: toastVisibleTime)
     }
     */
    
    //MARK: - Utils
    @objc func hideMicrophoneButton(notification: Notification) {
        //removeFloatingBtn()
    }
    
    @objc func showMicrophoneButton(notification: Notification) {
        //setUpMicroPhoneIcon()
    }
    
    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name:.tapOnMicrophoneCountrySelectionVoiceCamera, object: nil)
        NotificationCenter.default.removeObserver(self, name: .tapOffMicrophoneCountrySelectionVoiceCamera, object: nil)
        NotificationCenter.default.removeObserver(self, name: .cameraHistorySelectionLanguage, object: nil)
    }
    
    @objc func updateCameralanguageSelection (notification:Notification) {
        self.isFirstTimeLoad = false
        updateButton(index: 0)
        tabsViewDidSelectItemAt(position: 0)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionCamera
    }
    
    // TODO: Remove micrphone functionality as per current requirement. Will modify after final confirmation.
    /*
     private func removeFloatingBtn(){
     window.viewWithTag(languageSelectVoiceCameraFloatingBtnTag)?.removeFromSuperview()
     }
     */
    
    private func updateButton(index:Int){
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
    
    private func tabsViewDidSelectItemAt(position: Int) {
        if position != currentIndex {
            if position > currentIndex {
                self.pageController.setViewControllers([showViewController(position)!], direction: .forward, animated: true, completion: nil)
            } else {
                self.pageController.setViewControllers([showViewController(position)!], direction: .reverse, animated: true, completion: nil)
            }
        }
    }
    
    private func showViewController(_ index: Int) -> UIViewController? {
        currentIndex = index
        if index == 0 {
            let contentVC = storyboard?.instantiateViewController(withIdentifier:KLanguageListCamera) as! LanguageListCameraVC
            contentVC.pageIndex = index
            contentVC.isFirstTimeLoad = self.isFirstTimeLoad
            return contentVC
        } else if index == 1 {
            let contentVC = storyboard?.instantiateViewController(withIdentifier: KHistoryListCamera) as! LanguageHistoryListCameraVC
            contentVC.pageIndex = index
            return contentVC
        }else {
            let contentVC = storyboard?.instantiateViewController(withIdentifier: KLanguageListCamera) as! LanguageListCameraVC
            contentVC.pageIndex = index
            contentVC.isFirstTimeLoad = self.isFirstTimeLoad
            return contentVC
        }
    }
    
    private func isLanguageSupportRecognition(code: String?) -> Bool{
        let recogLangList = CameraLanguageSelectionViewModel.shared.getFromLanguageLanguageList()
        for item in recogLangList{
            if code == item.code{
                return true
            }
        }
        return false
    }
}

//MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
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
            }
        }
    }
    
    // Return the current position that is saved in the UIViewControllers we have in the UIPageViewController
    func getVCPageIndex(_ viewController: UIViewController?) -> Int {
        switch viewController {
        case is LanguageListCameraVC:
            let vc = viewController as! LanguageListCameraVC
            return vc.pageIndex
        case is LanguageHistoryListCameraVC:
            let vc = viewController as! LanguageHistoryListCameraVC
            return vc.pageIndex
        default:
            let vc = viewController as! LanguageListCameraVC
            return vc.pageIndex
        }
    }
}

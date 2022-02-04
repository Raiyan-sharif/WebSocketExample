//
//  LanguageSelectCameraVC.swift
//  PockeTalk
//

import UIKit
import AVFoundation

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
    let window :UIWindow = UIApplication.shared.keyWindow!
    var isFirstTimeLoad = true
    private var floatingMicrophoneButton: UIButton!
    var talkButtonImageView: UIImageView!
    var activeCamera: AVCaptureDevice?
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        talkButtonImageView = window.viewWithTag(109) as? UIImageView
        setButtonTopCornerRadius(btnLangList)
        setButtonTopCornerRadius(btnHistoryList)
        navigationViewCustomization()
        updateButton(index:0)
        setupPageViewController()
        registerNotification()
        self.view.bottomImageView(usingState: .gradient)
        FloatingMikeButton.sharedInstance.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + kScreenTransitionTime / 2) {
            if FloatingMikeButton.sharedInstance.hiddenStatus() == true{
                FloatingMikeButton.sharedInstance.isHidden(false)
            }
        }
    }
    
    deinit {
        unregisterNotification()
        talkButtonImageView.isHidden = true
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateCameralanguageSelection(notification:)), name: .cameraHistorySelectionLanguage, object: nil)
    }
    
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
        CameraViewController().turnOnCameraFlash()
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
        let transation = GlobalMethod.addMoveOutTransitionAnimatation(duration: kFadeAnimationTransitionTime, animationStyle: .fromRight)
        remove(asChildViewController: self, animation: transation)
        microphoneIcon(isHidden: true)
    }
    
    //MARK: - View Transactions
    private func navigateToLanguageScene(){
        let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromTop)
        let controller = UIStoryboard(name: "LanguageSelectCamera", bundle: nil).instantiateViewController(withIdentifier: "LnaguageSettingsTutorialCameraVC")as! LnaguageSettingsTutorialCameraVC
        controller.delegate = self
        add(asChildViewController: controller, containerView: self.view, animation: transition)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSettingsSelectionCamera
    }
    
    //MARK: - Utils
    @objc func showMicrophoneButton(notification: Notification) {
        microphoneIcon(isHidden: false)
    }
    
    private func microphoneIcon(isHidden: Bool){
        FloatingMikeButton.sharedInstance.isHidden(isHidden)
    }
    
    private func updateUI(){
        self.isFirstTimeLoad = false
        updateButton(index: 0)
        tabsViewDidSelectItemAt(position: 0)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionCamera
    }
    
    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name: .cameraHistorySelectionLanguage, object: nil)
    }
    
    @objc func updateCameralanguageSelection (notification:Notification) {
        self.isFirstTimeLoad = false
        updateButton(index: 0)
        tabsViewDidSelectItemAt(position: 0)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionCamera
    }
    
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

//MARK: - LanguageSelectCameraVC
extension LanguageSelectCameraVC: LnaguageSettingsTutorialCameraProtocol{
    func updateLanguageByVoice() {
        microphoneIcon(isHidden: false)
        updateUI()
    }
}

//MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension LanguageSelectCameraVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = pageViewController.viewControllers?.first
        var index: Int
        index = getVCPageIndex(vc)

        if index == 1 {
            return nil
        } else {
            index += 1
            return self.showViewController(index)
        }
    }
    
  
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

//MARK: - FloatingMikeButtonDelegate
extension LanguageSelectCameraVC: FloatingMikeButtonDelegate{
    func didTapOnMicrophoneButton() {
        PrintUtility.printLog(tag: TAG, text: "Language select voice camera Tap")
        if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionCamera ||
            ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionCamera {
            microphoneIcon(isHidden: true)
            if FloatingMikeButton.sharedInstance.hiddenStatus() {
                navigateToLanguageScene()
            }
        }
    }
}

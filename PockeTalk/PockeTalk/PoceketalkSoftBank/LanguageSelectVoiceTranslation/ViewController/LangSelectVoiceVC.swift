//
//  LangSelectVoiceVC.swift
//  PockeTalk
//

import UIKit
import SwiftyXMLParser

protocol RetranslationDelegate: AnyObject {
    func showRetranslation (selectedLanguage : String, fromScreenPurpose: SpeechProcessingScreenOpeningPurpose)
}

class LangSelectVoiceVC: BaseViewController {
    @IBOutlet weak private var tabsView: UIView!
    @IBOutlet weak private var btnHistoryList: UIButton!
    @IBOutlet weak private var btnLangList: UIButton!
    @IBOutlet weak private var btnBack: UIButton!
    @IBOutlet weak private var toolbarTitleLabel: UILabel!
    
    let TAG = "\(LangSelectVoiceVC.self)"
    var languageHasUpdated:(()->())?
    var updateHomeContainer:((_ isfullScreen:Bool)->())?

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
    var langugeListVC: LanguageListVC!
    var languageHistoryListVC: HistoryListVC!
    
    var isNative: Int = 0
    let trailing : CGFloat = -20
    let width : CGFloat = 100
    let widthMicrophone : CGFloat = 50
    let toastVisibleTime : Double = 2.0
    /// retranslation delegate
    var retranslationDelegate : RetranslationDelegate?
    let window :UIWindow = UIApplication.shared.keyWindow!

    /// check if navigation from Retranslation
    var fromRetranslation : Bool = false
    var isFirstTimeLoad = true
    var fromScreenPurpose: SpeechProcessingScreenOpeningPurpose = .HomeSpeechProcessing
    private var floatingMicrophoneButton: UIButton!
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPageViewController()
        registerNotification()
        self.view.bottomImageView(usingState: .gradient)
        FloatingMikeButton.sharedInstance.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateHomeContainer?(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + kScreenTransitionTime / 2) {
            if FloatingMikeButton.sharedInstance.hiddenStatus() == true{
                FloatingMikeButton.sharedInstance.isHidden(false)
            }
        }
    }
    
    deinit {
        self.updateHomeContainer?(false)
        unregisterNotification()
    }
    
    //MARK: - Initial setup
    private func setupUI(){
        UserDefaultsProperty<Int>(kIsNative).value = isNative
        setButtonTopCornerRadius(btnLangList)
        setButtonTopCornerRadius(btnHistoryList)
        toolbarTitleLabel.text = "Language".localiz()
        toolbarTitleLabel.textColor = UIColor.white
        updateButton(index:0)
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.showMicrophoneButton(notification:)), name: .popFromCountrySelectionVoice, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(removeChild(notification:)), name:.updateTranlationNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLanguageSelection(notification:)), name: .languageHistoryListNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePointLanguageSelection(notification:)), name: .talkButtonContainerSelectionPoint, object: nil)
    }
    
    //MARK: - LanguageListVC Notification for Point
    @objc func updatePointLanguageSelection(notification: Notification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let point = dict["point"] as? CGPoint{
                print(point)
                if(ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice){
                    let gap = SIZE_HEIGHT - langugeListVC.langListTableView.bounds.height
                    let newPoint = CGPoint(x: point.x,y: point.y - gap + langugeListVC.langListTableView.contentOffset.y)
                    if  let newIndexPath = langugeListVC.langListTableView.indexPathForRow(at: newPoint){
                        langugeListVC.tableView(langugeListVC.langListTableView, didSelectRowAt: newIndexPath)
                    }
                }
                else if(ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionVoice){
                    let gap = SIZE_HEIGHT - languageHistoryListVC.historyListTableView.bounds.height
                    let newPoint = CGPoint(x: point.x,y: point.y - gap + languageHistoryListVC.historyListTableView.contentOffset.y)
                    if  let newIndexPath = languageHistoryListVC.historyListTableView.indexPathForRow(at: newPoint){
                        languageHistoryListVC.tableView(languageHistoryListVC.historyListTableView, didSelectRowAt: newIndexPath)
                    }
                }
            }
        }
    }

    //MARK: - IBActions
    @IBAction func onLangSelectButton(_ sender: Any) {
        isFirstTimeLoad = false
        updateButton(index: 0)
        tabsViewDidSelectItemAt(position: 0)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionVoice
    }

    @IBAction func onHistoryButtonTapped(_ sender: Any) {
        isFirstTimeLoad = false
        updateButton(index: 1)
        tabsViewDidSelectItemAt(position: 1)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageHistorySelectionVoice
    }

    @IBAction func onCountryButtonTapped(_ sender: Any) {
        if FloatingMikeButton.sharedInstance.hiddenStatus() == false{
            navigateToCountryScene()
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
            NotificationCenter.default.post(name: .languageSelectionVoiceNotification, object: nil)
        }

        if fromRetranslation == true {
            let entity = LanguageSelectionEntity(id: 0, textLanguageCode: selectedLanguageCode, cameraOrVoice: LanguageType.voice.rawValue)
            _ = LanguageSelectionManager.shared.insertIntoDb(entity: entity)
            
            self.retranslationDelegate?.showRetranslation(
                selectedLanguage: selectedLanguageCode,
                fromScreenPurpose: fromScreenPurpose)
            
            self.remove(asChildViewController: self)
        }else{
            NotificationCenter.default.post(name: .containerViewSelection, object: nil)
        }
        microphoneIcon(isHidden: true)
    }
    
    //MARK: - View Transactions
    func showViewController(_ index: Int) -> UIViewController? {
        currentIndex = index
        if index == 0 {
            let contentVC = storyboard?.instantiateViewController(withIdentifier:tagLanguageListVC) as! LanguageListVC
            contentVC.pageIndex = index
            contentVC.tabsHeight = tabsView.bounds.height
            contentVC.isFirstTimeLoad = self.isFirstTimeLoad
            langugeListVC = contentVC
            return contentVC
        } else if index == 1 {
            let contentVC = storyboard?.instantiateViewController(withIdentifier: tagHistoryListVC) as! HistoryListVC
            contentVC.pageIndex = index
            languageHistoryListVC = contentVC
            return contentVC
        }else {
            let contentVC = storyboard?.instantiateViewController(withIdentifier: tagLanguageListVC) as! LanguageListVC
            contentVC.tabsHeight = tabsView.bounds.height
            contentVC.pageIndex = index
            contentVC.isFirstTimeLoad = self.isFirstTimeLoad
            langugeListVC = contentVC
            return contentVC
        }
    }
    
    private func navigateToCountryScene(){
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "CountryListViewController")as! CountryListViewController
        controller.isFromTranslation = fromRetranslation
        controller.isNative = isNative
        
        let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
        add(asChildViewController: controller, containerView: view, animation: transition)
        ScreenTracker.sharedInstance.screenPurpose = .CountrySelectionByVoice
    }
    
    private func navigateToLanguageSettingsScene(){
        let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromTop)
        let vc = UIStoryboard(name: "LanguageSelectVoice", bundle: nil).instantiateViewController(withIdentifier: "LanguageSettingsTutorialVC")as! LanguageSettingsTutorialVC
        vc.delegate = self
        vc.isFromLanguageScene = true
        add(asChildViewController: vc, containerView: self.view, animation: transition)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSettingsSelectionVoice
    }

    //MARK: - Utils
    @objc func showMicrophoneButton(notification: Notification) {
        FloatingMikeButton.sharedInstance.add()
        FloatingMikeButton.sharedInstance.delegate = self
    }
    
    @objc func updateLanguageSelection(notification: Notification) {
        updateUI()
    }
    
    private func microphoneIcon(isHidden: Bool){
        FloatingMikeButton.sharedInstance.isHidden(isHidden)
    }
    
    private func updateUI(){
        self.isFirstTimeLoad = false
        updateButton(index: 0)
        tabsViewDidSelectItemAt(position: 0)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionVoice
    }

    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name: .popFromCountrySelectionVoice, object: nil)
        NotificationCenter.default.removeObserver(self, name: .updateTranlationNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .languageListNotofication, object: nil)
        NotificationCenter.default.removeObserver(self, name: .talkButtonContainerSelectionPoint, object: nil)
    }
    
    @objc private func removeChild(notification: Notification) {
        selectedLanguageCode = UserDefaultsProperty<String>(KSelectedCountryLanguageVoice).value!
        self.retranslationDelegate?.showRetranslation(
            selectedLanguage: selectedLanguageCode,
            fromScreenPurpose: fromScreenPurpose)
        self.remove(asChildViewController: self)
    }
    
    private func updateButton(index:Int){
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

    private func tabsViewDidSelectItemAt(position: Int) {
        if position != currentIndex {
            if position > currentIndex {
                self.pageController.setViewControllers([showViewController(position)!], direction: .forward, animated: true, completion: nil)
            } else {
                self.pageController.setViewControllers([showViewController(position)!], direction: .reverse, animated: true, completion: nil)
            }
        }
    }
}

//MARK: - LanguageSettingsProtocol
extension LangSelectVoiceVC: LanguageSettingsTutorialProtocol{
    func updateLanguageByVoice() {
        microphoneIcon(isHidden: false)
        updateUI()
    }
}

//MARK: - UIPageViewControllerDataSource, UIPageViewControllerDelegate
extension LangSelectVoiceVC: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
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

//MARK: - FloatingMikeButtonDelegate
extension LangSelectVoiceVC: FloatingMikeButtonDelegate{
    func didTapOnMicrophoneButton() {
        PrintUtility.printLog(tag: TAG, text: "Language select voice microphone Tap")
        if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice ||
            ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionVoice {
            microphoneIcon(isHidden: true)
            if FloatingMikeButton.sharedInstance.hiddenStatus() {
                navigateToLanguageSettingsScene()
            }
        }
    }
}

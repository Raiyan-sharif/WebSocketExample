//
//  HomeViewController.swift
//  PockeTalk
//

import UIKit
import SwiftRichString

class HomeViewController: BaseViewController {
    @IBOutlet weak private var bottomLangSysLangName: UIButton!
    @IBOutlet weak private var languageChangedDirectionButton: UIButton!
    @IBOutlet weak private var topNativeLangNameLable: UIButton!
    @IBOutlet weak private var bottomFlipImageView: UIImageView!
    @IBOutlet weak private var topFlipImageView: UIImageView!
    @IBOutlet weak private var menuButton: UIButton!
    @IBOutlet weak private var topSysLangName: UILabel!
    @IBOutlet weak private var bottomLangNativeName: UILabel!
    @IBOutlet weak private var topCircleImgView: UIImageView!
    @IBOutlet weak private var bottomCircleleImgView: UIImageView!
    @IBOutlet weak private var topClickView: UIView!
    @IBOutlet weak private var bottomClickView: UIView!
    @IBOutlet weak  var bottomView: UIView!
    @IBOutlet weak private var buttonFav: UIButton!
    @IBOutlet weak var historyImageView: UIImageView!
    @IBOutlet weak var bottomImageViewOfAnimation: UIImageView!
    static var bottomViewRef: UIView!
    static var bottomImageViewOfAnimationRef: UIImageView!
    static var cameraTapFlag = 0
    let talkBtnImgView = UIImageView()
    
    let TAG = "\(HomeViewController.self)"
    private var homeVM : HomeViewModeling!
    let pulseLayer = CAShapeLayer()
    let pulseGrayWave: UIView = UIView(frame: CGRect(x: 50, y:  50, width: 100, height: 100))
    let midCircleViewOfPulse: UIView = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))
    let bottomImageView: UIImageView = UIImageView()
    private var animationCounter : Int = 0
    private var deviceLanguage : String = ""
    private let toastVisibleTime : Double = 2.0
    private let animationDuration : TimeInterval = 0.1
    let width : CGFloat = 100
    private var selectedTab = 0
    private var historyItemCount = 0
    private var favouriteItemCount = 0;
    var imageViewPanGesture: UIPanGestureRecognizer!
    var viewPanGesture: UIPanGestureRecognizer!
    private var selectedTouchView:UIView!
    let waitingTimeToShowSpeechProcessingFromHome : Double = 0.4
    let fadeAnimationDuration: TimeInterval = 0.1
    let fadeAnimationDelay: TimeInterval = 0.2
    let fadeOutAlpha: CGFloat = 0.0
    
    weak var homeVCDelegate: HomeVCDelegate?
    var isFromCameraPreview: Bool = false
    
    ///HistoryCardVC properties
    enum CardState {
        case expanded
        case collapsed
    }
    
    var historyCardVC: HistoryCardViewController!
    var cardHeight:CGFloat = 0
    var cardVisible = false
    let historyCardAnimationDuration = 0.5
    
    var nextState:CardState {
        return cardVisible ? .collapsed : .expanded
    }
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    lazy var homeContainerView:UIView = {
        let view  = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.zPosition = 100
        view.backgroundColor = .black
        return view
    }()
    
    lazy var speechContainerView:UIView = {
        let view  = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.zPosition = 101
        return view
    }()
    
    lazy var speechVC:SpeechProcessingViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let speechVC = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
        homeVCDelegate = speechVC
        return speechVC
    }()
    
    private lazy var statusBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    static var homeContainerViewBottomConstraint:NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bottomView.layer.zPosition = 103
        bottomView.backgroundColor = .clear
        view.backgroundColor = .clear
        registerNotification()
        self.homeVM = HomeViewModel()
        self.setUpUI()
        setLanguageDirection()
        
        cardHeight = (self.view.bounds.height / 4) * 3
        setupGestureForCardView()
        setupCardView()
        setupStatusBarView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.changeFontSize()
        self.topNativeLangNameLable.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getBiggestFontSize(), weight: .bold)
        self.bottomLangSysLangName.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())
        self.topSysLangName.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())
        self.bottomLangNativeName.font = UIFont.systemFont(ofSize: FontUtility.getBiggestFontSize(), weight: .bold)
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isHidden = true
        setHistoryAndFavouriteView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateLanguageNames()
    }
    
    deinit {
        unregisterNotification()
    }
    
    //MARK: - Initial Setup
    private func setUpUI () {
        navigationController?.navigationBar.barTintColor = UIColor.black
        tabBarController?.tabBar.tintColor = UIColor.white
        tabBarController?.tabBar.barTintColor = UIColor.white
        
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = UIColor.white
        
        if !UserDefaultsUtility.getBoolValue(forKey: kUserDefaultIsTutorialDisplayed) {
            UserDefaultsUtility.setBoolValue(true, forKey: kUserDefaultIsTutorialDisplayed)
            self.dislayTutorialScreen(shwoingTutorialForTheFirstTime: true)
        }
        
        if let lanCode = self.homeVM.getLanguageName() {
            self.deviceLanguage = lanCode
        }
        
        self.topNativeLangNameLable.titleLabel?.textAlignment = .center
        self.topNativeLangNameLable.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getBiggerFontSize(), weight: .bold)
        self.topNativeLangNameLable.setTitleColor(UIColor._whiteColor(), for: .normal)
        
        self.topSysLangName.textAlignment = .center
        self.topSysLangName.textColor = UIColor._whiteColor()
        
        self.bottomLangSysLangName.titleLabel?.textAlignment = .center
        self.bottomLangSysLangName.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getBiggerFontSize(), weight: .bold)
        self.bottomLangSysLangName.setTitleColor(UIColor._whiteColor(), for: .normal)
        
        ///Hide Circle Imageview at first
        self.topCircleImgView.isHidden = true
        self.bottomCircleleImgView.isHidden = true
        
        view.addSubview(homeContainerView)
        view.addSubview(speechContainerView)
        
        homeContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        homeContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        homeContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //homeContainerView.bottomAnchor.constraint(equalTo:self.bottomView.topAnchor).isActive = true
        HomeViewController.homeContainerViewBottomConstraint = homeContainerView.bottomAnchor.constraint(equalTo:self.bottomView.topAnchor, constant: 0)
        HomeViewController.homeContainerViewBottomConstraint.isActive = true
        
        speechContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        speechContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        speechContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        speechContainerView.bottomAnchor.constraint(equalTo:self.bottomView.topAnchor).isActive = true
        
        
        
        setUPLongPressGesture()
        addSpeechProcessingVC()
        addTalkButtonAnimationViews()
    }
    
    private func setHistoryAndFavouriteView(){
        historyItemCount =  homeVM.getHistoryItemCount()
        favouriteItemCount = homeVM.getFavouriteItemCount()
        updateHistoryViews()
        updateFavouriteViews()
    }
    
    private func setupStatusBarView() {
        self.view.addSubview(statusBarView)
        statusBarView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        statusBarView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        statusBarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        statusBarView.heightAnchor.constraint(equalToConstant: UIApplication.shared.statusBarFrame.height).isActive = true
    }
    
    func addTalkButtonAnimationViews(){
        self.bottomView.addSubview(pulseGrayWave)
        self.bottomView.layer.addSublayer(pulseLayer)
        self.bottomView.addSubview(midCircleViewOfPulse)
    }
    
    func addSpeechProcessingVC(){
        add(asChildViewController: speechVC, containerView:speechContainerView, animation: nil)
        hideSpeechView()
        homeGestureEnableOrDiable()
    }
    
    func updateHistoryViews(){
        if(historyItemCount>0){
            historyImageView.isHidden = false
            imageViewPanGesture.isEnabled = true
            viewPanGesture.isEnabled = true
        }else{
            historyImageView.isHidden = true
            imageViewPanGesture.isEnabled = false
            viewPanGesture.isEnabled = false
        }
    }
    
    private func updateFavouriteViews(){
        if( self.favouriteItemCount > 0 ){
            self.buttonFav.isHidden = false
        }else{
            self.buttonFav.isHidden = true
        }
    }
    
    private func registerNotification(){
        HomeViewController.bottomViewRef = self.bottomView
        HomeViewController.bottomImageViewOfAnimationRef = self.bottomImageViewOfAnimation
        NotificationCenter.default.addObserver(self, selector: #selector(updateContainer(notification:)), name:.containerViewSelection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(animationDidEnterBackground(notification:)), name: .animationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.onVoiceLanguageChanged(notification:)), name: .languageSelectionVoiceNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onArrowChanged(notification:)), name: .languageSelectionArrowNotification, object: nil)
    }
    
    //MARK: - IBActions
    @IBAction private func menuAction(_ sender: UIButton) {
        let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: nil)
        if let settinsViewController = settingsStoryBoard.instantiateViewController(withIdentifier: String(describing: SettingsViewController.self)) as? SettingsViewController {
            let transition = CATransition()
            transition.duration = kSettingsScreenTransitionDuration
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(settinsViewController, animated: false)
        }
    }
    
    @IBAction private func switchLanguageDirectionAction(_ sender: UIButton) {
        PrintUtility.printLog(tag: TAG, text: "switchLanguageDirectionAction isArrowUp \(LanguageSelectionManager.shared.isArrowUp)")
        if LanguageSelectionManager.shared.isArrowUp{
            LanguageSelectionManager.shared.isArrowUp = false
        }else{
            LanguageSelectionManager.shared.isArrowUp = true
        }
        setLanguageDirection()
    }
    
    @IBAction private func topLanguageBtnAction(_ sender: UIButton) {
        openLanguageSelectionScreen(isNative: LanguageName.topLang.rawValue)
    }
    
    @IBAction private func bottomLanguageBtnAction(_ sender: UIButton) {
        openLanguageSelectionScreen(isNative: LanguageName.bottomLang.rawValue)
    }
    
    
    
    @IBAction private func didTapOnFavoriteButton(_ sender: UIButton) {
        self.goToFavouriteScreen()
    }
    
    //MARK: - View Transactions
    private func dislayTutorialScreen(shwoingTutorialForTheFirstTime: Bool) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTutorialViewController)as! TutorialViewController
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        navController.modalTransitionStyle = .crossDissolve
        navController.navigationBar.isHidden = true
        controller.navController = navController
        controller.speechProDismissDelegateFromTutorial = self
        
        controller.isShwoingTutorialForTheFirstTime = shwoingTutorialForTheFirstTime
        if shwoingTutorialForTheFirstTime {
            controller.dismissTutorialDelegate = self
        } else {
            controller.dismissTutorialDelegate = nil
        }
        
        add(asChildViewController: controller, containerView:homeContainerView)
    }
    
    //TODO: Show history scene as swipe action. Will remove after new implementation merge.
    /*
     @objc func goToHistoryScreen () {
     let historyVC = HistoryViewController()
     add(asChildViewController: historyVC, containerView:homeContainerView, animation: nil)
     hideSpeechView()
     ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
     enableORDisableMicrophoneButton(isEnable: true)
     }
     */
    
    /// Top button trigger to history screen
    @objc func goToFavouriteScreen () {
        HomeViewController.bottomViewRef.backgroundColor = .black
        let fv = FavouriteViewController()
        let transition = GlobalMethod.getTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
        add(asChildViewController: fv, containerView:homeContainerView, animation: transition)
        hideSpeechView()
        ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
    }
    
    /// Navigate to Camera page
    @IBAction func didTapOnCameraButton(_ sender: UIButton) {
        let batteryPercentage = UIDevice.current.batteryLevel * batteryMaxPercent
        if batteryPercentage <= cameraDisableBatteryPercentage {
            showBatteryWarningAlert()
        } else {
            RuntimePermissionUtil().requestAuthorizationPermission(for: .video) { [weak self] (isGranted) in
                guard let `self` = self else { return }
                if isGranted {
                    let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
                    if let cameraViewController = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CameraViewController.self)) as? CameraViewController {
                        cameraViewController.updateHomeContainer = { [weak self]  isFullScreen in
                            guard let `self` = self else { return }
                            HomeViewController.homeContainerViewBottomConstraint.constant = isFullScreen ? self.bottomView.bounds.height: 0
                            self.bottomView.layer.zPosition = isFullScreen ? 0: 103
                            isFullScreen ? self.view.sendSubviewToBack(HomeViewController.bottomViewRef) : self.view.bringSubviewToFront(HomeViewController.bottomViewRef)
                            self.homeContainerView.layoutIfNeeded()
                            if(HomeViewController.cameraTapFlag != 0){
                                HomeViewController.homeContainerViewBottomConstraint.constant = self.bottomView.bounds.height
                            }
                        }
                        let transition = GlobalMethod.getTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
                        self.add(asChildViewController:cameraViewController, containerView: self.homeContainerView, animation: transition)
                        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionCamera
                        self.hideSpeechView()
                        self.isFromCameraPreview = true
                    }
                } else {
                    GlobalMethod.showPermissionAlert(viewController: self, title : kCameraUsageTitle, message : kCameraUsageMessage)
                }
            }
            
        }
    }
    
    func showBatteryWarningAlert(){
        let alertService = CustomAlertViewModel()
        let alert = alertService.alertDialogWithTitleWithOkButtonWithNoAction(title: "low_battery".localiz(), message: "charge_the_device".localiz()) {
            // handle action
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Utils
    func setLanguageDirection(){
        self.languageChangedDirectionButton.isUserInteractionEnabled = false
        let isArrowUp = LanguageSelectionManager.shared.isArrowUp
        PrintUtility.printLog(tag: TAG, text: "setLanguageDirection isArrowUp \(isArrowUp)")
        if (isArrowUp){
            self.languageChangedDirectionButton.setImage(UIImage(named: "arrow_circular_up"), for: .normal)
            self.animationChange(transitionToImageView: self.bottomFlipImageView, transitionFromImageView: self.topFlipImageView, animationOption: UIView.AnimationOptions.transitionFlipFromTop, imageName: "gradient_blue_bottom_bg")
        }else{
            self.languageChangedDirectionButton.setImage(UIImage(named: "arrow_circular_down"), for: .normal)
            self.animationChange(transitionToImageView: self.topFlipImageView, transitionFromImageView: self.bottomFlipImageView, animationOption: UIView.AnimationOptions.transitionFlipFromBottom, imageName: "gradient_blue_top_bg")
        }
        speechVC.languageHasUpdated = true
    }
    
    private func animationChange (transitionToImageView : UIImageView, transitionFromImageView : UIImageView, animationOption : UIView.AnimationOptions, imageName : String ){
        UIView.transition(with: transitionFromImageView,
                          duration: animationDuration,
                          options: animationOption,
                          animations: {
            transitionToImageView.isHidden = false
            transitionFromImageView.isHidden = true
            transitionToImageView.image = UIImage(named: imageName)
        }, completion: {_ in
            self.languageChangedDirectionButton.isUserInteractionEnabled = true
        })
    }
    
    
    private func updateLanguageNames() {
        PrintUtility.printLog(tag: TAG, text: "UpdateLanguageNames method called")
        let languageManager = LanguageSelectionManager.shared
        let nativeLangCode = languageManager.bottomLanguage
        let targetLangCode = languageManager.topLanguage
        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        PrintUtility.printLog(tag: TAG, text: "UpdateLanguageNames nativeLanguage \(String(describing: nativeLanguage)) targetLanguage \(String(describing: targetLanguage))")
        topSysLangName.text = targetLanguage?.sysLangName
        topNativeLangNameLable.setTitle(targetLanguage?.name, for: .normal)
        bottomLangSysLangName.setTitle(nativeLanguage?.sysLangName, for: .normal)
        bottomLangNativeName.text = nativeLanguage?.name
    }
    
    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name:.containerViewSelection, object: nil)
        NotificationCenter.default.removeObserver(self, name: .languageSelectionVoiceNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .languageSelectionArrowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .animationDidEnterBackground, object: nil)
    }
    
    private func openLanguageSelectionScreen(isNative: Int){
        PrintUtility.printLog(tag: TAG, text: "\(HomeViewController.self) isNative \(isNative)")
        
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
        
        //Update home container bottom view
        controller.updateHomeContainer = { [weak self]  isFullScreen in
            guard let `self` = self else { return }
            HomeViewController.homeContainerViewBottomConstraint.constant = isFullScreen ? self.bottomView.bounds.height: 0
            self.bottomView.layer.zPosition =  103
            self.bottomView.backgroundColor = isFullScreen ? UIColor.clear : UIColor.black
            self.enableORDisableMicrophoneButton(isEnable: true)
            isFullScreen ? self.view.bringSubviewToFront(self.bottomView) : self.view.sendSubviewToBack(self.bottomView)
            self.homeContainerView.layoutIfNeeded()
        }
        
        //Update language change
        controller.languageHasUpdated = { [weak self] in
            self?.speechVC.languageHasUpdated = true
        }
        controller.isNative = isNative
        
        //Add transition animation
        var transition = GlobalMethod.getTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
        if isNative != LanguageName.bottomLang.rawValue{
            transition = GlobalMethod.getTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
        }
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        //Add as child and other UI property
        add(asChildViewController: controller, containerView:homeContainerView, animation: transition)
        hideSpeechView()
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionVoice
    }
    
    
    @objc func onVoiceLanguageChanged(notification: Notification) {
        updateLanguageNames()
        speechVC.languageHasUpdated = true
    }
    
    @objc func onArrowChanged(notification: Notification) {
        setLanguageDirection()
        setHistoryAndFavouriteView()
    }
    
    
    @objc func updateContainer(notification: Notification) {
        self.removeAllChildControllers(self.selectedTab)
        ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
        historyDissmissed()
        self.historyImageView.becomeFirstResponder()
        self.view.becomeFirstResponder()
        self.historyCardVC.updateData(shouldCVScrollToBottom: false)
    }
}

//MARK: - HomeViewController Touch Functionalities
extension HomeViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == self.topClickView {
                topCircleImgView.isHidden = false
                selectedTab = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.topCircleImgView.isHidden = true
                    self?.bottomCircleleImgView.isHidden = true
                    self?.selectedTouchView = nil
                }
                selectedTouchView = topCircleImgView
            } else if touch.view == self.bottomClickView {
                bottomCircleleImgView.isHidden = false
                selectedTab = 1
                selectedTouchView = bottomCircleleImgView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.topCircleImgView.isHidden = true
                    self?.bottomCircleleImgView.isHidden = true
                    self?.selectedTouchView = nil
                }
            }  else {
                return
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectedTouchView == nil { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            print(self!.selectedTab)
            self?.topCircleImgView.isHidden = true
            self?.bottomCircleleImgView.isHidden = true
            self?.selectedTouchView = nil
            self?.openLanguageSelectionScreen(isNative:self!.selectedTab)
        }
    }
    
    func historyDissmissed() {
        favouriteItemCount = self.homeVM.getFavouriteItemCount()
        updateFavouriteViews()
        historyItemCount = self.homeVM.getHistoryItemCount()
        updateHistoryViews()
    }
}

//MARK:- SpeechProcessingDismissDelegate
extension HomeViewController : SpeechProcessingDismissDelegate {
    func showTutorial() {
        DispatchQueue.main.async {
            self.dislayTutorialScreen(shwoingTutorialForTheFirstTime: false)
        }
    }
}

//MARK:- DismissTutorialDelegate
extension HomeViewController : DismissTutorialDelegate {
    func dismissTutorialWhileFirstTimeLoad() {
        removeAllChildControllers(Int(IsTop.top.rawValue))
    }
}

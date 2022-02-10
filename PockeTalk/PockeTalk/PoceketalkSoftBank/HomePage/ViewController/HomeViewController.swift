//
//  HomeViewController.swift
//  PockeTalk
//

import UIKit
import SwiftRichString

class HomeViewController: BaseViewController {

    @IBOutlet weak private var bottomLangNativeNameLabel: UILabel!
    @IBOutlet weak private var bottomLangSysLangNameButton: UIButton!
    @IBOutlet weak private var topLangNativeNameLabel: UILabel!
    @IBOutlet weak private var topLangSysLangNameButton: UIButton!
    @IBOutlet weak private var languageChangedDirectionButton: UIButton!
    @IBOutlet weak private var menuButton: UIButton!
    @IBOutlet weak private var topClickView: UIView!
    @IBOutlet weak private var bottomClickView: UIView!
    @IBOutlet weak  var bottomView: UIView!
    @IBOutlet weak private var buttonFav: UIButton!
    @IBOutlet weak var historyImageView: UIImageView!
    @IBOutlet weak private var topHighlightedView: UIImageView!
    @IBOutlet weak private var bottomHighlightedView: UIImageView!
    @IBOutlet weak private var animatedView: UIView!
    @IBOutlet weak private var directionButtonContainerView: UIView!
    @IBOutlet weak private var ButtonBackgroundView: UIView!

    private var shouldCheckAppReviewGuide = false
    var isLanguageListVCOpened = false
    static var cameraTapFlag = 0
    let talkBtnImgView = UIImageView()
    static var dummyTalkBtnImgView = UIImageView()
    var window = UIApplication.shared.keyWindow ?? UIWindow()
    var bottomImageViewHeight: NSLayoutConstraint!
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

    private var selectedTouchView:UIView!
    let waitingTimeToShowSpeechProcessingFromHome : Double = 0.4
    let fadeAnimationDuration: TimeInterval = 0.1
    let fadeAnimationDelay: TimeInterval = 0.2
    let flipAnimationDuration: TimeInterval = 0.4
    var isTransitionComplete: Bool = true
    let fadeOutAlpha: CGFloat = 0.0
    static var isCameraButtonClickable = Bool()

    weak var homeVCDelegate: HomeVCDelegate?
    var isFromCameraPreview: Bool = false
    var bottmViewGesture:UILongPressGestureRecognizer!
    var talkButtonImageView: UIImageView!
    static var homeVCBottomViewHeight = CGFloat()

    ///HistoryCardVC properties
    var imageViewPanGesture: UIPanGestureRecognizer!
    var imageViewTapGesture: UITapGestureRecognizer!
    var viewPanGesture: UIPanGestureRecognizer!
    let historyCardTAG = "historyCardTAG"

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
        view.backgroundColor = .clear
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
    private var isEnableGessture:Bool{
        return ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing || ScreenTracker.sharedInstance.screenPurpose == .PronunciationPractice ||
        ScreenTracker.sharedInstance.screenPurpose == .HistroyPronunctiation
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        bottomView.isUserInteractionEnabled = true
        bottomImageView.isUserInteractionEnabled = false
        window = UIApplication.shared.keyWindow ?? UIWindow()
        registerNotification()
        self.homeVM = HomeViewModel()
        self.setUpUI()

        setupUITalkButton()
        setupGestureForCardView()
        setupCardView()
        setupStatusBarView()
        setupGestureForBottomView()
        setupFloatingMikeButton()
        bottomView.layer.zPosition = 103
        AppRater.shared.saveAppLaunchTimeOnce()
    }

    override func loadView() {
        super.loadView()
        directionButtonContainerView.layer.zPosition = .greatestFiniteMagnitude
        self.languageChangedDirectionButton.isUserInteractionEnabled = true
        let isArrowUp = LanguageSelectionManager.shared.isArrowUp
        let isDirectionUp = LanguageSelectionManager.shared.directionisUp

        if (isArrowUp == true) && (isDirectionUp == false) {} else {
            self.animatedView.layer.transform = CATransform3DConcat(self.animatedView.layer.transform, CATransform3DMakeRotation(-.pi,1.0,0.0,0.0))
        }

        if (isArrowUp){
            self.languageChangedDirectionButton.setImage(UIImage(named: "arrowUp"), for: .normal)
            LanguageSelectionManager.shared.directionisUp = false
            self.languageChangedDirectionButton.setImage(UIImage(named: "arrowUp"), for: .highlighted)
        }else{
            self.languageChangedDirectionButton.setImage(UIImage(named: "arrowDown"), for: .normal)
            LanguageSelectionManager.shared.directionisUp = true
            self.languageChangedDirectionButton.setImage(UIImage(named: "arrowDown"), for: .highlighted)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        bottomView.backgroundColor = .black
        HomeViewController.isCameraButtonClickable = true
        view.changeFontSize()
        self.bottomLangSysLangNameButton.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())
        self.topLangSysLangNameButton.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())
        self.bottomLangNativeNameLabel.font = UIFont.systemFont(ofSize: FontUtility.getBiggestFontSize(), weight: .bold)
        self.topLangNativeNameLabel.font = UIFont.systemFont(ofSize: FontUtility.getBiggestFontSize(), weight: .bold)
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isHidden = true
        setHistoryAndFavouriteView()

        talkButtonImageView = window.viewWithTag(109) as? UIImageView
        talkButtonImageView.isHidden = false

        if self.shouldCheckAppReviewGuide {
            _ = AppRater.shared.rateApp()
            self.shouldCheckAppReviewGuide = false
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        updateLanguageNames()
        if !UserDefaultsUtility.getBoolValue(forKey: kUserDefaultIsTutorialDisplayed){
            UserDefaultsUtility.setBoolValue(true, forKey: kUserDefaultIsTutorialDisplayed)
            self.dislayTutorialScreen(shwoingTutorialForTheFirstTime: true)
        }
    }

    deinit {
        unregisterNotification()
    }

    private func setupUITalkButton(){
        talkBtnImgView.tag = 109
        HomeViewController.dummyTalkBtnImgView.image = UIImage(named: "talk_button")
        HomeViewController.dummyTalkBtnImgView.translatesAutoresizingMaskIntoConstraints = false
        HomeViewController.dummyTalkBtnImgView.tintColor = UIColor._skyBlueColor()
        HomeViewController.dummyTalkBtnImgView.layer.cornerRadius = width/2
        HomeViewController.dummyTalkBtnImgView.clipsToBounds = true
        self.bottomView.addSubview(HomeViewController.dummyTalkBtnImgView)
        HomeViewController.dummyTalkBtnImgView.widthAnchor.constraint(equalToConstant: width).isActive = true
        HomeViewController.dummyTalkBtnImgView.heightAnchor.constraint(equalToConstant: width).isActive = true
        HomeViewController.dummyTalkBtnImgView.centerXAnchor.constraint(equalTo: self.bottomView.centerXAnchor).isActive = true
        HomeViewController.dummyTalkBtnImgView.bottomAnchor.constraint(equalTo: self.bottomView.bottomAnchor, constant: -(bottomView.bounds.height/2 + window.safeAreaInsets.bottom - width/2)).isActive = true
        HomeViewController.dummyTalkBtnImgView.isHidden = true

        talkBtnImgView.image = UIImage(named: "talk_button")
        talkBtnImgView.isUserInteractionEnabled = true
        talkBtnImgView.translatesAutoresizingMaskIntoConstraints = false
        bottomImageView.translatesAutoresizingMaskIntoConstraints = false
        talkBtnImgView.tintColor = UIColor._skyBlueColor()
        talkBtnImgView.layer.cornerRadius = width/2
        talkBtnImgView.clipsToBounds = true
        bottomView.addSubview(bottomImageView)
        bottomImageView.isUserInteractionEnabled = false
        self.window.addSubview(talkBtnImgView)
        talkBtnImgView.isHidden = false
        talkBtnImgView.widthAnchor.constraint(equalToConstant: width).isActive = true
        talkBtnImgView.heightAnchor.constraint(equalToConstant: width ).isActive = true
        talkBtnImgView.centerXAnchor.constraint(equalTo: self.window.centerXAnchor).isActive = true
        talkBtnImgView.bottomAnchor.constraint(equalTo: self.window.bottomAnchor, constant: -(bottomView.bounds.height/2 + window.safeAreaInsets.bottom - width/2)).isActive = true
        putGlowEffectUnderTalkButton()
        bottomImageView.widthAnchor.constraint(equalToConstant: bottomView.frame.width * 1.4).isActive = true
        bottomImageViewHeight = bottomImageView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.8)
        bottomImageViewHeight.isActive = true
        bottomImageView.centerXAnchor.constraint(equalTo: self.bottomView.centerXAnchor).isActive = true
        bottomImageView.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor).isActive = true
        self.pulseGrayWave.isHidden = true
        self.pulseLayer.isHidden = true
        self.midCircleViewOfPulse.isHidden = true
        self.bottomImageView.isHidden = true
        self.bottomImageView.image = #imageLiteral(resourceName: "bg_speak").withRenderingMode(.alwaysOriginal)
    }

    func putGlowEffectUnderTalkButton(){
        let talkButtonShadow = UIImageView()
        window.addSubview(talkButtonShadow)
        talkButtonShadow.image = UIImage(named: "bg_speak")
        talkButtonShadow.tag = 110
        talkButtonShadow.isUserInteractionEnabled = true
        talkButtonShadow.translatesAutoresizingMaskIntoConstraints = false
        talkButtonShadow.layer.cornerRadius = width/2
        talkButtonShadow.clipsToBounds = true
        talkButtonShadow.widthAnchor.constraint(equalToConstant: width*1.5).isActive = true
        talkButtonShadow.heightAnchor.constraint(equalToConstant: width*2 ).isActive = true
        talkButtonShadow.centerXAnchor.constraint(equalTo: self.talkBtnImgView.centerXAnchor).isActive = true
        talkButtonShadow.topAnchor.constraint(equalTo: self.talkBtnImgView.bottomAnchor, constant: window.safeAreaInsets.bottom - width/4).isActive = true
        talkButtonShadow.isHidden = true
    }

    //MARK: - Initial Setup
    private func setUpUI () {
        navigationController?.navigationBar.barTintColor = UIColor.black
        tabBarController?.tabBar.tintColor = UIColor.white
        tabBarController?.tabBar.barTintColor = UIColor.white

        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = UIColor.white

        if let lanCode = self.homeVM.getLanguageName() {
            self.deviceLanguage = lanCode
        }

        self.bottomLangSysLangNameButton.titleLabel?.textAlignment = .center
        self.bottomLangSysLangNameButton.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getBiggerFontSize(), weight: .bold)
        self.bottomLangSysLangNameButton.setTitleColor(UIColor._whiteColor(), for: .normal)

        self.topLangSysLangNameButton.titleLabel?.textAlignment = .center
        self.topLangSysLangNameButton.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getBiggerFontSize(), weight: .bold)
        self.topLangSysLangNameButton.setTitleColor(UIColor._whiteColor(), for: .normal)

        ///Hide Circle Imageview at first
        self.topHighlightedView.isHidden = true
        self.bottomHighlightedView.isHidden = true

        view.addSubview(homeContainerView)
        view.addSubview(speechContainerView)

        homeContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        homeContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        homeContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        homeContainerView.bottomAnchor.constraint(equalTo: self.bottomView.bottomAnchor, constant: 0).isActive = true

        speechContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        speechContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        speechContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        speechContainerView.bottomAnchor.constraint(equalTo:self.bottomView.topAnchor).isActive = true

        cardHeight = self.view.bounds.height
        HomeViewController.homeVCBottomViewHeight = self.view.frame.height * 0.25
        languageChangedDirectionButton.layer.zPosition = .greatestFiniteMagnitude

        setUPLongPressGesture()
        addSpeechProcessingVC()
        addTalkButtonAnimationViews()
    }

    ///setup mike button for the first time
    private func setupFloatingMikeButton(){
        FloatingMikeButton.sharedInstance.window = self.window
        FloatingMikeButton.sharedInstance.add()
        FloatingMikeButton.sharedInstance.isHidden(true)
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
        self.window.addSubview(pulseGrayWave)
        self.window.layer.addSublayer(pulseLayer)
        self.window.addSubview(midCircleViewOfPulse)
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateContainer(notification:)), name:.containerViewSelection, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(animationDidEnterBackground(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onVoiceLanguageChanged(notification:)), name: .languageSelectionVoiceNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.onArrowChanged(notification:)), name: .languageSelectionArrowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.enableorDisableGesture(notification:)), name: .bottmViewGestureNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.languageChangedFromSettings(notification:)), name: .languageChangeFromSettingsNotification, object: nil)
    }

    //MARK: - IBActions
    @IBAction private func menuAction(_ sender: UIButton) {
        talkBtnImgView.isHidden = true
        let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: nil)
        if let settinsViewController = settingsStoryBoard.instantiateViewController(withIdentifier: String(describing: SettingsViewController.self)) as? SettingsViewController {
            let transition = CATransition()
            transition.duration = kSettingsScreenTransitionDuration
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            shouldCheckAppReviewGuide = true
            self.navigationController?.pushViewController(settinsViewController, animated: false)
        }
    }

    @IBAction private func switchLanguageDirectionAction(_ sender: UIButton) {
        if self.isTransitionComplete {
            self.isTransitionComplete = false
            PrintUtility.printLog(tag: TAG, text: "switchLanguageDirectionAction isArrowUp \(LanguageSelectionManager.shared.isArrowUp)")
            if LanguageSelectionManager.shared.isArrowUp{
                LanguageSelectionManager.shared.isArrowUp = false
                LanguageSelectionManager.shared.directionisUp = true
            }else{
                LanguageSelectionManager.shared.isArrowUp = true
                LanguageSelectionManager.shared.directionisUp = false
            }
            setLanguageDirection()
        }
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
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: KTutorialViewController)as! TutorialViewController

        controller.speechProDismissDelegateFromTutorial = self

        controller.isShwoingTutorialForTheFirstTime = shwoingTutorialForTheFirstTime
        if shwoingTutorialForTheFirstTime {
            controller.dismissTutorialDelegate = self
        } else {
            controller.dismissTutorialDelegate = nil
        }

        homeContainerView.isHidden = false
        add(asChildViewController: controller, containerView:homeContainerView)
    }

    @objc func goToFavouriteScreen () {
        let fv = FavouriteViewController()
        let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
        self.enableORDisableMicrophoneButton(isEnable: true)
        add(asChildViewController: fv, containerView:homeContainerView, animation: transition)
        hideSpeechView()
        ScreenTracker.sharedInstance.screenPurpose = .FavouriteScreen
    }

    @IBAction func didTapOnCameraButton(_ sender: UIButton) {
        if HomeViewController.isCameraButtonClickable == true {
            let batteryPercentage = UIDevice.current.batteryLevel * batteryMaxPercent
            if batteryPercentage <= cameraDisableBatteryPercentage {
                showBatteryWarningAlert()
            } else {
                RuntimePermissionUtil().requestAuthorizationPermission(for: .video) { [weak self] (isGranted) in
                    guard let `self` = self else { return }
                    if isGranted {
                        let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
                        if let cameraViewController = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CameraViewController.self)) as? CameraViewController {
                            cameraViewController.updateHomeContainer = { [weak self]  isTalkButtonVisible in
                                guard let `self` = self else { return }
                                self.hideORShowlTalkButton(isEnable: isTalkButtonVisible)
                            }
                            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
                            self.add(asChildViewController:cameraViewController, containerView: self.homeContainerView, animation: transition)
                            ScreenTracker.sharedInstance.screenPurpose = .CameraScreen
                            self.hideSpeechView()
                            self.isFromCameraPreview = true
                        }
                    } else {
                        GlobalMethod.showPermissionAlert(viewController: self, title : kCameraUsageTitle, message : kCameraUsageMessage)
                    }
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
        self.languageChangedDirectionButton.isUserInteractionEnabled = true
        let isArrowUp = LanguageSelectionManager.shared.isArrowUp
        PrintUtility.printLog(tag: TAG, text: "setLanguageDirection isArrowUp \(isArrowUp)")
        UIView.animate(withDuration: flipAnimationDuration, delay: 0.1, options: .curveLinear) {
            self.languageChangedDirectionButton.layer.transform = CATransform3DConcat(self.languageChangedDirectionButton.layer.transform, CATransform3DMakeRotation(-.pi,1.0,0.0,0.0))
            self.animatedView.layer.transform = CATransform3DConcat(self.animatedView.layer.transform, CATransform3DMakeRotation(-.pi,-1.0,0.0,0.0))

        } completion: { _ in
            self.isTransitionComplete = true
        }

        speechVC.languageHasUpdated = true
    }

    private func updateLanguageNames() {
        PrintUtility.printLog(tag: TAG, text: "UpdateLanguageNames method called")
        let languageManager = LanguageSelectionManager.shared
        let nativeLangCode = languageManager.bottomLanguage
        let targetLangCode = languageManager.topLanguage
        PrintUtility.printLog(tag: TAG, text: "NativeLC \(nativeLangCode) TargetLC: \(targetLangCode)")
        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        PrintUtility.printLog(tag: TAG, text: "UpdateLanguageNames nativeLanguage \(String(describing: nativeLanguage)) targetLanguage \(String(describing: targetLanguage))")
        bottomLangSysLangNameButton.setTitle(nativeLanguage?.sysLangName, for: .normal)
        topLangSysLangNameButton.setTitle(targetLanguage?.sysLangName, for: .normal)
        bottomLangNativeNameLabel.text = nativeLanguage?.name
        topLangNativeNameLabel.text = targetLanguage?.name
    }

    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name: .containerViewSelection, object: nil)
        NotificationCenter.default.removeObserver(self, name: .languageSelectionVoiceNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .languageSelectionArrowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .bottmViewGestureNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .languageChangeFromSettingsNotification, object: nil)
    }

    private func openLanguageSelectionScreen(isNative: Int){
        PrintUtility.printLog(tag: TAG, text: "\(HomeViewController.self) isNative \(isNative)")

        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC

        //Update home container bottom view
        controller.updateHomeContainer = { [weak self]  isFullScreen in
            guard let `self` = self else { return }
            self.enableORDisableMicrophoneButton(isEnable: true)
        }

        //Update language change
        controller.languageHasUpdated = { [weak self] in
            self?.speechVC.languageHasUpdated = true
        }
        controller.isNative = isNative

        //Add transition animation
        var transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
        if isNative != LanguageName.bottomLang.rawValue{
            transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
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

    @objc func enableorDisableGesture(notification: Notification?) {
        if(isEnableGessture){
            self.bottomView.backgroundColor = UIColor.black
            view.bringSubviewToFront(bottomView)
        }
        else{
            self.bottomView.backgroundColor = UIColor.clear
            view.sendSubviewToBack(bottomView)
        }
    }

    @objc func languageChangedFromSettings(notification: Notification?) {
        if let languageInfo = notification?.userInfo as? [String: Bool] {
            if (languageInfo["isLanguageChanged"] ?? false) == true {
                speechVC.languageHasUpdated = true
            }
        }
    }

    @objc func updateContainer(notification: Notification) {
        self.removeAllChildControllers(self.selectedTab)
        if ScreenTracker.sharedInstance.screenPurpose != .HistoryScrren{
            ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
        }
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
                topHighlightedView.isHidden = false
                selectedTab = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.topHighlightedView.isHidden = true
                    self?.bottomHighlightedView.isHidden = true
                    self?.selectedTouchView = nil
                }
                selectedTouchView = topHighlightedView
            } else if touch.view == self.bottomClickView {
                bottomHighlightedView.isHidden = false
                selectedTab = 1
                selectedTouchView = bottomHighlightedView
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.topHighlightedView.isHidden = true
                    self?.bottomHighlightedView.isHidden = true
                    self?.selectedTouchView = nil
                }
            } else {
                return
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectedTouchView == nil { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            print(self!.selectedTab)
            self?.topHighlightedView.isHidden = true
            self?.bottomHighlightedView.isHidden = true
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

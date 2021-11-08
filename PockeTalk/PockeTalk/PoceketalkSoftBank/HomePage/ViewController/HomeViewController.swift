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
    
    let TAG = "\(HomeViewController.self)"
    private var homeVM : HomeViewModeling!
    private var animationCounter : Int = 0
    private var deviceLanguage : String = ""
    private let toastVisibleTime : Double = 2.0
    private let animationDuration : TimeInterval = 0.1
     let width : CGFloat = 100
    private var selectedTab = 0
    private var historyItemCount = 0
    private var favouriteItemCount = 0;
    var swipeDown : UISwipeGestureRecognizer!
    private var selectedTouchView:UIView!
    let waitingTimeToShowSpeechProcessingFromHome : Double = 0.4

    weak var homeVCDelegate: HomeVCDelegate?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    private lazy var topButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "TopHistoryBtn"), for: .normal)
        button.addTarget(self, action: #selector(goToHistoryScreen), for: .touchUpInside)
        button.layer.zPosition = 99
        return button
    }()

    lazy var homeContainerView:UIView = {
       let view  = UIView()
       view.backgroundColor = .white
       view.translatesAutoresizingMaskIntoConstraints = false
       view.layer.zPosition = 100
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

    var homeContainerViewBottomConstraint:NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        self.homeVM = HomeViewModel()
        self.setUpUI()
        setLanguageDirection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.changeFontSize()
       // setUpUI()
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isHidden = true
        //setLanguageDirection()
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
            self.dislayTutorialScreen()
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

        view.addSubview(topButton)
        topButton.translatesAutoresizingMaskIntoConstraints = false
        topButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        topButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
        topButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        topButton.centerYAnchor.constraint(equalTo: menuButton.centerYAnchor, constant: 0).isActive = true

        ///Hide Circle Imageview at first
        self.topCircleImgView.isHidden = true
        self.bottomCircleleImgView.isHidden = true
        
        /// Added down geture
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)

        view.addSubview(homeContainerView)
        view.addSubview(speechContainerView)

        homeContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        homeContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        homeContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //homeContainerView.bottomAnchor.constraint(equalTo:self.bottomView.topAnchor).isActive = true
        homeContainerViewBottomConstraint = homeContainerView.bottomAnchor.constraint(equalTo:self.bottomView.topAnchor, constant: 0)
        homeContainerViewBottomConstraint.isActive = true

        speechContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        speechContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        speechContainerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        speechContainerView.bottomAnchor.constraint(equalTo:self.bottomView.topAnchor).isActive = true



        setUPLongPressGesture()
        addSpeechProcessingVC()
    }
    
    private func setHistoryAndFavouriteView(){
        historyItemCount =  homeVM.getHistoryItemCount()
        favouriteItemCount = homeVM.getFavouriteItemCount()
        updateHistoryViews()
        updateFavouriteViews()
    }
    

    
    func addSpeechProcessingVC(){
        add(asChildViewController: speechVC, containerView:speechContainerView)
        hideSpeechView()
        homeGestureEnableOrDiable()
    }
    
    func updateHistoryViews(){
        // Add top button
        if(historyItemCount>0){
            topButton.isHidden = false
            swipeDown.isEnabled = true
        }else{
            topButton.isHidden = true
            swipeDown.isEnabled = false
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
    private func dislayTutorialScreen () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTutorialViewController)as! TutorialViewController
        let navController = UINavigationController(rootViewController: controller)
        navController.modalPresentationStyle = .overFullScreen
        navController.modalTransitionStyle = .crossDissolve
        navController.navigationBar.isHidden = true
        controller.navController = navController
        controller.speechProDismissDelegateFromTutorial = self
        self.present(navController, animated: true, completion: nil)
    }


    @objc private func goToHistoryScreen () {
    /// Top button trigger to history screen

        let historyVC = HistoryViewController()
        add(asChildViewController: historyVC, containerView:homeContainerView)
        hideSpeechView()
        ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
        enableORDisableMicrophoneButton(isEnable: true)
    }
    
    /// Top button trigger to history screen
    @objc func goToFavouriteScreen () {
        let fv = FavouriteViewController()

        add(asChildViewController: fv, containerView:homeContainerView)
        hideSpeechView()
        ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
        enableORDisableMicrophoneButton(isEnable: true)

    }

    /// Navigate to Camera page
    @IBAction func didTapOnCameraButton(_ sender: UIButton) {

        RuntimePermissionUtil().requestAuthorizationPermission(for: .video) { [weak self] (isGranted) in
            guard let `self` = self else { return }
            if isGranted {
                let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
                if let cameraViewController = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CameraViewController.self)) as? CameraViewController {
                    cameraViewController.updateHomeContainer = { [weak self]  isFullScreen in
                        guard let `self` = self else { return }
                        self.homeContainerViewBottomConstraint.constant = isFullScreen ? self.bottomView.bounds.height: 0
                        self.homeContainerView.layoutIfNeeded()
                    }
                     self.add(asChildViewController:cameraViewController, containerView: self.homeContainerView)
                     ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionCamera
                     self.hideSpeechView()
                     self.enableORDisableMicrophoneButton(isEnable: true)
                }
            } else {
                GlobalMethod.showPermissionAlert(viewController: self, title : kCameraUsageTitle, message : kCameraUsageMessage)
            }
        }

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
        print("\(HomeViewController.self) updateLanguageNames method called")
        let languageManager = LanguageSelectionManager.shared
        let nativeLangCode = languageManager.bottomLanguage
        let targetLangCode = languageManager.topLanguage
        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        print("\(HomeViewController.self) updateLanguageNames nativeLanguage \(String(describing: nativeLanguage)) targetLanguage \(String(describing: targetLanguage))")
        topSysLangName.text = targetLanguage?.sysLangName
        topNativeLangNameLable.setTitle(targetLanguage?.name, for: .normal)
        bottomLangSysLangName.setTitle(nativeLanguage?.sysLangName, for: .normal)
        bottomLangNativeName.text = nativeLanguage?.name
    }
    
    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name:.containerViewSelection, object: nil)
        NotificationCenter.default.removeObserver(self, name: .languageSelectionVoiceNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .languageSelectionArrowNotification, object: nil)
    }

    private func openLanguageSelectionScreen(isNative: Int){
        print("\(HomeViewController.self) isNative \(isNative)")
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
        controller.languageHasUpdated = { [weak self] in
            //self?.homeVM.updateLanguage()
            self?.speechVC.languageHasUpdated = true
        }
        controller.isNative = isNative
        //self.navigationController?.pushViewController(controller, animated: true);
        add(asChildViewController: controller, containerView:homeContainerView)
        hideSpeechView()
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionVoice
        enableORDisableMicrophoneButton(isEnable: true)
    }
    

    @objc func onVoiceLanguageChanged(notification: Notification) {
        updateLanguageNames()
    }
    
    @objc func onArrowChanged(notification: Notification) {
        setLanguageDirection()
        setHistoryAndFavouriteView()
    }


    @objc func updateContainer(notification: Notification) {
        self.removeAllChildControllers()
        historyDissmissed()
        ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
    }

    // Down ward gesture
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if gesture.state == .ended{
            if(historyItemCount > 0){
                self.goToHistoryScreen()
            }
        }
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
       // self.hideContainerView()
    }
}

extension HomeViewController : SpeechProcessingDismissDelegate {
    func showTutorial() {
        DispatchQueue.main.async {
            self.dislayTutorialScreen()
        }
    }
}

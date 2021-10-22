//
//  HomeViewController.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/1/21.

import UIKit
import SwiftRichString

class HomeViewController: BaseViewController {
    @IBOutlet weak private var bottomLangSysLangName: UIButton!
    @IBOutlet weak private var languageChangedDirectionButton: UIButton!
    @IBOutlet weak private var topNativeLangNameLable: UIButton!
    @IBOutlet weak private var bottomFlipImageView: UIImageView!
    @IBOutlet weak private var topFlipImageView: UIImageView!
    @IBOutlet weak private var menuButton: UIButton!
    @IBOutlet weak private var directionImageView: UIImageView!
    @IBOutlet weak private var topSysLangName: UILabel!
    @IBOutlet weak private var bottomLangNativeName: UILabel!
    @IBOutlet weak private var topCircleImgView: UIImageView!
    @IBOutlet weak private var bottomCircleleImgView: UIImageView!
    @IBOutlet weak private var topClickView: UIView!
    @IBOutlet weak private var bottomClickView: UIView!
    @IBOutlet weak private var bottomView: UIView!
    @IBOutlet weak private var buttonFav: UIButton!
    
    let TAG = "\(HomeViewController.self)"
    var languageHasUpdated = false
    private var homeVM : HomeViewModeling!
    private var animationCounter : Int = 0
    private var deviceLanguage : String = ""
    private let toastVisibleTime : Double = 2.0
    private let animationDuration : TimeInterval = 1.0
    private let width : CGFloat = 100
    private var selectedTab = 0
    private var historyItemCount = 0
    private var favouriteItemCount = 0;
    private var swipeDown = UISwipeGestureRecognizer()
    private var selectedTouchView:UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    private lazy var topButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "TopHistoryBtn"), for: .normal)
        button.addTarget(self, action: #selector(goToHistoryScreen), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        self.homeVM = HomeViewModel()
        self.setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.changeFontSize()
        setUpUI()
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isHidden = true
        setLanguageDirection()
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
        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomView, width: width, height: width)
        talkButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
        
        ///Add TopButton Subview
        view.addSubview(topButton)
        topButton.translatesAutoresizingMaskIntoConstraints = false
        topButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        topButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        ///Hide Circle Imageview at first
        self.topCircleImgView.isHidden = true
        self.bottomCircleleImgView.isHidden = true
        
        /// Added down geture
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
    }
    
    private func setHistoryAndFavouriteView(){
        historyItemCount =  homeVM.getHistoryItemCount()
        favouriteItemCount = homeVM.getFavouriteItemCount()
        updateHistoryViews()
        updateFavouriteViews()
    }
    
    private func updateHistoryViews(){
        if(historyItemCount > 0){
            view.addSubview(topButton)
            topButton.translatesAutoresizingMaskIntoConstraints = false
            topButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            topButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
            topButton.heightAnchor.constraint(equalToConstant: 150).isActive = true
            topButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -((topPadding ?? 0) - 10)).isActive = true
            self.view.addGestureRecognizer(swipeDown)
        }else{
            topButton.removeFromSuperview()
            self.view.removeGestureRecognizer(swipeDown)
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.onArrowChanged(notification:)), name: .languageSelectionArrowNotification, object: nil)
    }
    
    //MARK: - IBActions
    @IBAction private func menuAction(_ sender: UIButton) {
        let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: nil)
        if let settinsViewController = settingsStoryBoard.instantiateViewController(withIdentifier: String(describing: SettingsViewController.self)) as? SettingsViewController {
            self.navigationController?.pushViewController(settinsViewController, animated: true)
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
    
    @IBAction private func didTapOnCameraButton(_ sender: UIButton) {
        RuntimePermissionUtil().requestAuthorizationPermission(for: .video) { [weak self] (isGranted) in
            if isGranted {
                let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
                if let cameraViewController = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CameraViewController.self)) as? CameraViewController {
                    self?.navigationController?.pushViewController(cameraViewController, animated: true)
                }
            } else {
                GlobalMethod.showPermissionAlert(viewController: self, title : kCameraUsageTitle, message : kCameraUsageMessage)
            }
        }
    }
    
    @IBAction private func didTapOnFavoriteButton(_ sender: UIButton) {
        self.goToFavouriteScreen()
    }
    
    @objc private func microphoneTapAction (sender:UIButton) {
        let languageManager = LanguageSelectionManager.shared
        var speechLangCode = ""
        if languageManager.isArrowUp{
            speechLangCode = languageManager.bottomLanguage
        }else{
            speechLangCode = languageManager.topLanguage
        }
        if languageManager.hasSttSupport(languageCode: speechLangCode){
            proceedToTakeVoiceInput()
        }else {
            showToast(message: "no_stt_msg".localiz(), seconds: 2)
            PrintUtility.printLog(tag: TAG, text: "checkSttSupport don't have stt support")
        }
    }
    
    //MARK: - View Transactions
    private func dislayTutorialScreen () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTutorialViewController)as! TutorialViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(controller, animated: true, completion: nil)
    }
    
    private func proceedToTakeVoiceInput() {
        if Reachability.isConnectedToNetwork() {
            RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
                if isGranted {
                    let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
                    controller.homeMicTapTimeStamp = currentTS
                    controller.languageHasUpdated = self.languageHasUpdated
                    controller.screenOpeningPurpose = .HomeSpeechProcessing
                    self.navigationController?.pushViewController(controller, animated: true);
                    
                } else {
                    GlobalMethod.showPermissionAlert(viewController: self, title : kMicrophoneUsageTitle, message : kMicrophoneUsageMessage)
                    
                }
            }
        } else {
            GlobalMethod.showNoInternetAlert()
        }
    }
    
    @objc private func goToHistoryScreen () {
        let historyVC = HistoryViewController()
        historyVC.initDelegate(self)
        self.topCircleImgView.isHidden = true
        self.bottomCircleleImgView.isHidden = true
        
        let navController = UINavigationController(rootViewController: historyVC)
        navController.modalPresentationStyle = .overFullScreen
        navController.modalTransitionStyle = .crossDissolve
        navController.navigationBar.isHidden = true
        
        historyVC.navController = navController
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc private func goToFavouriteScreen () {
        let fv = FavouriteViewController()
        fv.modalPresentationStyle = .fullScreen
        fv.modalTransitionStyle = .crossDissolve
        fv.initDelegate(self)
        self.navigationController?.present(fv, animated: true, completion: nil)
    }
    
    //MARK: - Utils
    private func setLanguageDirection(){
        let isArrowUp = LanguageSelectionManager.shared.isArrowUp
        PrintUtility.printLog(tag: TAG, text: "setLanguageDirection isArrowUp \(isArrowUp)")
        if (isArrowUp){
            self.directionImageView.image = UIImage(named: "up_arrow")
            self.animationChange(transitionToImageView: self.bottomFlipImageView, transitionFromImageView: self.topFlipImageView, animationOption: UIView.AnimationOptions.transitionFlipFromTop, imageName: "gradient_blue_bottom_bg")
        }else{
            self.directionImageView.image = UIImage(named: "down_arrow")
            self.animationChange(transitionToImageView: self.topFlipImageView, transitionFromImageView: self.bottomFlipImageView, animationOption: UIView.AnimationOptions.transitionFlipFromBottom, imageName: "gradient_blue_top_bg")
        }
        languageHasUpdated = true
    }
    
    private func animationChange (transitionToImageView : UIImageView, transitionFromImageView : UIImageView, animationOption : UIView.AnimationOptions, imageName : String ){
        UIView.transition(with: transitionFromImageView,
                          duration: animationDuration,
                          options: animationOption,
                          animations: {
            transitionToImageView.isHidden = false
            transitionFromImageView.isHidden = true
            transitionToImageView.image = UIImage(named: imageName)
        }, completion: nil)
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
        NotificationCenter.default.removeObserver(self, name: .languageSelectionArrowNotification, object: nil)
    }
    
    private func openLanguageSelectionScreen(isNative: Int){
        print("\(HomeViewController.self) isNative \(isNative)")
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
        controller.languageHasUpdated = { [weak self] in
            //self?.homeVM.updateLanguage()
            self?.languageHasUpdated = true
        }
        controller.isNative = isNative
        self.navigationController?.pushViewController(controller, animated: true);
    }
    
    @objc private func onArrowChanged(notification: Notification) {
        setLanguageDirection()
        setHistoryAndFavouriteView()
    }
    
    @objc private func respondToSwipeGesture(gesture: UIGestureRecognizer) {
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
}

//MARK: - HistoryViewControllerDelegates
extension HomeViewController: HistoryViewControllerDelegates{
    func historyDissmissed() {
        favouriteItemCount = self.homeVM.getFavouriteItemCount()
        updateFavouriteViews()
        historyItemCount = self.homeVM.getHistoryItemCount()
        updateHistoryViews()
    }
}

//MARK: - FavouriteViewControllerDelegates
extension HomeViewController : FavouriteViewControllerDelegates {
    func dismissFavouriteView() {
        favouriteItemCount = self.homeVM.getFavouriteItemCount()
        updateFavouriteViews()
        historyItemCount = self.homeVM.getHistoryItemCount()
        updateHistoryViews()
    }
}

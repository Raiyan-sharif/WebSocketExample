//
//  HomeViewController.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/1/21.

import UIKit

class HomeViewController: BaseViewController {

    //Views
    @IBOutlet weak var bottomLangSysLangName: UIButton!
    @IBOutlet weak var languageChangedDirectionButton: UIButton!
    @IBOutlet weak var topNativeLangNameLable: UIButton!
    @IBOutlet weak var bottomFlipImageView: UIImageView!
    @IBOutlet weak var topFlipImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var directionImageView: UIImageView!
    @IBOutlet weak var topSysLangName: UILabel!
    @IBOutlet weak var bottomLangNativeName: UILabel!
    @IBOutlet weak var topCircleImgView: UIImageView!
    @IBOutlet weak var bottomCircleleImgView: UIImageView!
    @IBOutlet weak var topClickView: UIView!
    @IBOutlet weak var bottomClickView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var buttonFav: UIButton!
    
    var languageHasUpdated = false

    //Properties
    var homeVM : HomeViewModeling!
    var animationCounter : Int = 0
    var deviceLanguage : String = ""
    let toastVisibleTime : Double = 2.0
    let animationDuration : TimeInterval = 1.0
    let width : CGFloat = 100
    private var selectedTab = 0
    var historyItemCount = 0
    var favouriteItemCount = 0;
    var swipeDown = UISwipeGestureRecognizer()
    ///Top button
    private lazy var topButton:UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "TopHistoryBtn"), for: .normal)
        button.addTarget(self, action: #selector(goToHistoryScreen), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        // Do any additional setup after loading the view.
        self.homeVM = HomeViewModel()
        self.setUpUI()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.changeFontSize()
        setUpUI()
        self.navigationController?.navigationBar.isHidden = true
        setLanguageDirection(isArrowUp: UserDefaultsProperty<Bool>(kIsArrowUp).value ?? true)
        historyItemCount =  homeVM.getHistoryItemCount()
        favouriteItemCount = homeVM.getFavouriteItemCount()
        updateHistoryViews()
        updateFavouriteViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateLanguageNames()
    }
    // Initial UI set up
    func setUpUI () {
         ///Check whether tutorial has already been displayed
        if !UserDefaultsUtility.getBoolValue(forKey: kUserDefaultIsTutorialDisplayed) {
          UserDefaultsUtility.setBoolValue(true, forKey: kUserDefaultIsTutorialDisplayed)
            self.dislayTutorialScreen()
        }

        if let lanCode = self.homeVM.getLanguageName() {
            self.deviceLanguage = lanCode
        }

        //self.topNativeLangNameLable.setTitle("Japanese", for: .normal)
        self.topNativeLangNameLable.titleLabel?.textAlignment = .center
        self.topNativeLangNameLable.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getBiggerFontSize(), weight: .bold)
        self.topNativeLangNameLable.setTitleColor(UIColor._whiteColor(), for: .normal)

        //self.topSysLangName.text = "Japanese"
        self.topSysLangName.textAlignment = .center
        self.topSysLangName.textColor = UIColor._whiteColor()

        self.bottomLangSysLangName.setTitle(deviceLanguage, for: .normal)
        self.bottomLangSysLangName.titleLabel?.textAlignment = .center
        self.bottomLangSysLangName.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getBiggerFontSize(), weight: .bold)
        self.bottomLangSysLangName.setTitleColor(UIColor._whiteColor(), for: .normal)
        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomView, width: width, height: width)
        talkButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
        // Add top button
        view.addSubview(topButton)
        topButton.translatesAutoresizingMaskIntoConstraints = false
        topButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        topButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        //Hide Circle Imageview at first
        self.topCircleImgView.isHidden = true
        self.bottomCircleleImgView.isHidden = true

        // Added down geture
        swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down


    }
    
    func updateHistoryViews(){
        // Add top button
        if(historyItemCount>0){
            view.addSubview(topButton)
            topButton.translatesAutoresizingMaskIntoConstraints = false
            topButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            topButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            topButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
            topButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            self.view.addGestureRecognizer(swipeDown)
        }else{
            topButton.removeFromSuperview()
            self.view.removeGestureRecognizer(swipeDown)
        }
    }
    
    func updateFavouriteViews(){
        // Add top button
        if( self.favouriteItemCount > 0 ){
            self.buttonFav.isHidden = false
        }else{
            self.buttonFav.isHidden = true
        }
    }

    //TODO Menu tap event
    @IBAction func menuAction(_ sender: UIButton) {
        let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: nil)
        if let settinsViewController = settingsStoryBoard.instantiateViewController(withIdentifier: String(describing: SettingsViewController.self)) as? SettingsViewController {
            self.navigationController?.pushViewController(settinsViewController, animated: true)
        }

    }

    // This method is called
    @IBAction func switchLanguageDirectionAction(_ sender: UIButton) {
        if UserDefaultsProperty<Bool>(kIsArrowUp).value == false{
            setLanguageDirection(isArrowUp: true)
            UserDefaultsProperty<Bool>(kIsArrowUp).value = true
        }else{
            setLanguageDirection(isArrowUp: false)
            UserDefaultsProperty<Bool>(kIsArrowUp).value = false
        }
    }
    
    func setLanguageDirection(isArrowUp: Bool){
        if (isArrowUp){
            self.directionImageView.image = UIImage(named: "up_arrow")
            self.animationChange(transitionToImageView: self.bottomFlipImageView, transitionFromImageView: self.topFlipImageView, animationOption: UIView.AnimationOptions.transitionFlipFromTop, imageName: "gradient_blue_bottom_bg")
        }else{
            self.directionImageView.image = UIImage(named: "down_arrow")
            self.animationChange(transitionToImageView: self.topFlipImageView, transitionFromImageView: self.bottomFlipImageView, animationOption: UIView.AnimationOptions.transitionFlipFromBottom, imageName: "gradient_blue_top_bg")
        }
        LanguageSelectionManager.shared.isArrowUp = !LanguageSelectionManager.shared.isArrowUp!
                languageHasUpdated = true
    }

    func animationChange (transitionToImageView : UIImageView, transitionFromImageView : UIImageView, animationOption : UIView.AnimationOptions, imageName : String ){
        UIView.transition(with: transitionFromImageView,
                          duration: animationDuration,
                          options: animationOption,
                          animations: {
                            transitionToImageView.isHidden = false
                            transitionFromImageView.isHidden = true
                            transitionToImageView.image = UIImage(named: imageName)
                          }, completion: nil)
    }

    ///Move to Tutorial Screen
    func dislayTutorialScreen () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTutorialViewController)as! TutorialViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(controller, animated: true, completion: nil)
    }

    // TODO navigate to language selection page
    @IBAction func topLanguageBtnAction(_ sender: UIButton) {
        openLanguageSelectionScreen(isNative: 0)
        //self.showToast(message: kTopLanguageButtonActionToastMessage, seconds: toastVisibleTime)
    }

    // TODO navigate to language selection page
    @IBAction func bottomLanguageBtnAction(_ sender: UIButton) {
        openLanguageSelectionScreen(isNative: 1)
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        if Reachability.isConnectedToNetwork() {
            let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
            controller.homeMicTapTimeStamp = currentTS
            controller.languageHasUpdated = languageHasUpdated
            controller.screenOpeningPurpose = .HomeSpeechProcessing
            self.navigationController?.pushViewController(controller, animated: true);
        } else {
            GlobalMethod.showNoInternetAlert()
        }
    }

    /// Top button trigger to history screen
    @objc func goToHistoryScreen () {
        let historyVC = HistoryViewController()
        historyVC.modalTransitionStyle = .crossDissolve
        historyVC.initDelegate(self)
        self.navigationController?.present(historyVC, animated: true, completion: nil)
    }
    
    /// Top button trigger to history screen
    @objc func goToFavouriteScreen () {
        let fv = FavouriteViewController()
        fv.modalTransitionStyle = .crossDissolve
        fv.initDelegate(self)
        self.navigationController?.present(fv, animated: true, completion: nil)
    }

    /// Navigate to Camera page
    @IBAction func didTapOnCameraButton(_ sender: UIButton) {
        let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
        
        //TODO change CaptureImageProcessVC to CameraViewController to capture image. This change is made to run on simulator
        if let cameraViewController = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CaptureImageProcessVC.self)) as? CaptureImageProcessVC {
            self.navigationController?.pushViewController(cameraViewController, animated: true)
        }
        
//        if let cameraViewController = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CameraViewController.self)) as? CameraViewController {
//            self.navigationController?.pushViewController(cameraViewController, animated: true)
//        }

        
    }

    /// Naviagete to Favorite page
    @IBAction func didTapOnFavoriteButton(_ sender: UIButton) {
        self.goToFavouriteScreen()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
               if touch.view == self.topClickView {
                topCircleImgView.isHidden = false
                selectedTab = 0
               } else if touch.view == self.bottomClickView {
                bottomCircleleImgView.isHidden = false
                selectedTab = 1
               }  else {
                   return
               }
           }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            print(self!.selectedTab)
            self?.topCircleImgView.isHidden = true
            self?.bottomCircleleImgView.isHidden = true
            self?.openLanguageSelectionScreen(isNative:self!.selectedTab)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
      
    }
    
    deinit {
        unregisterNotification()
    }
    
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.onVoiceLanguageChanged(notification:)), name: .languageSelectionVoiceNotification, object: nil)
    }
    
    func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name: .languageSelectionVoiceNotification, object: nil)
    }
    
    func openLanguageSelectionScreen(isNative: Int){
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
    
    fileprivate func updateLanguageNames() {
        print("\(HomeViewController.self) updateLanguageNames method called")
        let languageManager = LanguageSelectionManager.shared
        let nativeLangCode = languageManager.nativeLanguage
        let targetLangCode = languageManager.targetLanguage
        
        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        print("\(HomeViewController.self) updateLanguageNames nativeLanguage \(String(describing: nativeLanguage)) targetLanguage \(String(describing: targetLanguage))")
        topSysLangName.text = targetLanguage?.sysLangName
        topNativeLangNameLable.setTitle(targetLanguage?.name, for: .normal)
        bottomLangSysLangName.setTitle(nativeLanguage?.sysLangName, for: .normal)
        bottomLangNativeName.text = nativeLanguage?.name
    }

    @objc func onVoiceLanguageChanged(notification: Notification) {
        updateLanguageNames()
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

extension HomeViewController: HistoryViewControllerDelegates{
    func historyDissmissed() {
        favouriteItemCount = self.homeVM.getFavouriteItemCount()
        updateFavouriteViews()
    }
    
    func historyAllItemsDeleted() {
        topButton.removeFromSuperview()
        favouriteItemCount = self.homeVM.getFavouriteItemCount()
        updateFavouriteViews()
        self.view.removeGestureRecognizer(swipeDown)
    }
}

extension HomeViewController : FavouriteViewControllerDelegates {
    func favouriteAllItemsDeleted() {
        favouriteItemCount = 0
        updateFavouriteViews()
    }
}

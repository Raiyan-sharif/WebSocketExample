//
//  HomeViewController.swift
//  PockeTalk
//

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
    //Properties
    var homeVM : HomeViewModel!
    var selected : Bool = false
    let FontSize : CGFloat = 23.0
    var animationCounter : Int = 0
    var deviceLanguage : String = ""
    let toastVisibleTime : Double = 2.0
    let animationDuration : TimeInterval = 1.0
    let trailing : CGFloat = -20
    let width : CGFloat = 100

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
        self.navigationController?.navigationBar.isHidden = true
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
        self.topNativeLangNameLable.titleLabel?.font = UIFont.systemFont(ofSize: FontSize, weight: .bold)
        self.topNativeLangNameLable.setTitleColor(UIColor._whiteColor(), for: .normal)

        //self.topSysLangName.text = "Japanese"
        self.topSysLangName.textAlignment = .center
        self.topSysLangName.font = UIFont.systemFont(ofSize: FontSize, weight: .bold)
        self.topSysLangName.textColor = UIColor._whiteColor()

        self.bottomLangSysLangName.setTitle(deviceLanguage, for: .normal)
        self.bottomLangSysLangName.titleLabel?.textAlignment = .center
        self.bottomLangSysLangName.titleLabel?.font = UIFont.systemFont(ofSize: FontSize, weight: .bold)
        self.bottomLangSysLangName.setTitleColor(UIColor._whiteColor(), for: .normal)
        let floatingButton = GlobalMethod.setUpMicroPhoneIcon(view: self.view, width: width, height: width, trailing: trailing, bottom: trailing)
        floatingButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
        // Add top button
        view.addSubview(topButton)
        topButton.translatesAutoresizingMaskIntoConstraints = false
        topButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        topButton.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        topButton.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // Added down geture
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }

    //TODO Menu tap event
    @IBAction func menuAction(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        guard let slideMenuController = storyboard.instantiateViewController(withIdentifier: String(describing: MenuViewController.self)) as? MenuViewController else {
            return
        }

        self.navigationController?.pushViewController(slideMenuController, animated: true)

    }

    // This method is called
    @IBAction func switchLanguageDirectionAction(_ sender: UIButton) {
        if selected == true {
            selected = false
            self.directionImageView.image = UIImage(named: "down_arrow")
            self.animationChange(transitionToImageView: self.topFlipImageView, transitionFromImageView: self.bottomFlipImageView, animationOption: UIView.AnimationOptions.transitionFlipFromBottom, imageName: "gradient_blue_top_bg")

        } else {
            selected = true
            self.directionImageView.image = UIImage(named: "up_arrow")
            self.animationChange(transitionToImageView: self.bottomFlipImageView, transitionFromImageView: self.topFlipImageView, animationOption: UIView.AnimationOptions.transitionFlipFromTop, imageName: "gradient_blue_bottom_bg")
        }
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
            self.navigationController?.pushViewController(controller, animated: true);
        } else {
            GlobalMethod.showNoInternetAlert()
        }
    }

    /// Top button trigger to history screen
    @objc func goToHistoryScreen () {
        let historyVC = HistoryViewController()
        historyVC.modalTransitionStyle = .crossDissolve
        self.navigationController?.present(historyVC, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
            self.goToHistoryScreen()
        }
    }

}

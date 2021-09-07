//
//  HomeViewController.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/1/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
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
    let width : CGFloat = 50

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
        /// Check whether tutorial has already been displayed
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
        self.setUpMicroPhoneIcon()
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
        let controller = storyboard.instantiateViewController(withIdentifier: "TutorialViewController")as! TutorialViewController
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
        self.showToast(message: "Navigate to Speech Controller", seconds: toastVisibleTime)
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
}

//
// SpeechProcessingViewController.swift
// PockeTalk
//

import UIKit

//MARK: - PronunciationResultDelegate
protocol PronunciationResult: AnyObject{
    func dismissResultHome()
}

//MARK: - SpeechProcessingVCDelegates
protocol SpeechProcessingVCDelegates: AnyObject{
    func searchCountry(text: String)
}

protocol SpeechProcessingDismissDelegate : AnyObject {
    func showTutorial()
}

class SpeechProcessingViewController: BaseViewController{
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var exampleLabel: UILabel!
    @IBOutlet weak private var descriptionLabel: UILabel!
    @IBOutlet weak private var speechProcessingAnimationView: UIView!
    @IBOutlet weak private var speecProcessingRightParentView: UIView!
    @IBOutlet weak private var speechProcessingLeftParentView: UIView!
    @IBOutlet weak private var speechProcessingRightImgView: UIImageView!
    @IBOutlet weak private var speechProcessingLeftImgView: UIImageView!
    @IBOutlet weak private var rightImgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var rightImgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var leftImgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var leftImgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var pronunciationView: UIView!
    @IBOutlet weak private var pronunciationLable: UILabel!
    var talkButtonImageView = UIImageView()
    var isTapOnMenu = false

    private let TAG:String = "SpeechProcessingViewController"
    weak var speechProcessingDelegate: SpeechProcessingVCDelegates?
    weak var pronunciationDelegate : DismissPronunciationFromHistory?
    static let didPressMicroBtn = Notification.Name("didPressMicroBtn")
    
    var isFromTutorial : Bool = false
    var countDownTimer:Timer?
    var languageHasUpdated = false
    private var socketData = [Data]()
    private let selectedLanguageIndex : Int = 8
    private var speechProcessingLanguageList = [SpeechProcessingLanguages]()
    private var speechProcessingVM : SpeechProcessingViewModeling!
    
    private let lineSpacing : CGFloat = 0.5
    private let width : CGFloat = 100
    var homeMicTapTimeStamp : Int = 0
    
    private var isFinalProvided : Bool = false
    private var timer: Timer?
    private var totalTime = 0
    
    private let transionDuration : CGFloat = 0.8
    private let transformation : CGFloat = 0.6
    private let leftImgDampiing : CGFloat = 0.10
    private let rightImgDamping : CGFloat = 0.05
    private let springVelocity : CGFloat = 6.0
    
    var isFromPronunciationPractice: Bool = false
    var isHistoryPronunciation: Bool = false
    private var speechLangCode : String = "en"
    var countrySearchspeechLangCode: String = ""
    
    private var service : MAAudioService?
    var screenOpeningPurpose: SpeechProcessingScreenOpeningPurpose?
    private var isSSTavailable = false
    private var spinnerView : SpinnerView!
    
    private let changedXPos : CGFloat = 20
    private let changedYPos : CGFloat = 20
    
    private let leftImgWidth : CGFloat = 45
    private let leftImgHeight : CGFloat = 45
    private let rightImgWidth : CGFloat = 45
    private let rightImgHeight : CGFloat = 45
    let window = UIApplication.shared.keyWindow ?? UIWindow()
    var pronunciationText : String = ""
    var pronunciationLanguageCode : String = ""
    
    private var isShowTutorial : Bool = false
    private let timeDifferenceToShowTutorial : Int = 1
    private let waitingTimeToShowExampleText : Double = 2.0
    private let waitngISFinalSecond:Int = 6
    private let burmeseWaitngISFinalSecond:Int = 10
    var isMinimumLimitExceed = false
    private var connectivity = Connectivity()

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.speechProcessingVM = SpeechProcessingViewModel()
        setupUI()
        checkSocketConnection()
        setupTriangeAnimationView()
        registerForNotification()
        bindData()
        setupAudio()
        //showLoaderDependentOnApiCall()
        AppDelegate.executeLicenseTokenRefreshFunctionality(){ result in }
        LanguageEngineDownloader.shared.checkTimeAndDownloadLanguageEngineFile()
        connectivity.startMonitoring { connection, reachable in
            PrintUtility.printLog(tag:"Current Connection :", text:" \(connection) Is reachable: \(reachable)")
            if  UserDefaultsProperty<Bool>(isNetworkAvailable).value == nil && reachable == .yes{
               
                LanguageEngineDownloader.shared.checkTimeAndDownloadLanguageEngineFile()
                AppDelegate.executeLicenseTokenRefreshFunctionality(){ result in }
            } else if reachable == .no {
                //SocketManager.sharedInstance.disconnect()
            }
        }
        SocketManager.sharedInstance.socketManagerDelegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.isMinimumLimitExceed = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.isMinimumLimitExceed = true
        stopRecord()
        isTapOnMenu = false
    }
    
    deinit {
        connectivity.cancel()
        NotificationCenter.default.removeObserver(self, name: .pronumTiationTextUpdate, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self, name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self, name: UIScene.didEnterBackgroundNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
    }

    private weak var homeVC:HomeViewController?  {
        return self.parent as? HomeViewController
    }


    func checkSocketConnection(){
        ActivityIndicator.sharedInstance.show()
        var runCount = 0
         countDownTimer =  Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let `self` = self else { return }
            runCount += 1
            if SocketManager.sharedInstance.isConnected == true {
                timer.invalidate()
                ActivityIndicator.sharedInstance.hide()
            }
            if runCount == 5 {
                timer.invalidate()
                ActivityIndicator.sharedInstance.hide()
                //SocketManager.sharedInstance.disconnect()
                //self.showServerErrorAlert()
            }
        }
    }


    private func setupTriangeAnimationView(){
        self.speechProcessingRightImgView.isHidden = true
        self.speechProcessingLeftImgView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) { [weak self] in
            self?.talkButtonImageView = self?.window.viewWithTag(109) as? UIImageView ?? UIImageView()
            self?.window.addSubview(self?.speechProcessingLeftImgView ?? UIView())
            self?.window.addSubview(self?.speechProcessingRightImgView ?? UIView())
            self?.speechProcessingLeftImgView.centerXAnchor.constraint(equalTo: self!.window.centerXAnchor, constant: -25).isActive = true
            self?.speechProcessingLeftImgView.bottomAnchor.constraint(equalTo: (self?.window.viewWithTag(109) as! UIImageView).topAnchor, constant: -41).isActive = true
            self?.speechProcessingRightImgView.centerXAnchor.constraint(equalTo: self!.window.centerXAnchor, constant: 25).isActive = true
            self?.speechProcessingRightImgView.bottomAnchor.constraint(equalTo: (self?.window.viewWithTag(109) as! UIImageView).topAnchor, constant: -41).isActive = true
        }
        
    }
    
    private func setupUI () {
        addSpinner()
        
        PrintUtility.printLog(tag: TAG, text: "Speech language code \(speechLangCode)")
        self.titleLabel.text = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: speechLangCode)?.initText
        
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .semibold)
        self.titleLabel.textColor = UIColor._whiteColor()
        
        self.exampleLabel.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .regular)
        self.exampleLabel.textAlignment = .center
        self.exampleLabel.textColor = UIColor._whiteColor()
        
        self.descriptionLabel.setLineHeight(lineHeight: lineSpacing)
        self.descriptionLabel.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .regular)
        self.descriptionLabel.textAlignment = .center
        self.descriptionLabel.textColor = UIColor._whiteColor()
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.lineBreakMode = .byWordWrapping
        
        self.pronunciationView.layer.cornerRadius = 20
        self.pronunciationView.layer.masksToBounds = true
        self.pronunciationView.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)
        self.view.bottomImageView(usingState: .black)
    }

    func showLoaderDependentOnApiCall() {
        ActivityIndicator.sharedInstance.show()

        if let couponCode = UserDefaults.standard.string(forKey: kCouponCode), couponCode != "" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                ActivityIndicator.sharedInstance.hide()
            }
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                ActivityIndicator.sharedInstance.hide()
            }
        }
    }
    
    private func registerForNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
            
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }

        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIScene.didEnterBackgroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(pronunciationTextUpdate(notification:)), name:.pronumTiationTextUpdate, object: nil)
    }
    
    private func addSpinner(){
        spinnerView = SpinnerView();
        self.view.addSubview(spinnerView)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        spinnerView.isHidden = true
    }
    
    private func updateAnimation () {
        self.speechProcessingRightImgView.isHidden = false
        self.speechProcessingLeftImgView.isHidden = false
        self.leftImgHeightConstraint.isActive = true
        self.leftImgWidthConstraint.isActive = true
        self.leftImgHeightConstraint.constant = leftImgHeight
        self.leftImgWidthConstraint.constant = leftImgWidth
        self.speechProcessingLeftParentView.layoutIfNeeded()
        
        self.rightImgHeightConstraint.isActive = true
        self.rightImgWidthConstraint.isActive = true
        self.rightImgWidthConstraint.constant = rightImgWidth
        self.rightImgHeightConstraint.constant = rightImgHeight
        self.speecProcessingRightParentView.layoutIfNeeded()
        
        self.speechProcessingVM.animateRightImage(leftImage: self.speechProcessingLeftImgView, rightImage: self.speechProcessingRightImgView, yPos: self.changedYPos, xPos: self.changedXPos)
        self.speechProcessingVM.animateLeftImage(leftImage: self.speechProcessingLeftImgView, yPos: changedYPos, xPos: changedXPos)
    }
    
    private func setupAudio(){
        service = MAAudioService(nil)
        service?.getData = {[weak self] data in
            guard let `self` = self else { return }
            
            if self.languageHasUpdated{
                self.socketData.append(data)
            }else if !self.languageHasUpdated  && self.socketData.count == 0 {
                SocketManager.sharedInstance.sendVoiceData(data: data)
            }
        }
        service?.getTimer = { [weak self] count in
            guard let `self` = self else { return }
            if count == 30 {
                self.isMinimumLimitExceed = true
                self.service?.stopRecord()
                self.removeAnimation()
            }
        }
        
        service?.getPower = { [weak self] avgVal in
            guard let `self` = self else { return }
            PrintUtility.printLog(tag: "Frequency : ", text: "\(avgVal)")
            let frequency = (avgVal >= 0.4) ? 0.9 : 0.5
            self.speechProcessingVM.setFrequency(CGFloat(frequency))
        }
        
        service?.recordDidStop = { [weak self]  in
            guard let `self` = self else { return }
            if self.speechLangCode == BURMESE_LANG_CODE {
                SocketManager.sharedInstance.sendTextData(text: self.speechProcessingVM.getTextFrame(),completion:nil)
                DispatchQueue.main.async  { [weak self] in
                    guard let `self` = self else { return }
                    var runCount = 0
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self]
                        innerTimer in
                        guard let `self` = self else { return }
                        runCount += 1
                        if runCount == self.burmeseWaitngISFinalSecond {
                            innerTimer.invalidate()
                            if !self.isFinalProvided {
                                self.loaderInvisible()
                                self.removeAnimation()
                            }
                        }
                    }
                }
            } else if self.speechProcessingVM.isGettingActualData{
                self.speechProcessingVM.isGettingActualData = false
                SocketManager.sharedInstance.sendTextData(text: self.speechProcessingVM.getTextFrame(),completion:nil)
                DispatchQueue.main.async  { [weak self] in
                    guard let `self` = self else { return }
                    var runCount = 0
                    self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] innerTimer in
                        guard let `self` = self else { return }
                        runCount += 1
                        if runCount == self.waitngISFinalSecond {
                            innerTimer.invalidate()
                            if !self.isFinalProvided {
                                PrintUtility.printLog(tag: self.TAG, text: "Service.recorderDidStop GetActualData, isGettingActualData: \(self.speechProcessingVM.isGettingActualData), isFinal: \(self.isFinalProvided)")
                                self.loaderInvisible()
                                self.removeAnimation()
                                //Show microphone button when get STT text from server
                                self.showMicrophoneBtnInLanguageScene(delayTime: 1.0)
                            }
                        }
                    }
                }
            }else{
                PrintUtility.printLog(tag: self.TAG, text: "Service.recorderDidStop Didnot GetActualData, isGettingActualData: \(self.speechProcessingVM.isGettingActualData), isFinal: \(self.isFinalProvided)")
                self.loaderInvisible()
                self.removeAnimation()
                //Show microphone button when failed to get STT text from server
                self.showMicrophoneBtnInLanguageScene(delayTime: 1.0)
            }
        }
    }
    
    private func loaderInvisible(isFromTutorial:Bool = false){
        let second =  isFromTutorial ? 0.5 : 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + second) { [weak self] in
            guard let `self` = self else { return }
            //SocketManager.sharedInstance.disconnect()
            ActivityIndicator.sharedInstance.hide()
            PrintUtility.printLog(tag: self.TAG, text: "loaderInvisible")
            self.homeVC?.enableORDisableMicrophoneButton(isEnable: true)
            self.homeVC?.hideSpeechView()
            self.isSSTavailable = false
        }
    }
    
    func hideOrOpenExampleText(isHidden:Bool){
        self.exampleLabel.isHidden = isHidden
        self.descriptionLabel.isHidden = isHidden
    }
    
    func updateLanguageInRemote(){
        //DispatchQueue.main.asyncAfter(deadline:.now()+2.0) { [weak self] in
        self.speechProcessingVM.updateLanguage()
        //}
    }
    
    private func showExampleText() {
        switch ScreenTracker.sharedInstance.screenPurpose {
        case .LanguageSelectionVoice, .LanguageSelectionCamera, .LanguageHistorySelectionVoice, .LanguageHistorySelectionCamera, .LanguageSettingsSelectionVoice, .LanguageSettingsSelectionCamera:
            self.titleLabel.text = "language_selection_voice_message".localiz()
            break
        case .HomeSpeechProcessing:
            let speechLanguage = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: speechLangCode)
            self.titleLabel.text = speechLanguage?.initText
            
            DispatchQueue.main.asyncAfter(deadline:.now()+2.0) { [weak self] in
                guard let `self` = self else { return }
                self.hideOrOpenExampleText(isHidden: self.isSSTavailable)
            }
            exampleLabel.text = speechLanguage?.exampleText
            descriptionLabel.text = speechLanguage?.secText
            if speechLangCode == BURMESE_MY_LANGUAGE_CODE {
                titleLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE)
                exampleLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE)
                descriptionLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE)
            } else {
                titleLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_OTHERS_LANGUAGE)
                exampleLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_OTHERS_LANGUAGE)
                descriptionLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_OTHERS_LANGUAGE)
            }
            titleLabel.textAlignment = .center
            exampleLabel.textAlignment = .center
            descriptionLabel.textAlignment = .center
            break
        case .CountrySelectionByVoice, .CountrySettingsSelectionByVoice:
            speechLangCode == systemLanguageCodeEN ? (self.titleLabel.text = countrySearchExampleText) : (self.titleLabel.text = "country_selection_voice_msg".localiz())
            break
        case .PronunciationPractice, .HistoryScrren,.HistroyPronunctiation, .FavouriteScreen, .PurchasePlanScreen, .CameraScreen, .InitialFlow, .countryWiseLanguageList: break
        }
    }
    
    func isSTTDataAvailable() -> Bool {
        let speechLanguage = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: speechLangCode)
        if titleLabel.text == speechLanguage?.initText {
            return true
        } else {
            return false
        }
    }
    
    private func showTutorial () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTutorialViewController)as! TutorialViewController
        controller.delegate = self
        self.homeVC!.add(asChildViewController: controller, containerView: self.homeVC!.homeContainerView)
        PrintUtility.printLog(tag: TAG, text: "Showing Tutorial")
        self.loaderInvisible(isFromTutorial: true)
    }
    
    //MARK: - Load Data
    private func bindData(){
        speechProcessingVM.isFinal.bindAndFire{ [weak self] isFinal  in
            guard let `self` = self else { return }
            if isFinal{
                self.isFinalProvided = true
                self.timer?.invalidate()
                ActivityIndicator.sharedInstance.hide()
                PrintUtility.printLog(tag: self.TAG, text: "isFinal: \(self.isFinalProvided)")
                self.service?.stopRecord()
                self.service?.timerInvalidate()
                self.isSSTavailable = false
                SocketManager.sharedInstance.disconnect()
                LanguageSelectionManager.shared.tempSourceLanguage = nil
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                    switch ScreenTracker.sharedInstance.screenPurpose {
                    case .CountrySelectionByVoice:
                        LanguageSelectionManager.shared.tempSourceLanguage = self.speechLangCode
                        NotificationCenter.default.post(name: .countySlectionByVoiceNotofication, object: nil, userInfo: ["country":self.speechProcessingVM.getSST_Text.value])
                        
                        self.homeVC?.hideSpeechView()
                        break
                    case .CountrySettingsSelectionByVoice:
                        LanguageSelectionManager.shared.tempSourceLanguage = self.speechLangCode
                        NotificationCenter.default.post(name: .countySettingsSlectionByVoiceNotofication, object: nil, userInfo: ["country":self.speechProcessingVM.getSST_Text.value])
                        
                        self.homeVC?.hideSpeechView()
                        break
                    case .LanguageSelectionVoice:
                        LanguageSelectionManager.shared.findLanugageCodeAndSelect(self.speechProcessingVM.getSST_Text.value, screen: SpeechProcessingScreenOpeningPurpose.LanguageSelectionVoice)
                        NotificationCenter.default.post(name: .languageListNotofication, object: nil)
                        
                        self.homeVC?.hideSpeechView()
                        break
                    case  .LanguageHistorySelectionVoice:
                        LanguageSelectionManager.shared.findLanugageCodeAndSelect(self.speechProcessingVM.getSST_Text.value, screen: SpeechProcessingScreenOpeningPurpose.LanguageHistorySelectionVoice)
                        NotificationCenter.default.post(name: .languageHistoryListNotification, object: nil)
                        
                        self.homeVC?.hideSpeechView()
                        break
                    case .LanguageSettingsSelectionVoice:
                        LanguageSelectionManager.shared.findLanugageCodeAndSelect(self.speechProcessingVM.getSST_Text.value, screen: SpeechProcessingScreenOpeningPurpose.LanguageSettingsSelectionVoice)
                        NotificationCenter.default.post(name: .languageSettingsListNotification, object: nil)
                        
                        self.homeVC?.hideSpeechView()
                        break
                    case .LanguageSelectionCamera:
                        CameraLanguageSelectionViewModel.shared.findLanugageCodeAndSelect(self.speechProcessingVM.getSST_Text.value, screen: .LanguageSelectionCamera)
                        NotificationCenter.default.post(name: .cameraSelectionLanguage, object: nil, userInfo:nil)
                        
                        self.homeVC?.hideSpeechView()
                        break
                    case .LanguageSettingsSelectionCamera:
                        CameraLanguageSelectionViewModel.shared.findLanugageCodeAndSelect(self.speechProcessingVM.getSST_Text.value, screen: .LanguageSettingsSelectionCamera)
                        
                        NotificationCenter.default.post(name: .cameraLanguageSettingsListNotification, object: nil, userInfo:nil)
                        
                        self.homeVC?.hideSpeechView()
                        break
                    case .LanguageHistorySelectionCamera:
                        CameraLanguageSelectionViewModel.shared.findLanugageCodeAndSelect(self.speechProcessingVM.getSST_Text.value, screen: .LanguageHistorySelectionCamera)
                        NotificationCenter.default.post(name: .cameraHistorySelectionLanguage, object: nil, userInfo:nil)
                        
                        self.homeVC?.hideSpeechView()
                        break
                    case .HomeSpeechProcessing :
                        AppRater.shared.incrementTranslationCount()
                        self.showTtsAlert(ttt: self.speechProcessingVM.getTTT_Text,stt: self.speechProcessingVM.getSST_Text.value)
                        break
                    case .PronunciationPractice,.HistroyPronunctiation:
                        self.homeVC?.hideSpeechView()
                        self.showPronunciationPracticeResult(stt: self.speechProcessingVM.getSST_Text.value)
                    default:
                        break
                    }
                    self.homeVC?.enableORDisableMicrophoneButton(isEnable: true)
                    
                    //Show microphone button on language scene depend on screen purpose
                    self.showMicrophoneBtnInLanguageScene(delayTime: 0)
                }
            }
        }
        speechProcessingVM.getSST_Text.bindAndFire { [weak self] sstText  in
            guard let `self` = self else { return }
            if sstText.count > 0{
                self.isSSTavailable = true
                self.titleLabel.text = sstText
                self.hideOrOpenExampleText(isHidden: true)
            }else{
                self.isSSTavailable = false
            }
            
            if self.speechLangCode == BURMESE_LANG_CODE {
                self.titleLabel.text = self.speechProcessingVM.getSST_Text.value
            }
        }
        
        speechProcessingVM.isUpdatedAPI.bindAndFire { [weak self] isUpdated in
            guard let `self` = self else { return }
            if isUpdated{
                if self.socketData.count > 0{
                    for data in self.socketData.reversed(){
                        SocketManager.sharedInstance.sendVoiceData(data: data)
                    }
                    self.socketData.removeAll()
                }
                self.languageHasUpdated = false
            }
        }
    }
    
    private func showTtsAlert ( ttt: String, stt: String ) {
        let languageManager = LanguageSelectionManager.shared
        let isArrowUp = languageManager.isArrowUp
        let isTop = isArrowUp ? IsTop.noTop.rawValue : IsTop.top.rawValue
        var nativeText = ""
        var targetText = ""
        let nativeLangCode = LanguageSelectionManager.shared.bottomLanguage
        let targetLangCode = LanguageSelectionManager.shared.topLanguage
        PrintUtility.printLog(tag: TAG, text: "nativeLangCode \(nativeLangCode) targetLangCode \(targetLangCode)  isArrowUp: \(isArrowUp)" )
        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        var nativeLangName = ""
        var targetLangName = ""
        
        PrintUtility.printLog(tag: TAG, text: "nativeLang \(nativeLanguage?.name ?? "") targetLang \(targetLanguage?.name ?? "")")
        nativeText = GlobalMethod.removeQuotationMark(input: stt)
        targetText = GlobalMethod.removeQuotationMark(input: ttt)
        
        if isArrowUp == true{
            nativeLangName = nativeLanguage?.name ?? ""
            targetLangName = targetLanguage?.name ?? ""
        }else{
            nativeLangName = targetLanguage?.name ?? ""
            targetLangName = nativeLanguage?.name ?? ""
        }
        
        let chatItem =  ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangName, textNativeLanguage: nativeLangName, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isTop, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue)
        
        self.showTTSScreen(chatItemModel: HistoryChatItemModel(chatItem: chatItem, idxPath: nil), hideMenuButton: false, hideBottmSection: false, saveDataToDB: true, fromHistory: false, ttsAlertControllerDelegate: nil, isRecreation: false, fromSpeech: true)
    }

    @objc private func pronunciationTextUpdate(notification:NSNotification) {
        if let value = notification.userInfo!["pronuntiationText"] as? PronuntiationValue{
            pronunciationLable.text = value.orginalText
            pronunciationText = value.orginalText
            pronunciationLanguageCode = value.languageCcode
            LanguageSelectionManager.shared.tempSourceLanguage = pronunciationLanguageCode
        }else{
            if LanguageSelectionManager.shared.isArrowUp{
                speechLangCode = LanguageSelectionManager.shared.bottomLanguage
                LanguageSelectionManager.shared.tempSourceLanguage = LanguageSelectionManager.shared.bottomLanguage
            }else{
                speechLangCode = LanguageSelectionManager.shared.topLanguage
                LanguageSelectionManager.shared.tempSourceLanguage = LanguageSelectionManager.shared.topLanguage
            }
            self.languageHasUpdated = true
        }
    }
    
    @objc private func appDidEnterBackground() {
        PrintUtility.printLog(tag: TAG, text: "Did enter background")
        //TODO: Comment out this code because it has some impact on the STT process in background
        /*
        self.service?.timerInvalidate()
        self.removeAnimation()
         */

        countDownTimer?.invalidate()
        countDownTimer = nil
        ActivityIndicator.sharedInstance.hide()
    }
    
    @objc private func appBecomeActive() {
        //self.loaderInvisible()
        checkSocketConnection()
        AppDelegate.executeLicenseTokenRefreshFunctionality(){ result in
        }
        PrintUtility.printLog(tag: TAG, text: "Become Active")
        self.exampleLabel.text = ""
        self.descriptionLabel.text = ""
    }

    @objc private func appWillEnterForeground() {
        PrintUtility.printLog(tag: TAG, text: "Will Enter foreground")
        SocketManager.sharedInstance.connect()
        LanguageEngineDownloader.shared.checkTimeAndDownloadLanguageEngineFile()
    }

    func showPronunciationPracticeResult (stt:String) {
        let pronumtiationValue = PronuntiationValue(practiceText: stt, orginalText: pronunciationText, languageCcode: pronunciationLanguageCode)
        NotificationCenter.default.post(name: .pronuntiationNotification, object: nil, userInfo: ["value":pronumtiationValue])
    }
    
    private func showMicrophoneBtnInLanguageScene(delayTime: Double){
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice ||
                ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionVoice ||
                ScreenTracker.sharedInstance.screenPurpose == .CountrySelectionByVoice ||
                ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionCamera ||
                ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionCamera {
                if FloatingMikeButton.sharedInstance.hiddenStatus() {
                    FloatingMikeButton.sharedInstance.isHidden(false)
                }
            }
        }
    }
}

//MARK: - PronunciationResult
extension SpeechProcessingViewController: PronunciationResult {
    func dismissResultHome() {}
}

//MARK: - SpeechControllerDismissDelegate
extension SpeechProcessingViewController : SpeechControllerDismissDelegate {
    func dismiss() {
        self.homeVC?.homeContainerView.isHidden = true
    }
}

//MARK: - SocketManagerDelegate
extension SpeechProcessingViewController : SocketManagerDelegate{
    func socket(isConnected: Bool) {
        //SocketManager.sharedInstance.connect()
    }

    func getText(text: String) {
        speechProcessingVM.isGettingActualData = true
        speechProcessingVM.setTextFromScoket(value: text)
    }
    
    func getData(data: Data) {}
    func faildSocketConnection(value: String) {}
}

//MARK: - HomeVCDelegate
extension SpeechProcessingViewController: HomeVCDelegate{
    func startRecord() {
        PrintUtility.printLog(tag: TAG, text: "Start Recording")
        ActivityIndicator.sharedInstance.hide()
        isFinalProvided = false
        if self.homeVC!.isFromPronuntiationPractice(){
            NotificationCenter.default.post(name: .pronuntiationResultNotification, object: nil, userInfo:nil)
            NotificationCenter.default.post(name: .pronuntiationTTSStopNotification, object: nil, userInfo:nil)
            
            pronunciationView.isHidden = false
            titleLabel.isHidden = true
            hideOrOpenExampleText(isHidden: true)
        }else{
            pronunciationView.isHidden = true
            titleLabel.isHidden = false
            showExampleText()
            speechProcessingVM.startTime = Date()
            showExampleIfNotgetResponse()
        }
        
        speechProcessingVM.isGettingActualData = false
        service?.startRecord()
        SpeechProcessingViewModel.isLoading = false
        updateAnimation()
        addSpinner()
    }
    
    func stopRecord() {
        PrintUtility.printLog(tag: TAG, text: "Stop Recording")
        if !self.isFinalProvided  && !isMinimumLimitExceed{
            ActivityIndicator.sharedInstance.show(hasBackground: false)
        }
        service?.stopRecord()
        service?.timerInvalidate()
        if ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing{
            if self.speechLangCode == BURMESE_LANG_CODE {
                self.titleLabel.text = ""
                self.exampleLabel.text = ""
                self.descriptionLabel.text = ""
            }
            hideOrOpenExampleText(isHidden: true)
            if speechProcessingVM.getTimeDifference(endTime: Date()) < 1  && !isSSTavailable && !isTapOnMenu {
                self.showTutorial()
            }
        }
        SpeechProcessingViewModel.isLoading = true
        removeAnimation()
    }
}

//MARK: - SpeechProcessingViewController Extension
extension SpeechProcessingViewController{
    func removeAnimation(){
        self.speechProcessingLeftImgView.layer.removeAllAnimations()
        self.speechProcessingRightImgView.layer.removeAllAnimations()
        self.speechProcessingRightImgView.isHidden = true
        self.speechProcessingLeftImgView.isHidden = true
        self.talkButtonImageView.image = #imageLiteral(resourceName: "talk_button").withRenderingMode(.alwaysOriginal)
    }
    
    func showTTSScreen(chatItemModel: HistoryChatItemModel, hideMenuButton: Bool, hideBottmSection: Bool, saveDataToDB: Bool, fromHistory:Bool, ttsAlertControllerDelegate: TtsAlertControllerDelegate?, isRecreation: Bool, fromSpeech: Bool = false){
        let chatItem = chatItemModel.chatItem!
        if saveDataToDB == true{
            do {
                let row = try ChatDBModel.init().insert(item: chatItem)
                chatItem.id = row
                UserDefaultsProperty<Int64>(kLastSavedChatID).value = row
            } catch _ {}
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let  ttsVC = storyboard.instantiateViewController(withIdentifier: KTtsAlertController) as! TtsAlertController
        ttsVC.chatItemModel = chatItemModel
        ttsVC.hideMenuButton = hideMenuButton
        ttsVC.hideBottomView = hideBottmSection
        ttsVC.isFromHistory = fromHistory
        ttsVC.isRecreation = isRecreation
        ttsVC.isFromSpeechProcessing = fromSpeech

        self.homeVC?.add(asChildViewController: ttsVC, containerView:homeVC!.homeContainerView, animation: nil)
        homeVC?.hideSpeechView()
        ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
        
    }
    
    func showExampleIfNotgetResponse(){
        if !isFromPronunciationPractice{
            DispatchQueue.main.asyncAfter(deadline: .now() + waitingTimeToShowExampleText) { [weak self]  in
                /// after 2 second of interval, check if server data is available. If not available show the example text
                guard let `self` = self else { return }
                if !self.isSSTavailable {
                    self.showExampleText()
                }
            }
        }
    }
    
    func updateLanguageType(){
        let languageManager = LanguageSelectionManager.shared
        pronunciationView.isHidden = true
        switch ScreenTracker.sharedInstance.screenPurpose {
        case .HomeSpeechProcessing:
            languageManager.tempSourceLanguage = nil
            if languageManager.isArrowUp{
                speechLangCode = languageManager.bottomLanguage
            }else{
                speechLangCode = languageManager.topLanguage
            }
            break
        case .LanguageSelectionVoice,.LanguageSelectionCamera, .LanguageHistorySelectionVoice, .LanguageHistorySelectionCamera, .LanguageSettingsSelectionVoice, .LanguageSettingsSelectionCamera:
            if countrySearchspeechLangCode != "" {
                speechLangCode = countrySearchspeechLangCode
            } else {
                speechLangCode = LanguageManager.shared.currentLanguage.rawValue
            }
            languageManager.tempSourceLanguage = speechLangCode
            languageHasUpdated = true
            break
        case .CountrySelectionByVoice, .CountrySettingsSelectionByVoice:
            speechLangCode = LanguageSelectionManager.shared.tempSourceLanguage ?? LanguageManager.shared.currentLanguage.rawValue
            languageHasUpdated = true
            break
        case .PronunciationPractice, .HistroyPronunctiation:
            speechLangCode = pronunciationLanguageCode
            languageHasUpdated = true
            break
        default:
            break
        }
    }
}

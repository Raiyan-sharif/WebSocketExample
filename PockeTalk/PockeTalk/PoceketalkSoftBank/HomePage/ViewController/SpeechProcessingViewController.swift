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

protocol SpeechProcessingDismissDelegate : class {
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
    @IBOutlet weak private var bottomTalkView: UIView!
    @IBOutlet weak private var rightImgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var rightImgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var leftImgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak private var leftImgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var pronunciationView: UIView!
    @IBOutlet weak private var pronunciationLable: UILabel!

    private let TAG:String = "SpeechProcessingViewController"
    weak var speechProcessingDelegate: SpeechProcessingVCDelegates?
    weak var pronunciationDelegate : DismissPronunciationFromHistory?
    static let didPressMicroBtn = Notification.Name("didPressMicroBtn")

    var isFromTutorial : Bool = false

    var languageHasUpdated = false
    private var socketData = [Data]()
    private let selectedLanguageIndex : Int = 8
    private var speechProcessingLanguageList = [SpeechProcessingLanguages]()
    private var speechProcessingVM : SpeechProcessingViewModeling!

    private let lineSpacing : CGFloat = 0.5
    private let width : CGFloat = 100
    var homeMicTapTimeStamp : Int = 0

    private var isSpeechProvided : Bool = false
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
   // var socketManager = SocketManager.sharedInstance
    private var isSSTavailable = false
    private var spinnerView : SpinnerView!
    
    private let changedXPos : CGFloat = 15
    private let changedYPos : CGFloat = 20
    
    private let leftImgWidth : CGFloat = 30
    private let leftImgHeight : CGFloat = 35
    private let rightImgWidth : CGFloat = 45
    private let rightImgHeight : CGFloat = 55
    
    var pronunciationText : String = ""
    var pronunciationLanguageCode : String = ""
    //weak var speechProcessingDismissDelegate : SpeechProcessingDismissDelegate?
    
    private var isShowTutorial : Bool = false
    private let timeDifferenceToShowTutorial : Int = 1
    private let waitingTimeToShowExampleText : Double = 2.0
    private let waitngISFinalSecond:Int = 6
    var isNetworkConnected = true
    var isMinimumLimitExceed = false

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.speechProcessingVM = SpeechProcessingViewModel()
        //socketManager.connect()
        //socketManager.socketManagerDelegate = self
        
        setupUI()
        registerForNotification()
        bindData()
        setupAudio()

        PrintUtility.printLog(tag: TAG, text: "languageHasUpdated \(languageHasUpdated)")
        Connectivity.shareInstance.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        //self.updateAnimation()
    }
    


    private weak var homeVC:HomeViewController?  {
        return self.parent as? HomeViewController
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
        
//        if isFromPronunciationPractice {
//            fromPronunciation()
//        }
        self.pronunciationView.layer.cornerRadius = 20
        self.pronunciationView.layer.masksToBounds = true
        self.pronunciationView.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)
        
//        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomTalkView, width: width, height: width)
//        talkButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }
    
    private func registerForNotification() {
        /// App become active
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

        ///app entered background
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self else { return }
            PrintUtility.printLog(tag: "Foreground", text: "last Background")
            self.service?.timerInvalidate()
           // self.service?.stopRecord()
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
        self.leftImgHeightConstraint.isActive = true
        self.leftImgWidthConstraint.isActive = true
        self.leftImgHeightConstraint.constant = leftImgHeight
        self.leftImgWidthConstraint.constant = leftImgWidth
        self.speechProcessingLeftParentView.layoutIfNeeded()
        
        self.speechProcessingVM.animateLeftImage(leftImage: self.speechProcessingLeftImgView, yPos: changedYPos, xPos: changedXPos)
        
        self.rightImgHeightConstraint.isActive = true
        self.rightImgWidthConstraint.isActive = true
        self.rightImgWidthConstraint.constant = rightImgWidth
        self.rightImgHeightConstraint.constant = rightImgHeight
        self.speecProcessingRightParentView.layoutIfNeeded()
        
        self.speechProcessingVM.animateRightImage(rightImage: self.speechProcessingRightImgView, yPos: changedYPos, xPos: changedXPos)
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
            }
        }
        service?.recordDidStop = { [weak self]  in
            guard let `self` = self else { return }
            if self.speechProcessingVM.isGettingActualData{
                self.speechProcessingVM.isGettingActualData = false
                if !self.isNetworkConnected{
                    self.loaderInvisible()
                    return
                }
                SocketManager.sharedInstance.sendTextData(text: self.speechProcessingVM.getTextFrame(),completion: {
                    DispatchQueue.main.async  { [weak self] in
                        guard let `self` = self else { return }
                        var runCount = 0
                        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] innerTimer in
                            guard let `self` = self else { return }
                            runCount += 1
                            if runCount == self.waitngISFinalSecond {
                                innerTimer.invalidate()
                                if !self.speechProcessingVM.isFinal.value {
                                    //self.navigationController?.popViewController(animated: true)
                                    self.loaderInvisible()
                                    SocketManager.sharedInstance.disconnect()
                                }
                            }
                        }
                    }
                    
                })
            }else{
                self.loaderInvisible()

            }}}

    private func loaderInvisible(){
        self.spinnerView.isHidden = true
        self.homeVC?.enableORDisableMicrophoneButton(isEnable: true)
        self.homeVC?.hideSpeechView()
        isSSTavailable = false
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
        let speechLanguage = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: speechLangCode)
        self.titleLabel.text = speechLanguage?.initText
        DispatchQueue.main.asyncAfter(deadline:.now()+2.0) { [weak self] in
            guard let `self` = self else { return }
            self.hideOrOpenExampleText(isHidden: self.isSSTavailable)
        }
        exampleLabel.text = speechLanguage?.exampleText
        descriptionLabel.text = speechLanguage?.secText
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
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK: - Load Data
    private func bindData(){
        speechProcessingVM.isFinal.bindAndFire{ [weak self] isFinal  in
            guard let `self` = self else { return }
            if isFinal{
                if !self.isNetworkConnected{
                    self.loaderInvisible()
                    return
                }
                self.timer?.invalidate()
                self.spinnerView.isHidden = true
                self.service?.stopRecord()
                self.service?.timerInvalidate()
                self.isSSTavailable = false
                SocketManager.sharedInstance.disconnect()
                self.homeVC?.enableORDisableMicrophoneButton(isEnable: true)
                LanguageSelectionManager.shared.tempSourceLanguage = nil
                DispatchQueue.main.async { [weak self] in
                    guard let `self` = self else { return }
                //if let purpose = self.screenPurpose{
                switch ScreenTracker.sharedInstance.screenPurpose {
                    case .CountrySelectionByVoice:
                       // self.speechProcessingDelegate?.searchCountry(text: self.speechProcessingVM.getSST_Text.value)
                        NotificationCenter.default.post(name: .countySlectionByVoiceNotofication, object: nil, userInfo: ["country":self.speechProcessingVM.getSST_Text.value])
                        
                        /// notification for showing microphone btn
                        NotificationCenter.default.post(name: .tapOffMicrophoneCountrySelectionVoice, object: nil)
                        //self.navigationController?.popViewController(animated: true)
                        self.homeVC?.hideSpeechView()
                        self.homeVC?.enableORDisableMicrophoneButton(isEnable: true)
                        break
                    case .LanguageSelectionVoice:
                        LanguageSelectionManager.shared.findLanugageCodeAndSelect(self.speechProcessingVM.getSST_Text.value)
                        
                        /// notification for showing microphone btn
                        NotificationCenter.default.post(name: .languageListNotofication, object: nil)
                        NotificationCenter.default.post(name: .tapOffMicrophoneLanguageSelectionVoice, object: nil)
                        self.homeVC?.hideSpeechView()
                        self.homeVC?.enableORDisableMicrophoneButton(isEnable: true)
                        break
                    case .LanguageSelectionCamera:
                        CameraLanguageSelectionViewModel.shared.findLanugageCodeAndSelect(self.speechProcessingVM.getSST_Text.value)
                        NotificationCenter.default.post(name: .cameraSelectionLanguage, object: nil, userInfo:nil)
                        NotificationCenter.default.post(name: .tapOffMicrophoneCountrySelectionVoiceCamera, object: nil)
                        self.homeVC?.hideSpeechView()
                        self.homeVC?.enableORDisableMicrophoneButton(isEnable: true)
                        break
                    case .HomeSpeechProcessing :
                        self.showTtsAlert(ttt: self.speechProcessingVM.getTTT_Text,stt: self.speechProcessingVM.getSST_Text.value)
                        break
                case .PronunciationPractice,.HistroyPronunctiation:
                        self.homeVC?.hideSpeechView()
                        self.showPronunciationPracticeResult(stt: self.speechProcessingVM.getSST_Text.value)

                default:
                    break
                    }
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

    deinit {
        NotificationCenter.default.removeObserver(self, name: .pronumTiationTextUpdate, object: nil)
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

    @objc private func appBecomeActive() {
        self.exampleLabel.text = ""
        self.descriptionLabel.text = ""
        
//        if let topVC = UIApplication.getTopViewController(), topVC is SpeechProcessingViewController {
//            service?.startRecord()
//        }
//        addSpinner()
//        updateAnimation ()
        self.loaderInvisible()
    }
    


    func showPronunciationPracticeResult (stt:String) {
        let pronumtiationValue = PronuntiationValue(practiceText: stt, orginalText: pronunciationText, languageCcode: pronunciationLanguageCode)
        NotificationCenter.default.post(name: .pronuntiationNotification, object: nil, userInfo: ["value":pronumtiationValue])
        }
}

//MARK: - PronunciationResult
extension SpeechProcessingViewController: PronunciationResult {
    func dismissResultHome() {

    }

}

//MARK: - SpeechControllerDismissDelegate
extension SpeechProcessingViewController : SpeechControllerDismissDelegate {
    func dismiss() {
        self.navigationController?.popViewController(animated: false)
        if let transitionView = self.view{
            UIView.transition(with:transitionView, duration: TimeInterval(self.transionDuration), options: .showHideTransitionViews, animations: nil, completion: nil)
        }
    }
}

//MARK: - SocketManagerDelegate
extension SpeechProcessingViewController : SocketManagerDelegate{
    func socket(isConnected: Bool) {
    }

    func getText(text: String) {
        speechProcessingVM.isGettingActualData = true
        speechProcessingVM.setTextFromScoket(value: text)
    }
    
    func getData(data: Data) {}
    func faildSocketConnection(value: String) {}
}


extension SpeechProcessingViewController:HomeVCDelegate{

    func startRecord() {
       // updateLanguageType()

        if self.homeVC!.isFromPronuntiationPractice(){
            NotificationCenter.default.post(name: .pronuntiationResultNotification, object: nil, userInfo:nil)
            NotificationCenter.default.post(name: .pronuntiationTTSStopNotification, object: nil, userInfo:nil)
            //FromPronunciation()
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
        updateAnimation()
        addSpinner()
    }

    func stopRecord() {
        self.spinnerView.isHidden = false
        service?.stopRecord()
        service?.timerInvalidate()
        if ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing{
            if speechProcessingVM.getTimeDifference(endTime: Date()) < 2  && !isSSTavailable {
                self.showTutorial()
            }
        }
        removeAnimation()
    }

}

extension SpeechProcessingViewController{


    func removeAnimation(){
        self.speechProcessingLeftImgView.layer.removeAllAnimations()
        self.speechProcessingRightImgView.layer.removeAllAnimations()
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
        //ttsVC.delegate = self
        ttsVC.chatItemModel = chatItemModel
        ttsVC.hideMenuButton = hideMenuButton
        ttsVC.hideBottomView = hideBottmSection
        ttsVC.isFromHistory = fromHistory
        //ttsVC!.ttsAlertControllerDelegate = ttsAlertControllerDelegate
        ttsVC.isRecreation = isRecreation
        ttsVC.isFromSpeechProcessing = fromSpeech
        //isViewOpened = .tts

        self.homeVC?.add(asChildViewController: ttsVC, containerView:homeVC!.homeContainerView)
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
        //if let purpose = self.screenPurpose{
            switch ScreenTracker.sharedInstance.screenPurpose {
            case .HomeSpeechProcessing:
                languageManager.tempSourceLanguage = nil
                if languageManager.isArrowUp{
                    speechLangCode = languageManager.bottomLanguage
                }else{
                    speechLangCode = languageManager.topLanguage
                }
                break
            case .LanguageSelectionVoice,.LanguageSelectionCamera,.CountrySelectionByVoice:
                if countrySearchspeechLangCode != "" {
                    speechLangCode = countrySearchspeechLangCode
                } else {
                    speechLangCode = LanguageManager.shared.currentLanguage.rawValue
                }
                languageManager.tempSourceLanguage = speechLangCode
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

extension SpeechProcessingViewController : ConnectivityDelegate{
    func checkInternetConnection(_ state: ConnectionState, isLowDataMode: Bool) {
        isNetworkConnected = state == .connected
    }
}

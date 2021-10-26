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
    private var socketManager = SocketManager.sharedInstance
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
    weak var speechProcessingDismissDelegate : SpeechProcessingDismissDelegate?
    
    private var isShowTutorial : Bool = false
    private let timeDifferenceToShowTutorial : Int = 1
    private let waitingTimeToShowExampleText : Double = 2.0
    private let waitngISFinalSecond:Int = 6
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.speechProcessingVM = SpeechProcessingViewModel()
        SocketManager.sharedInstance.connect()
        socketManager.socketManagerDelegate = self
        
        setupSpeechLangCode()
        setupUI()
        registerForNotification()
        bindData()
        setupAudio()
        
        ///update language
        if languageHasUpdated {
            speechProcessingVM.updateLanguage()
        }
        
        ///show example text
        setExampleText()
        PrintUtility.printLog(tag: TAG, text: "languageHasUpdated \(languageHasUpdated)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.updateAnimation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(SpeechProcessingViewController.didPressMicroBtn)
    }
    
    //MARK: - Initial Setup
    func initDelegate<T>(_ vc: T) {
        self.speechProcessingDelegate = vc.self as? SpeechProcessingVCDelegates
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
        
        if isFromPronunciationPractice {
            fromPronunciation()
        }
        
        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomTalkView, width: width, height: width)
        talkButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }
    
    private func registerForNotification() {
        /// App become active
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        ///Microphone btn press
        NotificationCenter.default.addObserver(self, selector: #selector(didPressMicroBtn(_:)), name: SpeechProcessingViewController.didPressMicroBtn, object: nil)
        
        ///app entered background
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self else { return }
            PrintUtility.printLog(tag: "Foreground", text: "last Background")
            self.service?.timerInvalidate()
            self.service?.stopRecord()
        }
    }
    
    private func setupSpeechLangCode() {
        let languageManager = LanguageSelectionManager.shared
        pronunciationView.isHidden = true
        if let purpose = self.screenOpeningPurpose {
            switch purpose {
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
            case .PronunciationPractice:
                speechLangCode = pronunciationLanguageCode
                break
            }
        }
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
                self.socketManager.sendVoiceData(data: data)
            }
        }
        service?.getTimer = { [weak self] count in
            guard let `self` = self else { return }
            if count == 30 {
                self.service?.stopRecord()
            }
        }
        service?.recordDidStop = { [weak self]  in
            guard let `self` = self else { return }
            if self.speechProcessingVM.isGettingActualData{
                self.speechProcessingVM.isGettingActualData = false
                self.socketManager.sendTextData(text: self.speechProcessingVM.getTextFrame(),completion: {
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
                                }
                            }
                        }
                    }
                    
                    
                    
                })
            }else{
                self.spinnerView.isHidden = true
                //                self.navigationController?.popViewController(animated: true)
                if self.isFromPronunciationPractice && !self.isHistoryPronunciation {
                    let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeViewController") as! PronunciationPracticeViewController
                    vc.orginalText = self.pronunciationText
                    vc.languageCode = self.pronunciationLanguageCode
                    vc.isFromSpeechProcessing = true
                    vc.speechDelegate = self
                    if(self.navigationController != nil){
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else{
                        vc.modalPresentationStyle = .fullScreen
                        self.present(vc, animated: true, completion: nil)
                    }
                } else if self.isShowTutorial == true {
                    if(self.navigationController != nil){
                        if self.isFromTutorial {
                            self.navigationController?.popViewController(animated: false)
                            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
                        } else {
                            self.navigationController?.popViewController(animated: false)
                        }
                    }else{
                        self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
                    }
                    self.speechProcessingDismissDelegate?.showTutorial()
                } else {
                    if(self.navigationController != nil){
                        if self.isFromTutorial {
                            self.navigationController?.popViewController(animated: false)
                            self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
                        } else {
                            self.navigationController?.popViewController(animated: true)
                        }

                    }else{
                        //self.dismiss(animated: true, completion: nil)
                        if let historyVC = self.presentingViewController  as? HistoryViewController{
                            historyVC.presentingViewController?.dismiss(animated: true, completion: nil)
                        }else if let favVC = self.presentingViewController  as? FavouriteViewController{
                            favVC.presentingViewController?.dismiss(animated: true, completion: nil)
                        }else if let ttsVC = self.presentingViewController?.presentingViewController as? HistoryViewController{
                            ttsVC.presentingViewController?.dismiss(animated: true, completion: nil)
                        }else{
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                }
            }
        }
        service?.startRecord()
    }

    private func setExampleText() {
        if !isFromPronunciationPractice {
            DispatchQueue.main.asyncAfter(deadline: .now() + waitingTimeToShowExampleText) { [weak self]  in
                guard let `self` = self else { return }
                if self.isSSTavailable == false {
                    self.showExampleText()
                }
            }
        }
    }
    
    private func showExampleText() {
        let speechLanguage = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: speechLangCode)
        exampleLabel.isHidden = false
        descriptionLabel.isHidden = false
        exampleLabel.text = speechLanguage?.exampleText
        descriptionLabel.text = speechLanguage?.secText
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
                self.timer?.invalidate()
                self.spinnerView.isHidden = true
                self.service?.stopRecord()
                self.service?.timerInvalidate()
                //SocketManager.sharedInstance.disconnect()
                LanguageSelectionManager.shared.tempSourceLanguage = nil
                if let purpose = self.screenOpeningPurpose{
                    switch purpose {
                    case .CountrySelectionByVoice:
                        self.speechProcessingDelegate?.searchCountry(text: self.speechProcessingVM.getSST_Text.value)
                        self.navigationController?.popViewController(animated: true)
                        break
                    case .LanguageSelectionVoice:
                        LanguageSelectionManager.shared.findLanugageCodeAndSelect(self.speechProcessingVM.getSST_Text.value)
                        self.navigationController?.popViewController(animated: true)
                        break
                    case .LanguageSelectionCamera:
                        CameraLanguageSelectionViewModel.shared.findLanugageCodeAndSelect(self.speechProcessingVM.getSST_Text.value)
                        self.navigationController?.popViewController(animated: true)
                        break
                    case .HomeSpeechProcessing :
                        self.showTtsAlert(ttt: self.speechProcessingVM.getTTT_Text,stt: self.speechProcessingVM.getSST_Text.value)
                        break
                    case .PronunciationPractice:
                        self.showPronunciationPracticeResult(stt: self.speechProcessingVM.getSST_Text.value)
                    }
                }
            }
        }
        speechProcessingVM.getSST_Text.bindAndFire { [weak self] sstText  in
            guard let `self` = self else { return }
            if sstText.count > 0{
                self.isSSTavailable = true
                self.titleLabel.text = sstText
                self.exampleLabel.isHidden = true
                self.descriptionLabel.isHidden = true
            }
        }
        speechProcessingVM.isUpdatedAPI.bindAndFire { [weak self] isUpdated in
            guard let `self` = self else { return }
            if isUpdated{
                if self.socketData.count > 0{
                    for data in self.socketData.reversed(){
                        self.socketManager.sendVoiceData(data: data)
                    }
                    self.socketData.removeAll()
                }
                self.languageHasUpdated = false
            }
        }
    }
    
    //MARK: - IBActions
    @objc private func microphoneTapAction (sender:UIButton) {
        let currentTs = GlobalMethod.getCurrentTimeStamp(with: 0)
        let timeGap = self.speechProcessingVM.getTimeDifference(startTime: homeMicTapTimeStamp, endTime: currentTs)
        if timeGap <= timeDifferenceToShowTutorial {
            /// show tutorial screen if talk button got tapped within 1 sec of tapping talk button of Home
            self.isShowTutorial = true
            service?.timerInvalidate()
            service?.stopRecord()
        } else {
            spinnerView.isHidden = false
            speechProcessingLeftImgView.isHidden = true
            speechProcessingRightImgView.isHidden = true
            service?.stopRecord()
            service?.timerInvalidate()
        }
    }
    
    @objc private func didPressMicroBtn(_ notification: Notification) {
        if let string = notification.userInfo?["vc"] as? String {
            if string == "PronunciationPracticeViewController" {
                isFromPronunciationPractice = true
                pronunciationText = (notification.userInfo?["text"] as! String)
                pronunciationLanguageCode = (notification.userInfo?["langCode"] as! String)
                fromPronunciation()
            } else if string == "PronunciationPracticeResultViewController" {
                isFromPronunciationPractice = true
                pronunciationView.isHidden = false
                pronunciationText = (notification.userInfo?["text"] as! String)
                pronunciationLanguageCode = (notification.userInfo?["langCode"] as! String)
                fromPronunciation()
            }
        }
        
        self.titleLabel.text = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: speechLangCode)?.initText
        
        isSSTavailable = false
        setExampleText()
        
        speechProcessingLeftImgView.isHidden = false
        speechProcessingRightImgView.isHidden = false
        
        self.speechProcessingVM.isGettingActualData = false
        speechProcessingVM.isFinal.value = false
        service?.startRecord()
    }
    
    //MARK: - Utils
    private func fromPronunciation() {
        screenOpeningPurpose = .PronunciationPractice
        pronunciationView.isHidden = false
        titleLabel.isHidden = true
        exampleLabel.isHidden = true
        descriptionLabel.isHidden = true
        speechLangCode = pronunciationLanguageCode
        LanguageSelectionManager.shared.tempSourceLanguage = pronunciationLanguageCode
        self.languageHasUpdated = true
        speechProcessingVM.updateLanguage()
        pronunciationLable.text = pronunciationText
        self.pronunciationView.layer.cornerRadius = 20
        self.pronunciationView.layer.masksToBounds = true
        self.pronunciationView.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)
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
        
        GlobalAlternative().showTtsAlert(viewController: self, chatItemModel: HistoryChatItemModel(chatItem: chatItem, idxPath: nil), hideMenuButton: false, hideBottmSection: false, saveDataToDB: true, fromHistory: false, ttsAlertControllerDelegate: nil, isRecreation: false, fromSpeech: true)
    }
    
    private func showPronunciationPracticeResult (stt:String) {
        let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeResultViewController")as! PronunciationPracticeResultViewController
        controller.practiceText = GlobalMethod.removeQuotationMark(input: stt)
        controller.delegate = self
        controller.isFromHistory = isHistoryPronunciation
        controller.orginalText = pronunciationText
        controller.languageCode = pronunciationLanguageCode
        if(self.navigationController != nil){
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @objc private func appBecomeActive() {
        self.exampleLabel.text = ""
        self.descriptionLabel.text = ""
        
        if let topVC = UIApplication.getTopViewController(), topVC is SpeechProcessingViewController {
            service?.startRecord()
        }
        addSpinner()
        updateAnimation ()
    }
    
    private func loaderInvisible(){
        if(self.navigationController != nil){
            if isFromTutorial{
                self.navigationController?.popViewController(animated: false)
                self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }else{
            self.dismiss(animated: true, completion: nil)
    }
 }
}

//MARK: - PronunciationResult
extension SpeechProcessingViewController: PronunciationResult {
    func dismissResultHome() {
        pronunciationView.isHidden = true
        titleLabel.isHidden = false
        exampleLabel.isHidden = false
        descriptionLabel.isHidden = false
        isFromPronunciationPractice = false
        screenOpeningPurpose = .HomeSpeechProcessing
        if LanguageSelectionManager.shared.isArrowUp{
            speechLangCode = LanguageSelectionManager.shared.bottomLanguage
            LanguageSelectionManager.shared.tempSourceLanguage = LanguageSelectionManager.shared.bottomLanguage
        }else{
            speechLangCode = LanguageSelectionManager.shared.topLanguage
            LanguageSelectionManager.shared.tempSourceLanguage = LanguageSelectionManager.shared.topLanguage
        }
        self.languageHasUpdated = true
        self.speechProcessingVM.updateLanguage()
        let index = UserDefaultsProperty<Int64>(kLastSavedChatID).value!
        let chat = TtsAlertViewModel().findLastSavedChat(id: Int64(index))
        self.dismiss(animated: false, completion: nil)
        GlobalAlternative().showTtsAlert(viewController: self, chatItemModel: HistoryChatItemModel(chatItem: chat, idxPath: nil), hideMenuButton: false, hideBottmSection: false, saveDataToDB: false, fromHistory: false, ttsAlertControllerDelegate: nil, isRecreation: true, fromSpeech: true)
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
    func getText(text: String) {
        speechProcessingVM.isGettingActualData = true
        speechProcessingVM.setTextFromScoket(value: text)
    }
    
    func getData(data: Data) {}
    func faildSocketConnection(value: String) {}
}

//MARK: - Enum SpeechProcessingScreenOpeningPurpose
enum SpeechProcessingScreenOpeningPurpose{
    case HomeSpeechProcessing
    case LanguageSelectionVoice
    case CountrySelectionByVoice
    case LanguageSelectionCamera
    case PronunciationPractice
}

extension SpeechProcessingViewController : CurrentTSDelegate {
    func passCurrentTSValue(currentTS: Int) {
        self.homeMicTapTimeStamp = currentTS
    }
}

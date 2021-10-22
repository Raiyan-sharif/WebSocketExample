//
// SpeechProcessingViewController.swift
// PockeTalk
//

import UIKit

protocol PronunciationResult : class{
    func dismissResultHome()
}

protocol SpeechProcessingVCDelegates:class {
    func searchCountry(text: String)
}

class SpeechProcessingViewController: BaseViewController, PronunciationResult{

    func dismissResultHome() {
        pronunciationView.isHidden = true
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
    private let TAG:String = "SpeechProcessingViewController"
    ///Views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var speechProcessingAnimationImageView: UIImageView!
    @IBOutlet weak var speechProcessingAnimationView: UIView!
    @IBOutlet weak var speecProcessingRightParentView: UIView!
    @IBOutlet weak var speechProcessingLeftParentView: UIView!
    @IBOutlet weak var speechProcessingRightImgView: UIImageView!
    @IBOutlet weak var speechProcessingLeftImgView: UIImageView!
    @IBOutlet weak var bottomTalkView: UIView!
    @IBOutlet weak var rightImgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightImgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftImgHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftImgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var leftImgTopConstraint: NSLayoutConstraint!
    weak var speechProcessingDelegate: SpeechProcessingVCDelegates?
    @IBOutlet weak var pronunciationView: UIView!
    @IBOutlet weak var pronunciationLable: UILabel!
    var languageHasUpdated = false
    var socketData = [Data]()
    ///Properties
    /// Showing Bengali for now
    let selectedLanguageIndex : Int = 8

    ///languageList for all languages
    var speechProcessingLanguageList = [SpeechProcessingLanguages]()
    var speechProcessingVM : SpeechProcessingViewModeling!
    let cornerRadius : CGFloat = 15
    let animatedViewTransformation : CGFloat = 0.01
    let lineSpacing : CGFloat = 0.5
    let width : CGFloat = 100
    var homeMicTapTimeStamp : Int = 0
    var isSpeechProvided : Bool = false
    var timer: Timer?
    var totalTime = 0
    let transionDuration : CGFloat = 0.8
    let transformation : CGFloat = 0.6
    let leftImgDampiing : CGFloat = 0.10
    let rightImgDamping : CGFloat = 0.05
    let springVelocity : CGFloat = 6.0
    var isFromPronunciationPractice: Bool = false
    var isHistoryPronunciation: Bool = false
    var speechLangCode : String = ""
    var countrySearchspeechLangCode: String = ""
    var service : MAAudioService?
    //var socketManager = SocketManager.sharedInstance
    var screenOpeningPurpose: SpeechProcessingScreenOpeningPurpose?
    var socketManager = SocketManager.sharedInstance
    var isSSTavailable = false
    var spinnerView : SpinnerView!

    let changedXPos : CGFloat = 15
    let changedYPos : CGFloat = 20
    let changedYPosForShrinkedFrame : CGFloat = 10
    var expandedFrame : CGRect?
    var shrinkedFrame : CGRect?
    let leftImgWidth : CGFloat = 30
    let leftImgHeight : CGFloat = 35
    let rightImgWidth : CGFloat = 45
    let rightImgHeight : CGFloat = 55
    var pronunciationText : String = ""
    var pronunciationLanguageCode : String = ""
    static let didPressMicroBtn = Notification.Name("didPressMicroBtn")
    var pronunciationDelegate : DismissPronunciationFromHistory?
    var isShowTutorial : Bool = false
    let timeDifferenceToShowTutorial : Int = 1
    let waitingTimeToShowExampleText : Double = 2.0
    let waitngISFinalSecond:Int = 6

    func initDelegate<T>(_ vc: T) {
        self.speechProcessingDelegate = vc.self as? SpeechProcessingVCDelegates
    }

//    @objc func appMovedToBackground() {
//        //SocketManager.sharedInstance.disconnect()
//        PrintUtility.printLog(tag: TAG, text: "App moved to background! SpeechController")
//        if let vc = self.navigationController?.children.last, vc is SpeechProcessingViewController{
//            PrintUtility.printLog(tag: "Foreground", text: "last Background")
//            service?.timerInvalidate()
//            service?.stopRecord()
//        }
//
//    }
    @objc func appBecomeActive() {
        self.titleLabel.text = ""
        self.exampleLabel.text = ""
        self.descriptionLabel.text = ""
        
//        if let vc = self.navigationController?.children.last, vc is SpeechProcessingViewController{
//            PrintUtility.printLog(tag: "Foreground", text: "last")
//            service?.startRecord()
//        }
        
        if let topVC = UIApplication.getTopViewController(), topVC is SpeechProcessingViewController {
           //topVC.view.addSubview(forgotPwdView)
            service?.startRecord()
        }
        addSpinner()
        updateAnimation ()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        SocketManager.sharedInstance.connect()
        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: nil) { [weak self](notification) in
            guard let `self` = self else { return }
            PrintUtility.printLog(tag: "Foreground", text: "last Background")
            self.service?.timerInvalidate()
            self.service?.stopRecord()
        }
        let languageManager = LanguageSelectionManager.shared
        pronunciationView.isHidden = true
        if let purpose = self.screenOpeningPurpose{
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
        
        // Do any additional setup after loading the view.
        self.speechProcessingVM = SpeechProcessingViewModel()
        self.setUpUI()
        bindData()
        PrintUtility.printLog(tag: TAG, text: "languageHasUpdated \(languageHasUpdated)")
        if languageHasUpdated {
            speechProcessingVM.updateLanguage()
        }
        socketManager.socketManagerDelegate = self
        self.setUpAudio()
        if !isFromPronunciationPractice {
            DispatchQueue.main.asyncAfter(deadline: .now() + waitingTimeToShowExampleText) { [weak self]  in
                /// after 2 second of interval, check if server data is available. If not available show the example text
            guard let `self` = self else { return }
            if self.isSSTavailable == false {
                self.showExample()
                }
            }
        }

        NotificationCenter.default.addObserver(self, selector: #selector(didPressMicroBtn(_:)), name: SpeechProcessingViewController.didPressMicroBtn, object: nil)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.updateAnimation()
    }

    /// Initial UI set up
    func setUpUI () {
        addSpinner()
        let speechLanguage = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: speechLangCode)
        PrintUtility.printLog(tag: TAG, text: "Speech language code \(speechLangCode)")
        self.titleLabel.text = speechLanguage?.initText
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .semibold)
        self.titleLabel.textColor = UIColor._whiteColor()

        if isFromPronunciationPractice {
            FromPronunciation()
        }

        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomTalkView, width: width, height: width)
        talkButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }
    
    func addSpinner(){
        spinnerView = SpinnerView();
        self.view.addSubview(spinnerView)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        spinnerView.isHidden = true
    }

    func updateAnimation () {
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

    private func setUpAudio(){
        service = MAAudioService(nil)
        service?.getData = {[weak self] data in
            guard let `self` = self else { return }

            if self.languageHasUpdated{
                self.socketData.append(data)
            }else if !self.languageHasUpdated  && self.socketData.count == 0{
                self.socketManager.sendVoiceData(data: data)
            }
        }
        service?.getTimer = { [weak self] count in
            guard let `self` = self else { return }
            if count == 30{
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
                    self.showTutorial()
                } else {
                    if(self.navigationController != nil){
                        self.navigationController?.popViewController(animated: true)
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
    
    private func loaderInvisible(){
        if(self.navigationController != nil){
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
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

    func showExample () {
        let speechLanguage = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: speechLangCode)
        self.exampleLabel.text = speechLanguage?.exampleText
        self.exampleLabel.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .regular)
        self.exampleLabel.textAlignment = .center
        self.exampleLabel.textColor = UIColor._whiteColor()

        self.descriptionLabel.text = speechLanguage?.secText
        self.descriptionLabel.setLineHeight(lineHeight: lineSpacing)
        self.descriptionLabel.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .regular)
        self.descriptionLabel.textAlignment = .center
        self.descriptionLabel.textColor = UIColor._whiteColor()
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.lineBreakMode = .byWordWrapping
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
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

    func FromPronunciation() {
        screenOpeningPurpose = .PronunciationPractice
        pronunciationView.isHidden = false
        speechLangCode = pronunciationLanguageCode
        LanguageSelectionManager.shared.tempSourceLanguage = pronunciationLanguageCode
        self.languageHasUpdated = true
        speechProcessingVM.updateLanguage()
        pronunciationLable.text = pronunciationText
        self.pronunciationView.layer.cornerRadius = 20
        self.pronunciationView.layer.masksToBounds = true
        self.pronunciationView.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)
    }

    @objc func didPressMicroBtn(_ notification: Notification) {
        if let string = notification.userInfo?["vc"] as? String {
            if string == "PronunciationPracticeViewController" {
                isFromPronunciationPractice = true
                pronunciationText = (notification.userInfo?["text"] as! String)
                pronunciationLanguageCode = (notification.userInfo?["langCode"] as! String)
                FromPronunciation()
            } else if string == "PronunciationPracticeResultViewController" {
                isFromPronunciationPractice = true
                pronunciationView.isHidden = false
                pronunciationText = (notification.userInfo?["text"] as! String)
                pronunciationLanguageCode = (notification.userInfo?["langCode"] as! String)
                FromPronunciation()
            }
        }
        self.titleLabel.text = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: speechLangCode)?.initText
        self.exampleLabel.isHidden = false
        self.descriptionLabel.isHidden = false
        speechProcessingLeftImgView.isHidden = false
        speechProcessingRightImgView.isHidden = false

        self.speechProcessingVM.isGettingActualData = false
        speechProcessingVM.isFinal.value = false
        service?.startRecord()
    }

    deinit {
        NotificationCenter.default.removeObserver(SpeechProcessingViewController.didPressMicroBtn)
    }

    func showTutorial () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTutorialViewController)as! TutorialViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }

    func showTtsAlert ( ttt: String, stt: String ) {
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
        PrintUtility.printLog(tag: TAG, text: "nativeLang \(nativeLanguage?.name) targetLang \(targetLanguage?.name)")
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
    
    func showPronunciationPracticeResult (stt:String) {
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
//        self.navigationController?.pushViewController(controller, animated: true);
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension SpeechProcessingViewController : SpeechControllerDismissDelegate {
    func dismiss() {
        self.navigationController?.popViewController(animated: false)
        if let transitionView = self.view{
            UIView.transition(with:transitionView, duration: TimeInterval(self.transionDuration), options: .showHideTransitionViews, animations: nil, completion: nil)
        }
    }
}

extension SpeechProcessingViewController : SocketManagerDelegate{

    func getText(text: String) {
        speechProcessingVM.isGettingActualData = true
        speechProcessingVM.setTextFromScoket(value: text)
    }

    func getData(data: Data) {

    }
    func faildSocketConnection(value: String) {
        
    }
}

enum SpeechProcessingScreenOpeningPurpose{
    case HomeSpeechProcessing
    case LanguageSelectionVoice
    case CountrySelectionByVoice
    case LanguageSelectionCamera
    case PronunciationPractice
}


extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}



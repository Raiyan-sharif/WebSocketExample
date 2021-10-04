//
// SpeechProcessingViewController.swift
// PockeTalk
//

import UIKit

protocol SpeechProcessingVCDelegates {
    func searchCountry(text: String)
}
class SpeechProcessingViewController: BaseViewController{
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
    var speechProcessingDelegate: SpeechProcessingVCDelegates?
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
    static let didPressMicroBtn = Notification.Name("didPressMicroBtn")

    func initDelegate<T>(_ vc: T) {
        self.speechProcessingDelegate = vc.self as? SpeechProcessingVCDelegates
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.speechProcessingVM = SpeechProcessingViewModel()
        let languageManager = LanguageSelectionManager.shared
        self.setUpUI()
        bindData()
        if languageHasUpdated {
            speechProcessingVM.updateLanguage()
        }
        PrintUtility.printLog(tag: TAG, text: "languageHasUpdated \(languageHasUpdated)")
        if let purpose = self.screenOpeningPurpose{
            switch purpose {
            case .HomeSpeechProcessing:
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
                break
            }
        }
        socketManager.socketManagerDelegate = self
        self.setUpAudio()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self]  in
            self?.showExample()
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
            self.timer?.invalidate()
            if self.speechProcessingVM.isGettingActualData{
                self.speechProcessingVM.isGettingActualData = false
                self.socketManager.sendTextData(text: self.speechProcessingVM.getTextFrame())
            }else{
                self.spinnerView.isHidden = true
                self.navigationController?.popViewController(animated: true)
            }
        }

        service?.startRecord()

    }
    private func bindData(){
        speechProcessingVM.isFinal.bindAndFire{ [weak self] isFinal  in
            guard let `self` = self else { return }
            if isFinal{
                self.spinnerView.isHidden = true
                self.service?.stopRecord()
                self.service?.timerInvalidate()
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
        spinnerView.isHidden = false
        speechProcessingLeftImgView.isHidden = true
        speechProcessingRightImgView.isHidden = true
        service?.stopRecord()
        service?.timerInvalidate()
        var runCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
             runCount += 1
             if runCount == 6 {
                 timer.invalidate()
                if !self.speechProcessingVM.isFinal.value {
                    self.navigationController?.popViewController(animated: true)
                }
             }
         }

    }


    @objc func didPressMicroBtn(_ notification: Notification) {
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
        let isArrowUp = languageManager.isArrowUp ?? true
        let isTop = isArrowUp ? IsTop.noTop.rawValue : IsTop.top.rawValue
        var nativeText = ""
        var targetText = ""
        let nativeLangCode = LanguageSelectionManager.shared.bottomLanguage
        let targetLangCode = LanguageSelectionManager.shared.topLanguage
        PrintUtility.printLog(tag: TAG, text: "nativeLangCode \(nativeLangCode) targetLangCode \(targetLangCode)")
        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        var nativeLangName = ""
        var targetLangName = ""
        
        if isArrowUp == true{
            nativeText = stt
            targetText = ttt
            nativeLangName = nativeLanguage?.name ?? ""
            targetLangName = targetLanguage?.name ?? ""
        }else{
            nativeText = ttt
            targetText = stt
            nativeLangName = targetLanguage?.name ?? ""
            targetLangName = nativeLanguage?.name ?? ""
        }
        
        let chatItem =  ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangName, textNativeLanguage: nativeLangName, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isTop, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue)
        
        GlobalMethod.showTtsAlert(viewController: self, chatItemModel: HistoryChatItemModel(chatItem: chatItem, idxPath: nil), hideMenuButton: false, hideBottmSection: false, saveDataToDB: true, ttsAlertControllerDelegate: nil)
    }
    
    func showPronunciationPracticeResult () {
        let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeResultViewController")as! PronunciationPracticeResultViewController
        self.navigationController?.pushViewController(controller, animated: true);
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
}

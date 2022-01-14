//
//  PronunciationPracticeViewController.swift
//  PockeTalk
//

import UIKit
import WebKit

protocol DismissPronunciationFromHistory: AnyObject {
    func dismissPronunciationFromHistory()
}

class PronunciationPracticeViewController: BaseViewController, DismissPronunciationFromHistory {

    func dismissPronunciationFromHistory() {
        if(self.navigationController != nil){
            self.navigationController?.popViewController(animated: false)
        }else{
            self.dismiss(animated: false, completion: nil)
        }
    }

    @IBOutlet weak var viewSpeechTextContainer: UIView!
    @IBOutlet weak var labelPronunciationGuideline: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var labelOriginalText: UILabel!
    @IBOutlet weak private var bottomViewBottomLayoutConstrain: NSLayoutConstraint!
    
    let width : CGFloat = 100
    var chatItem: ChatEntity?
    var orginalText: String = ""
    var languageCode: String = ""
    weak var delegate: Pronunciation?
    var isFromHistory: Bool = false
    var ttsResponsiveView = TTSResponsiveView()
    var isFromSpeechProcessing: Bool = false
    weak var speechDelegate : PronunciationResult?
    var voice : String = ""
    var rate : String = "1.0"
    var isSpeaking : Bool = false
    var isFromHistoryTTS = false
    var talkBtnImgView = UIImageView()
    let window :UIWindow = UIApplication.shared.keyWindow!
    let talkButtonShadow = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.getTtsValue()
        ttsResponsiveView.ttsResponsiveViewDelegate = self
        self.view.addSubview(ttsResponsiveView)
        ttsResponsiveView.isHidden = true
        registerNotification()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let `self` = self else { return }
            let pronumtiationValue = PronuntiationValue(practiceText:"" , orginalText: self.orginalText, languageCcode:self.languageCode)
            NotificationCenter.default.post(name: .pronumTiationTextUpdate, object: nil, userInfo: ["pronuntiationText":pronumtiationValue])
        }
        bottomViewBottomLayoutConstrain.constant = HomeViewController.homeVCBottomViewHeight
    }

    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(gotoPronuntiationPacticeVC(notification:)), name:.pronuntiationNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pronunciationStopTTS(notification:)), name:.pronuntiationTTSStopNotification, object: nil)
    }

    func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name:.pronuntiationNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:.pronuntiationTTSStopNotification, object: nil)
    }
    
    @objc func willResignActive(_ notification: Notification) {
        self.stopTTS()
        AudioPlayer.sharedInstance.stop()
        talkButtonShadow.removeFromSuperview()
        putGlowEffectUnderTalkButton()
    }

    @objc func gotoPronuntiationPacticeVC(notification: Notification) {

        if let value = notification.userInfo!["value"] as? PronuntiationValue{

            let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeResultViewController")as! PronunciationPracticeResultViewController
            controller.orginalText = value.orginalText
            controller.practiceText = value.practiceText
            controller.languageCode = value.languageCcode
            controller.isFromHistoryTTS = isFromHistoryTTS
            talkButtonShadow.removeFromSuperview()
            add(asChildViewController: controller, containerView: view, animation: nil)
        }
    }
    
    
    @objc func pronunciationStopTTS(notification: Notification) {
        stopTTS()
        AudioPlayer.sharedInstance.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        putGlowEffectUnderTalkButton()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        talkButtonShadow.removeFromSuperview()
    }
    // Initial UI set up
    func setUpUI () {
        if chatItem != nil {
            orginalText = (chatItem?.textTranslated)!
            let languageManager = LanguageSelectionManager.shared
            let language = languageManager.getLanguageCodeByName(langName: (chatItem?.textTranslatedLanguage)!)
            languageCode = language!.code
        }

        self.labelPronunciationGuideline.text = "PronunciationGuideline".localiz()
        self.viewSpeechTextContainer.layer.cornerRadius = 20
        self.viewSpeechTextContainer.layer.masksToBounds = true

        self.viewSpeechTextContainer.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)

        let tapForTTS = UITapGestureRecognizer(target: self, action: #selector(self.actionTappedOnTTSText(sender:)))
        labelOriginalText.isUserInteractionEnabled = true
        labelOriginalText.addGestureRecognizer(tapForTTS)
        labelOriginalText.text = orginalText
    }
    
    //MARK: Glow effect Under Talk Button
    
    func putGlowEffectUnderTalkButton(){
        talkBtnImgView = window.viewWithTag(109) as! UIImageView
        window.addSubview(talkButtonShadow)
        talkButtonShadow.image = UIImage(named: "bg_speak")
        talkButtonShadow.isUserInteractionEnabled = true
        talkButtonShadow.translatesAutoresizingMaskIntoConstraints = false
        talkButtonShadow.layer.cornerRadius = width/2
        talkButtonShadow.clipsToBounds = true
        talkButtonShadow.widthAnchor.constraint(equalToConstant: width*1.5).isActive = true
        talkButtonShadow.heightAnchor.constraint(equalToConstant: width*2 ).isActive = true
        talkButtonShadow.centerXAnchor.constraint(equalTo: self.talkBtnImgView.centerXAnchor).isActive = true
        talkButtonShadow.topAnchor.constraint(equalTo: self.talkBtnImgView.bottomAnchor, constant: window.safeAreaInsets.bottom - width/4).isActive = true
    }
    
    func checkTTSValueAndPlay(){
        if let _ = LanguageEngineParser.shared.getTtsValueByCode(code:languageCode){
            if(!isSpeaking){
                playTTS()
            }
        }else{
            AudioPlayer.sharedInstance.delegate = self
            if !AudioPlayer.sharedInstance.isPlaying{
                AudioPlayer.sharedInstance.getTTSDataAndPlay(translateText:orginalText, targetLanguageItem: languageCode, tempo:normal)
            }
        }
    }

    /// Retreive tts value from respective language code
    func getTtsValue () {
        let item = LanguageEngineParser.shared.getTtsValue(langCode: languageCode)
        self.voice = item.voice
        self.rate = item.rate
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        self.stopTTS()
        AudioPlayer.sharedInstance.stop()
        if Reachability.isConnectedToNetwork() {
            RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
                if isGranted {
                    if self.isFromHistory {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let controller = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
                        controller.isFromPronunciationPractice = true
                        controller.pronunciationText = self.orginalText
                        controller.pronunciationLanguageCode = self.languageCode
                        controller.screenOpeningPurpose = .PronunciationPractice
                        controller.languageHasUpdated = true
                        controller.isHistoryPronunciation = self.isFromHistory
                        self.present(controller, animated: true, completion: nil)
                    } else if self.isFromSpeechProcessing {
                        var dict = [String:String]()
                        dict["vc"] = "PronunciationPracticeViewController"
                        dict["text"] = self.orginalText
                        dict["langCode"] = self.languageCode
                        self.navigationController?.popViewController(animated: false)
                    } else {
                        var dict = [String:String]()
                        dict["vc"] = "PronunciationPracticeViewController"
                        dict["text"] = self.orginalText
                        dict["langCode"] = self.languageCode
                        self.dismiss(animated: false, completion: {
                            self.delegate?.dismissPro(dict: dict)
                        })
                    }
                } else {
                    GlobalMethod.showPermissionAlert(viewController: self, title : kMicrophoneUsageTitle, message : kMicrophoneUsageMessage)
                }
            }
        } else {
            GlobalMethod.showNoInternetAlert(in: self)
        }
    }

    @IBAction func actionBack(_ sender: Any) {
        stopTTS()
        AudioPlayer.sharedInstance.stop()
        LanguageSelectionManager.shared.tempSourceLanguage = nil
        if isFromSpeechProcessing {
            speechDelegate?.dismissResultHome()
        }
        NotificationCenter.default.post(name: .pronumTiationTextUpdate, object: nil, userInfo: ["pronuntiationText":"pronuntiationText"])
        if ScreenTracker.sharedInstance.screenPurpose == .PronunciationPractice{
            NotificationCenter.default.post(name: .ttsNotofication, object: nil)
            ScreenTracker.sharedInstance.screenPurpose  = .HomeSpeechProcessing
        }else if ScreenTracker.sharedInstance.screenPurpose == .HistroyPronunctiation{
            if isFromHistoryTTS{
                NotificationCenter.default.post(name: .ttsNotofication, object: nil)
                ScreenTracker.sharedInstance.screenPurpose  = .HistoryScrren
            }else{
                NotificationCenter.default.post(name: .historyNotofication, object: nil)
            }
        }
        talkButtonShadow.removeFromSuperview()
    }

    @objc func actionTappedOnTTSText(sender:UITapGestureRecognizer) {
        checkTTSValueAndPlay()
    }
    
    func playTTS(){
        ttsResponsiveView.checkSpeakingStatus()
        ttsResponsiveView.setRate(rate: rate)
        PrintUtility.printLog(tag: "Translate ", text: orginalText)
        ttsResponsiveView.TTSPlay(voice: voice,text: orginalText)
    }
    func stopTTS(){
        ttsResponsiveView.stopTTS()
    }

    deinit {
        unregisterNotification()
    }
}

extension PronunciationPracticeViewController : TTSResponsiveViewDelegate {
    func speakingStatusChanged(isSpeaking: Bool) {
        self.isSpeaking = isSpeaking
    }
    
    func onVoiceEnd() {}
    
    func onReady() {}
}

struct PronuntiationValue {
    let practiceText:String
    let orginalText:String
    let languageCcode:String
}

extension PronunciationPracticeViewController :AudioPlayerDelegate{
    func didStartAudioPlayer() {

    }

    func didStopAudioPlayer(flag: Bool) {

    }
}

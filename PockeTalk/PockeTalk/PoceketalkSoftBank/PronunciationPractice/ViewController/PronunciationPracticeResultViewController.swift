//
//  PronunciationPracticeResultViewController.swift
//  PockeTalk
//

import UIKit
import SwiftRichString
import WebKit

class PronunciationPracticeResultViewController: BaseViewController {
    let TAG = "\(PronunciationPracticeResultViewController.self)"
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet var viewRoot: UIView!
    @IBOutlet weak var viewFailureContainer: UIView!
    @IBOutlet weak var labelFailedOriginalText: UILabel!
    @IBOutlet weak var labelFailedPronuncedText: UILabel!
    @IBOutlet weak var viewSuccessContainer: UIView!
    @IBOutlet weak var labelSuccessText: UILabel!
    @IBOutlet weak private var bottomViewBottomLayoutConstrain: NSLayoutConstraint!
    @IBOutlet weak var tempoControlButton: UIButton!
    
    let width : CGFloat = 100
    var practiceText : String = ""
    var orginalText : String = ""
    var languageCode : String = ""
    weak var delegate : PronunciationResult?
    var isFromHistory : Bool = false
    var ttsResponsiveView = TTSResponsiveView()
    var voice : String = ""
    var rate : String = "1.0"
    var isSpeaking : Bool = false
    var isFromHistoryTTS = false
    var tempo:String = "normal"
    var multipartAudioPlayer: MultipartAudioPlayer?
    var urlStrings:[String] = []

    var mainResultMenuPracticeCheckStr: String!
    var mainResultMenuPracticeCheckSpeedStr: String!
    
    @IBAction func actionBack(_ sender: Any) {
        backButtonTapLogEvent()
        stopTTS()
        LanguageSelectionManager.shared.tempSourceLanguage = nil
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

        if isFromHistory {
            if let historyVC = self.presentingViewController?.presentingViewController  as? PronunciationPracticeViewController{
                if(historyVC.presentingViewController != nil){
                    historyVC.presentingViewController?.dismiss(animated: true, completion: nil)
                }else{
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                if let nav = self.presentingViewController?.presentingViewController, nav is UINavigationController{
                    self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: false) {
                    }
                }
            }
        } else {
            self.delegate?.dismissResultHome()
        }
        HomeViewController.showOrHideTalkButtonImage(true)
    }

    //TODO: need to replace with valid action
    @IBAction func actionReplay(_ sender: Any) {
        replayButtonTapLogEvent()
        stopTTS()
        let vc = TempoControlSelectionAlertController.init()
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.getTtsValue()
        ttsResponsiveView.ttsResponsiveViewDelegate = self
        self.view.addSubview(ttsResponsiveView)
        ttsResponsiveView.isHidden = true
        UserDefaultsProperty<String>(kTempoControlSpeed).value = TempoControlSpeedType.standard.rawValue
        registerNotification()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let `self` = self else { return }
            let pronumtiationValue = PronuntiationValue(practiceText:"" , orginalText: self.orginalText, languageCcode:self.languageCode)
            NotificationCenter.default.post(name: .pronumTiationTextUpdate, object: nil, userInfo: ["pronuntiationText":pronumtiationValue])
            
        }
        bottomViewBottomLayoutConstrain.constant = HomeViewController.homeVCBottomViewHeight
        multipartAudioPlayer = MultipartAudioPlayer(controller: self, delegate: self)
        setAnalyticsScreenName()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AudioPlayer.sharedInstance.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        HomeViewController.showOrHideTalkButtonImage(true)
    }

    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updatePronuntiationPacticeResult(notification:)), name:.pronuntiationResultNotification, object: nil)
    }

    func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name:.pronuntiationResultNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    @objc func willResignActive(_ notification: Notification) {
        self.stopTTS()
    }

    @objc func updatePronuntiationPacticeResult(notification: Notification) {
        stopTTS()
        remove(asChildViewController: self)
    }

    func setUpUI() {
        self.viewContainer.layer.cornerRadius = 20
        self.viewContainer.layer.masksToBounds = true
        // Hide Tempo control menu for TTS unsupported language
        let languageManager = LanguageSelectionManager.shared
        if !(languageManager.hasTtsSupport(languageCode: languageCode)) || languageManager.isNeedToHideTempoControll(languageCode: languageCode) {
            self.tempoControlButton.isHidden = true
        }

        self.viewContainer.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)
        showResultView()
        
        let tapForTTS = UITapGestureRecognizer(target: self, action: #selector(self.actionTappedOnTTSText(sender:)))
        labelFailedOriginalText.isUserInteractionEnabled = true
        labelFailedOriginalText.addGestureRecognizer(tapForTTS)
        let tapForTTSSuccess = UITapGestureRecognizer(target: self, action: #selector(self.actionTappedOnTTSText(sender:)))
        labelSuccessText.isUserInteractionEnabled = true
        labelSuccessText.addGestureRecognizer(tapForTTSSuccess)

    }
    
    func getTtsValue () {
        let item = LanguageEngineParser.shared.getTtsValue(langCode: languageCode)
        self.voice = item.voice
        self.rate = item.rate
    }

    private func setAnalyticsScreenName() {
        if isFromHistoryTTS {
            //Show self scene from history card scene
            if viewSuccessContainer.isHidden {
                mainResultMenuPracticeCheckStr = analytics.historyCardMenuPracticeWrong
                mainResultMenuPracticeCheckSpeedStr = analytics.historyCardMenuPracticeWrongSpeed
            } else {
                mainResultMenuPracticeCheckStr = analytics.historyCardMenuPracticeCheck
                mainResultMenuPracticeCheckSpeedStr = analytics.historyCardMenuPracticeCheckSpeed
            }
        } else {
            if isFromHistory {
                //Show self scene from history scene
                if viewSuccessContainer.isHidden {
                    mainResultMenuPracticeCheckStr = analytics.historyLongTapMenuPracticeWrong
                    mainResultMenuPracticeCheckSpeedStr = analytics.historyLongTapMenuPracticeWrongSpeed
                } else {
                    mainResultMenuPracticeCheckStr = analytics.historyLongTapMenuPracticeCheck
                    mainResultMenuPracticeCheckSpeedStr = analytics.historyLongTapMenuPracticeCheckSpeed
                }
            } else {
                //Show self scene from home scene
                if viewSuccessContainer.isHidden {
                    mainResultMenuPracticeCheckStr = analytics.mainResultMenuPracticeWrong
                    mainResultMenuPracticeCheckSpeedStr = analytics.mainResultMenuPracticeWrongSpeed
                } else {
                    mainResultMenuPracticeCheckStr = analytics.mainResultMenuPracticeCheck
                    mainResultMenuPracticeCheckSpeedStr = analytics.mainResultMenuPracticeCheckSpeed
                }
            }
        }
    }
    
    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        self.stopTTS()
        if Reachability.isConnectedToNetwork() {
            RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
                if isGranted {
                    var dict = [String:String]()
                    dict["vc"] = "PronunciationPracticeResultViewController"
                    dict["text"] = self.orginalText
                    dict["langCode"] = self.languageCode
                    if(self.navigationController != nil){
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        self.dismiss(animated: true, completion: nil)
                    }
                } else {
                    GlobalMethod.showPermissionAlert(viewController: self, title : kMicrophoneUsageTitle, message : kMicrophoneUsageMessage)
                }
            }
        } else {
            GlobalMethod.showNoInternetAlert(in: self)
        }
    }

    func showResultView() {
        let styleColor = Style({
            $0.color = UIColor.red
        })
        let style = StyleXML(base: nil, ["b" : styleColor])

        let result = PronunciationModel().generateDiff(original: orginalText, practice: practiceText, languageCode: languageCode)

        if result[0] == DIFF_STRING_MATCHED {
            viewFailureContainer.isHidden = true
            viewSuccessContainer.isHidden = false
            if languageCode == BURMESE_MY_LANGUAGE_CODE {
                labelSuccessText.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE)
                labelSuccessText.textAlignment = .center
            }
            labelSuccessText.attributedText = result[1].set(style: style)
        } else {
            viewFailureContainer.isHidden = false
            viewSuccessContainer.isHidden = true
            if languageCode == BURMESE_MY_LANGUAGE_CODE {
                labelFailedOriginalText.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE)
                labelFailedOriginalText.textAlignment = .center
                labelFailedPronuncedText.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE)
                labelFailedPronuncedText.textAlignment = .center
            }
            labelFailedOriginalText.attributedText = result[1].set(style: style)
            labelFailedPronuncedText.attributedText = result[2].set(style: style)
        }
    }

    func checkTTSValueAndPlay(){
        if let _ = LanguageEngineParser.shared.getTtsValueByCode(code:languageCode){
            if(!isSpeaking){
                urlStrings = []
                playTTS()
            }
        }else{
            AudioPlayer.sharedInstance.delegate = self
            if !AudioPlayer.sharedInstance.isPlaying{
                AudioPlayer.sharedInstance.getTTSDataAndPlay(translateText:orginalText, targetLanguageItem: languageCode, tempo:tempo)
            }
        }
    }

    @objc func actionTappedOnTTSText(sender:UITapGestureRecognizer) {
        checkTTSValueAndPlay()
    }

    deinit {
        unregisterNotification()
        ttsResponsiveView.removeObserver()
    }

    func playTTS(){
        ttsResponsiveView.checkSpeakingStatus()
        if languageCode == ENGLISH_SLOW_LANG_CODE && tempo == TEMPO_STANDARD {
            rate = ENGLISH_SLOW_DEFAULT_PITCH_RATE
        }
        ttsResponsiveView.setRate(rate: rate)
        PrintUtility.printLog(tag: "Translate ", text: orginalText )
        ttsResponsiveView.TTSPlay(voice: voice,text: orginalText )
    }
    func stopTTS(){
        ttsResponsiveView.stopTTS()
        multipartAudioPlayer?.stop()
        AudioPlayer.sharedInstance.stop()
    }
}

//MARK: - TTSResponsiveViewDelegate
extension PronunciationPracticeResultViewController: TTSResponsiveViewDelegate {
    func onMultipartUrlReceived(url: String) {
        if(!url.isEmpty){
            urlStrings.append(url)
        }
    }
    
    func onMultipartUrlEnd() {
        multipartAudioPlayer?.playMultipartAudio(urls: urlStrings)
    }
    
    func speakingStatusChanged(isSpeaking: Bool) {
        self.isSpeaking = isSpeaking
    }
    
    func onVoiceEnd() { }
    func onReady() {}
}

//MARK: - TempoControlSelectionDelegate
extension PronunciationPracticeResultViewController: TempoControlSelectionDelegate{
    func onStandardSelection() {
        normalPlayBackLogEvent()
        rate = TempoEngineValueParser.shared.getEngineTempoValue(engineName: ttsResponsiveView.engineName, type: .standard)
        PrintUtility.printLog(tag: TAG, text: "rate: \(rate)")
        tempo = "normal"
    }
    
    func onSlowSelection() {
        slowPlayBackLogEvent()
        rate = TempoEngineValueParser.shared.getEngineTempoValue(engineName: ttsResponsiveView.engineName, type: .slow)
        PrintUtility.printLog(tag: TAG, text: "rate: \(rate)")
        tempo = "slow"
    }
    
    func onVerySlowSelection() {
        verySlowPlayBackLogEvent()
        rate = TempoEngineValueParser.shared.getEngineTempoValue(engineName: ttsResponsiveView.engineName, type: .verySlow)
        PrintUtility.printLog(tag: TAG, text: "rate: \(rate)")
        tempo = "veryslow"
    }
}

//MARK: - AudioPlayerDelegate
extension PronunciationPracticeResultViewController: AudioPlayerDelegate{
    func didStartAudioPlayer() {}
    func didStopAudioPlayer(flag: Bool) {}
}

//MARK: - MultipartAudioPlayerProtocol
extension PronunciationPracticeResultViewController: MultipartAudioPlayerProtocol{
    func onSpeakStart() {
        self.isSpeaking = true
    }
    func onSpeakFinish() {
        self.isSpeaking = false
    }
    func onError() {
        self.isSpeaking = false
    }
}

//MARK: - Google analytics log events
extension PronunciationPracticeResultViewController {
    private func backButtonTapLogEvent() {
        analytics.buttonTap(screenName: mainResultMenuPracticeCheckStr,
                            buttonName: analytics.buttonBack)
    }

    private func replayButtonTapLogEvent() {
        analytics.buttonTap(screenName: mainResultMenuPracticeCheckStr,
                            buttonName: analytics.buttonSpeed)
    }

    private func normalPlayBackLogEvent() {
        analytics.pronunciationPlayBack(screenName: mainResultMenuPracticeCheckSpeedStr,
                                        playBackType: GoogleAnalytics.PronunciationPlayBackSpeed.normal)
    }

    private func slowPlayBackLogEvent() {
        analytics.pronunciationPlayBack(screenName: mainResultMenuPracticeCheckSpeedStr,
                                        playBackType: GoogleAnalytics.PronunciationPlayBackSpeed.slow)
    }

    private func verySlowPlayBackLogEvent() {
        analytics.pronunciationPlayBack(screenName: mainResultMenuPracticeCheckSpeedStr,
                                        playBackType: GoogleAnalytics.PronunciationPlayBackSpeed.verySlow)
    }
}




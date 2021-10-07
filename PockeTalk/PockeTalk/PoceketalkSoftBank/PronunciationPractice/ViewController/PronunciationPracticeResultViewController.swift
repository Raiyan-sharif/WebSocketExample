//
//  PronunciationPracticeResultViewController.swift
//  PockeTalk
//
//  Created by Khairuzzaman Shipon on 8/9/21.
//

import UIKit
import SwiftRichString
import WebKit

class PronunciationPracticeResultViewController: BaseViewController {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet var viewRoot: UIView!
    @IBOutlet weak var viewFailureContainer: UIView!
    @IBOutlet weak var labelFailedOriginalText: UILabel!
    @IBOutlet weak var labelFailedPronuncedText: UILabel!
    @IBOutlet weak var viewSuccessContainer: UIView!
    @IBOutlet weak var labelSuccessText: UILabel!
    @IBOutlet weak var bottomTalkView: UIView!
    let width : CGFloat = 100
    var practiceText : String = ""
    var orginalText : String = ""
    var languageCode : String = ""
    var delegate : PronunciationResult?
    var isFromHistory : Bool = false
    var ttsResponsiveView = TTSResponsiveView()
    var voice : String = ""
    var rate : String = "1.0"
    var isSpeaking : Bool = false
    
    @IBAction func actionBack(_ sender: Any) {
        stopTTS()
        if isFromHistory {
            self.delegate?.dismissResultHistory()
            self.dismiss(animated: false, completion: nil)
        } else {
            self.delegate?.dismissResultHome()
            self.navigationController?.popViewController(animated: true)
        }
    }

    //TODO: need to replace with valid action
    @IBAction func actionReplay(_ sender: Any) {
        let vc = TempoControlSelectionAlertController.init()
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        present(vc, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.getTtsValue()
        ttsResponsiveView.ttsResponsiveViewDelegate = self
        self.view.addSubview(ttsResponsiveView)
        ttsResponsiveView.isHidden = true
    }

    // Initial UI set up
    func setUpUI () {
        self.setUpMicroPhoneIcon()
        self.viewContainer.layer.cornerRadius = 20
        self.viewContainer.layer.masksToBounds = true

        self.viewContainer.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)
        showResultView()
        
        let tapForTTS = UITapGestureRecognizer(target: self, action: #selector(self.actionTappedOnTTSText(sender:)))
        labelFailedOriginalText.isUserInteractionEnabled = true
        labelFailedOriginalText.addGestureRecognizer(tapForTTS)
        let tapForTTSSuccess = UITapGestureRecognizer(target: self, action: #selector(self.actionTappedOnTTSText(sender:)))
        labelSuccessText.isUserInteractionEnabled = true
        labelSuccessText.addGestureRecognizer(tapForTTSSuccess)

    }
    /// Retreive tts value from respective language code
    func getTtsValue () {
        let item = TTSEngine.shared.getTtsValue(langCode: languageCode)
        self.voice = item.voice
        self.rate = item.rate
    }

    // floating microphone button
    func setUpMicroPhoneIcon () {
        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomTalkView, width: width, height: width)
        talkButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        self.stopTTS()
        RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
            if isGranted {
                var dict = [String:String]()
                dict["vc"] = "PronunciationPracticeResultViewController"
                dict["text"] = self.orginalText
                dict["langCode"] = self.languageCode
                NotificationCenter.default.post(name: SpeechProcessingViewController.didPressMicroBtn, object: nil, userInfo: dict)
                if(self.navigationController != nil){
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                GlobalMethod.showAlert(title: kMicrophoneUsageTitle, message: kMicrophoneUsageMessage, in: self) {
                    GlobalMethod.openSettingsApplication()
                }
            }
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
            labelSuccessText.attributedText = result[1].set(style: style)
        } else {
            viewFailureContainer.isHidden = false
            viewSuccessContainer.isHidden = true
            labelFailedOriginalText.attributedText = result[1].set(style: style)
            labelFailedPronuncedText.attributedText = result[2].set(style: style)
        }
    }

    @objc func actionTappedOnTTSText(sender:UITapGestureRecognizer) {
        if(!isSpeaking){
            playTTS()
        }
    }
    
    func playTTS(){
        ttsResponsiveView.isSpeaking()
        ttsResponsiveView.setRate(rate: rate)
        PrintUtility.printLog(tag: "Translate ", text: orginalText )
        ttsResponsiveView.TTSPlay(voice: voice,text: orginalText )
    }
    func stopTTS(){
        ttsResponsiveView.stopTTS()
    }
}
extension PronunciationPracticeResultViewController : TTSResponsiveViewDelegate {
    func speakingStatusChanged(isSpeaking: Bool) {
        self.isSpeaking = isSpeaking
    }
    
    func onVoiceEnd() { }
    
    func onReady() {
        if(!isSpeaking){
            playTTS()
        }
    }
}

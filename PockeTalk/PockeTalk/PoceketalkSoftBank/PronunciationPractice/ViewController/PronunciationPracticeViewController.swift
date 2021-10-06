//
//  PronunciationPracticeViewController.swift
//  PockeTalk
//

import UIKit
import WebKit

protocol DismissPronunciationFromHistory {
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
    @IBOutlet weak var bottomTalkView: UIView!
    let width : CGFloat = 100
    var chatItem: ChatEntity?
    var orginalText: String = ""
    var languageCode: String = ""
    var delegate: Pronunciation?
    var isFromHistory: Bool = false
    var ttsResponsiveView = TTSResponsiveView()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpUI()
        
        ttsResponsiveView.ttsResponsiveViewDelegate = self
        self.view.addSubview(ttsResponsiveView)
        ttsResponsiveView.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    // Initial UI set up
    func setUpUI () {
        if chatItem != nil {
            orginalText = (chatItem?.textTranslated)!
            let languageManager = LanguageSelectionManager.shared
            let language = languageManager.getLanguageCodeByName(langName: (chatItem?.textTranslatedLanguage)!)
            languageCode = language!.code
        }
        self.setUpMicroPhoneIcon()
        self.labelPronunciationGuideline.text = "PronunciationGuideline".localiz()
        self.viewSpeechTextContainer.layer.cornerRadius = 20
        self.viewSpeechTextContainer.layer.masksToBounds = true

        self.viewSpeechTextContainer.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)

        let tapForTTS = UITapGestureRecognizer(target: self, action: #selector(self.actionTappedOnTTSText(sender:)))
        labelOriginalText.isUserInteractionEnabled = true
        labelOriginalText.addGestureRecognizer(tapForTTS)
        labelOriginalText.text = orginalText
    }

    // floating microphone button
    func setUpMicroPhoneIcon () {
        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomTalkView, width: width, height: width)
        talkButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
            if isGranted {
                if self.isFromHistory {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "SpeechProcessingViewController")as! SpeechProcessingViewController
                    controller.isFromPronunciationPractice = true
                    controller.pronunciationText = self.orginalText
                    controller.pronunciationLanguageCode = self.languageCode
                    controller.screenOpeningPurpose = .PronunciationPractice
                    controller.languageHasUpdated = true
                    controller.pronunciationDelegate = self
                    controller.isHistoryPronunciation = self.isFromHistory
                    NotificationCenter.default.post(name: SpeechProcessingViewController.didPressMicroBtn, object: nil)
                    self.present(controller, animated: true, completion: nil)
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
                GlobalMethod.showAlert(title: kMicrophoneUsageTitle, message: kMicrophoneUsageMessage, in: self) {
                    GlobalMethod.openSettingsApplication()
                }
            }
        }
    }

    @IBAction func actionBack(_ sender: Any) {
        stopTTS()
        if(self.navigationController != nil){
            self.navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc func actionTappedOnTTSText(sender:UITapGestureRecognizer) {
        playTTS()
    }
    func playTTS(){
        let translateText = chatItem?.textTranslated
        PrintUtility.printLog(tag: "Translate ", text: translateText ?? "")
        //startAnimation()
        ttsResponsiveView.TTSPlay(voice: "US English Female",text: translateText ??  "")
    }
    func stopTTS(){
        //TODO stop tts
        //ttsResponsiveView.stopTTS()
    }
}

extension PronunciationPracticeViewController : TTSResponsiveViewDelegate {
    func userContentController(message: WKScriptMessage) {
        if(message.name == "iosListener"){
            if message.body as! String == "end"{
                //stopAnimation ()
            }
        }
    }
    
    func webView() {
        playTTS()
    }
    
    
}

//
//  PronunciationPracticeResultViewController.swift
//  PockeTalk
//
//  Created by Khairuzzaman Shipon on 8/9/21.
//

import UIKit
import SwiftRichString

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

    @IBAction func actionBack(_ sender: Any) {
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

        labelSuccessText.isUserInteractionEnabled = true
        labelSuccessText.addGestureRecognizer(tapForTTS)

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
        GlobalMethod.showAlert("TODO: PLAY TTS!")
    }
}

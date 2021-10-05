//
//  PronunciationPracticeResultViewController.swift
//  PockeTalk
//
//  Created by Khairuzzaman Shipon on 8/9/21.
//  Copyright © 2021 BJIT LTD All rights reserved.
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

    @IBAction func actionBack(_ sender: Any) {
        self.showPronunciationPractice()
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
                let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = storyboard.instantiateViewController(withIdentifier: "SpeechProcessingViewController")as! SpeechProcessingViewController
                controller.homeMicTapTimeStamp = currentTS
                controller.isFromPronunciationPractice = true
                self.navigationController?.pushViewController(controller, animated: true);
            } else {
                GlobalMethod.showAlert(title: kMicrophoneUsageTitle, message: kMicrophoneUsageMessage, in: self) {
                    GlobalMethod.openSettingsApplication()
                }
            }
        }
    }

    func showPronunciationPractice () {
        let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeViewController")as! PronunciationPracticeViewController
        self.navigationController?.pushViewController(controller, animated: true);
    }

    func showResultView() {
        let styleColor = Style({
            $0.color = UIColor.red
        })
        let style = StyleXML(base: nil, ["b" : styleColor])

        // TODO : dummy data call, will remove
        let dummyData = dummyRandomIO()

        let result = PronunciationModel().generateDiff(original: dummyData[0], practice: dummyData[1], languageCode: dummyData[2])

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

    // TODO : Dummy method will be removed
    func dummyRandomIO() -> [String] {
        let lang = ["en", "ja"]
        let english = ["Hello, how are you?", "What are you doing?", "hello how are you", "How are you?", "what are you doing", "HOW ARE ???? You"]
        let japanese = ["引きずる", "ひきずる", "きょうしつ", "やすめる", "ずるすめ", "しつ", "きず"]
        var result = [String]()
        if lang.randomElement()! == "en" {
            result.append(english.randomElement()!)
            result.append(english.randomElement()!)
            result.append(lang[0])
        } else {
            result.append(japanese.randomElement()!)
            result.append(japanese.randomElement()!)
            result.append(lang[1])
        }
        return result
    }
    
    @objc func actionTappedOnTTSText(sender:UITapGestureRecognizer) {
        GlobalMethod.showAlert("TODO: PLAY TTS!")
    }
}

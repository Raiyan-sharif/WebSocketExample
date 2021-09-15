//
//  PronunciationPracticeViewController.swift
//  PockeTalk
//

import UIKit
protocol DismissPronunciationDelegate {
    func dismissPro()
}
class PronunciationPracticeViewController: BaseViewController {
    
    @IBOutlet weak var viewSpeechTextContainer: UIView!
    @IBOutlet weak var labelPronunciationGuideline: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var labelOriginalText: UILabel!
    let width : CGFloat = 100
    let trailing : CGFloat = -20
    var delegate : DismissPronunciationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    // Initial UI set up
    func setUpUI () {
        self.setUpMicroPhoneIcon()
        self.labelPronunciationGuideline.text = "PronunciationGuideline".localiz()
        self.viewSpeechTextContainer.layer.cornerRadius = 20
        self.viewSpeechTextContainer.layer.masksToBounds = true

        self.viewSpeechTextContainer.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)
        
        let tapForTTS = UITapGestureRecognizer(target: self, action: #selector(self.actionTappedOnTTSText(sender:)))
        labelOriginalText.isUserInteractionEnabled = true
        labelOriginalText.addGestureRecognizer(tapForTTS)

    }
    
    // floating microphone button
    func setUpMicroPhoneIcon () {
        let floatingButton = GlobalMethod.setUpMicroPhoneIcon(view: self.view, width: width, height: width, trailing: trailing, bottom: trailing)
        floatingButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }
    
    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SpeechProcessingViewController")as! SpeechProcessingViewController
        controller.homeMicTapTimeStamp = currentTS
        controller.isFromPronunciationPractice = true
        self.navigationController?.pushViewController(controller, animated: true);
    }
    
    @IBAction func actionBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        self.delegate?.dismissPro()
    }
    
    @objc func actionTappedOnTTSText(sender:UITapGestureRecognizer) {
        GlobalMethod.showAlert("TODO: PLAY TTS!")
    }
}

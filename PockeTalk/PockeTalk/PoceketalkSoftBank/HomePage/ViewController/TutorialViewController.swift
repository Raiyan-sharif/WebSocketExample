//
// TutorialViewController.swift
// PockeTalk
//

import UIKit
import AVKit
protocol SpeechControllerDismissDelegate : class {
    func dismiss()
}

class TutorialViewController: UIViewController {
    ///Views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomTalkView: UIView!

    ///Properties
    let TAG = "\(TutorialViewController.self)"
    var tutorialVM : TutorialViewModel!
    var avPlayer: AVPlayer!
    let cornerRadius : CGFloat = 15
    let animationDuration = 0.3
    let animationDelay = 0
    let animatedViewTransformation : CGFloat = 0.01
    let lineSpacing : CGFloat = 0.5
    weak var delegate : SpeechControllerDismissDelegate?
    let width : CGFloat = 100
    weak var navController: UINavigationController?
    let waitingTimeToShowSpeechProcessing : Double = 0.4
    let toastVisibleTime : Double = 2.0
    weak var speechProDismissDelegateFromTutorial : SpeechProcessingDismissDelegate?


    /// Showing Bengali for now
    let selectedLanguageIndex : Int = 8
    ///languageList for all languages
    var tutorialLanguageList = [TutorialLanguages]()
    weak var talkBtn : UIButton?


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tutorialVM = TutorialViewModel()
        self.setUpUI()
    }

    deinit {
        self.deinitGotCalled()
    }

    func deinitGotCalled () {
        PrintUtility.printLog(tag: TAG, text: "Tutorial deinit Got Called")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.playVideo()
    }

    /// Initial UI set up
    func setUpUI () {
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = cornerRadius

        let languageManager = LanguageSelectionManager.shared
        var tutorialLangCode = ""
        if languageManager.isArrowUp{
            tutorialLangCode = languageManager.bottomLanguage
        }else{
            tutorialLangCode = languageManager.topLanguage
        }
        let tutorialLanguage = self.tutorialVM.getTutorialLanguageInfoByCode(langCode: tutorialLangCode)

        self.titleLabel.text = tutorialLanguage?.lineOne
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont.systemFont(ofSize: FontUtility.getBiggerFontSize(), weight: .semibold)
        self.titleLabel.textColor = UIColor._blackColor()

        self.infoLabel.text = tutorialLanguage?.lineTwo
        self.infoLabel.font = UIFont.systemFont(ofSize: FontUtility.getBiggerFontSize(), weight: .regular)
        self.infoLabel.setLineHeight(lineHeight: lineSpacing)
        self.infoLabel.textAlignment = .center
        self.infoLabel.textColor = UIColor._blackColor()

        talkBtn = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomTalkView, width: width, height: width)
        talkBtn?.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }

    @objc func microphoneTapAction (sender : UIButton) {
        sender.isUserInteractionEnabled = false
        let languageManager = LanguageSelectionManager.shared
        var speechLangCode = ""
        if languageManager.isArrowUp{
            speechLangCode = languageManager.bottomLanguage
        }else{
            speechLangCode = languageManager.topLanguage
        }
        if languageManager.hasSttSupport(languageCode: speechLangCode){
            proceedToTakeVoiceInput()

        }else {
            showToast(message: "no_stt_msg".localiz(), seconds: toastVisibleTime)
            PrintUtility.printLog(tag: TAG, text: "checkSttSupport don't have stt support")
        }
    }

    fileprivate func proceedToTakeVoiceInput() {
        if Reachability.isConnectedToNetwork() {
            RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
                if isGranted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.waitingTimeToShowSpeechProcessing) {
                        self.moveToSpeechProcessing()
                        self.talkBtn?.isUserInteractionEnabled = true
                    }
                } else {
                    GlobalMethod.showPermissionAlert(viewController: self, title : kMicrophoneUsageTitle, message : kMicrophoneUsageMessage)

                }
            }
        } else {
            GlobalMethod.showNoInternetAlert()
        }
    }

    func moveToSpeechProcessing() {
        let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
        controller.homeMicTapTimeStamp = currentTS
        controller.languageHasUpdated = true
        controller.screenOpeningPurpose = .HomeSpeechProcessing
        controller.isFromTutorial = true
        controller.speechProcessingDismissDelegate = self
        self.navigationController?.pushViewController(controller, animated: true);
    }

    /// This method is called to play tutorial video using AVPlayer
    func playVideo () {
        guard let path = Bundle.main.path(forResource: "tutorial", ofType: "mp4") else {
            return
        }
        let videoURL = NSURL(fileURLWithPath: path)

        // Create an AVPlayer, passing it the local video url path
        let player = AVPlayer(url: videoURL as URL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        self.videoView.layer.addSublayer(playerLayer)
        player.play()
    }

    // Dismiss tutorial view with animation
    @IBAction func crossActiion(_ sender: UIButton) {

        UIView.animate(withDuration: animationDuration, delay: TimeInterval(animationDelay), options: .curveEaseOut, animations: {
            self.view.transform = CGAffineTransform(scaleX:self.animatedViewTransformation, y: self.animatedViewTransformation)
        }, completion: { _ in
            self.delegate?.dismiss()
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.window?.rootViewController?.dismiss(animated: false, completion: nil)
                (appDelegate.window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: false)
            }
        })
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

extension TutorialViewController : SpeechProcessingDismissDelegate {
    func showTutorial() {
        self.speechProDismissDelegateFromTutorial?.showTutorial()
    }
}

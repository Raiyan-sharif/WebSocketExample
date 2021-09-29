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

    ///Properties
    var tutorialVM : TutorialViewModel!
    var avPlayer: AVPlayer!
    let cornerRadius : CGFloat = 15
    let animationDuration = 0.3
    let animationDelay = 0
    let animatedViewTransformation : CGFloat = 0.01
    let lineSpacing : CGFloat = 0.5
    var delegate : SpeechControllerDismissDelegate?

    /// Showing Bengali for now
    let selectedLanguageIndex : Int = 8
    ///languageList for all languages
    var tutorialLanguageList = [TutorialLanguages]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.tutorialVM = TutorialViewModel()
        self.setUpUI()
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
        let nativeLangCode = languageManager.bottomLanguage
        let tutorialLanguage = self.tutorialVM.getTutorialLanguageInfoByCode(langCode: nativeLangCode)

        self.titleLabel.text = tutorialLanguage?.lineOne
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont.systemFont(ofSize: FontUtility.getBiggerFontSize(), weight: .semibold)
        self.titleLabel.textColor = UIColor._blackColor()

        self.infoLabel.text = tutorialLanguage?.lineTwo
        self.infoLabel.font = UIFont.systemFont(ofSize: FontUtility.getBiggerFontSize(), weight: .regular)
        self.infoLabel.setLineHeight(lineHeight: lineSpacing)
        self.infoLabel.textAlignment = .center
        self.infoLabel.textColor = UIColor._blackColor()
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
            self.dismiss(animated: true, completion: nil)
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

//
// SpeechProcessingViewController.swift
// PockeTalk
//

import UIKit

class SpeechProcessingViewController: BaseViewController{
    ///Views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var speechProcessingAnimationImageView
        : UIImageView!
    @IBOutlet weak var speechProcessingAnimationView: UIView!
    @IBOutlet weak var speechProcessingRightImgView: UIImageView!
    @IBOutlet weak var speechProcessingLeftImgView: UIImageView!
    ///Properties
    /// Showing Bengali for now
    let selectedLanguageIndex : Int = 8

    ///languageList for all languages
    var speechProcessingLanguageList = [SpeechProcessingLanguages]()
    var speechProcessingVM : SpeechProcessingViewModel!
    let cornerRadius : CGFloat = 15
    let titleFontSize : CGFloat = 30
    let fontSize : CGFloat = 27
    let animationDuration = 1.5
    let animationDelay = 0
    let animatedViewTransformation : CGFloat = 0.01
    let lineSpacing : CGFloat = 0.5
    let trailing : CGFloat = -20
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
    var nativeLangCode : String = ""
    var service : MAAudioService?
    var socketManager = SocketManager.sharedInstance
    var screenOpeningPurpose: SpeechProcessingScreenOpeningPurpose?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.speechProcessingVM = SpeechProcessingViewModel()
        let languageManager = LanguageSelectionManager.shared
        nativeLangCode = languageManager.nativeLanguage
        self.setUpUI()
        self.startTimer()
        socketManager.socketManagerDelegate = self
        service = MAAudioService(nil)
        //service?.startRecord()
//        service?.getData = {[weak self] data in
//            self?.socketManager.sendVoiceData(data: data)
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }

    /// Initial UI set up
    func setUpUI () {
        let speechLanguage = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: nativeLangCode)
        self.titleLabel.text = speechLanguage?.initText
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .semibold)
        self.titleLabel.textColor = UIColor._whiteColor()

        let floatingButton = GlobalMethod.setUpMicroPhoneIcon(view: self.view, width: width, height: width, trailing: trailing, bottom: trailing)
        floatingButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)

        self.updateAnimation()
    }

    func updateAnimation () {
        self.speechProcessingLeftImgView.transform = CGAffineTransform(scaleX: transformation, y: transformation)
        self.speechProcessingRightImgView.transform = CGAffineTransform(scaleX: transformation, y: transformation)

        UIView.animate(withDuration: animationDuration,
                       delay: TimeInterval(animationDelay),
                       usingSpringWithDamping: leftImgDampiing,
                       initialSpringVelocity: springVelocity,
                       options: [.repeat, .autoreverse],
                       animations: {
                        self.speechProcessingLeftImgView.transform = CGAffineTransform.identity
                       },
                       completion: { Void in()  }
        )

        UIView.animate(withDuration: animationDuration,
                       delay: TimeInterval(animationDelay),
                       usingSpringWithDamping: rightImgDamping,
                       initialSpringVelocity: springVelocity,
                       options: [.repeat, .autoreverse],
                       animations: {
                        self.speechProcessingRightImgView.transform = CGAffineTransform.identity
                       },
                       completion: { Void in()  }
        )
    }

    func startTimer () {
        self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(checkTime), userInfo: nil, repeats: true)
    }

    @objc func checkTime () {
        totalTime += 1
        if totalTime > 2 {
            self.showExample()
            self.timer?.invalidate()
            self.timer = nil
        }
    }

    func showExample () {
        let speechLanguage = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: nativeLangCode)
        self.exampleLabel.text = speechLanguage?.exampleText
        self.exampleLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.exampleLabel.textAlignment = .center
        self.exampleLabel.textColor = UIColor._whiteColor()

        self.descriptionLabel.text = speechLanguage?.secText
        self.descriptionLabel.setLineHeight(lineHeight: lineSpacing)
        self.descriptionLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.descriptionLabel.textAlignment = .center
        self.descriptionLabel.textColor = UIColor._whiteColor()
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.lineBreakMode = .byWordWrapping
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.timer?.invalidate()
        self.timer = nil
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        if let purpose = screenOpeningPurpose{
            switch purpose {
            case .LanguageSelectionVoice, .LanguageSelectionCamera,  .CountrySelectionByVoice:
                self.navigationController?.popViewController(animated: true)
                break
            default:
                //service?.stopRecord()
                let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
                if (currentTS - self.homeMicTapTimeStamp) <=  1 {
                    self.showTutorial()
                } else {
                    if(isFromPronunciationPractice){
                        self.showPronunciationPracticeResult()
                    }else{
                        self.showTtsAlert()
                    }
                }
            }
        }
    }

    func showTutorial () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTutorialViewController)as! TutorialViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }

    func showTtsAlert () {
        GlobalMethod.showTtsAlert(viewController: self)
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
    }
    func getData(data: Data) {
    }
}

enum SpeechProcessingScreenOpeningPurpose{
    case HomeSpeechProcessing
    case LanguageSelectionVoice
    case CountrySelectionByVoice
    case LanguageSelectionCamera
}

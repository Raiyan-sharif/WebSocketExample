//
// SpeechProcessingViewController.swift
// PockeTalk
//

import UIKit

class SpeechProcessingViewController: BaseViewController{
    private let TAG:String = "SpeechProcessingViewController"
    ///Views
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var exampleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var speechProcessingAnimationImageView: UIImageView!
    @IBOutlet weak var speechProcessingAnimationView: UIView!
    @IBOutlet weak var speechProcessingRightImgView: UIImageView!
    @IBOutlet weak var speechProcessingLeftImgView: UIImageView!
    @IBOutlet weak var bottomTalkView: UIView!
    var languageHasUpdated = false
    var socketData = [Data]()
    ///Properties
    /// Showing Bengali for now
    let selectedLanguageIndex : Int = 8

    ///languageList for all languages
    var speechProcessingLanguageList = [SpeechProcessingLanguages]()
    var speechProcessingVM : SpeechProcessingViewModeling!
    let cornerRadius : CGFloat = 15
    let animationDuration = 1.5
    let animationDelay = 0
    let animatedViewTransformation : CGFloat = 0.01
    let lineSpacing : CGFloat = 0.5
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
    //var socketManager = SocketManager.sharedInstance
    var screenOpeningPurpose: SpeechProcessingScreenOpeningPurpose?
    var socketManager = SocketManager.sharedInstance
    var isSSTavailable = false

    override func viewDidLoad() {
        super.viewDidLoad()
        socketManager.connect()
        // Do any additional setup after loading the view.
        self.speechProcessingVM = SpeechProcessingViewModel()
        let languageManager = LanguageSelectionManager.shared
        nativeLangCode = languageManager.nativeLanguage
        self.setUpUI()
        bindData()
        if languageHasUpdated {
            speechProcessingVM.updateLanguage()
        }
        socketManager.socketManagerDelegate = self
        self.setUpAudio()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) { [weak self]  in
            self?.showExample()
        }
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
        self.titleLabel.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .semibold)
        self.titleLabel.textColor = UIColor._whiteColor()

        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomTalkView, width: width, height: width)
        talkButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)

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


    private func setUpAudio(){
        service = MAAudioService(nil)
        service?.getData = {[weak self] data in
            guard let `self` = self else { return }

            if self.languageHasUpdated{
                self.socketData.append(data)
            }else if !self.languageHasUpdated  && self.socketData.count == 0{
                self.socketManager.sendVoiceData(data: data)
            }
        }
        service?.getTimer = { [weak self] count in
            guard let `self` = self else { return }
            if count == 30{
                self.service?.stopRecord()
            }
        }
        service?.recordDidStop = { [weak self]  in
            self?.socketManager.sendTextData(text: (self?.speechProcessingVM.getTextFrame())!)
        }

        service?.startRecord()

    }
    private func bindData(){
        speechProcessingVM.isFinal.bindAndFire{ [weak self] isFinal  in
            guard let `self` = self else { return }
            if isFinal{
                self.service?.stopRecord()
                self.service?.timerInvalidate()
                self.showTtsAlert(ttt: self.speechProcessingVM.getTTT_Text,stt: self.speechProcessingVM.getSST_Text.value)
            }
        }
        speechProcessingVM.getSST_Text.bindAndFire { [weak self] sstText  in
            guard let `self` = self else { return }
            if sstText.count > 0{
                self.isSSTavailable = true
                self.titleLabel.text = sstText
                self.exampleLabel.isHidden = true
                self.descriptionLabel.isHidden = true
            }
        }
        speechProcessingVM.isUpdatedAPI.bindAndFire { [weak self] isUpdated in
            guard let `self` = self else { return }
            if isUpdated{
                if self.socketData.count > 0{
                    for data in self.socketData.reversed(){
                        self.socketManager.sendVoiceData(data: data)
                    }
                    self.socketData.removeAll()
                }
                self.languageHasUpdated = false
            }
        }
    }

    func showExample () {
        let speechLanguage = self.speechProcessingVM.getSpeechLanguageInfoByCode(langCode: nativeLangCode)
        self.exampleLabel.text = speechLanguage?.exampleText
        self.exampleLabel.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .regular)
        self.exampleLabel.textAlignment = .center
        self.exampleLabel.textColor = UIColor._whiteColor()

        self.descriptionLabel.text = speechLanguage?.secText
        self.descriptionLabel.setLineHeight(lineHeight: lineSpacing)
        self.descriptionLabel.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .regular)
        self.descriptionLabel.textAlignment = .center
        self.descriptionLabel.textColor = UIColor._whiteColor()
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.lineBreakMode = .byWordWrapping
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        service?.stopRecord()
        service?.timerInvalidate()
        var runCount = 0
         Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
             print("Timer fired!")
             runCount += 1
             if runCount == 6 {
                 timer.invalidate()
                if !self.speechProcessingVM.isFinal.value {
                    self.navigationController?.popViewController(animated: true)
                }
             }
         }
        
//        if let purpose = screenOpeningPurpose{
//            switch purpose {
//            case .LanguageSelectionVoice, .LanguageSelectionCamera,  .CountrySelectionByVoice:
//                self.navigationController?.popViewController(animated: true)
//                break
//
//            case .HomeSpeechProcessing :
//                let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
//                if (currentTS - self.homeMicTapTimeStamp) <=  1 {
//                    self.showTutorial()
//                } else {
//                    if(isFromPronunciationPractice){
//                        self.showPronunciationPracticeResult()
//                    }else{
//                        //self.showTtsAlert()
//                    }
//                }
//                break
//            }
//        }
    }

    func showTutorial () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTutorialViewController)as! TutorialViewController
        controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }

    func showTtsAlert (ttt:String,stt:String) {
        GlobalMethod.showTtsAlert(viewController: self, tttValue: ttt, sttValue: stt)
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
        speechProcessingVM.setTextFromScoket(value: text)
    }

    func getData(data: Data) {

    }
    func faildSocketConnection(value: String) {
        
    }
}

enum SpeechProcessingScreenOpeningPurpose{
    case HomeSpeechProcessing
    case LanguageSelectionVoice
    case CountrySelectionByVoice
    case LanguageSelectionCamera
}

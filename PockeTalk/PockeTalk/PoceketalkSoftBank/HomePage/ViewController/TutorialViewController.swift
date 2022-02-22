//
// TutorialViewController.swift
// PockeTalk
//

import UIKit

//MARK: - SpeechControllerDismissDelegate
protocol SpeechControllerDismissDelegate : AnyObject {
    func dismiss()
}

protocol DismissTutorialDelegate: AnyObject {
    func dismissTutorialWhileFirstTimeLoad()
}

class TutorialViewController: BaseViewController {
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var infoLabel: UILabel!
    @IBOutlet weak private var crossButton: UIButton!
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var bottomTalkView: UIView!
    @IBOutlet weak private var tutorialContainerView: UIView!
    @IBOutlet weak var bottomViewBottomLayoutConstrain: NSLayoutConstraint!
    
    ///Properties
    private let TAG = "\(TutorialViewController.self)"
    private var tutorialVM : TutorialViewModel!
    
    private var selectedLanguageCode = String()
    private var tutorialLanguage: TutorialLanguages?

    private let cornerRadius : CGFloat = 15
    private let lineSpacing : CGFloat = 0.5
    private let width : CGFloat = 100
    
    private let toastVisibleTime : Double = 2.0
    private let animationDuration = 0.3
    private let animationDelay = 0
    private let animatedViewTransformation : CGFloat = 0.01
    private let waitingTimeToShowSpeechProcessing : Double = 0.4
    
    private let ttsResponsiveView = TTSResponsiveView()
    private var voice : String = ""
    private var rate : String = "1.0"
    private static let toChildContainer = "ChildVC"
    
    weak var speechProDismissDelegateFromTutorial : SpeechProcessingDismissDelegate?
    weak var delegate : SpeechControllerDismissDelegate?
    var dismissTutorialDelegate: DismissTutorialDelegate?
    var isShwoingTutorialForTheFirstTime = false
    weak var navController: UINavigationController?
    var urlStrings:[String] = []
    var multipartAudioPlayer: MultipartAudioPlayer?

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tutorialVM = TutorialViewModel()

        setTutorialLanguageCode()
        setUpUI()
        setupTTSView()
        registerForNotification()
        multipartAudioPlayer = MultipartAudioPlayer(controller: self, delegate: self)
    }

    deinit {
        stopTTS()
        PrintUtility.printLog(tag: TAG, text: "Tutorial deinit Got Called")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
    }

    //MARK: - Initial Setup
    private func setUpUI () {
        bottomViewBottomLayoutConstrain.constant = HomeViewController.homeVCBottomViewHeight
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = cornerRadius

        self.titleLabel.text = tutorialLanguage?.lineOne
        self.titleLabel.textAlignment = .center
        self.titleLabel.font = UIFont.systemFont(ofSize: FontUtility.getTutorialFontSize(), weight: .semibold)
        self.titleLabel.textColor = UIColor._blackColor()

        self.infoLabel.text = tutorialLanguage?.lineTwo
        self.infoLabel.font = UIFont.systemFont(ofSize: FontUtility.getTutorialFontSize(), weight: .regular)
        self.infoLabel.setLineHeight(lineHeight: lineSpacing)
        self.infoLabel.textAlignment = .center
        self.infoLabel.textColor = UIColor._blackColor()
    }
    
    private func setTutorialLanguageCode() {
        let languageManager = LanguageSelectionManager.shared
        
        languageManager.isArrowUp ? (selectedLanguageCode = languageManager.bottomLanguage) :
                                    (selectedLanguageCode = languageManager.topLanguage)
        
        tutorialLanguage = self.tutorialVM.getTutorialLanguageInfoByCode(langCode: selectedLanguageCode)
    }
    
    private func setupTTSView() {
        ttsResponsiveView.ttsResponsiveViewDelegate = self
        self.view.addSubview(ttsResponsiveView)
        ttsResponsiveView.isHidden = true
        getTTSValue()
    }
    
    private func registerForNotification() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
    }

    //MARK: - IBActions
    @IBAction private func crossActiion(_ sender: UIButton) {
        UIView.animate(withDuration: animationDuration, delay: TimeInterval(animationDelay), options: .curveEaseOut, animations: {
            self.view.transform = CGAffineTransform(scaleX:self.animatedViewTransformation, y: self.animatedViewTransformation)
        }, completion: { [weak self] _ in
            guard let `self` = self else { return }
            self.delegate?.dismiss()
            self.stopTTS()
            self.remove(asChildViewController: self)
            if self.isShwoingTutorialForTheFirstTime {
                self.dismissTutorialDelegate?.dismissTutorialWhileFirstTimeLoad()
            }
        })
    }

    //MARK: - View Transactions
    private func proceedToTakeVoiceInput() {
        if Reachability.isConnectedToNetwork() {
            RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
                if isGranted {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.waitingTimeToShowSpeechProcessing) {
                        self.stopTTS()
                    }
                } else {
                    GlobalMethod.showPermissionAlert(viewController: self, title : kMicrophoneUsageTitle, message : kMicrophoneUsageMessage)

                }
            }
        } else {
            GlobalMethod.showNoInternetAlert()
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == TutorialViewController.toChildContainer {
            if let childCV = segue.destination as? TutorialContainerViewController {
                childCV.playVideoCallback = { [weak self] in
                    self?.stopTTS()
                    self?.playTTS()
                }
            }
        }
    }

    //MARK: - Utils
    ///TTS functionalities
    private func getTTSValue() {
        let item = LanguageEngineParser.shared.getTtsValue(langCode: selectedLanguageCode)
        self.voice = item.voice
        self.rate = item.rate
    }
    
    private func playTTS(){
        let languageManager = LanguageSelectionManager.shared
        
        if(languageManager.hasTtsSupport(languageCode: selectedLanguageCode)){
            PrintUtility.printLog(tag: TAG,text: "checkTtsSupport has TTS support \(selectedLanguageCode)")
            if let _ = LanguageEngineParser.shared.getTtsValueByCode(code:selectedLanguageCode){
                urlStrings = []
                proceedAndPlayTTS()
            }else{
                AudioPlayer.sharedInstance.delegate = self
                if !AudioPlayer.sharedInstance.isPlaying{
                    AudioPlayer.sharedInstance.getTTSDataAndPlay(translateText: tutorialLanguage?.lineTwo ?? "", targetLanguageItem: selectedLanguageCode, tempo:normal)
                }
            }
        }else{
            PrintUtility.printLog(tag: TAG,text: "checkTtsSupport don't have TTS support \(selectedLanguageCode)")
            let seconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.stopTTS()
            }
        }
    }

    private func stopTTS(){
        ttsResponsiveView.stopTTS()
        multipartAudioPlayer?.stop()
        AudioPlayer.sharedInstance.stop()
    }
    
    private func proceedAndPlayTTS() {
        ttsResponsiveView.checkSpeakingStatus()
        ttsResponsiveView.setRate(rate: rate)
        PrintUtility.printLog(tag: "Translate ", text: tutorialLanguage?.lineTwo ?? "")
        ttsResponsiveView.TTSPlay(voice: voice, text: tutorialLanguage?.lineTwo ?? "")
    }
    
    @objc private func willResignActive(_ notification: Notification) {
        stopTTS()
    }
}

//MARK: - SpeechProcessingDismissDelegate
extension TutorialViewController : SpeechProcessingDismissDelegate {
    func showTutorial() {
        self.speechProDismissDelegateFromTutorial?.showTutorial()
    }
}

//MARK: - TTSResponsiveViewDelegate
extension TutorialViewController: TTSResponsiveViewDelegate{
    func onMultipartUrlReceived(url: String) {
        if(!url.isEmpty){
            urlStrings.append(url)
        }
    }
    
    func onMultipartUrlEnd() {
        multipartAudioPlayer?.playMultipartAudio(urls: urlStrings)
    }
    
    func speakingStatusChanged(isSpeaking: Bool) {}
    func onReady() {}
    func onVoiceEnd() {}
}

extension TutorialViewController :AudioPlayerDelegate{
    func didStartAudioPlayer() {

    }

    func didStopAudioPlayer(flag: Bool) {

    }
}
extension TutorialViewController : MultipartAudioPlayerProtocol{
    func onSpeakStart() {}
    func onSpeakFinish() {}
    func onError() {}
}

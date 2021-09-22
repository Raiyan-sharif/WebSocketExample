//
// TtsAlertController.swift
// PockeTalk
//

import UIKit
protocol DismissReverseVieeDelegate {
    func dismissReverse ()
}
class TtsAlertController: BaseViewController {
    private let TAG:String = "TtsAlertController"
    ///Views
    @IBOutlet weak var toTranslateLabel: UILabel!
    @IBOutlet weak var fromTranslateLabel: UILabel!
    @IBOutlet weak var changeTranslationButton: UIButton!
    @IBOutlet weak var fromLanguageLabel: UILabel!
    @IBOutlet weak var toLanguageLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomTalkView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var fromLangLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var toLangLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewtrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint!
    ///Properties
    var ttsVM : TtsAlertViewModel!
    var chatEntity : ChatEntity?
    let cornerRadius : CGFloat = 15
    let fontSize : CGFloat = FontUtility.getFontSize()
    let reverseFontSize : CGFloat = FontUtility.getBiggerFontSize()
    let width : CGFloat = 100
    let toastVisibleTime : CGFloat = 2.0
    var nativeLanguage : String = ""
    var targetLanguage : String = ""
    var delegate : SpeechControllerDismissDelegate?
    var itemsToShowOnContextMenu : [AlertItems] = []
    var talkButton : UIButton?
    var nativeText: String = ""
    var targetText: String = ""
    var nativeLangCode : String = ""
    var targetLangCode : String = ""
    let animationDuration : CGFloat = 0.6
    let animationDelay : CGFloat = 0
    let transform : CGFloat = 0.97
    var isFromHistoryOrFavourite = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.ttsVM = TtsAlertViewModel()

        /// Initialize Language Manager
        let languageManager = LanguageSelectionManager.shared

        /// Populate UI with language data
        if isFromHistoryOrFavourite == false{
            self.getLanguageInfo(nativeCode: languageManager.nativeLanguage, targetCode: languageManager.targetLanguage)
        }

        self.setUpUI()
        self.populateData()
        let isArrowUp = languageManager.isArrowUp ?? true
        let isTop = isArrowUp ? IsTop.noTop.rawValue : IsTop.top.rawValue
        self.ttsVM.saveChatData(nativeText: nativeText, nativeLangCode: nativeLanguage, targetText: targetText, targetLangCode: targetLanguage, isTop: isTop)
        PrintUtility.printLog(tag: TAG, text: nativeText)
        PrintUtility.printLog(tag: TAG, text: targetText)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }

    func getLanguageInfo (nativeCode : String, targetCode : String) {
        let language = self.ttsVM.getLanguage(nativeLangCode: nativeCode, targetLangCode: targetCode)
        if let nativeLangName = language.nativaLanguage?.name, let nativeCode = language.nativaLanguage?.code {
            nativeLanguage = nativeLangName
            nativeLangCode = nativeCode
        }

        if let targetLangName = language.targetLanguage?.name, let targetCode = language.targetLanguage?.code {
            targetLanguage = targetLangName
            targetLangCode = targetCode
        }

//        let stt = self.ttsVM.getTranslationData(nativeCode: nativeCode, targetCode: targetCode)
//        if let nativeSTTText = stt.nativeText{
//            nativeText = nativeSTTText
//        }
//        if let targetSTTText = stt.targetText{
//            targetText = targetSTTText
//        }
    }

    /// Initial UI set up
    func setUpUI () {
        self.backgroundImageView.layer.masksToBounds = true
        self.backgroundImageView.layer.cornerRadius = cornerRadius
        self.startAnimation()

        self.toLanguageLabel.text = targetText
        self.toLanguageLabel.textAlignment = .center
        self.toLanguageLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.toLanguageLabel.textColor = UIColor._blackColor()

        self.fromLanguageLabel.text = nativeText
        self.fromLanguageLabel.textAlignment = .center
        self.fromLanguageLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.fromLanguageLabel.textColor = UIColor.gray

        self.toTranslateLabel.text = targetLanguage
        self.toTranslateLabel.textAlignment = .right
        self.toTranslateLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.toTranslateLabel.textColor = UIColor.gray

        self.fromTranslateLabel.text = nativeLanguage
        self.fromTranslateLabel.textAlignment = .left
        self.fromTranslateLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.fromTranslateLabel.textColor = UIColor._whiteColor()
        
        if(LanguageSelectionManager.shared.isArrowUp ?? true){
            changeTranslationButton.image(for: UIControl.State.normal)
        }
        talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomTalkView, width: width, height: width)
        talkButton?.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
        
        setLanguageDirection(isArrowUp: UserDefaultsProperty<Bool>(kIsArrowUp).value ?? true)
        
        if isFromHistoryOrFavourite == true{
            self.bottomView.isHidden = true
        }
    }

    /// Start animation on background image view
    func startAnimation () {
        self.backgroundImageView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: TimeInterval(animationDelay), options: [.repeat, .autoreverse], animations: {
            self.backgroundImageView.transform = CGAffineTransform(scaleX: self.transform, y: self.transform)
        },completion: { Void in()  })
    }

    /// Stop animation on background image view
    func stopAnimation () {
        self.backgroundImageView.layer.removeAllAnimations()
    }

    /// Update UI for Reverse translation
    func updateUIForReverse () {
        updateViewShowHideStatus()
        self.updateConstraints()
        self.startAnimation()

        let reversedToLanguageText = self.toLanguageLabel.text
        let reversedFromLanguageText = self.fromLanguageLabel.text
        self.toLanguageLabel.text = reversedFromLanguageText
        self.fromLanguageLabel.text = reversedToLanguageText
        self.toLanguageLabel.font = UIFont.systemFont(ofSize: reverseFontSize, weight: .semibold)
        self.fromLanguageLabel.font = UIFont.systemFont(ofSize: reverseFontSize, weight: .semibold)

        if let lastSavedChatID = UserDefaultsProperty<Int64>(kLastSavedChatID).value {
            chatEntity = self.ttsVM.findLastSavedChat(id: lastSavedChatID)
            self.updateBackgroundImage(topSelected: chatEntity?.chatIsTop ?? 0, featureType: .reverse)
        }

        self.saveReversedTranslatedDataToDB(nativeText: reversedToLanguageText, targetText: reversedFromLanguageText)
    }

    /// Save reversed translation data to chat table
    func saveReversedTranslatedDataToDB (nativeText : String?, targetText : String?) {
        self.ttsVM.saveChatData(nativeText: nativeText, nativeLangCode: targetLangCode, targetText: targetText, targetLangCode: nativeLangCode, isTop: chatEntity?.chatIsTop == IsTop.top.rawValue ? IsTop.noTop.rawValue : IsTop.top.rawValue)
    }

    /// Update UI for Retranslation
    func updateUIForRetranslation () {
        self.updateViewShowHideStatus()
        self.updateConstraints()
        self.startAnimation()

        if let lastSavedChatID = UserDefaultsProperty<Int64>(kLastSavedChatID).value {
            chatEntity = self.ttsVM.findLastSavedChat(id: lastSavedChatID)
            self.updateBackgroundImage(topSelected: chatEntity?.chatIsTop ?? 0, featureType: .retranslation)
        }

        /// set translated text on label
        self.toLanguageLabel.text = targetText
        self.toLanguageLabel.font = UIFont.systemFont(ofSize: reverseFontSize, weight: .semibold)

        self.fromLanguageLabel.text = nativeText
        self.fromLanguageLabel.font = UIFont.systemFont(ofSize: reverseFontSize, weight: .semibold)
    }

    func updateBackgroundImage (topSelected : Int64, featureType : AlertFeatureType) {
        if featureType == .reverse {
            self.backgroundImageView.image = topSelected == IsTop.top.rawValue ? UIImage(named: "back_texture_white") : UIImage(named: "slider_back_texture_blue")
        } else {
            self.backgroundImageView.image = topSelected == IsTop.top.rawValue ? UIImage(named: "slider_back_texture_blue") : UIImage(named: "back_texture_white")
        }
    }

    func updateViewShowHideStatus () {
        self.crossButton.isHidden = false
        self.bottomView.isHidden = true
        self.talkButton?.isHidden = true
        self.menuButton.isHidden = true
        self.backButton.isHidden = true
    }

    /// Update constraints for Reverse translation
    func updateConstraints () {
        self.containerViewTopConstraint.constant = 20
        self.containerViewtrailingConstraint.constant = 25
        self.containerViewBottomConstraint.constant = 25
        self.containerViewLeadingConstraint.constant = 25
        self.toLangLabelTopConstraint.constant = 220
        self.fromLangLabelBottomConstraint.constant = 60
    }
    
    @IBAction func actionLanguageDirectionChange(_ sender: UIButton) {
        if UserDefaultsProperty<Bool>(kIsArrowUp).value == false{
            setLanguageDirection(isArrowUp: true)
            UserDefaultsProperty<Bool>(kIsArrowUp).value = true
        }else{
            setLanguageDirection(isArrowUp: false)
            UserDefaultsProperty<Bool>(kIsArrowUp).value = false
        }
        self.delegate?.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setLanguageDirection(isArrowUp: Bool){
        if (isArrowUp){
            self.changeTranslationButton.setImage(UIImage(named: "arrow_back_icon"), for: UIControl.State.normal)
            self.backgroundImageView.image = UIImage(named: "back_texture_white")
        }else{
            self.changeTranslationButton.setImage(UIImage(named: "arrow_forward"), for: UIControl.State.normal)
            self.backgroundImageView.image = UIImage(named: "slider_back_texture_blue")

        }
    }

    @IBAction func menuTapAction(_ sender: UIButton) {
        self.stopAnimation()
        let vc = AlertReusableViewController.init()
        vc.items = self.itemsToShowOnContextMenu
        vc.reverseDelegate = self
        vc.retranslateDelegate = self
        let navController = UINavigationController.init(rootViewController: vc)
        navController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        navController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.navigationController?.present(navController, animated: true, completion: nil)
    }

    // Populate item to show on context menu
    func populateData () {
        self.itemsToShowOnContextMenu.append(AlertItems(title: "history_add_fav".localiz(), imageName: "icon_favorite_popup.png", menuType: .favorite))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "retranslation".localiz(), imageName: "", menuType: .retranslation))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "reverse".localiz(), imageName: "", menuType: .reverse))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "pronunciation_practice".localiz(), imageName: "", menuType: .practice))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "send_an_email".localiz(), imageName: "", menuType: .sendMail))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "cancel".localiz(), imageName: "", menuType: .cancel) )
    }

    // This method get called when cross button is tapped
    @IBAction func crossActiioin(_ sender: UIButton) {
        self.stopAnimation()
        self.delegate?.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    //Dismiss view on back button press
    @IBAction func dismissView(_ sender: UIButton) {
        self.stopAnimation()
        self.delegate?.dismiss()
        self.dismiss(animated: true, completion: nil)
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        self.showToast(message: "Navigate to Speech Controller", seconds: Double(toastVisibleTime))
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

extension TtsAlertController : ReverseDelegate {
    func transitionFromReverse() {
        self.updateUIForReverse()
    }
}

extension TtsAlertController : RetranslationDelegate {
    func showRetranslation(selectedLanguage: String) {
        let languageManager = LanguageSelectionManager.shared

        // Get language data for selected target language and populate UI
        if UserDefaultsProperty<Bool>(kIsArrowUp).value == false{
            self.getLanguageInfo(nativeCode: selectedLanguage , targetCode: languageManager.targetLanguage)
        } else {
            self.getLanguageInfo(nativeCode: languageManager.nativeLanguage, targetCode: selectedLanguage)
        }
        self.updateUIForRetranslation()
    }
}

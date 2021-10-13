//
// TtsAlertController.swift
// PockeTalk
//

import UIKit
import WebKit
protocol TtsAlertControllerDelegate : class{
    func itemAdded(_ chatItemModel: HistoryChatItemModel)
    func itemDeleted(_ chatItemModel: HistoryChatItemModel)
    func updatedFavourite(_ chatItemModel: HistoryChatItemModel)
}
protocol Pronunciation {
    func dismissPro(dict:[String : String])
}
class TtsAlertController: BaseViewController, UIGestureRecognizerDelegate, Pronunciation {
    func dismissPro(dict:[String : String]) {
        NotificationCenter.default.post(name: SpeechProcessingViewController.didPressMicroBtn, object: nil, userInfo: dict)
        self.dismiss(animated: true, completion: nil)
    }
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
   weak var delegate : SpeechControllerDismissDelegate?
    var itemsToShowOnContextMenu : [AlertItems] = []
    var talkButton : UIButton?
    let animationDuration : CGFloat = 0.6
    let animationDelay : CGFloat = 0
    let transform : CGFloat = 0.97
    var chatItemModel: HistoryChatItemModel?
    var hideMenuButton = false
    var hideBottomView = false
    weak var ttsAlertControllerDelegate: TtsAlertControllerDelegate?
    var longTapGesture : UILongPressGestureRecognizer?
    var wkView:WKWebView!
    var ttsResponsiveView = TTSResponsiveView()
    var isFromHistory : Bool = false
    var voice : String = ""
    var rate : String = "1.0"
    var isSpeaking : Bool = false
    var isRecreation: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.ttsVM = TtsAlertViewModel()
        self.setUpUI()
        self.getTtsValue()
        ttsResponsiveView.ttsResponsiveViewDelegate = self
        self.view.addSubview(ttsResponsiveView)
        ttsResponsiveView.isHidden = true
        
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!isRecreation){
            self.startAnimation()
            
        }
    }
    
    @objc func willResignActive(_ notification: Notification) {
        self.stopTTS()
    }
    
    /// Initial UI set up
    func setUpUI () {
        self.backgroundImageView.layer.masksToBounds = true
        self.backgroundImageView.layer.cornerRadius = cornerRadius
        self.toLanguageLabel.text = chatItemModel?.chatItem?.textTranslated
        self.fromLanguageLabel.sizeToFit()
        
        //self.toLanguageLabel.text = chatItemModel?.chatItem?.textTranslated
        self.toLanguageLabel.textAlignment = .center
        self.toLanguageLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.toLanguageLabel.textColor = UIColor._blackColor()
        self.fromLanguageLabel.text = chatItemModel?.chatItem?.textNative
        self.fromLanguageLabel.sizeToFit()
        
        //self.fromLanguageLabel.text = chatItemModel?.chatItem?.textNative
        self.fromLanguageLabel.textAlignment = .center
        self.fromLanguageLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.fromLanguageLabel.textColor = UIColor.gray

        self.toTranslateLabel.text = chatItemModel?.chatItem?.chatIsTop == IsTop.noTop.rawValue ? chatItemModel?.chatItem?.textTranslatedLanguage : chatItemModel?.chatItem?.textNativeLanguage
        self.toTranslateLabel.textAlignment = .right
        self.toTranslateLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.toTranslateLabel.textColor = UIColor.gray

        self.fromTranslateLabel.text = chatItemModel?.chatItem?.chatIsTop == IsTop.noTop.rawValue ? chatItemModel?.chatItem?.textNativeLanguage : chatItemModel?.chatItem?.textTranslatedLanguage
        self.fromTranslateLabel.textAlignment = .left
        self.fromTranslateLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.fromTranslateLabel.textColor = UIColor._whiteColor()
        
        if(LanguageSelectionManager.shared.isArrowUp){
            changeTranslationButton.image(for: UIControl.State.normal)
        }
        talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomTalkView, width: width, height: width)
        talkButton?.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
        setLanguageDirection()
        longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longTapGesture!.minimumPressDuration = 0.2
        longTapGesture!.delegate = self
        longTapGesture!.delaysTouchesBegan = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(recognizer:)))
        tapGesture.delegate = self
        self.containerView.isUserInteractionEnabled = true
        self.containerView.addGestureRecognizer(tapGesture)
        
        if hideBottomView == true{
            self.bottomView.isHidden = true
        }
        if hideMenuButton == true{
            updateUI()
        }else{
            self.containerView.addGestureRecognizer(longTapGesture!)
        }
        self.updateBackgroundImage(topSelected: chatItemModel?.chatItem?.chatIsTop ?? 0)
    }

    /// Retreive tts value from respective language code
    func getTtsValue () {
        let languageManager = LanguageSelectionManager.shared
        let targetLanguageItem = languageManager.getLanguageCodeByName(langName: chatItemModel!.chatItem!.textTranslatedLanguage!)
        let item = LanguageEngineParser.shared.getTtsValue(langCode: targetLanguageItem!.code)
        self.voice = item.voice
        self.rate = item.rate
    }

    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state == UIGestureRecognizer.State.ended){
            self.stopTTS()
            self.openContextMenu()
        }
        
    }
    @objc func handleSingleTap(recognizer:UITapGestureRecognizer) {
        if(!isSpeaking){
            playTTS()
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

    func updateUI () {
        updateViewShowHideStatus()
        self.updateConstraints()
        self.startAnimation()

        self.toLanguageLabel.text = chatItemModel?.chatItem?.textTranslated
        self.fromLanguageLabel.text = chatItemModel?.chatItem?.textNative
        self.toLanguageLabel.font = UIFont.systemFont(ofSize: reverseFontSize, weight: .semibold)
        self.fromLanguageLabel.font = UIFont.systemFont(ofSize: reverseFontSize, weight: .semibold)
        
        self.updateBackgroundImage(topSelected: chatItemModel?.chatItem?.chatIsTop ?? 0)
        
        self.containerView.removeGestureRecognizer(longTapGesture!)
        if(!isSpeaking){
            playTTS()
        }
    }
    
    func UpdateUIForHidingMenu(){
        self.updateViewShowHideStatus()
        self.updateConstraints()
        self.startAnimation()
    }
    
    func updateUIForFavourite (){
        self.crossButton.isHidden = false
        self.bottomView.isHidden = true
        self.talkButton?.isHidden = true
        self.menuButton.isHidden = true
        self.backButton.isHidden = true
    }

    func updateBackgroundImage (topSelected : Int64) {
        self.backgroundImageView.image = topSelected == IsTop.top.rawValue ? UIImage(named: "slider_back_texture_blue") : UIImage(named: "back_texture_white")
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
        //self.toLangLabelTopConstraint.constant = 220
        //self.fromLangLabelBottomConstraint.constant = 60
    }
    
    @IBAction func actionLanguageDirectionChange(_ sender: UIButton) {
        if LanguageSelectionManager.shared.isArrowUp{
            LanguageSelectionManager.shared.isArrowUp = false
        }else{
            LanguageSelectionManager.shared.isArrowUp = true
        }
        self.delegate?.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setLanguageDirection(){
        let isArrowUp = LanguageSelectionManager.shared.isArrowUp
        if (isArrowUp){
            self.changeTranslationButton.setImage(UIImage(named: "arrow_back_icon"), for: UIControl.State.normal)
        }else{
            self.changeTranslationButton.setImage(UIImage(named: "arrow_forward"), for: UIControl.State.normal)
        }
    }

    @IBAction func menuTapAction(_ sender: UIButton) {
        self.stopTTS()
        self.stopAnimation()
        self.openContextMenu()
    }
    
    func openContextMenu(){
        let vc = AlertReusableViewController.init()
        let languageManager = LanguageSelectionManager.shared
        let language = languageManager.getLanguageCodeByName(langName: (chatItemModel?.chatItem?.textTranslatedLanguage)!)
        if languageManager.hasSttSupport(languageCode: language!.code){
            PrintUtility.printLog(tag: "TAG", text: "checkSttSupport has support \(language?.code)")
            populateData(withPronounciation: true)
        }else{
            PrintUtility.printLog(tag: "TAG", text: "checkSttSupport not support \(language?.code)")
            populateData(withPronounciation: false)
        }
        vc.items = self.itemsToShowOnContextMenu
        vc.delegate = self
        vc.chatItemModel = self.chatItemModel
        let navController = UINavigationController.init(rootViewController: vc)
        navController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        navController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        if self.navigationController != nil{
            self.navigationController?.present(navController, animated: true, completion: nil)
        }else{
            self.present(navController, animated: true, completion: nil)
        }
    }

    // Populate item to show on context menu
    func populateData (withPronounciation: Bool) {
        self.itemsToShowOnContextMenu.removeAll()
        self.itemsToShowOnContextMenu.append(AlertItems(title: "history_add_fav".localiz(), imageName: "icon_favorite_popup.png", menuType: .favorite))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "retranslation".localiz(), imageName: "", menuType: .retranslation))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "reverse".localiz(), imageName: "", menuType: .reverse))
        if(hideBottomView){
            self.itemsToShowOnContextMenu.append(AlertItems(title: "delete".localiz(), imageName: "Delete_icon.png", menuType: .delete))
        }
        if withPronounciation {
            self.itemsToShowOnContextMenu.append(AlertItems(title: "pronunciation_practice".localiz(), imageName: "", menuType: .practice))
        }
        self.itemsToShowOnContextMenu.append(AlertItems(title: "send_an_email".localiz(), imageName: "", menuType: .sendMail))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "cancel".localiz(), imageName: "", menuType: .cancel) )
    }

    // This method get called when cross button is tapped
    @IBAction func crossActiioin(_ sender: UIButton) {
        self.dismissPopUp()
    }
    //Dismiss view on back button press
    @IBAction func dismissView(_ sender: UIButton) {
        self.dismissPopUp()
    }
    func dismissPopUp(){
        stopTTS()
        self.stopAnimation()
        if let historyVC = self.presentingViewController?.presentingViewController  as? HistoryViewController{
            historyVC.presentingViewController?.dismiss(animated: true, completion: nil)
        }else if let favVC = self.presentingViewController?.presentingViewController  as? FavouriteViewController{
            favVC.presentingViewController?.dismiss(animated: true, completion: nil)
        }else if let ttsVC = self.presentingViewController?.presentingViewController?.presentingViewController as? HistoryViewController{
            ttsVC.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            if let nav = self.presentingViewController, nav is UINavigationController{
                self.dismiss(animated: false) {
                    (nav as! UINavigationController).popViewController(animated: false)
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
       // self.delegate?.dismiss()
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
       // self.showToast(message: "Navigate to Speech Controller", seconds: Double(toastVisibleTime))
        self.stopTTS()
        if isFromHistory {
            let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
            controller.homeMicTapTimeStamp = currentTS
            controller.languageHasUpdated = true
            controller.screenOpeningPurpose = .HomeSpeechProcessing
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        } else {
            NotificationCenter.default.post(name: SpeechProcessingViewController.didPressMicroBtn, object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }

    fileprivate func proceedAndPlayTTS() {
        ttsResponsiveView.isSpeaking()
        ttsResponsiveView.setRate(rate: rate)
        let translateText = chatItemModel?.chatItem?.textTranslated
        PrintUtility.printLog(tag: "Translate ", text: translateText ?? "")
        startAnimation()
        ttsResponsiveView.TTSPlay(voice: voice,text: translateText ??  "")
    }

    func playTTS(){
        let languageManager = LanguageSelectionManager.shared
        if let targetLanguageItem = languageManager.getLanguageCodeByName(langName: chatItemModel!.chatItem!.textTranslatedLanguage!){
            if(languageManager.hasTtsSupport(languageCode: targetLanguageItem.code)){
                PrintUtility.printLog(tag: TAG,text: "checkTtsSupport has TTS support \(targetLanguageItem.code)")
                proceedAndPlayTTS()
            }else{
                PrintUtility.printLog(tag: TAG,text: "checkTtsSupport don't have TTS support \(targetLanguageItem.code)")
                let seconds = 1.0
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.stopTTS()
                }
            }
        }
    }

    func stopTTS(){
        ttsResponsiveView.stopTTS()
        stopAnimation()
    }
}

extension TtsAlertController : RetranslationDelegate {
    func showRetranslation(selectedLanguage: String) {
        let isTop = chatItemModel?.chatItem?.chatIsTop
        let nativeText = chatItemModel?.chatItem!.textNative
        let nativeLangName = chatItemModel?.chatItem!.textNativeLanguage!
        let targetLangName = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: selectedLanguage)?.name
        
        //TODO call websocket api for ttt
        let targetText = chatItemModel?.chatItem!.textTranslated
        
        let chatEntity =  ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangName, textNativeLanguage: nativeLangName!, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isTop, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue)
        self.chatItemModel?.chatItem = chatEntity
        self.getTtsValue()
        ttsVM.saveChatItem(chatItem: chatEntity)
        self.updateUI()
        ttsAlertControllerDelegate?.itemAdded(HistoryChatItemModel(chatItem: chatEntity, idxPath: nil))
    }
}

extension TtsAlertController : AlertReusableDelegate {
    func onDeleteItem(chatItemModel: HistoryChatItemModel?) {
        self.dismissPopUp()
        ttsVM.deleteChatItemFromHistory(chatItem: chatItemModel!.chatItem!)
        ttsAlertControllerDelegate?.itemDeleted(chatItemModel!)
    }
    
    func updateFavourite(chatItemModel: HistoryChatItemModel) {
        ttsAlertControllerDelegate?.updatedFavourite(chatItemModel)
    }
    
    func pronunciationPracticeTap(chatItemModel: HistoryChatItemModel?) {
        let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeViewController") as! PronunciationPracticeViewController
        vc.chatItem = chatItemModel?.chatItem
        vc.delegate = self
        vc.isFromHistory = isFromHistory
        if(self.navigationController != nil){
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    func transitionFromRetranslation(chatItemModel: HistoryChatItemModel?) {
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
        controller.isNative = chatItemModel?.chatItem?.chatIsTop ?? 0 == IsTop.noTop.rawValue ? 1 : 0
        controller.retranslationDelegate = self
        controller.fromRetranslation = true
        if(self.navigationController != nil){
            self.navigationController?.pushViewController(controller, animated: true)
        }else{
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func transitionFromReverse(chatItemModel: HistoryChatItemModel?) {
        self.chatItemModel?.chatItem = chatItemModel?.chatItem
        self.getTtsValue()
        self.updateUI()
        ttsAlertControllerDelegate?.itemAdded(chatItemModel!)
    }
    
}

extension TtsAlertController : TTSResponsiveViewDelegate {
    
    func onVoiceEnd() {
        stopAnimation ()
    }
    
    func speakingStatusChanged(isSpeaking: Bool) {
        self.isSpeaking = isSpeaking
        if(!isSpeaking){
            stopAnimation()
        }
    }
    
    func onReady() {
        if(!isSpeaking && !isRecreation){
            playTTS()
        }
    }
}



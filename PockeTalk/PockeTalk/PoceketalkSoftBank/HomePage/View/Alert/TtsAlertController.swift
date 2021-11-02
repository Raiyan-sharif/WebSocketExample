//
// TtsAlertController.swift
// PockeTalk
//

import UIKit
import WebKit
import CallKit

protocol TtsAlertControllerDelegate : class{
    func itemAdded(_ chatItemModel: HistoryChatItemModel)
    func itemDeleted(_ chatItemModel: HistoryChatItemModel)
    func updatedFavourite(_ chatItemModel: HistoryChatItemModel)
    func dismissed()
}
protocol Pronunciation {
    func dismissPro(dict:[String : String])
}

protocol CurrentTSDelegate : class {
    func passCurrentTSValue (currentTS : Int)
}

class TtsAlertController: BaseViewController, UIGestureRecognizerDelegate, Pronunciation{
  
    
    func dismissPro(dict:[String : String]) {
        NotificationCenter.default.post(name: SpeechProcessingViewController.didPressMicroBtn, object: nil, userInfo: dict)
        self.dismiss(animated: true, completion: nil)
    }
    private let TAG:String = "TtsAlertController"
    var callObserver = CXCallObserver()
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
    var hideTalkButton = false
    weak var ttsAlertControllerDelegate: TtsAlertControllerDelegate?
    var longTapGesture : UILongPressGestureRecognizer?
    var wkView:WKWebView!
    var ttsResponsiveView = TTSResponsiveView()
    var isFromHistory : Bool = false
    private var spinnerView : SpinnerView!

    var voice : String = ""
    var rate : String = "1.0"
    var isSpeaking : Bool = false
    var isRecreation: Bool = false
    var isFromSpeechProcessing = false
    weak var currentTSDelegate : CurrentTSDelegate?
    weak var speechProDismissDelegateFromTTS : SpeechProcessingDismissDelegate?
    var isReverse = false
    
    private var socketManager = SocketManager.sharedInstance
    private var speechProcessingVM : SpeechProcessingViewModeling!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        callObserver.setDelegate(self, queue: nil)
        self.ttsVM = TtsAlertViewModel()
        self.setUpUI()
        self.getTtsValue()
        ttsResponsiveView.ttsResponsiveViewDelegate = self
        self.view.addSubview(ttsResponsiveView)
        ttsResponsiveView.isHidden = true
        self.speechProcessingVM = SpeechProcessingViewModel()
        bindData()
        //SocketManager.sharedInstance.connect()
//        socketManager.socketManagerDelegate = self
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIScene.willDeactivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        }
        if(!isSpeaking){
            playTTS()
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
    
    override func viewWillDisappear(_ animated: Bool) {
        callObserver.setDelegate(nil, queue: nil)
    }
    
    @objc func willResignActive(_ notification: Notification) {
        self.stopTTS()
    }
    
    /// Initial UI set up
    func setUpUI () {
        self.backgroundImageView.layer.masksToBounds = true
        self.backgroundImageView.sizeToFit()
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
            //updateUI()
            updateUIForFavourite ()
        }else{
            self.containerView.addGestureRecognizer(longTapGesture!)
        }
        if hideTalkButton == true{
            self.talkButton?.isHidden = true
        }
        self.updateBackgroundImage(topSelected: chatItemModel?.chatItem?.chatIsTop ?? 0)
        addSpinner()
    }
    
    private func addSpinner(){
        spinnerView = SpinnerView();
        self.view.addSubview(spinnerView)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        spinnerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        spinnerView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        spinnerView.isHidden = true
    }

    /// Retreive tts value from respective language code
    func getTtsValue () {
        PrintUtility.printLog(tag: "TTT CHAT", text: "\(chatItemModel!.chatItem!.textTranslatedLanguage)")
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
//        self.toLanguageLabel.font = UIFont.systemFont(ofSize: reverseFontSize, weight: .semibold)
//        self.fromLanguageLabel.font = UIFont.systemFont(ofSize: reverseFontSize, weight: .semibold)
        
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
        self.talkButton?.isHidden = false
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
        self.dismissPopUp()
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
        self.itemsToShowOnContextMenu.append(AlertItems(title: "share".localiz(), imageName: "", menuType: .sendMail))
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
        if(isFromSpeechProcessing){
            NotificationCenter.default.post(name: .languageSelectionArrowNotification, object: nil)
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
               appDelegate.window?.rootViewController?.dismiss(animated: false, completion: nil)
               (appDelegate.window?.rootViewController as? UINavigationController)?.popToRootViewController(animated: false)
            }
        }else{
            self.ttsAlertControllerDelegate?.dismissed()
            self.dismiss(animated: true, completion: nil)
        }
        
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
            controller.speechProcessingDismissDelegate = self
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        } else {
            let currentTs = GlobalMethod.getCurrentTimeStamp(with: 0)
            self.currentTSDelegate?.passCurrentTSValue(currentTS: currentTs)
            NotificationCenter.default.post(name: SpeechProcessingViewController.didPressMicroBtn, object: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }

    fileprivate func proceedAndPlayTTS() {
        ttsResponsiveView.checkSpeakingStatus()
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

    func shareData(chatItemModel: HistoryChatItemModel?){
        let languageManager = LanguageSelectionManager.shared
        let tranlatedLang = languageManager.getLanguageCodeByName(langName: (chatItemModel?.chatItem!.textTranslatedLanguage)!)?.englishName ?? ""
        let tranlatedText = chatItemModel?.chatItem?.textTranslated ?? ""

        let nativeLang = languageManager.getLanguageCodeByName(langName: (chatItemModel?.chatItem!.textNativeLanguage)!)?.englishName ?? ""
        let nativeText = chatItemModel?.chatItem?.textNative ?? ""

        let sharedData = "Translated language: \(tranlatedLang)\n" + "\(tranlatedText) \n\n" +
        "Original language: \(nativeLang)\n" + "\(nativeText)"

        let dataToSend = [sharedData]

        PrintUtility.printLog(tag: TAG, text: "sharedData \(sharedData)")
        let activityViewController = UIActivityViewController(activityItems: dataToSend, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    func bindData(){
        speechProcessingVM.isFinal.bindAndFire{[weak self] isFinal  in
            guard let `self` = self else { return }
            if isFinal{
                SocketManager.sharedInstance.disconnect()
                PrintUtility.printLog(tag: "TTT text: ",text: self.speechProcessingVM.getTTT_Text)
                PrintUtility.printLog(tag: "TTT src: ", text: self.speechProcessingVM.getSrcLang_Text)
                PrintUtility.printLog(tag: "TTT dest: ", text: self.speechProcessingVM.getDestLang_Text)
                var isTop = self.chatItemModel?.chatItem?.chatIsTop
                var nativeText = self.chatItemModel?.chatItem!.textNative
                var nativeLangName = self.chatItemModel?.chatItem?.textNativeLanguage
                let targetLangName = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: self.speechProcessingVM.getDestLang_Text)?.name
                if(self.isReverse){
                    isTop = self.chatItemModel?.chatItem?.chatIsTop == IsTop.top.rawValue ? IsTop.noTop.rawValue : IsTop.top.rawValue
                    nativeText = self.chatItemModel?.chatItem!.textTranslated
                    nativeLangName = self.chatItemModel?.chatItem?.textTranslatedLanguage
                }
                
                let targetText = self.speechProcessingVM.getTTT_Text
                let chatEntity =  ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangName, textNativeLanguage: nativeLangName!, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isTop, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue)
                self.getTtsValue()
                let row = self.ttsVM.saveChatItem(chatItem: chatEntity)
                chatEntity.id = row
                self.chatItemModel?.chatItem = chatEntity
                self.getTtsValue()
                self.spinnerView.isHidden = true
                self.updateUI()
                self.ttsAlertControllerDelegate?.itemAdded(HistoryChatItemModel(chatItem: chatEntity, idxPath: nil))
                
            }
        }
    }
}

extension TtsAlertController : RetranslationDelegate {
    func showRetranslation(selectedLanguage: String) {
        if Reachability.isConnectedToNetwork() {
            spinnerView.isHidden = false
            self.isReverse = false
        socketManager.socketManagerDelegate = self
            SocketManager.sharedInstance.connect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                let nativeText = self!.chatItemModel?.chatItem!.textNative
                let nativeLangName = self!.chatItemModel?.chatItem!.textNativeLanguage!
                
                let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: nativeText!,srcLang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLangName!)!.code,destlang: selectedLanguage)
                self!.socketManager.sendTextData(text: textFrameData, completion: nil)
            }
        }else {
            GlobalMethod.showNoInternetAlert()
        }
    }
}

extension TtsAlertController : AlertReusableDelegate {
    func onSharePressed(chatItemModel: HistoryChatItemModel?) {
        PrintUtility.printLog(tag: TAG, text: "TtsAlertController shareJson called")
        self.shareData(chatItemModel: chatItemModel)
    }

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
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
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
        if Reachability.isConnectedToNetwork() {
            spinnerView.isHidden = false
            self.isReverse = true
        socketManager.socketManagerDelegate = self
            SocketManager.sharedInstance.connect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                let nativeText = chatItemModel?.chatItem!.textTranslated
                let nativeLangName = chatItemModel?.chatItem!.textTranslatedLanguage
                let targetLangName = chatItemModel?.chatItem!.textNativeLanguage!

                let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: nativeText!,srcLang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLangName!)!.code,destlang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: targetLangName!)!.code)
                self!.socketManager.sendTextData(text: textFrameData, completion: nil)
            }
        }else{
            GlobalMethod.showNoInternetAlert()
        }
        
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

extension TtsAlertController : SpeechProcessingDismissDelegate {
    func showTutorial() {
        self.speechProDismissDelegateFromTTS?.showTutorial()
    }
}

extension TtsAlertController : SocketManagerDelegate{
    func faildSocketConnection(value: String) {
        PrintUtility.printLog(tag: TAG, text: value)
    }
    
    func getText(text: String) {
        speechProcessingVM.setTextFromScoket(value: text)
        PrintUtility.printLog(tag: "TtsAlertController Retranslation: ", text: text)
    }
    
    func getData(data: Data) {}
    
}

extension TtsAlertController: CXCallObserverDelegate{
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        PrintUtility.printLog(tag: TAG, text: "callObserver")
        stopTTS()
        if call.hasConnected {
            stopTTS()
        }

           if call.isOutgoing {
               stopTTS()
           }

           if call.hasEnded {
               self.dismiss(animated: false, completion: nil)
           }

           if call.isOnHold {
               stopTTS()
             }
        
//        TtsAlertController.ttsResponsiveView.stopTTS()
    }
}

//
// TtsAlertController.swift
// PockeTalk
//

import UIKit
import WebKit
import CallKit

//MARK: - TtsAlertControllerDelegate
protocol TtsAlertControllerDelegate: AnyObject{
    func itemAdded(_ chatItemModel: HistoryChatItemModel)
    func itemDeleted(_ chatItemModel: HistoryChatItemModel)
    func updatedFavourite(_ chatItemModel: HistoryChatItemModel)
    func dismissed()
}

//MARK: - Pronunciation
protocol Pronunciation: AnyObject{
    func dismissPro(dict:[String : String])
}

//MARK: - CurrentTSDelegate
protocol CurrentTSDelegate: AnyObject{
    func passCurrentTSValue (currentTS : Int)
}

class TtsAlertController: BaseViewController, UIGestureRecognizerDelegate {
    private let TAG:String = "TtsAlertController"
    var callObserver = CXCallObserver()
    ///Views
    @IBOutlet weak var toTranslateLabel: UILabel!
    @IBOutlet weak var fromTranslateLabel: UILabel!
    @IBOutlet weak var changeTranslationButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var crossButton: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var containerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewtrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak private var placeholderContainerView: UIView!
    @IBOutlet weak private var ttsResultTV: UITableView!
    @IBOutlet weak private var bottomViewBottomLayoutConstrain: NSLayoutConstraint!
    
    
    var ttsVM : TtsAlertViewModel!
    var chatEntity : ChatEntity?
    let cornerRadius : CGFloat = 15
    let fontSize : CGFloat = FontUtility.getFontSize()
    let biggerFontSize : CGFloat = FontUtility.getBiggerFontSize()
    let width : CGFloat = 100
    let toastVisibleTime : CGFloat = 2.0
    
    var itemsToShowOnContextMenu : [AlertItems] = []
    var talkButton : UIButton?
    let animationDuration : CGFloat = 0.6
    let animationDelay : CGFloat = 0
    let transform : CGFloat = 0.97
    var chatItemModel: HistoryChatItemModel?
    
    var timer: Timer? = nil
    var timeInterval: TimeInterval = 30
    
    var hideMenuButton = false
    var hideBottomView = false
    var hideTalkButton = false
    
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
    var isReverse = false
    
    private var socketManager = SocketManager.sharedInstance
    private var speechProcessingVM : SpeechProcessingViewModeling!
    private var languageHasUpdated = false
    
    weak var delegate : SpeechControllerDismissDelegate?
    weak var ttsAlertControllerDelegate: TtsAlertControllerDelegate?
    weak var currentTSDelegate : CurrentTSDelegate?
    
    //tts Result TV property
    private var defaultTextLabelCellHeight = CGFloat()
    private var toTextLabelCellHeight = CGFloat()
    private var fromTextLabelCellHeight = CGFloat()
    
    private var isTextFittedInCell = true
    private var sttText = [String](repeating: "", count: 3)
    private var leftRightPadding: CGFloat = 150
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callObserver.setDelegate(self, queue: nil)
        self.ttsVM = TtsAlertViewModel()
        self.setUpUI()
        self.getTtsValue()
        ttsResponsiveView.ttsResponsiveViewDelegate = self
        self.view.addSubview(ttsResponsiveView)
        ttsResponsiveView.isHidden = true
        self.speechProcessingVM = SpeechProcessingViewModel()
        bindData()
        
        self.view.backgroundColor = .black
        registerNotification()
        checkTTSValueAndPlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(!isRecreation){
            self.startAnimation()
        }
        
        defaultTextLabelCellHeight = ((placeholderContainerView.frame.size.height * 45) / 100)
        setupTTSTableViewProperty()
        setupTTSTableView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        callObserver.setDelegate(nil, queue: nil)
        stopTTS()
        AudioPlayer.sharedInstance.stop()
    }
    
    private func setupTTSTableView(){
        ttsResultTV.delegate = self
        ttsResultTV.dataSource = self
        ttsResultTV.separatorStyle = .none
        ttsResultTV.showsVerticalScrollIndicator = false
        ttsResultTV.register(UINib(nibName: "SingleLabelCell", bundle: nil), forCellReuseIdentifier: "SingleLabelCell")
    }
    
    private func setupTTSTableViewProperty(){
        sttText[0] = chatItemModel?.chatItem?.textTranslated ?? ""
        sttText[2] = chatItemModel?.chatItem?.textNative ?? ""
        let font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .regular)
        
        toTextLabelCellHeight = sttText[0].heightWithConstrainedWidth(
            width: UIScreen.main.bounds.width - leftRightPadding,
            font: font)
        
        fromTextLabelCellHeight = sttText[2].heightWithConstrainedWidth(
            width: UIScreen.main.bounds.width - leftRightPadding,
            font: font)
        
        PrintUtility.printLog(tag: TAG, text: "PCH \(placeholderContainerView.frame.size.height), TVH \(ttsResultTV.bounds.height), DTLH \(defaultTextLabelCellHeight), TTLH \(toTextLabelCellHeight), FTLH \(fromTextLabelCellHeight) TTxt: \(sttText[0]), FTxt: \(sttText[2])")
        
        if toTextLabelCellHeight < defaultTextLabelCellHeight && fromTextLabelCellHeight < defaultTextLabelCellHeight {
            isTextFittedInCell = true
            ttsResultTV.isScrollEnabled = false
        } else {
            isTextFittedInCell = false
            ttsResultTV.isScrollEnabled = true
        }
    }
    
    func checkTTSValueAndPlay(){
        let translateText = chatItemModel?.chatItem?.textTranslated
        let languageManager = LanguageSelectionManager.shared
        let targetLanguageItem = languageManager.getLanguageCodeByName(langName: chatItemModel!.chatItem!.textTranslatedLanguage!)!.code
        if let _ = LanguageEngineParser.shared.getTtsValueByCode(code:targetLanguageItem){
            if(!isSpeaking){
                playTTS()
            }
        }else{
            AudioPlayer.sharedInstance.delegate = self
            if !AudioPlayer.sharedInstance.isPlaying{
                AudioPlayer.sharedInstance.getTTSDataAndPlay(translateText: translateText!, targetLanguageItem: targetLanguageItem, tempo: "normal")
            }
        }
    }
    
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeChild(notification:)), name: .ttsNotofication, object: nil)
    }
    
    
    func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name:.ttsNotofication, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIApplication.willResignActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    @objc func willResignActive(_ notification: Notification) {
        self.stopTTS()
        AudioPlayer.sharedInstance.stop()
    }
    
    @objc func removeChild(notification: Notification) {
        if let vc = view.subviews.last?.parentViewController{
            remove(asChildViewController: vc)
        }
    }
    
    func setUpUI () {
        self.backgroundImageView.layer.masksToBounds = true
        self.backgroundImageView.sizeToFit()
        self.backgroundImageView.layer.cornerRadius = cornerRadius
        
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
        
        bottomViewBottomLayoutConstrain.constant = HomeViewController.homeVCBottomViewHeight
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
    
    func getTtsValue () {
        PrintUtility.printLog(tag: "TTT CHAT", text: "\(String(describing: chatItemModel!.chatItem!.textTranslatedLanguage))")
        
        let languageManager = LanguageSelectionManager.shared
        let targetLanguageItem = languageManager.getLanguageCodeByName(langName: chatItemModel!.chatItem!.textTranslatedLanguage!)
        let item = LanguageEngineParser.shared.getTtsValue(langCode: targetLanguageItem!.code)
        self.voice = item.voice
        self.rate = item.rate
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state == UIGestureRecognizer.State.ended){
            AudioPlayer.sharedInstance.stop()
            self.stopTTS()
            self.openContextMenu()
        }
        
    }
    
    @objc func handleSingleTap(recognizer:UITapGestureRecognizer) {
        checkTTSValueAndPlay()
    }
    
    func startAnimation () {
        self.backgroundImageView.transform = CGAffineTransform.identity
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: TimeInterval(animationDelay), options: [.repeat, .autoreverse], animations: {
            self.backgroundImageView.transform = CGAffineTransform(scaleX: self.transform, y: self.transform)
        },completion: { Void in()  })
    }
    
    func stopAnimation () {
        self.backgroundImageView.layer.removeAllAnimations()
    }
    
    func updateUI () {
        updateViewShowHideStatus()
        self.updateConstraints()
        self.startAnimation()
        
        self.setupTTSTableViewProperty()
        self.ttsResultTV.reloadData()
        self.updateBackgroundImage(topSelected: chatItemModel?.chatItem?.chatIsTop ?? 0)
        
        self.containerView.removeGestureRecognizer(longTapGesture!)
        checkTTSValueAndPlay()
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
    
    func updateConstraints () {
        self.containerViewTopConstraint.constant = 20
        self.containerViewtrailingConstraint.constant = 25
        self.containerViewBottomConstraint.constant = 25
        self.containerViewLeadingConstraint.constant = 25
    }
    
    @IBAction func actionLanguageDirectionChange(_ sender: UIButton) {
        languageHasUpdated = true
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
            PrintUtility.printLog(tag: "TAG", text: "checkSttSupport has support \(language?.code ?? "")")
            populateData(withPronounciation: true)
        }else{
            PrintUtility.printLog(tag: "TAG", text: "checkSttSupport not support \(language?.code ?? "")")
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
        AudioPlayer.sharedInstance.stop()
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
        self.zoomOutDismissAnimation()
    }
    //Dismiss view on back button press
    @IBAction func dismissView(_ sender: UIButton) {
        self.backButton.isHidden = true
        self.bottomView.isHidden = true
        self.zoomOutDismissAnimation()
    }
    
    private func zoomOutDismissAnimation() {
        self.view.backgroundColor = .clear
        UIView.animate(withDuration: 0.5, animations: {
            self.containerView.transform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.01)
        }) { _ in
            self.dismissPopUp()
        }
    }
    
    func dismissPopUp(){
        stopTTS()
        self.stopAnimation()
        if ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing{
            if languageHasUpdated{
                NotificationCenter.default.post(name: .languageSelectionArrowNotification, object: nil)
                languageHasUpdated = false
            }
            remove(asChildViewController: self)
            NotificationCenter.default.post(name: .containerViewSelection, object: nil, userInfo: nil)
        }else if ScreenTracker.sharedInstance.screenPurpose == .HistoryScrren{
            remove(asChildViewController: self)
            NotificationCenter.default.post(name: .containerViewSelection, object: nil, userInfo: nil)
        }else if ScreenTracker.sharedInstance.screenPurpose == .FavouriteScreen{
            remove(asChildViewController: self)
        }else{
            NotificationCenter.default.post(name: .containerViewSelection, object: nil, userInfo: nil)
        }
        
    }
    
    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
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
            let currentTs = GlobalMethod.getCurrentTimeStamp(with: 0)
            self.currentTSDelegate?.passCurrentTSValue(currentTS: currentTs)
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
    deinit {
        AudioPlayer.sharedInstance.stop()
        stopTTS()
        unregisterNotification()
    }
    
    func stopTTS(){
        ttsResponsiveView.stopTTS()
        stopAnimation()
    }
    
    func shareData(chatItemModel: HistoryChatItemModel?){
        if Reachability.isConnectedToNetwork() {
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
        } else {
            GlobalMethod.showNoInternetAlert(in: self)
        }
    }
    
    func bindData(){
        speechProcessingVM.isFinal.bindAndFire{[weak self] isFinal  in
            guard let `self` = self else { return }
            if isFinal{
                SocketManager.sharedInstance.disconnect()
                if self.timer != nil {
                    self.timer?.invalidate()
                }
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

//MARK: - PronunciationDelegate
extension TtsAlertController: Pronunciation{
    func dismissPro(dict:[String : String]) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - RetranslationDelegate
extension TtsAlertController : RetranslationDelegate {
    func showRetranslation(selectedLanguage: String, fromScreenPurpose: SpeechProcessingScreenOpeningPurpose) {
        if Reachability.isConnectedToNetwork() {
            spinnerView.isHidden = false
            self.isReverse = false
            socketManager.socketManagerDelegate = self
            SocketManager.sharedInstance.connect()
            ScreenTracker.sharedInstance.screenPurpose = fromScreenPurpose
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let nativeText = self?.chatItemModel?.chatItem!.textNative, let nativeLangName = self?.chatItemModel?.chatItem!.textNativeLanguage else{ return}
                let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: nativeText,srcLang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLangName)!.code,destlang: selectedLanguage)
                self?.socketManager.sendTextData(text: textFrameData, completion: nil)
                self?.startCountdown()
            }
        }else {
            GlobalMethod.showNoInternetAlert()
        }
    }
}

//MARK: - AlertReusableDelegate
extension TtsAlertController : AlertReusableDelegate {
    func onSharePressed(chatItemModel: HistoryChatItemModel?) {
        PrintUtility.printLog(tag: TAG, text: "TtsAlertController shareJson called")
        self.shareData(chatItemModel: chatItemModel)
    }
    
    func onDeleteItem(chatItemModel: HistoryChatItemModel?) {
        ttsAlertControllerDelegate?.itemDeleted(chatItemModel!)
        self.dismissPopUp()
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
        
        if  ScreenTracker.sharedInstance.screenPurpose == .HistoryScrren{
            vc.isFromHistoryTTS = true
        }
        
        add(asChildViewController: vc, containerView:self.view, animation: nil)
        ScreenTracker.sharedInstance.screenPurpose = ScreenTracker.sharedInstance.screenPurpose == .HistoryScrren ? .HistroyPronunctiation :.PronunciationPractice
        //self.present(vc, animated: true, completion: nil)
        
    }
    
    func transitionFromRetranslation(chatItemModel: HistoryChatItemModel?) {
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
        controller.isNative = chatItemModel?.chatItem?.chatIsTop ?? 0 == IsTop.noTop.rawValue ? 1 : 0
        
        controller.retranslationDelegate = self
        controller.fromRetranslation = true
        controller.fromScreenPurpose = ScreenTracker.sharedInstance.screenPurpose
        
        let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
        add(asChildViewController: controller, containerView: view, animation: transition)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionVoice
    }
    
    func transitionFromReverse(chatItemModel: HistoryChatItemModel?) {
        spinnerView.isHidden = false
        if Reachability.isConnectedToNetwork() {
            self.isReverse = true
            socketManager.socketManagerDelegate = self
            SocketManager.sharedInstance.connect()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                guard let `self` = self else {return}
                let nativeText = chatItemModel?.chatItem!.textTranslated
                let nativeLangName = chatItemModel?.chatItem!.textTranslatedLanguage
                let targetLangName = chatItemModel?.chatItem!.textNativeLanguage!
                
                let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: nativeText!,srcLang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLangName!)!.code,destlang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: targetLangName!)!.code)
                self.socketManager.sendTextData(text: textFrameData, completion: nil)
                self.startCountdown()
                
            }
        }else{
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.spinnerView.isHidden = true
                GlobalMethod.showNoInternetAlert()
            }
        }
    }
    
    func startCountdown() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.timeInterval -= 1
            if self?.timeInterval == 0 {
                timer.invalidate()
                self?.spinnerView.isHidden = true
                self?.timeInterval = 30
            } else if let seconds = self?.timeInterval {
                //PrintUtility.printLog(tag: "Timer On TTS Alert : ", text: "\(seconds)")
            }
        }
    }
    
}



//MARK: - TTSResponsiveViewDelegate
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
        if(!isRecreation){
            checkTTSValueAndPlay()
        }
    }
}

//MARK: - SpeechProcessingDismissDelegate
extension TtsAlertController : SpeechProcessingDismissDelegate {
    func showTutorial() {
        // self.speechProDismissDelegateFromTTS?.showTutorial()
    }
}

//MARK: - SocketManagerDelegate
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

//MARK: - CXCallObserverDelegate
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
        AudioPlayer.sharedInstance.stop()
    }
}

//MARK: - AudioPlayerDelegate
extension TtsAlertController :AudioPlayerDelegate{
    func didStartAudioPlayer() {
        startAnimation()
    }
    
    func didStopAudioPlayer(flag: Bool) {
        stopAnimation()
    }
}

//MARK: - UITableViewDe legate, UITableViewDataSource
extension TtsAlertController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ttsResultTV.dequeueReusableCell(withIdentifier: "SingleLabelCell", for: indexPath) as! SingleLabelCell
        cell.configCell(ttsText: sttText[indexPath.row], indexPath: indexPath, chatItem: chatItemModel?.chatItem)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return isTextFittedInCell ? (0) : (20)
        }
        
        if isTextFittedInCell{
            return defaultTextLabelCellHeight
        } else {
            return UITableView.automaticDimension
        }
    }
}



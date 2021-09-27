//
// TtsAlertController.swift
// PockeTalk
//

import UIKit
protocol TtsAlertControllerDelegate {
    func itemAdded(_ chatItem: ChatEntity)
}
class TtsAlertController: BaseViewController, UIGestureRecognizerDelegate {
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
    var delegate : SpeechControllerDismissDelegate?
    var itemsToShowOnContextMenu : [AlertItems] = []
    var talkButton : UIButton?
    let animationDuration : CGFloat = 0.6
    let animationDelay : CGFloat = 0
    let transform : CGFloat = 0.97
    var chatItem: ChatEntity?
    var hideMenuButton = false
    var hideBottomView = false
    var ttsAlertControllerDelegate: TtsAlertControllerDelegate?
    var longTapGesture : UILongPressGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.ttsVM = TtsAlertViewModel()
        self.setUpUI()
        self.populateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    /// Initial UI set up
    func setUpUI () {
        self.backgroundImageView.layer.masksToBounds = true
        self.backgroundImageView.layer.cornerRadius = cornerRadius
        self.startAnimation()

        self.toLanguageLabel.text = chatItem?.textTranslated
        self.toLanguageLabel.textAlignment = .center
        self.toLanguageLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.toLanguageLabel.textColor = UIColor._blackColor()

        self.fromLanguageLabel.text = chatItem?.textNative 
        self.fromLanguageLabel.textAlignment = .center
        self.fromLanguageLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.fromLanguageLabel.textColor = UIColor.gray

        self.toTranslateLabel.text = chatItem?.chatIsTop == IsTop.noTop.rawValue ? chatItem?.textTranslatedLanguage : chatItem?.textNativeLanguage
        self.toTranslateLabel.textAlignment = .right
        self.toTranslateLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.toTranslateLabel.textColor = UIColor.gray

        self.fromTranslateLabel.text = chatItem?.chatIsTop == IsTop.noTop.rawValue ? chatItem?.textNativeLanguage : chatItem?.textTranslatedLanguage
        self.fromTranslateLabel.textAlignment = .left
        self.fromTranslateLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.fromTranslateLabel.textColor = UIColor._whiteColor()
        
        if(LanguageSelectionManager.shared.isArrowUp ?? true){
            changeTranslationButton.image(for: UIControl.State.normal)
        }
        talkButton = GlobalMethod.setUpMicroPhoneIcon(view: self.bottomTalkView, width: width, height: width)
        talkButton?.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
        
        setLanguageDirection(isArrowUp: UserDefaultsProperty<Bool>(kIsArrowUp).value ?? true)
        longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longTapGesture!.minimumPressDuration = 0.2
        longTapGesture!.delegate = self
        longTapGesture!.delaysTouchesBegan = true
        
        if hideBottomView == true{
            self.bottomView.isHidden = true
        }
        if hideMenuButton == true{
            updateUI()
        }else{
            self.containerView.addGestureRecognizer(longTapGesture!)
        }
        self.updateBackgroundImage(topSelected: chatItem?.chatIsTop ?? 0)
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state == UIGestureRecognizer.State.ended){
            self.openContextMenu()
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

        self.toLanguageLabel.text = chatItem?.textTranslated
        self.fromLanguageLabel.text = chatItem?.textNative
        self.toLanguageLabel.font = UIFont.systemFont(ofSize: reverseFontSize, weight: .semibold)
        self.fromLanguageLabel.font = UIFont.systemFont(ofSize: reverseFontSize, weight: .semibold)
        
        self.updateBackgroundImage(topSelected: chatItem?.chatIsTop ?? 0)
        
        self.containerView.removeGestureRecognizer(longTapGesture!)
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
        self.toLangLabelTopConstraint.constant = 220
        self.fromLangLabelBottomConstraint.constant = 60
    }
    
    @IBAction func actionLanguageDirectionChange(_ sender: UIButton) {
        if UserDefaultsProperty<Bool>(kIsArrowUp).value == false{
            UserDefaultsProperty<Bool>(kIsArrowUp).value = true
        }else{
            UserDefaultsProperty<Bool>(kIsArrowUp).value = false
        }
        self.delegate?.dismiss()
        self.dismiss(animated: true, completion: nil)
    }
    
    func setLanguageDirection(isArrowUp: Bool){
        if (isArrowUp){
            self.changeTranslationButton.setImage(UIImage(named: "arrow_back_icon"), for: UIControl.State.normal)
        }else{
            self.changeTranslationButton.setImage(UIImage(named: "arrow_forward"), for: UIControl.State.normal)
        }
    }

    @IBAction func menuTapAction(_ sender: UIButton) {
        self.stopAnimation()
        self.openContextMenu()
    }
    
    func openContextMenu(){
        let vc = AlertReusableViewController.init()
        vc.items = self.itemsToShowOnContextMenu
        vc.delegate = self
        vc.chatItemModel = HistoryChatItemModel.init(chatItem: self.chatItem, idxPath: nil)
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
        self.dismissPopUp()
    }
    //Dismiss view on back button press
    @IBAction func dismissView(_ sender: UIButton) {
        self.dismissPopUp()
    }
    func dismissPopUp(){
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

extension TtsAlertController : RetranslationDelegate {
    func showRetranslation(selectedLanguage: String) {
        let isTop = chatItem?.chatIsTop
        let nativeText = chatItem!.textNative
        let nativeLangName = chatItem!.textNativeLanguage!
        let targetLangName = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: selectedLanguage)?.name
        
        //TODO call websocket api for ttt
        let targetText = chatItem!.textTranslated
        
        let chatEntity =  ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangName, textNativeLanguage: nativeLangName, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isTop, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue)
        self.chatItem = chatEntity
        ttsVM.saveChatItem(chatItem: chatEntity)
        self.updateUI()
        ttsAlertControllerDelegate?.itemAdded(chatEntity)
    }
}

extension TtsAlertController : AlertReusableDelegate {
    func onDeleteItem(chatItemModel: HistoryChatItemModel?) {
        self.dismissPopUp()
    }
    
    func updateFavourite(chatItemModel: HistoryChatItemModel) {}
    
    func pronunciationPracticeTap(chatItemModel: HistoryChatItemModel?) {
        let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeViewController") as! PronunciationPracticeViewController
        vc.chatItem = chatItemModel?.chatItem
        
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
        self.chatItem = chatItemModel?.chatItem
        self.updateUI()
        ttsAlertControllerDelegate?.itemAdded(chatItemModel!.chatItem!)
    }
    
}

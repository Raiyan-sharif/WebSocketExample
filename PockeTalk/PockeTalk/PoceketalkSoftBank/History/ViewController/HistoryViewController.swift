//
//  HistoryViewController.swift
//  PockeTalk
//

import UIKit

protocol HistoryViewControllerDelegates:class {
    func historyDissmissed()
}

class HistoryViewController: BaseViewController {
    let TAG = "\(HistoryViewController.self)"
    ///History Layout to postion the cell
    let historylayout = HistoryLayout()
    ///Collection View top constraint
    var topConstraintOfCV:NSLayoutConstraint!
    /// Ccolectionview Width constraint
    var widthConstraintOfCV:NSLayoutConstraint!

    var  isCollectionViewVisible = false
    var loclItems = [HistoryModel]()
    var historyViewModel: HistoryViewModel!
    let transionDuration : CGFloat = 0.8
    let transformation : CGFloat = 0.6
    let buttonWidth : CGFloat = 100
    var deletedCellHeight = CGFloat()
    private var spinnerView : SpinnerView!

   // var navController: UINavigationController?

    weak var delegate: HistoryViewControllerDelegates?
    var itemsToShowOnContextMenu : [AlertItems] = []
    var selectedChatItemModel : HistoryChatItemModel?
    weak var speechProDismissDelegateFromHistory : SpeechProcessingDismissDelegate?
    var isReverse = false
    private var socketManager = SocketManager.sharedInstance
    private var speechProcessingVM : SpeechProcessingViewModeling!
    var enableOrDisableMicrophoneBtn:((_ value:Bool)->())?

    ///CollectionView to show history item
    private lazy var collectionView:UICollectionView = {
        let collectionView = UICollectionView(frame:.zero ,collectionViewLayout:historylayout)
        historylayout.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType: HistoryCell.self)
        return collectionView
    }()

    
    private lazy var topView:UIView = {
        let view = UIView()
        return view
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        historyViewModel = HistoryViewModel()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05) { [weak self] in
            self?.showCollectionView()
        }
        
        let swipeToDismiss = UISwipeGestureRecognizer(target: self, action: #selector(swipeToClose))
        swipeToDismiss.direction = .up
        self.view.addGestureRecognizer(swipeToDismiss)

        self.speechProcessingVM = SpeechProcessingViewModel()
        bindData()
        //SocketManager.sharedInstance.connect()
//        socketManager.socketManagerDelegate = self
        registerNotification()
        
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
    
    @objc func swipeToClose(gesture: UIGestureRecognizer) {

        if let swipeGesture = gesture as? UISwipeGestureRecognizer {

            switch swipeGesture.direction {
            case .right:
                break
            case .down:
                break
            case .left:
                break
            case .up:
                dismissHistoryWithAnimation()
                break
            default:
                break
            }
        }
    }

    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(removeChild(notification:)), name:.historyNotofication, object: nil)
    }

    func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name:.historyNotofication, object: nil)
    }


    @objc func removeChild(notification: Notification) {
        if let vc = view.subviews.last?.parentViewController{
                remove(asChildViewController: vc)
            }
        ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
    }

    // Populate item to show on context menu
    func populateData (withPronounciation: Bool) {
        self.itemsToShowOnContextMenu.removeAll()
        self.itemsToShowOnContextMenu.append(AlertItems(title: "history_add_fav".localiz(), imageName: "icon_favorite_popup.png", menuType: .favorite))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "retranslation".localiz(), imageName: "", menuType: .retranslation))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "reverse".localiz(), imageName: "", menuType: .reverse))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "delete".localiz(), imageName: "Delete_icon.png", menuType: .delete))
        if withPronounciation{
            self.itemsToShowOnContextMenu.append(AlertItems(title: "pronunciation_practice".localiz(), imageName: "", menuType: .practice))
        }
        self.itemsToShowOnContextMenu.append(AlertItems(title: "cancel".localiz(), imageName: "", menuType: .cancel) )
    }
    
    
    private func setUpCollectionView(){
        self.view.addSubview(collectionView)

        addSpinner()

        //self.view.addSubview(bottmView)
        self.view.addSubview(topView)
        let window = UIApplication.shared.windows.first
        

        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: (window?.safeAreaInsets.top ?? 20) + 55).isActive = true
        topView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        topView.clipsToBounds =  true
        topView.backgroundColor = UIColor.black

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        widthConstraintOfCV = collectionView.widthAnchor.constraint(equalToConstant: SIZE_WIDTH)
        widthConstraintOfCV.isActive = true
//        let margin = view.safeAreaLayoutGuide
//        let topPadding = window?.safeAreaInsets.top
        topConstraintOfCV =  collectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant:0)
        topConstraintOfCV.isActive = true
       // collectionView.heightAnchor.constraint(equalToConstant: SIZE_HEIGHT-buttonWidth-(topPadding ?? 0.0)).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.alpha = 0.0
        
        self.view.addSubview(backBtn)
        
//        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: bottmView, width: buttonWidth, height: buttonWidth)
//        talkButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)

    }

    deinit {
        unregisterNotification()
    }

    private var backBtn:UIButton!{
            guard let window = UIApplication.shared.keyWindow else {return nil}
            let topPadding = window.safeAreaInsets.top
            let okBtn = UIButton(frame: CGRect(x: window.safeAreaInsets.left, y: topPadding, width: 40, height: 40))
            okBtn.setImage(UIImage(named: "btn_back_tempo.png"), for: UIControl.State.normal)
            okBtn.addTarget(self, action: #selector(actionBack), for: .touchUpInside)
            return okBtn
    }
    @objc func actionBack () {
            self.dismissHistory(animated: true, completion: nil )
    }
    fileprivate func proceedToTakeVoiceInput() {
        if Reachability.isConnectedToNetwork() {
            let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
            controller.homeMicTapTimeStamp = currentTS
            controller.languageHasUpdated = true
            controller.screenOpeningPurpose = .HomeSpeechProcessing
//            controller.speechProcessingDismissDelegate = self
//            controller.isFromTutorial = false
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: true, completion: nil)
        } else {
            GlobalMethod.showNoInternetAlert()
        }
    }

    @objc func microphoneTapAction (sender:UIButton) {
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
            showToast(message: "no_stt_msg".localiz(), seconds: 2)
            PrintUtility.printLog(tag: TAG, text: "checkSttSupport don't have stt support")
        }
    }

    private var btnMenu: UIButton!{
        guard let window = UIApplication.shared.keyWindow else {return nil}
        PrintUtility.printLog(tag: "SafeArea", text: " \(window.safeAreaInsets.top)")
        let btnMenu = UIButton(frame: CGRect(x: window.safeAreaInsets.left + 10, y: window.safeAreaInsets.top + 5, width: 30, height: 30))
        btnMenu.setImage(UIImage(named: "hamburger_menu_icon.png"), for: UIControl.State.normal)
        btnMenu.addTarget(self, action: #selector(actionMenu), for: .touchUpInside)
        return btnMenu
    }
    
    private var cameraButton: UIButton!{
        guard let window = UIApplication.shared.keyWindow else {return nil}
        PrintUtility.printLog(tag: "SafeArea", text: " \(window.frame.width)")
        let cameraButton = UIButton(frame: CGRect(x: window.frame.width - 40, y: window.safeAreaInsets.top + 5, width: 30, height: 30))
        if #available(iOS 13.0, *) {
            cameraButton.setImage(UIImage(systemName: "camera.fill"), for: UIControl.State.normal)
        } else {
            // Fallback on earlier versions
        }
        cameraButton.addTarget(self, action: #selector(actionCamera), for: .touchUpInside)
        return cameraButton
    }
    
    ///Move to next screeen
    @objc func actionCamera () {
        RuntimePermissionUtil().requestAuthorizationPermission(for: .video) { [weak self] (isGranted) in
            if isGranted {
                let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
                if let cameraViewController = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CameraViewController.self)) as? CameraViewController {
                    self?.navigationController?.pushViewController(cameraViewController, animated: true)
                }
            } else {
                GlobalMethod.showPermissionAlert(viewController: self, title : kCameraUsageTitle, message : kCameraUsageMessage)
            }
        }
    }
    
    ///Move to next screeen
    @objc func actionMenu () {
        let settingsStoryBoard = UIStoryboard(name: "Settings", bundle: nil)
        if let settinsViewController = settingsStoryBoard.instantiateViewController(withIdentifier: String(describing: SettingsViewController.self)) as? SettingsViewController {
            let transition = CATransition()
                        transition.duration = 0.5
                        transition.type = CATransitionType.push
                        transition.subtype = CATransitionSubtype.fromLeft
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(settinsViewController, animated: false)
        }
    }
    
    func dismissHistory(animated: Bool, completion: (() -> Void)? = nil) {

//        if self.presentingViewController == nil{
//            self.dismiss(animated: animated, completion: completion)
//        }else{
//            self.presentingViewController?.dismiss(animated: animated, completion: completion)
//        }

        //self.delegate?.historyDissmissed()
        NotificationCenter.default.post(name: .containerViewSelection, object: nil, userInfo: nil)
        ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
    }
    
    func showCollectionView(){
        isCollectionViewVisible = true
        collectionView.scrollToItem(at: IndexPath(item: historyViewModel.items.value.count-1, section: 0), at: .bottom, animated: false)
        collectionView.alpha = 1.0
        let transitionAnimation = CABasicAnimation(keyPath: "position.y")
        transitionAnimation.fromValue = view.layer.position.y -
            collectionView.bounds.height
        transitionAnimation.toValue = view.layer.position.y - buttonWidth

        let scalAnimation = CABasicAnimation(keyPath: "transform.scale")
        scalAnimation.fromValue = 0.5
        scalAnimation.toValue = 1.0

        let transitionAndScale = CAAnimationGroup()
        transitionAndScale.fillMode = .removed
        transitionAndScale.isRemovedOnCompletion = true
        transitionAndScale.animations = [ transitionAnimation, scalAnimation]
        transitionAndScale.duration = 1.0
        collectionView.layer.add(transitionAndScale, forKey: nil)
        let diff = collectionView.frame.height - collectionView.contentSize.height
        if diff > 0 {
            collectionView.contentInset = UIEdgeInsets(top: diff, left: 0, bottom: 0, right: 0)
        }
        PrintUtility.printLog(tag: "contentSize.height", text: "\(collectionView.contentSize.height)")

    }

    func bindData(){
        historyViewModel.items.bindAndFire { [weak self] items in
            if items.count == 0{
                DispatchQueue.main.async {
                    self?.dismissHistory(animated: true, completion: nil)
                }
            }
            if items.count > 0{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    guard let `self` = self else { return }
                    
                    let collectionViewHeight = self.collectionView.frame.height
                    
                    let diff = CGFloat(collectionViewHeight) - CGFloat(self.collectionView.contentSize.height - self.deletedCellHeight)
                    if diff > 0 {
                        self.collectionView.contentInset = UIEdgeInsets(top: diff, left: 0, bottom: 0, right: 0)
                    }
                }
            }
        }
        speechProcessingVM.isFinal.bindAndFire{[weak self] isFinal  in
            guard let `self` = self else { return }
            if isFinal{
                SocketManager.sharedInstance.disconnect()
                PrintUtility.printLog(tag: "TTT text: ",text: self.speechProcessingVM.getTTT_Text)
                PrintUtility.printLog(tag: "TTT src: ", text: self.speechProcessingVM.getSrcLang_Text)
                PrintUtility.printLog(tag: "TTT dest: ", text: self.speechProcessingVM.getDestLang_Text)
                var isTop = self.selectedChatItemModel?.chatItem?.chatIsTop
                var nativeText = self.selectedChatItemModel?.chatItem!.textNative
                var nativeLangName = self.selectedChatItemModel?.chatItem?.textNativeLanguage
                let targetLangName = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: self.speechProcessingVM.getDestLang_Text)?.name
                if(self.isReverse){
                    isTop = self.selectedChatItemModel?.chatItem?.chatIsTop == IsTop.top.rawValue ? IsTop.noTop.rawValue : IsTop.top.rawValue
                    nativeText = self.selectedChatItemModel?.chatItem!.textTranslated
                    nativeLangName = self.selectedChatItemModel?.chatItem?.textTranslatedLanguage
                }
                
                let targetText = self.speechProcessingVM.getTTT_Text

                let chatEntity =  ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangName, textNativeLanguage: nativeLangName!, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isTop, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue)
                let row = self.historyViewModel.saveChatItem(chatItem: chatEntity)
                chatEntity.id = row
                self.selectedChatItemModel?.chatItem = chatEntity
             
                self.spinnerView.isHidden = true
                self.showTTSScreen(chatItemModel: HistoryChatItemModel(chatItem: chatEntity, idxPath: nil), hideMenuButton: true, hideBottmSection: true, saveDataToDB: false, fromHistory: true, ttsAlertControllerDelegate: self, isRecreation: false)
                self.historyViewModel.addItem(chatEntity)
                self.collectionView.reloadData()
                self.scrollToBottom()
            }
        }
    }
    
    func scrollToBottom(){
        let item = self.collectionView(self.collectionView, numberOfItemsInSection: 0) - 1
        let lastItemIndex = IndexPath(item: item, section: 0)
        self.collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: true)
    }

}

extension HistoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyViewModel.items.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: HistoryCell.self)
        let item = historyViewModel.items.value[indexPath.item] as! ChatEntity
        cell.fromLabel.text = item.textTranslated
        cell.toLabel.text = item.textNative
        let historyModel = historyViewModel.items.value[indexPath.item] as! ChatEntity
        
        if(indexPath.row == historyViewModel.items.value.count - 1){
            cell.bottomStackViewOfLabel.constant = 25
            cell.favouriteRightBarBottom.constant = -20
            cell.topStackViewOfLabel.constant = 25
            cell.favouriteRightBarTop.constant = 20
        }
        else{
            cell.topStackViewOfLabel.constant = 25
            cell.bottomStackViewOfLabel.constant = 85
            cell.favouriteRightBarBottom.constant = -70
//            cell.favouriteRightBarTop.constant = -60
        }
        if item.chatIsTop == IsTop.noTop.rawValue {
            cell.childView.backgroundColor = UIColor._lightGrayColor()
            cell.initialColor = UIColor._lightGrayColor()
        }else{
            cell.childView.backgroundColor = UIColor._skyBlueColor()
            cell.initialColor = UIColor._skyBlueColor()
        }
        PrintUtility.printLog(tag: "FV:Controller", text: "\(String(describing: item.chatIsLiked))")
        if item.chatIsLiked == IsLiked.noLike.rawValue{
            cell.hideFavourite()
        }else{
            cell.showAsFavourite()
        }

        cell.deleteItem = { [weak self] point in
            guard let `self`  = self else {
                return
            }
            let cellPoint =  collectionView.convert(point, from:collectionView)
            let indexpath = collectionView.indexPathForItem(at: cellPoint)!
            self.historyViewModel.deleteHistory(indexpath.item)
            self.deletedCellHeight = cell.frame.height
            PrintUtility.printLog(tag: "cell Height", text: "\(self.deletedCellHeight)")
            self.collectionView.performBatchUpdates{
                self.collectionView.deleteItems(at: [indexpath])
                if(self.historyViewModel.items.value.count == indexpath.row){
                    self.collectionView.reloadItems(at: [IndexPath(item: self.historyViewModel.items.value.count - 1, section: 0)])
                }
                
            }
        }

        cell.favouriteItem = { [weak self] point in
            guard let `self`  = self else {
                return
            }
            let cellPoint =  collectionView.convert(point, from:collectionView)
            let indexpath = collectionView.indexPathForItem(at: cellPoint)!
            self.historyViewModel.makeFavourite(indexpath.item)
            self.collectionView.reloadItems(at: [indexpath])
        }
        
        cell.tappedItem = { [weak self] point in
            guard let `self`  = self else {
                return
            }
            let cellPoint =  collectionView.convert(point, from:collectionView)
            let indexpath = collectionView.indexPathForItem(at: cellPoint)!
            self.openTTTResult(indexpath)
        }
        
        cell.longTappedItem = { [weak self] point in
            guard let `self`  = self else {
                return
            }
            let cellPoint =  collectionView.convert(point, from:collectionView)
            let indexpath = collectionView.indexPathForItem(at: cellPoint)!
            self.openTTTResultAlert(indexpath)
        }
        return cell
    }
    
    func openTTTResult(_ idx: IndexPath){
        let chatItem = historyViewModel.items.value[idx.item] as! ChatEntity

//        GlobalMethod.showTtsAlert(viewController: self, chatItemModel: HistoryChatItemModel(chatItem: chatItem, idxPath: idx), hideMenuButton: false, hideBottmSection: true, saveDataToDB: false, fromHistory: true, ttsAlertControllerDelegate: self, isRecreation: false)
        self.showTTSScreen(chatItemModel: HistoryChatItemModel(chatItem: chatItem, idxPath: idx), hideMenuButton: false, hideBottmSection: true, saveDataToDB: false, fromHistory: true, ttsAlertControllerDelegate: self, isRecreation: false)
    }
    
    func openTTTResultAlert(_ idx: IndexPath){
        let vc = AlertReusableViewController.init()
        let languageManager = LanguageSelectionManager.shared
        let chatItem = historyViewModel.items.value[idx.item] as! ChatEntity
        let language = languageManager.getLanguageCodeByName(langName: chatItem.textTranslatedLanguage!)

        if languageManager.hasSttSupport(languageCode: language!.code){
            PrintUtility.printLog(tag: "TAG", text: "checkSttSupport has support \(language?.code)")
            populateData(withPronounciation: true)
        }else{
            PrintUtility.printLog(tag: "TAG", text: "checkSttSupport not support \(language?.code)")
            populateData(withPronounciation: false)
            //showToast(message: "no_stt_msg".localiz(), seconds: 2)
        }
        vc.items = self.itemsToShowOnContextMenu
        vc.delegate = self
        vc.chatItemModel = HistoryChatItemModel(chatItem: chatItem, idxPath: idx)
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(vc, animated: true, completion: nil)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if collectionView.contentSize.height+100 < (scrollView.contentOffset.y+collectionView.bounds.height) && isCollectionViewVisible{
            isCollectionViewVisible = false
            dismissHistoryWithAnimation()
        }
    }
    
    func dismissHistoryWithAnimation() {
        CATransaction.begin()
        let transitionAnimation = CABasicAnimation(keyPath: "position.y")
        transitionAnimation.fromValue = view.layer.position.y
        
        transitionAnimation.toValue = view.layer.position.y - SIZE_HEIGHT
        
        let scalAnimation = CABasicAnimation(keyPath: "transform.scale")
        scalAnimation.fromValue = 1.0
        scalAnimation.toValue = 0.3

        let transitionAndScale = CAAnimationGroup()
        transitionAndScale.duration = 1.0
        transitionAndScale.fillMode = .forwards
        transitionAndScale.isRemovedOnCompletion = false
        transitionAndScale.animations = [ transitionAnimation, scalAnimation]
        
        CATransaction.setCompletionBlock {
            self.view.alpha = 0.0
            self.dismissHistory(animated: true, completion: nil )
            self.delegate?.historyDissmissed()
        }
        collectionView.layer.add(transitionAndScale, forKey: nil)
        CATransaction.commit()
    }
    
    func gotoLanguageSelectVoice () {
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
        if LanguageSelectionManager.shared.isArrowUp{
            controller.isNative = LanguageName.bottomLang.rawValue
        }else{
            controller.isNative = LanguageName.topLang.rawValue
        }
        controller.retranslationDelegate = self
        controller.fromRetranslation = true
        self.navigationController?.pushViewController(controller, animated: true);
    }
    
    func actualNumberOfLines(width:CGFloat, text:String, font:UIFont) -> Int {
        let rect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = text.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)
        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }
}


extension HistoryViewController:HistoryLayoutDelegate{
    func getHeightFrom(collectionView: UICollectionView, heightForRowIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let historyModel = historyViewModel.items.value[indexPath.item] as! ChatEntity
        let font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .regular)
        
        let fromHeight = historyModel.textTranslated!.heightWithConstrainedWidth(width: width-buttonWidth, font: font)
        let toHeight = historyModel.textNative!.heightWithConstrainedWidth(width: width-buttonWidth, font: font)
        let count = self.actualNumberOfLines(width: SIZE_WIDTH - 80, text: historyModel.textTranslated!, font: font)

        PrintUtility.printLog(tag: "HistoryViewController", text: "fromHeight: \(fromHeight) toHeight: \(toHeight) count: \(count) width: \(width) font: \(font.pointSize)")
        PrintUtility.printLog(tag: "HistoryViewController", text: "Font \(FontUtility.getFontSizeIndex())")
       
        if(indexPath.row == historyViewModel.items.value.count-1){
            return 20 + fromHeight + ((CGFloat(count) * FontUtility.getFontSize() ) ) + 40 + toHeight + 40 + 10
        }
        return 20 + fromHeight + ((CGFloat(count) * FontUtility.getFontSize() ) ) + 40 + toHeight + 40 + 65
        
        
    }
}


extension HistoryViewController : RetranslationDelegate{
    func showRetranslation(selectedLanguage: String) {
        if Reachability.isConnectedToNetwork() {
            spinnerView.isHidden = false
            let chatItem = selectedChatItemModel?.chatItem!
            self.isReverse = false
            socketManager.socketManagerDelegate = self
            SocketManager.sharedInstance.connect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                let nativeText = chatItem!.textNative
                let nativeLangName = chatItem!.textNativeLanguage!
                    
                let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: nativeText!,srcLang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLangName)!.code,destlang: selectedLanguage)
                self!.socketManager.sendTextData(text: textFrameData, completion: nil)
                ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
            }
        }else{
            GlobalMethod.showNoInternetAlert()
        }
    }
}

extension HistoryViewController : AlertReusableDelegate {
    func onSharePressed(chatItemModel: HistoryChatItemModel?) {

    }

    func onDeleteItem(chatItemModel: HistoryChatItemModel?) {
        self.historyViewModel.deleteHistory(chatItemModel!.idxPath!.item)
        self.collectionView.performBatchUpdates{
            self.collectionView.deleteItems(at: [chatItemModel!.idxPath!])
        }
    }
    
    func updateFavourite(chatItemModel: HistoryChatItemModel) {
        self.historyViewModel.items.value[chatItemModel.idxPath!.row] = chatItemModel.chatItem!
        self.collectionView.reloadItems(at: [chatItemModel.idxPath!])
    }
    
    func pronunciationPracticeTap(chatItemModel: HistoryChatItemModel?) {
        let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeViewController")as! PronunciationPracticeViewController
        controller.modalPresentationStyle = .fullScreen
        controller.chatItem = chatItemModel?.chatItem
        controller.isFromHistory = true
        add(asChildViewController: controller, containerView: view, animation: nil)
        ScreenTracker.sharedInstance.screenPurpose = .HistroyPronunctiation
        //self.present(controller, animated: true, completion: nil)
    }
    
    func transitionFromRetranslation(chatItemModel: HistoryChatItemModel?) {
        selectedChatItemModel = chatItemModel
        
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
        controller.isNative = chatItemModel?.chatItem?.chatIsTop ?? 0 == IsTop.noTop.rawValue ? 1 : 0
        controller.retranslationDelegate = self
        controller.fromRetranslation = true
        controller.modalPresentationStyle = .fullScreen
        let transition = GlobalMethod.getTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        //self.navigationController?.pushViewController(controller, animated: false)
        //self.present(controller, animated: true, completion: nil)
        add(asChildViewController: controller, containerView: view, animation: transition)
        ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
    }
    
    func transitionFromReverse(chatItemModel: HistoryChatItemModel?) {
        if Reachability.isConnectedToNetwork() {
            self.spinnerView.isHidden = false
            socketManager.socketManagerDelegate = self
            SocketManager.sharedInstance.connect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self!.selectedChatItemModel = chatItemModel

                self!.isReverse = true
                let nativeText = self!.selectedChatItemModel?.chatItem?.textTranslated
                let nativeLangName = self!.selectedChatItemModel?.chatItem!.textTranslatedLanguage
                let targetLangName = self!.selectedChatItemModel?.chatItem!.textNativeLanguage!

                let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: nativeText!,srcLang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLangName!)!.code,destlang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: targetLangName!)!.code)
                self!.socketManager.sendTextData(text: textFrameData, completion: nil)
            }
        }else{
            GlobalMethod.showNoInternetAlert()
        }
        
    }
    
}

extension HistoryViewController: TtsAlertControllerDelegate{
    func dismissed() {
        //SocketManager.sharedInstance.connect()
        socketManager.socketManagerDelegate = self
    }
    
    func itemAdded(_ chatItemModel: HistoryChatItemModel) {
        self.historyViewModel.addItem(chatItemModel.chatItem!)
        self.collectionView.reloadData()
        self.scrollToBottom()
    }
    
    func itemDeleted(_ chatItemModel: HistoryChatItemModel) {
        self.historyViewModel.removeItem(chatItemModel.idxPath!.item)
        self.collectionView.performBatchUpdates{
            self.collectionView.deleteItems(at: [chatItemModel.idxPath!])
        }

    }
    
    func updatedFavourite(_ chatItemModel: HistoryChatItemModel) {
        self.historyViewModel.replaceItem(chatItemModel.chatItem!, chatItemModel.idxPath!.row)
        self.collectionView.reloadItems(at: [chatItemModel.idxPath!])
    }


    func showTTSScreen(chatItemModel: HistoryChatItemModel, hideMenuButton: Bool, hideBottmSection: Bool, saveDataToDB: Bool, fromHistory:Bool, ttsAlertControllerDelegate: TtsAlertControllerDelegate?, isRecreation: Bool, fromSpeech: Bool = false){
        self.enableOrDisableMicrophoneBtn?(true)
        let chatItem = chatItemModel.chatItem!
        if saveDataToDB == true{
            do {
                let row = try ChatDBModel.init().insert(item: chatItem)
                chatItem.id = row
                UserDefaultsProperty<Int64>(kLastSavedChatID).value = row
            } catch _ {}
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ttsVC = storyboard.instantiateViewController(withIdentifier: KTtsAlertController) as! TtsAlertController
        ttsVC.chatItemModel = chatItemModel
        ttsVC.hideMenuButton = hideMenuButton
        ttsVC.hideBottomView = hideBottmSection
        add(asChildViewController: ttsVC, containerView: self.view, animation: nil)

    }
}

extension HistoryViewController : SpeechProcessingDismissDelegate {
    func showTutorial() {
        self.speechProDismissDelegateFromHistory?.showTutorial()

    }
}

extension HistoryViewController : SocketManagerDelegate{
    func faildSocketConnection(value: String) {
        PrintUtility.printLog(tag: TAG, text: value)
    }
    
    func getText(text: String) {
        PrintUtility.printLog(tag: "Retranslation: ", text: text)
        speechProcessingVM.setTextFromScoket(value: text)
    }
    
    func getData(data: Data) {}
    
}

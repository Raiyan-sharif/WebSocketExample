//
//  HistoryCardViewController.swift
//  PockeTalk
//

import UIKit
protocol HistoryCardViewControllerDelegate: AnyObject {
    func dissmissHistory(shouldUpdateViewAlpha: Bool, isFromHistoryScene: Bool)
}

class HistoryCardViewController: BaseViewController {
    let TAG = "\(HistoryCardViewController.self)"
    let historylayout = HistoryLayout()
    var topConstraintOfCV:NSLayoutConstraint!
    var widthConstraintOfCV:NSLayoutConstraint!
    
    var isCollectionViewVisible = false
    var isReverse = false
    
    var historyViewModel: HistoryViewModel!
    var selectedChatItemModel : HistoryChatItemModel?
    private var speechProcessingVM : SpeechProcessingViewModeling!
    var animationDelay = 0.2
    var timer: Timer? = nil
    var timeInterval: TimeInterval = 30
    
    let buttonWidth : CGFloat = 100
    var deletedCellHeight = CGFloat()
    
    private var spinnerView : SpinnerView!
    weak var delegate: HistoryCardViewControllerDelegate?
    var itemsToShowOnContextMenu : [AlertItems] = []
    
    weak var speechProDismissDelegateFromHistory : SpeechProcessingDismissDelegate?
    var enableOrDisableMicrophoneBtn:((_ value:Bool)->())?
    
    lazy var collectionView:UICollectionView = {
        let collectionView = UICollectionView(frame:.zero ,collectionViewLayout:historylayout)
        historylayout.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType: HistoryCell.self)
        return collectionView
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.image = UIImage(named: "bottomBackgroudImage")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var backBtn:UIButton = {
        guard let window = UIApplication.shared.keyWindow else {return UIButton()}
        let topPadding = window.safeAreaInsets.top
        let backBtn = UIButton(frame: CGRect(x: window.safeAreaInsets.left, y: topPadding, width: 40, height: 40))
        backBtn.setImage(UIImage(named: "btn_back_tempo.png"), for: UIControl.State.normal)
        backBtn.addTarget(self, action: #selector(actionBack), for: .touchUpInside)
        return backBtn
    }()
    
    //MARK: - Lifecycle methods
    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUIView()
        historyViewModel = HistoryViewModel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.showCollectionView()
        }
        
        self.speechProcessingVM = SpeechProcessingViewModel()
        bindData()
        registerNotification()
    }
    
    deinit {
        unregisterNotification()
    }
    
    //MARK:- Initial setup
    private func setUpUIView(){
        self.view.addSubview(collectionView)
        addSpinner()
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        widthConstraintOfCV = collectionView.widthAnchor.constraint(equalToConstant: SIZE_WIDTH)
        widthConstraintOfCV.isActive = true
        topConstraintOfCV =  collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant:0)
        
        topConstraintOfCV.isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        
        self.view.addSubview(backBtn)
        self.view.addSubview(imageView)

        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 5).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: HomeViewController.homeVCBottomViewHeight + 5).isActive = true
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
    
    private func showCollectionView(){
        isCollectionViewVisible = true
        let contentSize = self.collectionView.contentSize
        let bottmInset = self.collectionView.bounds.size.height * 0.25
        historylayout.bottomInset = bottmInset
        
        let bottomOffset = CGPoint(x: 0, y: contentSize.height + bottmInset  - self.collectionView.bounds.size.height)
        self.collectionView.setContentOffset(bottomOffset, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.collectionView.alpha = 1.0
        }
    }
    
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(removeChild(notification:)), name:.historyNotofication, object: nil)
    }
    
    //MARK: - Load Data
    private func bindData(){
        historyViewModel.items.bindAndFire { [weak self] items in
            guard let `self` = self else { return }
            if items.count > 0{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    guard let `self` = self else { return }
                    if items.count <= 1 {
                        self.showCollectionView()
                    }
                }
            }
        }
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
    
    func updateData(shouldCVScrollToBottom: Bool){
        deletedCellHeight = 0
        historyViewModel.getData()
        if shouldCVScrollToBottom {
            collectionView.reloadData()
            self.scrollToBottom()
        }
    }
    //MARK: - View Transactions
    private func openTTTResultAlert(_ idx: IndexPath){
        ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
        let vc = AlertReusableViewController.init()
        let languageManager = LanguageSelectionManager.shared
        let chatItem = historyViewModel.items.value[idx.item] as! ChatEntity
        let language = languageManager.getLanguageCodeByName(langName: chatItem.textTranslatedLanguage!)
        
        if languageManager.hasSttSupport(languageCode: language!.code){
            PrintUtility.printLog(tag: "TAG", text: "checkSttSupport has support \(language?.code ?? "")")
            populateData(withPronounciation: true)
        }else{
            PrintUtility.printLog(tag: "TAG", text: "checkSttSupport not support \(language?.code ?? "")")
            populateData(withPronounciation: false)
        }
        vc.items = self.itemsToShowOnContextMenu
        vc.delegate = self
        vc.chatItemModel = HistoryChatItemModel(chatItem: chatItem, idxPath: idx)
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    private func openTTTResult(_ idx: IndexPath){
        let chatItem = historyViewModel.items.value[idx.item] as! ChatEntity
        ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
        self.showTTSScreen(chatItemModel: HistoryChatItemModel(chatItem: chatItem, idxPath: idx), hideMenuButton: false, hideBottmSection: true, saveDataToDB: false, fromHistory: true, ttsAlertControllerDelegate: self, isRecreation: false)
    }
    
    //MARK: - Utils
    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name:.historyNotofication, object: nil)
    }
    
    @objc private func removeChild(notification: Notification) {
        if let vc = view.subviews.last?.parentViewController{
            remove(asChildViewController: vc)
        }
        ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
    }
    
    private func populateData (withPronounciation: Bool) {
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
    
    private func dismissHistory(shouldUpdateViewAlpha: Bool) {
        delegate?.dissmissHistory(shouldUpdateViewAlpha: shouldUpdateViewAlpha, isFromHistoryScene: true)
        ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
        NotificationCenter.default.post(name: .bottmViewGestureNotification, object: nil)
        if self.spinnerView.isHidden == false {
            self.spinnerView.isHidden = true
        }
    }
    
    //MARK: - IBActions
    @objc private func actionBack() {
        UIView.animate(withDuration: kFadeAnimationTransitionTime, delay: animationDelay, options: .curveEaseOut) {
            self.view.alpha = viewsAlphaValue
            if self.spinnerView.isHidden == false {
                self.spinnerView.isHidden = true
            }
        } completion: { _ in
            self.dismissHistory(shouldUpdateViewAlpha: true)
        }
    }
    
    private func scrollToBottom(){
        let item = self.collectionView(self.collectionView, numberOfItemsInSection: 0) - 1
        let lastItemIndex = IndexPath(item: item, section: 0)
        self.collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: true)
    }
    
    private func actualNumberOfLines(width:CGFloat, text:String, font:UIFont) -> Int {
        let rect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = text.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)
        return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }
}

//MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension HistoryCardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyViewModel.items.value.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: HistoryCell.self)
        let item = historyViewModel.items.value[indexPath.item] as! ChatEntity
        cell.fromLabel.text = item.textTranslated
        cell.toLabel.text = item.textNative
        cell.deleteLabel.text = "delete_from_fv".localiz()
        cell.favouriteLabel.text = "Favorite".localiz()
        //let historyModel = historyViewModel.items.value[indexPath.item] as! ChatEntity
        
        if(indexPath.row == historyViewModel.items.value.count - 1){
            cell.bottomStackViewOfLabel.constant = 25
            cell.favouriteRightBarBottom.constant = -20
            cell.topStackViewOfLabel.constant = 25
            cell.favouriteRightBarTop.constant = 20
            cell.deleteStackViewHeightConstraint.constant = 0
            cell.favouriteStackViewHeightConstraint.constant = 0
        }
        else{
            cell.topStackViewOfLabel.constant = 25
            cell.bottomStackViewOfLabel.constant = 85
            cell.favouriteRightBarBottom.constant = -70
            cell.deleteStackViewHeightConstraint.constant = -30
            cell.favouriteStackViewHeightConstraint.constant = -30
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
            let bottomInset = self.collectionView.contentInset.bottom
            self.historylayout.bottomInset = bottomInset
            let cellPoint =  collectionView.convert(point, from:collectionView)
            let indexpath = collectionView.indexPathForItem(at: cellPoint)!
            self.historyViewModel.deleteHistory(indexpath.item)
            self.deletedCellHeight = cell.frame.height
            
            self.collectionView.performBatchUpdates { [weak self]  in
                guard let `self`  = self else {return}
                
                self.collectionView.deleteItems(at: [indexpath])
                let itemCount = self.historyViewModel.items.value.count
                if itemCount > 0{
                    if(itemCount == indexpath.row){
                        self.collectionView.reloadItems(at: [IndexPath(item: itemCount - 1, section: 0)])
                    }
                }else{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self]  in
                        guard let `self` = self else { return }
                        self.dismissHistory(shouldUpdateViewAlpha: false)
                    }
                }
            }
        completion: { [weak self] _ in
            self?.historylayout.deletedCellHeight = 0
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
}

//MARK: - ScrollView Delegate
extension HistoryCardViewController {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if collectionView.contentSize.height + (SIZE_HEIGHT / 4 + 10) < (scrollView.contentOffset.y + collectionView.bounds.height){
            self.dismissHistory(shouldUpdateViewAlpha: false)
        }
    }
}

//MARK: - HistoryLayoutDelegate
extension HistoryCardViewController: HistoryLayoutDelegate {
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

//MARK: - RetranslationDelegate   
extension HistoryCardViewController : RetranslationDelegate{
    func showRetranslation(selectedLanguage: String, fromScreenPurpose: SpeechProcessingScreenOpeningPurpose) {
        if Reachability.isConnectedToNetwork() {
            spinnerView.isHidden = false
            let chatItem = selectedChatItemModel?.chatItem!
            self.isReverse = false
            SocketManager.sharedInstance.socketManagerDelegate = self
            SocketManager.sharedInstance.connect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let nativeText = chatItem!.textNative
                let nativeLangName = chatItem!.textNativeLanguage!
                
                let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: nativeText!,srcLang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLangName)!.code,destlang: selectedLanguage)
                SocketManager.sharedInstance.sendTextData(text: textFrameData, completion: nil)
                self.startCountdown()
                ScreenTracker.sharedInstance.screenPurpose = fromScreenPurpose
            }
        }else{
            GlobalMethod.showNoInternetAlert()
        }
    }
}

//MARK:- AlertReusableDelegate
extension HistoryCardViewController : AlertReusableDelegate{
    func onSharePressed(chatItemModel: HistoryChatItemModel?) {}
    
    func onDeleteItem(chatItemModel: HistoryChatItemModel?) {
        self.historyViewModel.deleteHistory(chatItemModel!.idxPath!.item)
        self.collectionView.performBatchUpdates{
            let itemCount = self.collectionView.numberOfItems(inSection: 0)
            if(itemCount > 0){
                self.collectionView.deleteItems(at: [chatItemModel!.idxPath!])
                if(itemCount  == 1){
                  self.dismissHistory(shouldUpdateViewAlpha: false)
                }
            }
        }
    }
    
    func updateFavourite(chatItemModel: HistoryChatItemModel){
        self.historyViewModel.items.value[chatItemModel.idxPath!.row] = chatItemModel.chatItem!
        self.collectionView.reloadItems(at: [chatItemModel.idxPath!])
    }
    
    func pronunciationPracticeTap(chatItemModel: HistoryChatItemModel?){
        let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeViewController")as! PronunciationPracticeViewController
        controller.modalPresentationStyle = .fullScreen
        controller.chatItem = chatItemModel?.chatItem
        controller.isFromHistory = true
        add(asChildViewController: controller, containerView: view)
        ScreenTracker.sharedInstance.screenPurpose = .HistroyPronunctiation
    }
    
    func transitionFromRetranslation(chatItemModel: HistoryChatItemModel?){
        selectedChatItemModel = chatItemModel
        
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
        controller.isNative = chatItemModel?.chatItem?.chatIsTop ?? 0 == IsTop.noTop.rawValue ? 1 : 0
        
        controller.retranslationDelegate = self
        controller.fromRetranslation = true
        controller.fromScreenPurpose = ScreenTracker.sharedInstance.screenPurpose
        
        controller.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        add(asChildViewController: controller, containerView: view)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionVoice
    }
    
    func transitionFromReverse(chatItemModel: HistoryChatItemModel?){
        addSpinner()
        self.spinnerView.isHidden = false
        if Reachability.isConnectedToNetwork() {
            SocketManager.sharedInstance.socketManagerDelegate = self
            SocketManager.sharedInstance.connect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self!.selectedChatItemModel = chatItemModel
                
                self!.isReverse = true
                let nativeText = self!.selectedChatItemModel?.chatItem?.textTranslated
                let nativeLangName = self!.selectedChatItemModel?.chatItem!.textTranslatedLanguage
                let targetLangName = self!.selectedChatItemModel?.chatItem!.textNativeLanguage!
                
                let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: nativeText!,srcLang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLangName!)!.code,destlang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: targetLangName!)!.code)
                SocketManager.sharedInstance.sendTextData(text: textFrameData, completion: nil)
                self?.startCountdown()
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
                //PrintUtility.printLog(tag: "Timer On Favorite : ", text: "\(seconds)")
            }
        }
    }

}

//MARK: - TtsAlertControllerDelegate
extension HistoryCardViewController: TtsAlertControllerDelegate{
    func dismissed() {
        SocketManager.sharedInstance.socketManagerDelegate = self
    }
    
    func itemAdded(_ chatItemModel: HistoryChatItemModel) {
        self.historyViewModel.addItem(chatItemModel.chatItem!)
        self.collectionView.reloadData()
        self.scrollToBottom()
    }
    
    func itemDeleted(_ chatItemModel: HistoryChatItemModel) {
        self.historyViewModel.deleteHistory(chatItemModel.idxPath!.item)
        self.collectionView.performBatchUpdates{
            let itemCount = self.collectionView.numberOfItems(inSection: 0)
            if(itemCount > 0){
                self.collectionView.deleteItems(at: [chatItemModel.idxPath!])
                if(itemCount  == 1){
                  self.dismissHistory(shouldUpdateViewAlpha: false)
                }
            }
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
        ttsVC.view.tag = ttsAlertViewTag
        ttsVC.ttsAlertControllerDelegate = ttsAlertControllerDelegate
        add(asChildViewController: ttsVC, containerView: self.view)
        
    }
}

//MARK: - SpeechProcessingDismissDelegate
extension HistoryCardViewController : SpeechProcessingDismissDelegate {
    func showTutorial() {
        self.speechProDismissDelegateFromHistory?.showTutorial()
        
    }
}

//MARK: - SocketManagerDelegate
extension HistoryCardViewController : SocketManagerDelegate{
    func faildSocketConnection(value: String) {
        PrintUtility.printLog(tag: TAG, text: value)
    }
    
    func getText(text: String) {
        PrintUtility.printLog(tag: "Retranslation: ", text: text)
        speechProcessingVM.setTextFromScoket(value: text)
    }
    
    func getData(data: Data) {}
}


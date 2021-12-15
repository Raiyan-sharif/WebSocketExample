//
//  FavouriteViewController
//  PockeTalk
//

import UIKit

class FavouriteViewController: BaseViewController {
    let TAG = "\(FavouriteViewController.self)"
    ///Favourite Layout to postion the cell
    let favouritelayout = FavouriteLayout()
    ///Collection View top constraint
    var topConstraintOfCV:NSLayoutConstraint!
    /// Ccolectionview Width constraint
    var widthConstraintOfCV:NSLayoutConstraint!

    var  isCollectionViewVisible = false
    var loclItems = [FavouriteModel]()
    var favouriteViewModel: FavouriteViewModel!
    let transionDuration : CGFloat = 0.8
    let transformation : CGFloat = 0.6
    let buttonWidth : CGFloat = 100
    private var spinnerView : SpinnerView!

    var itemsToShowOnContextMenu : [AlertItems] = []
    var selectedChatItemModel : HistoryChatItemModel?
    //var deletedCellHeight = CGFloat()
    weak var speechProDismissDelegateFromFav : SpeechProcessingDismissDelegate?
    var isReverse = false
    private var socketManager = SocketManager.sharedInstance
    private var speechProcessingVM : SpeechProcessingViewModeling!
    var navController: UINavigationController?

    ///CollectionView to show favourite item
    private lazy var collectionView:UICollectionView = {
        let collectionView = UICollectionView(frame:.zero ,collectionViewLayout:favouritelayout)
        favouritelayout.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellType: FavouriteCell.self)
        return collectionView
    }()
    
    private lazy var backBtn:UIButton = {
        guard let window = UIApplication.shared.keyWindow else {return UIButton()}
        let topPadding = window.safeAreaInsets.top
        let okBtn = UIButton(frame: CGRect(x: window.safeAreaInsets.left, y: topPadding, width: 40, height: 40))
        okBtn.setImage(UIImage(named: "btn_back_tempo.png"), for: UIControl.State.normal)
        okBtn.addTarget(self, action: #selector(actionBack), for: .touchUpInside)
        return okBtn
    }()

    //MARK: - Lifecycle methods
    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        favouriteViewModel = FavouriteViewModel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.showCollectionView()
        }
        populateData()
        self.speechProcessingVM = SpeechProcessingViewModel()
        bindData()
    }

    //MARK: - Initial setup
    private func populateData () {
        self.itemsToShowOnContextMenu.append(AlertItems(title: "retranslation".localiz(), imageName: "", menuType: .retranslation))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "reverse".localiz(), imageName: "", menuType: .reverse))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "delete_from_fv".localiz(), imageName: "Delete_icon.png", menuType: .delete))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "cancel".localiz(), imageName: "", menuType: .cancel) )
    }
    
    private func setUpCollectionView(){
        self.view.addSubview(collectionView)
        addSpinner()

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        widthConstraintOfCV = collectionView.widthAnchor.constraint(equalToConstant: SIZE_WIDTH)
        widthConstraintOfCV.isActive = true
        let margin = view.safeAreaLayoutGuide
        
        topConstraintOfCV =  collectionView.topAnchor.constraint(equalTo: margin.topAnchor, constant:0)
        topConstraintOfCV.isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.alpha = 0.0
        self.view.addSubview(backBtn)
    }

    private func showCollectionView(){
        isCollectionViewVisible = true
        collectionView.scrollToItem(at: IndexPath(item: favouriteViewModel.items.value.count-1, section: 0), at: .bottom, animated: false)
        collectionView.alpha = 1.0
        
        //TODO: Remove animation from collectionview. Will remove permanently after final confirmation.
        
        /*
        let transitionAnimation = CABasicAnimation(keyPath: "position.y")
        transitionAnimation.fromValue = view.layer.position.y -
            view.frame.size.height
        transitionAnimation.toValue = view.layer.position.y - buttonWidth/2

        let scalAnimation = CABasicAnimation(keyPath: "transform.scale")
        scalAnimation.fromValue = 0.5
        scalAnimation.toValue = 1.0

        let transitionAndScale = CAAnimationGroup()
        transitionAndScale.fillMode = .removed
        transitionAndScale.isRemovedOnCompletion = true
        transitionAndScale.animations = [ transitionAnimation, scalAnimation]
        transitionAndScale.duration = 1.0
        collectionView.layer.add(transitionAndScale, forKey: nil)
        */
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
    
    //MARK: - Bind Data
    private func bindData(){
        favouriteViewModel.items.bindAndFire { [weak self] items in
            if items.count == 0{
                
            }
            if items.count > 0{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.collectionView.reloadData()
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
                let row = self.favouriteViewModel.saveChatItem(chatItem: chatEntity)
                chatEntity.id = row
                self.selectedChatItemModel?.chatItem = chatEntity
                self.spinnerView.isHidden = true
                self.showTTSScreen( chatItemModel: HistoryChatItemModel(chatItem: chatEntity, idxPath: nil), hideMenuButton: true, hideBottmSection: true, saveDataToDB: false, fromHistory: true, ttsAlertControllerDelegate: self, isRecreation: false)
            }
        }
    }
    
    //MARK: - IBActions
    @objc private func actionBack() {
        dismissFavourite(byBackBtnPress: true)
    }

    //MARK: - View Transactions
    private func dismissFavourite(byBackBtnPress isPresssed: Bool) {
        if isPresssed {
            addBackNavigationTransationalAnimation()
        } else {
            if favouriteViewModel.items.value.count > 1 {
                addBackNavigationTransationalAnimation()
            }
        }
        NotificationCenter.default.post(name: .containerViewSelection, object: nil)
    }
    
    private func openTTTResult(_ item: Int){
        let chatItem = favouriteViewModel.items.value[item] as! ChatEntity
        self.showTTSScreen (chatItemModel: HistoryChatItemModel(chatItem: chatItem, idxPath: nil), hideMenuButton: true, hideBottmSection: true, saveDataToDB: false, fromHistory: true, ttsAlertControllerDelegate: self, isRecreation: false)
    }
    
    private func openTTTResultAlert(_ idx: IndexPath){
        let chatItem = favouriteViewModel.items.value[idx.item] as! ChatEntity
        let vc = AlertReusableViewController.init()
        vc.items = self.itemsToShowOnContextMenu
        vc.delegate = self
        vc.chatItemModel = HistoryChatItemModel(chatItem: chatItem, idxPath: idx)
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    private func showTTSScreen(chatItemModel: HistoryChatItemModel, hideMenuButton: Bool, hideBottmSection: Bool, saveDataToDB: Bool, fromHistory:Bool, ttsAlertControllerDelegate: TtsAlertControllerDelegate?, isRecreation: Bool, fromSpeech: Bool = false){
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
    
    //MARK: - Utils
    private func actualNumberOfLines(width:CGFloat, text:String, font:UIFont) -> Int {
           let rect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
           let labelSize = text.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)
           return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }
    
    private func addBackNavigationTransationalAnimation() {
        let transition = GlobalMethod.getBackTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
        self.view.window!.layer.add(transition, forKey: kCATransition)
    }
}

//MARK: - UICollectionViewDelegate and UICollectionViewDataSource
extension FavouriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteViewModel.items.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: FavouriteCell.self)
        let item = favouriteViewModel.items.value[indexPath.item] as! ChatEntity
        cell.fromLabel.text = item.textTranslated
        cell.toLabel.text = item.textNative
        cell.deleteLabel.text = "delete_from_fv".localiz()
        if(indexPath.row == favouriteViewModel.items.value.count - 1){
            cell.bottomStackViewOfLabel.constant = 25
            cell.favoriteRightBarBottom.constant = -20
            cell.topStackViewOfLabel.constant = 25
            cell.deleteStackViewHeightConstraint.constant = 0
            cell.favouriteStackViewHeightConstraint.constant = 0
          }
          else{
              cell.topStackViewOfLabel.constant = 25
              cell.bottomStackViewOfLabel.constant = 85
              cell.favoriteRightBarBottom.constant = -70
              cell.deleteStackViewHeightConstraint.constant = -30
              cell.favouriteStackViewHeightConstraint.constant = -30
          }
        
        if item.chatIsTop == IsTop.noTop.rawValue {
            cell.childView.backgroundColor = UIColor._lightGrayColor()
        }else{
            cell.childView.backgroundColor = UIColor._skyBlueColor()
        }
        cell.showAsFavourite()
        cell.deleteItem = { [weak self] point in
            guard let `self`  = self else {
                return
            }
            let cellPoint =  collectionView.convert(point, from:collectionView)
            let indexpath = collectionView.indexPathForItem(at: cellPoint)!
            self.favouriteViewModel.deleteFavourite(indexpath.item)
           
            self.favouritelayout.deletedCellHeight = cell.frame.height
            self.collectionView.performBatchUpdates { [weak self]  in
                guard let `self`  = self else {
                    return
                }
                self.collectionView.deleteItems(at: [indexpath])
                let itemCount = self.favouriteViewModel.items.value.count
                if itemCount > 0{
                    if(itemCount == indexpath.row){
                        self.collectionView.reloadItems(at: [IndexPath(item: itemCount - 1, section: 0)])
                    }
                }else{
                    self.dismissFavourite(byBackBtnPress: false)
                }
            } completion: { [weak self] _ in
                self?.favouritelayout.deletedCellHeight = 0
            }
        }
        
        cell.tappedItem = { [weak self] point in
            guard let `self`  = self else {
                return
            }
            let cellPoint =  collectionView.convert(point, from:collectionView)
            let indexpath = collectionView.indexPathForItem(at: cellPoint)!
            self.openTTTResult(indexpath.item)
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

//MARK: - FavouriteLayoutDelegate
extension FavouriteViewController:FavouriteLayoutDelegate{
    func getHeightFrom(collectionView: UICollectionView, heightForRowIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let favouriteModel = favouriteViewModel.items.value[indexPath.item] as! ChatEntity
        let font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .regular)
        
        let fromHeight = favouriteModel.textTranslated!.heightWithConstrainedWidth(width: width-buttonWidth, font: font)
        let toHeight = favouriteModel.textNative!.heightWithConstrainedWidth(width: width-buttonWidth, font: font)
        let count = self.actualNumberOfLines(width: SIZE_WIDTH - 80, text: favouriteModel.textTranslated!, font: font)

        PrintUtility.printLog(tag: "FavouriteViewController", text: "fromHeight: \(fromHeight) toHeight: \(toHeight) count: \(count) width: \(width) font: \(font.pointSize)")
        PrintUtility.printLog(tag: "FavouriteViewController", text: "Font \(FontUtility.getFontSizeIndex())")
        
        if(indexPath.row == favouriteViewModel.items.value.count-1){
            return 20 + fromHeight + ((CGFloat(count) * FontUtility.getFontSize() ) ) + 40 + toHeight + 40 + 10
        }
        return 20 + fromHeight + ((CGFloat(count) * FontUtility.getFontSize() ) ) + 40 + toHeight + 40 + 65
    }
}

//MARK: - RetranslationDelegate
extension FavouriteViewController : RetranslationDelegate{
    func showRetranslation(selectedLanguage: String) {
        if Reachability.isConnectedToNetwork() {
            spinnerView.isHidden = false
            let chatItem = selectedChatItemModel?.chatItem!
            self.isReverse = false
            let nativeText = chatItem!.textNative
            let nativeLangName = chatItem!.textNativeLanguage!
            socketManager.socketManagerDelegate = self
            SocketManager.sharedInstance.connect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: nativeText!,srcLang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLangName)!.code,destlang: selectedLanguage)
                self!.socketManager.sendTextData(text: textFrameData, completion: nil)
                ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
            }
        }else {
            GlobalMethod.showNoInternetAlert()
        }
    }
}

//MARK: - AlertReusableDelegate
extension FavouriteViewController : AlertReusableDelegate {
    func onSharePressed(chatItemModel: HistoryChatItemModel?) {

    }

    func onDeleteItem(chatItemModel: HistoryChatItemModel?) {
        self.favouriteViewModel.deleteFavourite((chatItemModel?.idxPath!.item)!)
        self.collectionView.performBatchUpdates{
            self.collectionView.deleteItems(at: [chatItemModel!.idxPath!])
        }
    }
    
    func updateFavourite(chatItemModel: HistoryChatItemModel) {}
    
    func pronunciationPracticeTap(chatItemModel: HistoryChatItemModel?) {}
    
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
        add(asChildViewController: controller, containerView: view, animation: transition)
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionVoice
    }
    
    func transitionFromReverse(chatItemModel: HistoryChatItemModel?) {
        if Reachability.isConnectedToNetwork() {
            spinnerView.isHidden = false
            selectedChatItemModel = chatItemModel
            self.isReverse = true
            let nativeText = selectedChatItemModel?.chatItem?.textTranslated
            let nativeLangName = selectedChatItemModel?.chatItem!.textTranslatedLanguage
            let targetLangName = selectedChatItemModel?.chatItem!.textNativeLanguage!
            socketManager.socketManagerDelegate = self
            SocketManager.sharedInstance.connect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: nativeText!,srcLang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLangName!)!.code,destlang: LanguageSelectionManager.shared.getLanguageCodeByName(langName: targetLangName!)!.code)
                self!.socketManager.sendTextData(text: textFrameData, completion: nil)
            }
        }else {
            PrintUtility.printLog(tag: TAG, text: "No internet!")
            GlobalMethod.showNoInternetAlert()
        }
    }
}

//MARK: - SocketManagerDelegate
extension FavouriteViewController : SocketManagerDelegate{
    func faildSocketConnection(value: String) {
        PrintUtility.printLog(tag: TAG, text: value)
    }
    
    func getText(text: String) {
        speechProcessingVM.setTextFromScoket(value: text)
        PrintUtility.printLog(tag: "Retranslation: ", text: text)
    }
    
    func getData(data: Data) {}
    
}

//MARK: - SpeechProcessingDismissDelegate
extension FavouriteViewController : SpeechProcessingDismissDelegate {
    func showTutorial() {
        self.speechProDismissDelegateFromFav?.showTutorial()
    }
}

//MARK: - TtsAlertControllerDelegate
extension FavouriteViewController : TtsAlertControllerDelegate{
    func itemAdded(_ chatItemModel: HistoryChatItemModel) {}
    
    func itemDeleted(_ chatItemModel: HistoryChatItemModel) {}
    
    func updatedFavourite(_ chatItemModel: HistoryChatItemModel) {}
    
    func dismissed() {
        socketManager.socketManagerDelegate = self
    }
}

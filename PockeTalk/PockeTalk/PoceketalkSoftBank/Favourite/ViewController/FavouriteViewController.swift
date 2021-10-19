import UIKit

protocol FavouriteViewControllerDelegates {
    func dismissFavouriteView()
}

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
    var favouriteViewModel:FavouriteViewModeling!
    let transionDuration : CGFloat = 0.8
    let transformation : CGFloat = 0.6
    let buttonWidth : CGFloat = 100

    private(set) var delegate: FavouriteViewControllerDelegates?
    var itemsToShowOnContextMenu : [AlertItems] = []
    var selectedChatItemModel : HistoryChatItemModel?
    var deletedCellHeight = CGFloat()

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

    private lazy var bottmView:UIView = {
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
        favouriteViewModel = FavouriteViewModel()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
            self.showCollectionView()
        }
        bindData()
        populateData()
        
    }
    
    func initDelegate<T>(_ vc: T) {
            self.delegate = vc.self as? FavouriteViewControllerDelegates
    }
    
    // Populate item to show on context menu
    func populateData () {
        self.itemsToShowOnContextMenu.append(AlertItems(title: "retranslation".localiz(), imageName: "", menuType: .retranslation))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "reverse".localiz(), imageName: "", menuType: .reverse))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "delete_from_fv".localiz(), imageName: "Delete_icon.png", menuType: .delete))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "cancel".localiz(), imageName: "", menuType: .cancel) )
    }
    
    private func setUpCollectionView(){
        self.view.addSubview(collectionView)
        self.view.addSubview(bottmView)

        bottmView.translatesAutoresizingMaskIntoConstraints = false
        bottmView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        bottmView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        bottmView.heightAnchor.constraint(equalToConstant: buttonWidth).isActive = true
        bottmView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true


        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        widthConstraintOfCV = collectionView.widthAnchor.constraint(equalToConstant: SIZE_WIDTH)
        widthConstraintOfCV.isActive = true
        let margin = view.safeAreaLayoutGuide
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top
        topConstraintOfCV =  collectionView.topAnchor.constraint(equalTo: margin.topAnchor, constant:0)
        topConstraintOfCV.isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: SIZE_HEIGHT-buttonWidth-(topPadding ?? 0.0)).isActive = true
        collectionView.alpha = 0.0

        self.view.addSubview(backBtn)

        let talkButton = GlobalMethod.setUpMicroPhoneIcon(view: bottmView, width: buttonWidth, height: buttonWidth)
        talkButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)

    }


    fileprivate func proceedToTakeVoiceInput() {
        if Reachability.isConnectedToNetwork() {
            let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: KSpeechProcessingViewController)as! SpeechProcessingViewController
            controller.homeMicTapTimeStamp = currentTS
            controller.languageHasUpdated = true
            controller.screenOpeningPurpose = .HomeSpeechProcessing
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

    func showCollectionView(){
        isCollectionViewVisible = true
        collectionView.scrollToItem(at: IndexPath(item: favouriteViewModel.items.value.count-1, section: 0), at: .bottom, animated: false)
        collectionView.alpha = 1.0
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
        let diff = collectionView.frame.height - collectionView.contentSize.height
        if diff > 0 {
            collectionView.contentInset = UIEdgeInsets(top: diff, left: 0, bottom: 0, right: 0)
        }

    }
    
    private var backBtn:UIButton!{
        guard let window = UIApplication.shared.keyWindow else {return nil}
        let topPadding = window.safeAreaInsets.top
        let okBtn = UIButton(frame: CGRect(x: window.safeAreaInsets.left, y: topPadding, width: 40, height: 40))
        okBtn.setImage(UIImage(named: "btn_back_tempo.png"), for: UIControl.State.normal)
        okBtn.addTarget(self, action: #selector(actionBack), for: .touchUpInside)
        return okBtn
    }
    
    ///Move to next screeen
    @objc func actionBack () {
        self.dismissFavourite(animated: true, completion: nil )
    }

    func bindData(){
        favouriteViewModel.items.bindAndFire { [weak self] items in
            if items.count == 0{
                DispatchQueue.main.async {
                    self?.dismissFavourite(animated: true, completion: nil)
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
    }
    
    func dismissFavourite(animated: Bool, completion: (() -> Void)? = nil) {
        self.delegate?.dismissFavouriteView()
        self.dismiss(animated: animated, completion: completion )
    }
    
    func actualNumberOfLines(width:CGFloat, text:String, font:UIFont) -> Int {
           let rect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
           let labelSize = text.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)
           return Int(ceil(CGFloat(labelSize.height) / font.lineHeight))
    }
}

extension FavouriteViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favouriteViewModel.items.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: FavouriteCell.self)
        let item = favouriteViewModel.items.value[indexPath.item] as! ChatEntity
        cell.fromLabel.text = item.textTranslated
        cell.toLabel.text = item.textNative
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
            self.deletedCellHeight = cell.frame.height
            self.collectionView.performBatchUpdates{
                self.collectionView.deleteItems(at: [indexpath])
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
    
    func openTTTResult(_ item: Int){
        let chatItem = favouriteViewModel.items.value[item] as! ChatEntity
        GlobalMethod.showTtsAlert(viewController: self, chatItemModel: HistoryChatItemModel(chatItem: chatItem, idxPath: nil), hideMenuButton: true, hideBottmSection: true, saveDataToDB: false, fromHistory: true, ttsAlertControllerDelegate: nil, isRecreation: false)
    }
    
    func openTTTResultAlert(_ idx: IndexPath){
        let chatItem = favouriteViewModel.items.value[idx.item] as! ChatEntity
        let vc = AlertReusableViewController.init()
        vc.items = self.itemsToShowOnContextMenu
        vc.delegate = self
        vc.chatItemModel = HistoryChatItemModel(chatItem: chatItem, idxPath: idx)
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
}


extension FavouriteViewController:FavouriteLayoutDelegate{
    func getHeightFrom(collectionView: UICollectionView, heightForRowIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let favouriteModel = favouriteViewModel.items.value[indexPath.item] as! ChatEntity
        let font = UIFont.systemFont(ofSize: 20, weight: .regular)

        let fromHeight = favouriteModel.textTranslated!.heightWithConstrainedWidth(width: width, font: font)
        let toHeight = favouriteModel.textNative!.heightWithConstrainedWidth(width: width, font: font)
        let count = self.actualNumberOfLines(width: SIZE_WIDTH - 20, text: favouriteModel.textTranslated!, font: font)
        if(count == 1){
            return 20 + fromHeight + 40 + toHeight + 40
        }else if(count == 2){
            return 20 + fromHeight + 60 + toHeight + 40
        }
        return 20 + fromHeight + 100 + toHeight + 40
    }
}
extension FavouriteViewController : RetranslationDelegate{
    func showRetranslation(selectedLanguage: String) {
        
        let chatItem = selectedChatItemModel?.chatItem!
        let isTop = chatItem?.chatIsTop
        let nativeText = chatItem!.textNative
        let nativeLangName = chatItem!.textNativeLanguage!
        let targetLangName = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: selectedLanguage)?.name
        
        //TODO call websocket api for ttt
        let targetText = chatItem!.textTranslated
        
        let chatEntity =  ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangName, textNativeLanguage: nativeLangName, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isTop, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue)
        
        GlobalMethod.showTtsAlert(viewController: self, chatItemModel: HistoryChatItemModel(chatItem: chatEntity, idxPath: nil), hideMenuButton: true, hideBottmSection: true, saveDataToDB: true, fromHistory: true, ttsAlertControllerDelegate: nil, isRecreation: false)

    }
}

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
        self.present(controller, animated: true, completion: nil)
    }
    
    func transitionFromReverse(chatItemModel: HistoryChatItemModel?) {
        GlobalMethod.showTtsAlert(viewController: self, chatItemModel: chatItemModel!, hideMenuButton: true, hideBottmSection: true, saveDataToDB: false, fromHistory: true, ttsAlertControllerDelegate: nil, isRecreation: false)
    }
    
}



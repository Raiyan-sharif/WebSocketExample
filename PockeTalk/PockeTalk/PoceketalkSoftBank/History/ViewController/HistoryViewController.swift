//
//  HistoryViewController.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/6/21.
//

import UIKit

protocol HistoryViewControllerDelegates {
    func historyDissmissed()
}

class HistoryViewController: BaseViewController {

    ///History Layout to postion the cell
    let historylayout = HistoryLayout()
    ///Collection View top constraint
    var topConstraintOfCV:NSLayoutConstraint!
    /// Ccolectionview Width constraint
    var widthConstraintOfCV:NSLayoutConstraint!

    var  isCollectionViewVisible = false
    var loclItems = [HistoryModel]()
    var historyViewModel:HistoryViewModeling!
    let transionDuration : CGFloat = 0.8
    let transformation : CGFloat = 0.6
    private(set) var delegate: HistoryViewControllerDelegates?
    var itemsToShowOnContextMenu : [AlertItems] = []
    var selectedChatItemModel : HistoryChatItemModel?

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

    override func loadView() {
        view = UIView()
        view.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        historyViewModel = HistoryViewModel()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
            self.showCollectionView()
        }
        bindData()
        populateData()

    }
    
    func initDelegate<T>(_ vc: T) {
            self.delegate = vc.self as? HistoryViewControllerDelegates
    }
    
    // Populate item to show on context menu
    func populateData () {
        self.itemsToShowOnContextMenu.append(AlertItems(title: "history_add_fav".localiz(), imageName: "icon_favorite_popup.png", menuType: .favorite))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "retranslation".localiz(), imageName: "", menuType: .retranslation))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "reverse".localiz(), imageName: "", menuType: .reverse))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "delete".localiz(), imageName: "", menuType: .delete))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "pronunciation_practice".localiz(), imageName: "", menuType: .practice))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "cancel".localiz(), imageName: "", menuType: .cancel) )
    }
    
    
    private func setUpCollectionView(){
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            .isActive = true
        widthConstraintOfCV = collectionView.widthAnchor.constraint(equalToConstant: SIZE_WIDTH)
        widthConstraintOfCV.isActive = true
        topConstraintOfCV =  collectionView.topAnchor.constraint(equalTo: view.topAnchor, constant:0)
        topConstraintOfCV.isActive = true
        collectionView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        collectionView.alpha = 0.0
        
        self.view.addSubview(backBtn)

    }
    private var backBtn:UIButton!{
        let okBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        okBtn.setImage(UIImage(named: "btn_back_tempo.png"), for: UIControl.State.normal)
        okBtn.addTarget(self, action: #selector(actionBack), for: .touchUpInside)
        return okBtn
    }
    
    ///Move to next screeen
    @objc func actionBack () {
        self.dismissHistory(animated: true, completion: nil )
    }
    
    func dismissHistory(animated: Bool, completion: (() -> Void)? = nil) {
        self.delegate?.historyDissmissed()
        self.dismiss(animated: animated, completion: completion )
    }
    
    func showCollectionView(){
        isCollectionViewVisible = true
        collectionView.scrollToItem(at: IndexPath(item: historyViewModel.items.value.count-1, section: 0), at: .bottom, animated: false)
        collectionView.alpha = 1.0
        let transitionAnimation = CABasicAnimation(keyPath: "position.y")
        transitionAnimation.fromValue = view.layer.position.y -
            view.frame.size.height
        transitionAnimation.toValue = view.layer.position.y
        
        let scalAnimation = CABasicAnimation(keyPath: "transform.scale")
        scalAnimation.fromValue = 0.5
        scalAnimation.toValue = 1.0

        let transitionAndScale = CAAnimationGroup()
        transitionAndScale.fillMode = .removed
        transitionAndScale.isRemovedOnCompletion = true
        transitionAndScale.animations = [ transitionAnimation, scalAnimation]
        transitionAndScale.duration = 1.0
        collectionView.layer.add(transitionAndScale, forKey: nil)

    }

    func bindData(){
        historyViewModel.items.bindAndFire { [weak self] items in
            if items.count == 0{
                DispatchQueue.main.async {
                    self?.dismissHistory(animated: true, completion: nil)
                }
            }
            if items.count > 0{
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            }
        }
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
        if item.chatIsTop == IsTop.noTop.rawValue {
            cell.childView.backgroundColor = UIColor._lightGrayColor()
        }else{
            cell.childView.backgroundColor = UIColor._skyBlueColor()
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
            self.collectionView.performBatchUpdates{
                self.collectionView.deleteItems(at: [indexpath])
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
        GlobalMethod.showTtsAlert(viewController: self, chatItemModel: HistoryChatItemModel(chatItem: chatItem, idxPath: idx), hideMenuButton: false, hideBottmSection: true, saveDataToDB: false, ttsAlertControllerDelegate: self)
    }
    
    func openTTTResultAlert(_ idx: IndexPath){
        let chatItem = historyViewModel.items.value[idx.item] as! ChatEntity
        let vc = AlertReusableViewController.init()
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
}


extension HistoryViewController:HistoryLayoutDelegate{
    func getHeightFrom(collectionView: UICollectionView, heightForRowIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let historyModel = historyViewModel.items.value[indexPath.item] as! ChatEntity
        let font = UIFont.systemFont(ofSize:17)
        
        let fromHeight = historyModel.textTranslated!.heightWithConstrainedWidth(width: width, font: font)
        let toHeight = historyModel.textNative!.heightWithConstrainedWidth(width: width, font: font)
        return 20 + fromHeight + 120 + toHeight + 40
    }
}

extension HistoryViewController : RetranslationDelegate{
    func showRetranslation(selectedLanguage: String) {
        let chatItem = selectedChatItemModel?.chatItem!
        let isTop = chatItem?.chatIsTop
        let nativeText = chatItem!.textNative
        let nativeLangName = chatItem!.textNativeLanguage!
        let targetLangName = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: selectedLanguage)?.name
        
        //TODO call websocket api for ttt
        let targetText = chatItem!.textTranslated
        
        let chatEntity =  ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangName, textNativeLanguage: nativeLangName, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isTop, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue)
        
        GlobalMethod.showTtsAlert(viewController: self, chatItemModel: HistoryChatItemModel(chatItem: chatEntity, idxPath: nil), hideMenuButton: true, hideBottmSection: true, saveDataToDB: true, ttsAlertControllerDelegate: self)
        self.historyViewModel.addItem(chatEntity)
    
    }
}

extension HistoryViewController : AlertReusableDelegate {
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
        self.present(controller, animated: true, completion: nil)
    }
    
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
        GlobalMethod.showTtsAlert(viewController: self, chatItemModel: chatItemModel!, hideMenuButton: true, hideBottmSection: true, saveDataToDB: false, ttsAlertControllerDelegate: self)
        self.historyViewModel.addItem(chatItemModel!.chatItem!)
    }
    
}

extension HistoryViewController: TtsAlertControllerDelegate{
    func itemAdded(_ chatItemModel: HistoryChatItemModel) {
        self.historyViewModel.addItem(chatItemModel.chatItem!)
    }
    
    func itemDeleted(_ chatItemModel: HistoryChatItemModel) {
        self.historyViewModel.removeItem(chatItemModel.idxPath!.item)
        self.collectionView.reloadItems(at: [chatItemModel.idxPath!])
    }
    
    func updatedFavourite(_ chatItemModel: HistoryChatItemModel) {
        self.historyViewModel.replaceItem(chatItemModel.chatItem!, chatItemModel.idxPath!.row)
        self.collectionView.reloadItems(at: [chatItemModel.idxPath!])
    }
}

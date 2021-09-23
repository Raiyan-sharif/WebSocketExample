//
//  HistoryViewController.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/6/21.
//

import UIKit

protocol HistoryViewControllerDelegates {
    func historyAllItemsDeleted()
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
        self.itemsToShowOnContextMenu.append(AlertItems(title: "pronunciation_practice".localiz(), imageName: "", menuType: .practice))
        self.itemsToShowOnContextMenu.append(AlertItems(title: "send_an_email".localiz(), imageName: "", menuType: .sendMail))
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
                    self?.dismiss(animated: true, completion: nil)
                    self?.delegate?.historyAllItemsDeleted()
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

        //TODO if fabourite

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
            self.openTTTResult(indexpath.item, isReOrRetranslation: false)
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
    
    func openTTTResult(_ item: Int, isReOrRetranslation: Bool){
        let chatItem = historyViewModel.items.value[item] as! ChatEntity
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTtsAlertController)as! TtsAlertController
        controller.nativeText = !isReOrRetranslation ? chatItem.textNative! : chatItem.textTranslated!
        controller.targetText = !isReOrRetranslation ? chatItem.textTranslated! : chatItem.textNative!
        controller.isReOrRetranslation = isReOrRetranslation
        controller.modalPresentationStyle = .fullScreen
        controller.isFromHistoryOrFavourite = true
        self.present(controller, animated: true, completion: nil)
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
                self.dismiss(animated: true, completion: nil )
                self.delegate?.historyDissmissed()
            }
            collectionView.layer.add(transitionAndScale, forKey: nil)
            CATransaction.commit()
        }
    }
    
    func gotoLanguageSelectVoice () {
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
        if UserDefaultsProperty<Bool>(kIsArrowUp).value == false{
            controller.isNative = 1
        }else{
            controller.isNative = 0
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
        
        //TODO call api for retranslation
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTtsAlertController)as! TtsAlertController
        controller.nativeText = chatItem!.textNative!
        controller.targetText = chatItem!.textTranslated!
        controller.isReOrRetranslation = true
        controller.modalPresentationStyle = .fullScreen
        controller.isFromHistoryOrFavourite = true
        self.present(controller, animated: true, completion: nil)
    }
}

extension HistoryViewController : AlertReusableDelegate {
    func onDeleteItem(chatItemModel: HistoryChatItemModel?) {}
    
    func updateFavourite(chatItemModel: HistoryChatItemModel) {
        PrintUtility.printLog(tag: "ContextMenu: ", text: "updateFavourite>>>")
        self.historyViewModel.items.value[chatItemModel.idxPath.row] = chatItemModel.chatItem!
        self.collectionView.reloadItems(at: [chatItemModel.idxPath])
    }
    
    func pronunciationPracticeTap(chatItemModel: HistoryChatItemModel?) {
        let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeViewController")as! PronunciationPracticeViewController
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    func transitionFromRetranslation(chatItemModel: HistoryChatItemModel?) {
        selectedChatItemModel = chatItemModel
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLanguageSelectVoice)as! LangSelectVoiceVC
        if UserDefaultsProperty<Bool>(kIsArrowUp).value == false{
            controller.isNative = 1
        }else{
            controller.isNative = 0
        }
        controller.retranslationDelegate = self
        controller.fromRetranslation = true
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    func transitionFromReverse(chatItemModel: HistoryChatItemModel?) {
        self.openTTTResult((chatItemModel?.idxPath.row)!, isReOrRetranslation: true)
    }
    
}

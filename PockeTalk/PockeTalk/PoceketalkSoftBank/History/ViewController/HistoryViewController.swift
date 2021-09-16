//
//  HistoryViewController.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/6/21.
//

import UIKit

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
            if items.count > 0{
                //Todo
                self?.collectionView.reloadData()
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
        cell.deleteItem = { [weak self] point in
            guard let `self`  = self else {
                return
            }
            let indexpath = collectionView.indexPathForItem(at: point)!
            self.historyViewModel.deleteHistory(indexpath.item)
            self.collectionView.performBatchUpdates{
                self.collectionView.deleteItems(at: [indexpath])
            }
        }

        cell.favouriteItem = { [weak self] point in
            guard let `self`  = self else {
                return
            }
            let indexpath = collectionView.indexPathForItem(at: point)!
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.item)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
            }
            collectionView.layer.add(transitionAndScale, forKey: nil)
            CATransaction.commit()
        }
    }
}


extension HistoryViewController:HistoryLayoutDelegate{
    func getHeightFrom(collectionView: UICollectionView, heightForRowIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let historyModel = historyViewModel.items.value[indexPath.item] as! ChatEntity
        let font = UIFont.systemFont(ofSize:17)
        
        let fromHeight = historyModel.textTranslated!.heightWithConstrainedWidth(width: width, font: font)
        let toHeight = historyModel.textNative!.heightWithConstrainedWidth(width: width, font: font)
        //        print(fromHeight)
        //        print(toHeight)
        return 20 + fromHeight + 120 + toHeight + 40
    }
}


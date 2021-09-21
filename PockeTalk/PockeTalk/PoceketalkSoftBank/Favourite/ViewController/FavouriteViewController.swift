import UIKit

protocol FavouriteViewControllerDelegates {
    func favouriteAllItemsDeleted()
}

class FavouriteViewController: BaseViewController {

    ///Favourite Layout to postion the cell
    let favouritelayout = FavouriteLayout()
    ///Collection View top constraint
    var topConstraintOfCV:NSLayoutConstraint!
    /// Ccolectionview Width constraint
    var widthConstraintOfCV:NSLayoutConstraint!

    var  isCollectionViewVisible = false
    var loclItems = [FavouriteModel]()
    var favouriteViewModel:FavouriteViewModeling!
    
    private(set) var delegate: FavouriteViewControllerDelegates?

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

    }
    
    func initDelegate<T>(_ vc: T) {
            self.delegate = vc.self as? FavouriteViewControllerDelegates
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

    func showCollectionView(){
        isCollectionViewVisible = true
        collectionView.scrollToItem(at: IndexPath(item: favouriteViewModel.items.value.count-1, section: 0), at: .bottom, animated: false)
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
    
    private var backBtn:UIButton!{
        let okBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        okBtn.setImage(UIImage(named: "btn_back_tempo.png"), for: UIControl.State.normal)
        okBtn.addTarget(self, action: #selector(actionBack), for: .touchUpInside)
        return okBtn
    }
    
    ///Move to next screeen
    @objc func actionBack () {
        self.dismiss(animated: true, completion: nil )
    }

    func bindData(){
        favouriteViewModel.items.bindAndFire { [weak self] items in
            if items.count == 0{
                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: nil)
                    self?.delegate?.favouriteAllItemsDeleted()
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
            self.collectionView.performBatchUpdates{
                self.collectionView.deleteItems(at: [indexpath])
            }
        }
        return cell
    }
}


extension FavouriteViewController:FavouriteLayoutDelegate{
    func getHeightFrom(collectionView: UICollectionView, heightForRowIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        let favouriteModel = favouriteViewModel.items.value[indexPath.item] as! ChatEntity
        let font = UIFont.systemFont(ofSize:17)
        
        let fromHeight = favouriteModel.textTranslated!.heightWithConstrainedWidth(width: width, font: font)
        let toHeight = favouriteModel.textNative!.heightWithConstrainedWidth(width: width, font: font)
        return 20 + fromHeight + 120 + toHeight + 40
    }
}


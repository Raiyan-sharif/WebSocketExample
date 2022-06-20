//
//  HistoryCell.swift
//  PockeTalk
//

import UIKit

class HistoryCell: UICollectionViewCell, UIGestureRecognizerDelegate, NibReusable {

    @IBOutlet weak var favouriteStackView: UIStackView!
    @IBOutlet weak var deleteStackView: UIStackView!
    @IBOutlet weak var favouriteLabel: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var favView: UIView!
    @IBOutlet weak var favImagView: UIImageView!
    @IBOutlet weak var deleteImgView: UIImageView!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var childView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bottomStackViewOfLabel: NSLayoutConstraint!
    @IBOutlet weak var favouriteRightBarBottom: NSLayoutConstraint!
    @IBOutlet weak var topStackViewOfLabel: NSLayoutConstraint!
    @IBOutlet weak var favouriteRightBarTop: NSLayoutConstraint!
    @IBOutlet weak var deleteStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var favouriteStackViewHeightConstraint: NSLayoutConstraint!
    //forces the system to do one layout pass
    var isHeightCalculated: Bool = false
    var initialColor:UIColor!

    /// Records the view's center for use as an offset while dragging
    var viewCenter: CGPoint!
    var initialCenter:CGPoint!
    var deleteItem:((_ point:CGPoint) -> ())?
    var favouriteItem:((_ tag:CGPoint) -> ())?
    var tappedItem:((_ point:CGPoint) -> ())?
    var longTappedItem:((_ point:CGPoint) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        favView.backgroundColor = .clear
        containerView.layer.shadowRadius = 10.0
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: -1)
        containerView.layer.cornerRadius = 30
        childView.layer.cornerRadius = 30
        childView.center = self.center
        favView.layer.cornerRadius = 2
        containerView.backgroundColor = initialColor

        let panGestureRecognizer = PanDirectionGestureRecognizer(direction: .horizontal, target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        self.childView.addGestureRecognizer(panGestureRecognizer)
        
        self.childView.backgroundColor = UIColor(patternImage: UIImage(named: "back_texture_white.png")!)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        tapGesture.delegate = self
        self.childView.isUserInteractionEnabled = true
        self.childView.addGestureRecognizer(tapGesture)
        
        let longTapGesture : UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        longTapGesture.minimumPressDuration = 0.2
        longTapGesture.delegate = self
        longTapGesture.delaysTouchesBegan = true
        self.childView.addGestureRecognizer(longTapGesture)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        changeFontSize()
        // Improve scrolling performance with an explicit shadowPath
//        containerView.layer.shadowPath = UIBezierPath(
//            roundedRect: containerView.bounds,
//                    cornerRadius: 20
//                ).cgPath
    }
    
    @objc func handleTap(recognizer:UITapGestureRecognizer) {
        self.tappedItem?(self.center)
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state == UIGestureRecognizer.State.ended){
            self.longTappedItem?(self.center)
        }
        
    }

    @objc func handlePanGesture(_ pan: UIPanGestureRecognizer) {
        let target = pan.view
        let panViewMinX = pan.view?.frame.minX ?? 0.0
        
        switch pan.state {
        case .began:
            viewCenter = target?.center
            initialCenter = target?.center
            
            if !PanGestureDetection.shareInstance.isEnabble {
                PanGestureDetection.shareInstance.isEnabble = true
                pan.state = .cancelled
            }else{
                PanGestureDetection.shareInstance.isEnabble = false
            }
            if panViewMinX > 0 {
                showHideStackView(isDeleteStackViewHidden: true, isFavouriteStackViewHidden: false)
            }else{
                showHideStackView(isDeleteStackViewHidden: false, isFavouriteStackViewHidden: true)
            }
            
        case .changed:
            let translation = pan.translation(in: self)
            target!.center = CGPoint(x: viewCenter!.x + translation.x, y: viewCenter!.y)
            
            if panViewMinX > 0{
                showHideStackView(isDeleteStackViewHidden: true, isFavouriteStackViewHidden: false)
            } else {
                showHideStackView(isDeleteStackViewHidden: false, isFavouriteStackViewHidden: true)
            }
            
        case .ended:
            let translationX = abs(pan.translation(in: self).x)
            
            if translationX > childView.bounds.width/2 {
                if panViewMinX > 0  {
                    ///Favorite limit check, Favorite icon check on swipe action
                    let favoriteLimitFlag = UserDefaultsProperty<Bool>("FAVORITE_LIMIT_FLAG_KEY").value ?? false
                    if !favoriteLimitFlag {
                        favImagView.tintColor = .yellow
                    }
                    favView.backgroundColor = .orange
                    target!.center = CGPoint(x:self.bounds.maxX*2, y: viewCenter!.y)
                    self.favouriteItem?(self.center)
                }else{
                    target!.center = CGPoint(x: -self.bounds.maxX*2, y: viewCenter!.y)
                    self.deleteItem?(self.center)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                    target?.center = self.initialCenter
                })
            }else{
                containerView.backgroundColor = initialColor
                target?.center = self.initialCenter
            }
            PanGestureDetection.shareInstance.isEnabble = true
        default: break
        }
    }
    
    func showAsFavourite(){
        favView.isHidden = false
        favImagView.layer.cornerRadius = 30
        favImagView.tintColor = .yellow
        favView.backgroundColor = UIColor._mangoColor()
    }
    func hideFavourite(){
        favView.isHidden = true
        favImagView.layer.cornerRadius = 30
        favImagView.tintColor = .white
        favView.backgroundColor = .white
    }
    
    private func showHideStackView(isDeleteStackViewHidden: Bool, isFavouriteStackViewHidden: Bool) {
        deleteStackView.isHidden = isDeleteStackViewHidden
        favouriteStackView.isHidden = isFavouriteStackViewHidden
        isDeleteStackViewHidden ? (containerView.backgroundColor = UIColor._mangoColor()) :
                                  (containerView.backgroundColor = UIColor._pastelRedColor())
    }
}

enum PanDirection {
    case vertical
    case horizontal
}

class PanDirectionGestureRecognizer: UIPanGestureRecognizer {

    let direction: PanDirection

    init(direction: PanDirection, target: AnyObject, action: Selector) {
        self.direction = direction
        super.init(target: target, action: action)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        if state == .began {
            let vel = velocity(in: view)
            switch direction {
            case .horizontal where abs(vel.y) > abs(vel.x):
                state = .cancelled
            case .vertical where abs(vel.x) > abs(vel.y):
                state = .cancelled
            default:
                break
            }
        }
    }
}

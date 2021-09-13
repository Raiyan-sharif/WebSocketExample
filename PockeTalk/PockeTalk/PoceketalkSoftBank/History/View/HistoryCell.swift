//
//  HistoryCell.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/6/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit

class HistoryCell: UICollectionViewCell,NibReusable {

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

    //forces the system to do one layout pass
    var isHeightCalculated: Bool = false

    /// Records the view's center for use as an offset while dragging
    var viewCenter: CGPoint!
    var initialCenter:CGPoint!
    var deleteItem:((_ point:CGPoint) -> ())?
    var favouriteItem:((_ tag:CGPoint) -> ())?

    override func awakeFromNib() {
        super.awakeFromNib()
        favView.backgroundColor = .clear
        containerView.layer.shadowRadius = 10.0
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 5)
//        containerView.dropShadow(color: .black, opacity: 0.5, offSet: CGSize(width: 0, height: 5), radius: 10, scale: true)
        childView.layer.cornerRadius = 20
        childView.center = self.center
        favView.layer.cornerRadius = 2

        let panGestureRecognizer = PanDirectionGestureRecognizer(direction: .horizontal, target: self, action: #selector(handlePanGesture(_:)))
        panGestureRecognizer.cancelsTouchesInView = false
        self.childView.addGestureRecognizer(panGestureRecognizer)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        // Improve scrolling performance with an explicit shadowPath
        containerView.layer.shadowPath = UIBezierPath(
            roundedRect: containerView.bounds,
                    cornerRadius: 20
                ).cgPath
    }

    @objc func handlePanGesture(_ pan: UIPanGestureRecognizer) {
       // let percent = max(pan.translation(in: self).x, 0) / self.frame.width
        let target = pan.view
        let velocity = pan.velocity(in: self)
        switch pan.state {
        case .began:
            viewCenter = target?.center
            initialCenter = target?.center
            if velocity.x > 0 {
                deleteStackView.isHidden = true
                favouriteStackView.isHidden = false
                containerView.backgroundColor = UIColor._mangoColor()
            }else{
                deleteStackView.isHidden = false
                favouriteStackView.isHidden = true
                containerView.backgroundColor = UIColor._pastelRedColor()
            }
        case .changed:
            let translation = pan.translation(in: self)
            target!.center = CGPoint(x: viewCenter!.x + translation.x, y: viewCenter!.y)
        case .ended:
            let translation = pan.translation(in: self)
            let translationX = abs(translation.x)
            if translationX > childView.bounds.width/2 {
                if velocity.x > 0 {
                    favouriteLabel.textColor = .orange
                    favImagView.tintColor = UIColor.orange
                    favView.backgroundColor = .orange
                    target!.center = CGPoint(x:self.bounds.maxX*2, y: viewCenter!.y)
                    self.favouriteItem?(initialCenter)
                }else{
                    target!.center = CGPoint(x: -self.bounds.maxX*2, y: viewCenter!.y)
                    self.deleteItem?(initialCenter)
                }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.2, execute: {
                    target?.center = self.initialCenter
                })
            }else{
                target?.center = self.initialCenter
            }
        default: break
        }
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


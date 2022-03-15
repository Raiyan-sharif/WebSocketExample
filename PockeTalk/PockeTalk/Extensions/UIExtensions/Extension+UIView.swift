//
//  Extension+UIView.swift
//  PockeTalk
//

import Foundation
import UIKit

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
         let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
         let mask = CAShapeLayer()
         mask.path = path.cgPath
         layer.mask = mask
     }
    
    func changeFontSize(){
        let fontSize = FontUtility.getFontSize()
        if let view = self as? UIButton {
            view.titleLabel?.font = view.titleLabel?.font.withSize(fontSize)
        } else if let view = self as? UILabel {
            view.font = view.font.withSize(fontSize)
        } else if let view = self as? UITextField {
            view.font = view.font?.withSize(fontSize)
        } else {
            for view in subviews {
                view.changeFontSize()
            }
        }
    }
    
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
    
    func bottomImageView(usingState: BottomImageViewState){
        let imageView = UIImageView()
        imageView.isUserInteractionEnabled = false
        imageView.frame = CGRect(
            x: self.frame.minX - 5,
            y: self.frame.maxY - HomeViewController.homeVCBottomViewHeight,
            width: self.frame.width + 10,
            height: HomeViewController.homeVCBottomViewHeight + 5
        )

        switch usingState {
            case .gradient:
                imageView.image = UIImage(named: "bottomBackgroudImage")
            case .black:
                imageView.image = UIImage(named: "blackView")
            case .hidden:
                imageView.image = UIImage()
        }
        self.addSubview(imageView)
    }
}

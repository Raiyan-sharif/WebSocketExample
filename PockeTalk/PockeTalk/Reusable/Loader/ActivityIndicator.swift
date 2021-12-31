//
//  ActivityIndicator.swift
//  PockeTalk
//

import Foundation
import UIKit

@objc open class ActivityIndicator: NSObject {
    var container: UIView = UIView()
    let loadingIndicator: CustomLoaderProgressView = {
        let progress = CustomLoaderProgressView(colors: [.white], widthOfLine: 5)
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()
    
    @objc func showLoading(view: UIView?) {
        if let view = view {
            container.frame = view.frame
            container.center = view.center
            container.backgroundColor =  UIColorFromHex(rgbValue: 0xffffff, alpha: 0)
            view.addSubview(container)
            container.addSubview(loadingIndicator)
            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor
                    .constraint(equalTo: container.centerXAnchor),
                loadingIndicator.centerYAnchor
                    .constraint(equalTo: container.centerYAnchor),
                loadingIndicator.widthAnchor
                    .constraint(equalToConstant: 50),
                loadingIndicator.heightAnchor
                    .constraint(equalTo: loadingIndicator.widthAnchor)
            ])
            loadingIndicator.isAnimating = true
        }
        
    }
    
    @objc func hideLoading() {
            DispatchQueue.main.async { [self] in
                self.loadingIndicator.isAnimating = false
                container.removeFromSuperview()
            }
    }
    
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    

}

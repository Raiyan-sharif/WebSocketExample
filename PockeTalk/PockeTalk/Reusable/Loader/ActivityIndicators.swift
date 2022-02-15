//
//  ActivityIndicator.swift
//  PockeTalk
//

import Foundation
import UIKit

@objc open class ActivityIndicators: NSObject {
    public static let sharedInstance = ActivityIndicators()
    var container: UIView = UIView()
    let window = UIApplication.shared.keyWindow ?? UIWindow()
    let loadingIndicator: CustomLoaderProgressView = {
        let progress = CustomLoaderProgressView(colors: [.white], widthOfLine: 3)
        progress.translatesAutoresizingMaskIntoConstraints = false
        return progress
    }()

    private override init() {
        super.init()
    }

    @objc private func showLoading() {
        DispatchQueue.main.async { [self] in
            container.frame = UIScreen.main.bounds //view.frame
            container.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
            container.backgroundColor =  .clear

            container.tag = activityIndictorViewTag
            window.addSubview(container)
            container.addSubview(loadingIndicator)

            NSLayoutConstraint.activate([
                loadingIndicator.centerXAnchor
                    .constraint(equalTo: container.centerXAnchor),
                loadingIndicator.centerYAnchor
                    .constraint(equalTo: container.centerYAnchor),
                loadingIndicator.widthAnchor
                    .constraint(equalToConstant: 110),
                loadingIndicator.heightAnchor
                    .constraint(equalTo: loadingIndicator.widthAnchor)
            ])
            loadingIndicator.isAnimating = true
        }
    }

    @objc private func hideLoading() {
        DispatchQueue.main.async { [self] in
            self.loadingIndicator.isAnimating = false
            container.removeFromSuperview()
        }
    }

    private func isActivityIndicatorExistOnWindow() -> Bool{
        guard let activityIndicator = window.viewWithTag(activityIndictorViewTag) else {return false}

        if window.subviews.contains(activityIndicator) {
            return true
        } else {
            return false
        }
    }

    func show(){
        if !isActivityIndicatorExistOnWindow(){
            showLoading()
        } else {
            hideLoading()
            showLoading()
        }
    }

    func hide(){
        if isActivityIndicatorExistOnWindow(){
            hideLoading()
        }
    }
}

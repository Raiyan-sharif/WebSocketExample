//
//  ActivityIndicator.swift
//  PockeTalk
//

import UIKit

open class ActivityIndicator: NSObject{
    public static let sharedInstance = ActivityIndicator()
    private let container: UIView = UIView()
    var window = UIApplication.shared.keyWindow ?? UIWindow()

    let activityIndicator: ActivityIndicatorView = {
        let progressView = ActivityIndicatorView(
           frame: .zero,
           color: .white,
           padding: loaderPadding,
           lineWidth: loaderLineWidth)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        return progressView
    }()

    private override init() {
        super.init()
    }

    private func showLoading(_ hasBackground: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.container.frame = UIScreen.main.bounds
            self.container.center = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)

            hasBackground ? (self.container.backgroundColor =  UIColor._loaderBackgroundColor()) : (self.container.backgroundColor =  .clear)

            self.container.tag = activityIndictorViewTag
            self.window.addSubview(self.container)
            self.container.addSubview(self.activityIndicator)

            NSLayoutConstraint.activate([
                self.activityIndicator.widthAnchor.constraint(equalToConstant: loaderWidth),
                self.activityIndicator.heightAnchor.constraint(equalToConstant: loaderWidth),
                self.activityIndicator.centerXAnchor.constraint(equalTo: self.container.centerXAnchor),
                self.activityIndicator.centerYAnchor.constraint(equalTo: self.container.centerYAnchor)
            ])

            self.activityIndicator.startAnimating()
        }
    }

    private func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            self.container.removeFromSuperview()
            PrintUtility.printLog(tag: "activityIndicatorTAG:", text: "Function: hideLoading(), isLoaderExistOnWindow: \(self.isActivityIndicatorExistOnWindow()), isAnimationExist: \(self.activityIndicator.animating)")
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

    func show(hasBackground: Bool = true){
        if !isActivityIndicatorExistOnWindow() && !activityIndicator.animating{
            PrintUtility.printLog(tag: "activityIndicatorTAG:", text: "Function: show(if), isLoaderExistOnWindow: \(isActivityIndicatorExistOnWindow()), isAnimationExist: \(activityIndicator.animating)")
            showLoading(hasBackground)
        } else {
            PrintUtility.printLog(tag: "activityIndicatorTAG:", text: "Function: show(else), isLoaderExistOnWindow: \(isActivityIndicatorExistOnWindow()), isAnimationExist: \(activityIndicator.animating)")
            hideLoading()
            showLoading(hasBackground)
        }
    }

    func hide(){
        if isActivityIndicatorExistOnWindow(){
            hideLoading()
        }
        PrintUtility.printLog(tag: "activityIndicatorTAG:", text: "Function: hide(), isLoaderExistOnWindow: \(isActivityIndicatorExistOnWindow()), isAnimationExist: \(activityIndicator.animating)")
    }
}

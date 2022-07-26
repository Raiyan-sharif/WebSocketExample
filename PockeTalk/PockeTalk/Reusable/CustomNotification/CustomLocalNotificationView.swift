//
//  CustomNotificationView.swift
//  PockeTalk
//

import Foundation
import UIKit
import WebKit

protocol CustomLocalNotificationViewDelegate: AnyObject {
    func dismiss()
    func cancel()
    func retry()
}

class CustomLocalNotificationView: UIView, WKUIDelegate, WKNavigationDelegate {
    @IBOutlet weak private var contentView: UIView!
    @IBOutlet weak private var noInternetContainerView: UIView!
    @IBOutlet weak private var retryButton: UIButton!
    @IBOutlet weak private var cancelButton: UIButton!
    @IBOutlet weak private var dismissButton: UIButton!
    @IBOutlet weak private var noInternetTitleLabel: UILabel!
    @IBOutlet weak private var webContainerview: UIView!
    @IBOutlet weak private var webkitView: WKWebView!

    var notificationDelegate: CustomLocalNotificationViewDelegate?

    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("CustomLocalNotificationView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        noInternetTitleLabel.text = "No Internet"
        //noInternetTitleLabel.text = "internet_connection_error".localiz()
        //cancelButton.setTitle("cancel".localiz(), for: .normal)
        webkitView.navigationDelegate = self
        webkitView.backgroundColor = .clear
    }

    func viewWebContainer(isHidden: Bool) {
        webContainerview.isHidden = isHidden
        webkitView.isHidden = isHidden
    }

    func loadWebViewUsing(urlString: String) {
        let url = URL(string: urlString)
        webkitView.load(URLRequest(url: url!))
    }

    //MARK: - IBActions
    @IBAction private func dismissButtonEventListener(_ sender: UIButton) {
        self.notificationDelegate?.dismiss()
    }

    @IBAction private func cencelButtonEventListener(_ sender: UIButton) {
        self.notificationDelegate?.cancel()
    }

    @IBAction private func retryButtonEventListener(_ sender: UIButton) {
        self.notificationDelegate?.retry()
    }

    func webView(_ webView: WKWebView, didFinish  navigation: WKNavigation!)
    {
        let _ = webView.url?.absoluteString
        PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Did Finish Loading")
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        viewWebContainer(isHidden: true)
    }

}


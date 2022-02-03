//
//  LicenseInfoViewController.swift
//  PockeTalk
//

import UIKit
import WebKit

class LicenseInfoViewController: BaseViewController {

    @IBOutlet weak var labelTopBarTitle: UILabel!
    @IBOutlet weak var webView: WKWebView!

    private let TAG: String = "\(LicenseInfoViewController.self)"
    private let licenseInfoFileName = "text-license"
    private let licenseInfoFileExtension = "html"

    override func viewDidLoad() {
        super.viewDidLoad()
        PrintUtility.printLog(tag: TAG, text: "LicenseInfoViewController[+]")

        self.navigationController?.navigationBar.isHidden = true
        labelTopBarTitle.text = "license_info".localiz()

        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        guard let url = Bundle.main.url(forResource: licenseInfoFileName, withExtension: licenseInfoFileExtension) else { return }
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @IBAction func actionBack(_ sender: UIButton) {
        PrintUtility.printLog(tag: TAG, text: "actionBack from LicenseInfoViewController")
        if (self.navigationController == nil) {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

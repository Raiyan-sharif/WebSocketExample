//
//  IAPStatusCheckDummyLoadingViewController.swift
//  PockeTalk
//

import UIKit

class IAPStatusCheckDummyLoadingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ActivityIndicator.sharedInstance.show()
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ActivityIndicator.sharedInstance.hide()
    }
}

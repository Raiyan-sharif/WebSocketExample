//
//  IAPStatusCheckDummyLoadingViewController.swift
//  PockeTalk
//
//  Created by BJIT on 3/2/22.
//

import UIKit

class IAPStatusCheckDummyLoadingViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activityIndicator.stopAnimating()
    }
}

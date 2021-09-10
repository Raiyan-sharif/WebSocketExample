//
//  ViewController.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 8/31/21.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor._blackColor()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !Reachability.isConnectedToNetwork() {
            GlobalMethod.showAlert("No Internet conneciton")
        }
    }
}


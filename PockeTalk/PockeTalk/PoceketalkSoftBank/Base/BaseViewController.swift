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
        self.view.changeFontSize()
        self.view.backgroundColor = UIColor._blackColor()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

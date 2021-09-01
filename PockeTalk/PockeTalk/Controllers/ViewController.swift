//
//  ViewController.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 8/31/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var mLabelWelcome: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.mLabelWelcome.text = "Welcome to the PTLabo"
        // Do any additional setup after loading the view.
    }

}


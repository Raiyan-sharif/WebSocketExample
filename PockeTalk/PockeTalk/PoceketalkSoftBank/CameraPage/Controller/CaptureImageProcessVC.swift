//
//  CaptureImageProcessVC.swift
//  PockeTalk
//
//  Created by BJIT LTD on 6/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit

class CaptureImageProcessVC: UIViewController {

    @IBOutlet weak var cameraImageView: UIImageView!
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cameraImageView.image = image

        // Do any additional setup after loading the view.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @IBAction func backButtonEventListener(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
}

//
//  PronunciationPracticeResultViewController.swift
//  PockeTalk
//
//  Created by Khairuzzaman Shipon on 8/9/21.
//  Copyright © 2021 BJIT LTD All rights reserved.
//

import UIKit

class PronunciationPracticeResultViewController: BaseViewController {
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet var viewRoot: UIView!
    @IBOutlet weak var viewFailureContainer: UIView!
    @IBOutlet weak var labelFailedOriginalText: UILabel!
    @IBOutlet weak var labelFailedPronuncedText: UILabel!
    @IBOutlet weak var viewSuccessContainer: UIView!
    @IBOutlet weak var labelSuccessText: UILabel!
    let width : CGFloat = 50
    let trailing : CGFloat = -20
        
    @IBAction func actionBack(_ sender: Any) {
        self.showPronunciationPractice()
    }
    
    //TODO: need to replace with valid action
    @IBAction func actionReplay(_ sender: Any) {
        GlobalMethod.showAlert("TODO: Replay")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpUI()
    }
    
    // Initial UI set up
    func setUpUI () {
        self.setUpMicroPhoneIcon()
        self.viewContainer.layer.cornerRadius = 20
        self.viewContainer.layer.masksToBounds = true

        self.viewContainer.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)

    }
    
    // floating microphone button
    func setUpMicroPhoneIcon () {
        let floatingButton = UIButton()
        floatingButton.setImage(UIImage(named: "mic"), for: .normal)
        floatingButton.backgroundColor = UIColor._buttonBackgroundColor()
        floatingButton.layer.cornerRadius = width/2
        floatingButton.clipsToBounds = true
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: width).isActive = true
        floatingButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: trailing).isActive = true
        floatingButton.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor, constant: trailing).isActive = true
        floatingButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }
    
    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        let currentTS = GlobalMethod.getCurrentTimeStamp(with: 0)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SpeechProcessingViewController")as! SpeechProcessingViewController
        controller.homeMicTapTimeStamp = currentTS
        controller.isFromPronunciationPractice = true
        self.navigationController?.pushViewController(controller, animated: true);
    }
    
    func showPronunciationPractice () {
        let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeViewController")as! PronunciationPracticeViewController
        self.navigationController?.pushViewController(controller, animated: true);
    }
}

//
//  PronunciationPracticeViewController.swift
//  PockeTalk
//
//  Created by Khairuzzaman Shipon on 7/9/21.
//  Copyright © 2021 BJIT LTD All rights reserved.
//

import UIKit

class PronunciationPracticeViewController: BaseViewController {
    
    @IBOutlet weak var viewSpeechTextContainer: UIView!
    @IBOutlet weak var labelPronunciationGuideline: UILabel!
    @IBOutlet weak var btnBack: UIButton!
    let width : CGFloat = 50
    let trailing : CGFloat = -20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpUI()
    }
    
    // Initial UI set up
    func setUpUI () {
        self.setUpMicroPhoneIcon()
        self.labelPronunciationGuideline.text = "PronunciationGuideline".localiz()
        self.viewSpeechTextContainer.layer.cornerRadius = 20
        self.viewSpeechTextContainer.layer.masksToBounds = true

        self.viewSpeechTextContainer.backgroundColor = UIColor(patternImage: UIImage(named: "slider_back_texture_white.png")!)

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
    
    @IBAction func actionBack(_ sender: Any) {
        self.showHome()
    }
    
    func showHome () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "HomeViewController")as! HomeViewController
        self.navigationController?.pushViewController(controller, animated: true);
    }
}

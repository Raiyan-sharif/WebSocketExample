//
//  HomeViewController.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/1/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit

class HomeViewController: BaseViewController {

    //Views
    @IBOutlet weak var bottomLanguageNameButton: UIButton!
    @IBOutlet weak var languageChangedDirectionButton: UIButton!
    @IBOutlet weak var topLanguagePronouncedNameButton: UIButton!
    @IBOutlet weak var bottomFlipImageView: UIImageView!
    @IBOutlet weak var topFlipImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var directionImageView: UIImageView!
    @IBOutlet weak var topLanguageNameLabel: UILabel!

    //Properties
    var homeVM : HomeViewModel!
    var selected : Bool = false
    let FontSize : CGFloat = 23.0
    var animationCounter : Int = 0
    var deviceLanguage : String = ""
    let toastVisibleTime : Double = 2.0
    let animationDuration : TimeInterval = 1.0
    let trailing : CGFloat = -20
    let width : CGFloat = 50

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.homeVM = HomeViewModel()
        self.setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }

    // Initial UI set up
    func setUpUI () {
        if let lanCode = self.homeVM.getLanguageName() {
            self.deviceLanguage = lanCode
        }

        self.topLanguagePronouncedNameButton.setTitle("Japanese", for: .normal)
        self.topLanguagePronouncedNameButton.titleLabel?.textAlignment = .center
        self.topLanguagePronouncedNameButton.titleLabel?.font = UIFont.systemFont(ofSize: FontSize, weight: .bold)
        self.topLanguagePronouncedNameButton.setTitleColor(UIColor._whiteColor(), for: .normal)

        self.topLanguageNameLabel.text = "Japanese"
        self.topLanguageNameLabel.textAlignment = .center
        self.topLanguageNameLabel.font = UIFont.systemFont(ofSize: FontSize, weight: .bold)
        self.topLanguageNameLabel.textColor = UIColor._whiteColor()

        self.bottomLanguageNameButton.setTitle(deviceLanguage, for: .normal)
        self.bottomLanguageNameButton.titleLabel?.textAlignment = .center
        self.bottomLanguageNameButton.titleLabel?.font = UIFont.systemFont(ofSize: FontSize, weight: .bold)
        self.bottomLanguageNameButton.setTitleColor(UIColor._whiteColor(), for: .normal)
        self.setUpMicroPhoneIcon()
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

    //TODO Menu tap event
    @IBAction func menuAction(_ sender: UIButton) {
        self.showToast(message: kMenuActionToastMessage, seconds: toastVisibleTime)
    }

    // This method is called
    @IBAction func switchLanguageDirectionAction(_ sender: UIButton) {
        if selected == true {
            selected = false
            self.directionImageView.image = UIImage(named: "down_arrow")
            self.animationChange(transitionToImageView: self.topFlipImageView, transitionFromImageView: self.bottomFlipImageView, animationOption: UIView.AnimationOptions.transitionFlipFromBottom, imageName: "gradient_blue_top_bg")

        } else {
            selected = true
            self.directionImageView.image = UIImage(named: "up_arrow")
            self.animationChange(transitionToImageView: self.bottomFlipImageView, transitionFromImageView: self.topFlipImageView, animationOption: UIView.AnimationOptions.transitionFlipFromTop, imageName: "gradient_blue_bottom_bg")
        }
    }

    func animationChange (transitionToImageView : UIImageView, transitionFromImageView : UIImageView, animationOption : UIView.AnimationOptions, imageName : String ){
        UIView.transition(with: transitionFromImageView,
                          duration: animationDuration,
                          options: animationOption,
                          animations: {
                            transitionToImageView.isHidden = false
                            transitionFromImageView.isHidden = true
                            transitionToImageView.image = UIImage(named: imageName)
                          }, completion: nil)
    }

    // TODO navigate to language selection page
    @IBAction func topLanguageBtnAction(_ sender: UIButton) {
        self.showToast(message: kTopLanguageButtonActionToastMessage, seconds: toastVisibleTime)
    }

    // TODO navigate to language selection page
    @IBAction func bottomLanguageBtnAction(_ sender: UIButton) {
        self.showToast(message: kBottomLanguageButtonActionToastMessage, seconds: toastVisibleTime)
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        self.showToast(message: "Navigate to Speech Controller", seconds: toastVisibleTime)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//
// TtsAlertController.swift
// PockeTalk
//
// Created by Shymosree on 9/8/21.
// Copyright © 2021 BJIT Inc. All rights reserved.
//

import UIKit

class TtsAlertController: UIViewController {
    ///Views
    @IBOutlet weak var toTranslateLabel: UILabel!
    @IBOutlet weak var fromTranslateLabel: UILabel!
    @IBOutlet weak var changeTranslationButton: UIButton!
    @IBOutlet weak var fromLanguageLabel: UILabel!
    @IBOutlet weak var toLanguageLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var containerView: UIView!

    ///Properties
    var ttsVM : TtsAlertViewModel!
    let cornerRadius : CGFloat = 15
    let fontSize : CGFloat = 20
    let trailing : CGFloat = -20
    let width : CGFloat = 40
    let toastVisibleTime : CGFloat = 2.0
    var nativeLanguage : String = ""
    var targetLanguage : String = ""
    var delegate : SpeechControllerDismissDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.ttsVM = TtsAlertViewModel()
        let language = self.ttsVM.getLanguage()
        if let nativeLangName = language.nativaLanguage?.name {
            nativeLanguage = nativeLangName
        }

        if let targetLangName = language.targetLanguage?.name {
            targetLanguage = targetLangName
        }
        self.setUpUI()
    }

    /// Initial UI set up
    func setUpUI () {
        self.containerView.layer.masksToBounds = true
        self.containerView.layer.cornerRadius = cornerRadius

        self.toLanguageLabel.text = NSLocalizedString("TtsToLanguage", comment: "")
        self.toLanguageLabel.textAlignment = .center
        self.toLanguageLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.toLanguageLabel.textColor = UIColor._blackColor()

        self.fromLanguageLabel.text = NSLocalizedString("TtsFromLanguage", comment: "")
        self.fromLanguageLabel.textAlignment = .center
        self.fromLanguageLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.fromLanguageLabel.textColor = UIColor.gray

        self.toTranslateLabel.text = targetLanguage
        self.toTranslateLabel.textAlignment = .right
        self.toTranslateLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.toTranslateLabel.textColor = UIColor.gray

        self.fromTranslateLabel.text = nativeLanguage
        self.fromTranslateLabel.textAlignment = .left
        self.fromTranslateLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.fromTranslateLabel.textColor = UIColor._whiteColor()

        let floatingButton = GlobalMethod.setUpMicroPhoneIcon(view: self.view, width: width, height: width, trailing: trailing, bottom: trailing)
        floatingButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }

    //Dismiss view on back button press
    @IBAction func dismissView(_ sender: UIButton) {
        self.delegate?.dismiss()
        self.dismiss(animated: true, completion: nil)
    }

    // TODO microphone tap event
    @objc func microphoneTapAction (sender:UIButton) {
        self.showToast(message: "Navigate to Speech Controller", seconds: Double(toastVisibleTime))
    }

    fileprivate func updateLanguageNames() {
        print("\(HomeViewController.self) updateLanguageNames method called")
        let languageManager = LanguageSelectionManager.shared
        let nativeLangCode = languageManager.nativeLanguage
        let targetLangCode = languageManager.targetLanguage

        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        print("\(HomeViewController.self) updateLanguageNames nativeLanguage \(String(describing: nativeLanguage)) targetLanguage \(String(describing: targetLanguage))")
        self.fromTranslateLabel.text = nativeLanguage?.name
        self.toTranslateLabel.text = targetLanguage?.name
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

//
//  LnaguageSettingsTutorialCameraVC.swift
//  PockeTalk
//

import UIKit

//MARK: - LnaguageSettingsTutorialCameraProtocol
protocol LnaguageSettingsTutorialCameraProtocol: AnyObject{
    func updateLanguageByVoice(isFromSTT: Bool)
}

class LnaguageSettingsTutorialCameraVC: BaseViewController {
    @IBOutlet weak private var toolbarTitleLabel: UILabel!
    @IBOutlet weak private var guidelineTextLabel: UILabel!
    weak var delegate: LnaguageSettingsTutorialCameraProtocol?

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbarTitleLabel.text = "Language Settings".localiz()
        guidelineTextLabel.text = "Speech Guideline".localiz()
        registerNotification()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        PrintUtility.printLog(tag: TagUtility.sharedInstance.cameraScreenPurpose, text: "\(ScreenTracker.sharedInstance.screenPurpose)")
    }

    //MARK: - Initial setup
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(notification:)), name: .cameraLanguageSettingsListNotification, object: nil)
    }

    //MARK: - IBActions
    @IBAction func onBackPressed(_ sender: Any) {
        removeVC(isFromSTT: false)
    }

    //MARK: - Utils
    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name: .cameraLanguageSettingsListNotification, object: nil)
    }

    @objc func updateUI(notification: Notification) {
        removeVC(isFromSTT: true)
    }

    private func removeVC(isFromSTT: Bool){
        delegate?.updateLanguageByVoice(isFromSTT: isFromSTT)
        remove(asChildViewController: self)
    }
}

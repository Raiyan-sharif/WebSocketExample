//
//  LanguageSettingsTutorialVC.swift
//  PockeTalk
//

import UIKit

//MARK: - LanguageSettingsProtocol
protocol LanguageSettingsTutorialProtocol: AnyObject{
    func updateLanguageByVoice()
    func updateCountryByVoice(selectedCountry: String)
}

//MARK: - Protocol extension - providing methods default implementation
extension LanguageSettingsTutorialProtocol{
    func updateLanguageByVoice(){}
    func updateCountryByVoice(selectedCountry: String){}
}

class LanguageSettingsTutorialVC: BaseViewController {
    @IBOutlet weak private var toolbarTitleLabel: UILabel!
    @IBOutlet weak private var guidelineTextLabel: UILabel!
    
    var isFromLanguageScene: Bool = false
    weak var delegate: LanguageSettingsTutorialProtocol?
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        registerNotification()
    }
    
    deinit{
        unregisterNotification()
    }
    
    //MARK: - Initial setup
    private func setupUI(){
        if isFromLanguageScene{
            toolbarTitleLabel.text = "Language Settings".localiz()
            guidelineTextLabel.text = "Speech Guideline".localiz()
        } else {
            toolbarTitleLabel.text = "Language Settings".localiz()
            guidelineTextLabel.text = "Country Speech Guideline".localiz()
        }
    }
    
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateUI(notification:)), name: .languageSettingsListNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCountrySelection(notification:)), name: .countySettingsSlectionByVoiceNotofication, object: nil)
    }
    
    //MARK: - IBActions
    @IBAction func onBackPressed(_ sender: Any) {
        removeVC()
    }
    
    //MARK: - Utils
    private func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name: .languageSettingsListNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .countySettingsSlectionByVoiceNotofication, object: nil)
    }
    
    @objc func updateUI(notification: Notification) {
        removeVC()
    }
    
    @objc func updateCountrySelection(notification: Notification) {
        if let country = notification.userInfo!["country"] as? String{
            removeVC(selectedCountry: country)
        }
    }
    
    private func removeVC(selectedCountry: String = ""){
        isFromLanguageScene ? (delegate?.updateLanguageByVoice()) : (delegate?.updateCountryByVoice(selectedCountry: selectedCountry))
        remove(asChildViewController: self)
    }
}

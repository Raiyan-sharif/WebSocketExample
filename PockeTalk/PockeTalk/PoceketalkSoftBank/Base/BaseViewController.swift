//
//  ViewController.swift
//  PockeTalk
//

import UIKit
enum SpeechProcessingScreenOpeningPurpose{
    case HomeSpeechProcessing
    
    case LanguageSelectionVoice
    case LanguageHistorySelectionVoice
    case LanguageSettingsSelectionVoice
    case CountrySelectionByVoice
    case CountrySettingsSelectionByVoice
    case countryWiseLanguageList
    
    case LanguageSelectionCamera
    case LanguageHistorySelectionCamera
    case LanguageSettingsSelectionCamera
    
    case CameraScreen
    case PronunciationPractice
    case HistoryScrren
    case HistroyPronunctiation
    case FavouriteScreen
    case PurchasePlanScreen
    case InitialFlow
    case WalkThroughViewController
}

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.changeFontSize()
        self.view.backgroundColor = UIColor._blackColor()
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .bottmViewGestureNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.post(name: .bottmViewGestureNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: .bottmViewGestureNotification, object: nil)
    }
}

class ScreenTracker {
    static let sharedInstance = ScreenTracker()
    private init() { }
    var screenPurpose: SpeechProcessingScreenOpeningPurpose = .HomeSpeechProcessing
}

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
    
    case LanguageSelectionCamera
    case LanguageHistorySelectionCamera
    case LanguageSettingsSelectionCamera
    
    case PronunciationPractice
    case HistoryScrren
    case HistroyPronunctiation
    case FavouriteScreen
}

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

//
//  ViewController.swift
//  PockeTalk
//

import UIKit
enum SpeechProcessingScreenOpeningPurpose{
    case HomeSpeechProcessing
    case LanguageSelectionVoice
    case LanguageHistorySelectionVoice
    case CountrySelectionByVoice
    case LanguageSelectionCamera
    case LanguageHistorySelectionCamera
    case PronunciationPractice
    case HistoryScrren
    case HistroyPronunctiation
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
        super.viewDidAppear(animated)
    }
}

class ScreenTracker {
    static let sharedInstance = ScreenTracker()
    private init() { }
    var screenPurpose: SpeechProcessingScreenOpeningPurpose = .HomeSpeechProcessing
}

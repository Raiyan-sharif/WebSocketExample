//
//  LanguageSettingsTutorialVC.swift
//  PockeTalk
//

import UIKit

class LanguageSettingsTutorialVC: BaseViewController {

    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBOutlet weak var toolbarTitleLabel: UILabel!

    @IBOutlet weak var guidelineTextLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        toolbarTitleLabel.text = "Language Settings".localiz()
        guidelineTextLabel.text = "Speech Guideline".localiz()
        // Do any additional setup after loading the view.
    }

    static func openShowViewController(navigationController: UINavigationController?){
        //self.showToast(message: "Show country selection screen", seconds: toastVisibleTime)
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LanguageSettingsTutorialVC")as! LanguageSettingsTutorialVC
        navigationController?.pushViewController(controller, animated: true);
    }
}

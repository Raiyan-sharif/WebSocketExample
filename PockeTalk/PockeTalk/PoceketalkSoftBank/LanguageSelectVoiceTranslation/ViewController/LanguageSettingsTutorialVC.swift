//
//  LanguageSettingsVC.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 9/9/21.
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    static func openShowViewController(navigationController: UINavigationController?){
        //self.showToast(message: "Show country selection screen", seconds: toastVisibleTime)
        let storyboard = UIStoryboard(name: "LanguageSelectVoice", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LanguageSettingsTutorialVC")as! LanguageSettingsTutorialVC
        navigationController?.pushViewController(controller, animated: true);
    }
}

//
//  LnaguageSettingsTutorialCameraVC.swift
//  PockeTalk
//
//  Created by BJIT on 10/11/21.
//

import UIKit

class LnaguageSettingsTutorialCameraVC: BaseViewController {

    @IBAction func onBackPressed(_ sender: Any) {
        // TODO: Remove micrphone functionality as per current requirement. Will modify after final confirmation.
        //NotificationCenter.default.post(name: .popFromCameralanguageSelectionVoice, object: nil)
        
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
        let storyboard = UIStoryboard(name: "LanguageSelectCamera", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LnaguageSettingsTutorialCameraVC")as! LnaguageSettingsTutorialCameraVC
        navigationController?.pushViewController(controller, animated: true);
    }

}

//
//  WelcomeViewController.swift
//  PockeTalk
//
//  Created by BJIT on 3/1/22.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabelTop: UILabel!
    @IBOutlet weak var titleLabelBottom: UILabel!
    @IBOutlet weak var startUsingButton: UIButton!
    
    func initialUISetUp() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        titleLabelTop.text = "kWelcomeVCTitleLabelTop".localiz()
        titleLabelBottom.text = "kWelcomeVCTitleLabelBottom".localiz()
        startUsingButton.setTitle("kWelcomeVCStartUsingButtonTitle".localiz(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetUp()
    }
    
    @IBAction func startUsingButtonAction(_ sender: Any) {
        UserDefaultsUtility.setBoolValue(false, forKey: kIsClearedDataAll)
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let homeViewController = mainStoryBoard.instantiateViewController(withIdentifier: String(describing: HomeViewController.self)) as? HomeViewController {
            let transition = CATransition()
            transition.duration = kSettingsScreenTransitionDuration
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(homeViewController, animated: false)
        }
    }
}

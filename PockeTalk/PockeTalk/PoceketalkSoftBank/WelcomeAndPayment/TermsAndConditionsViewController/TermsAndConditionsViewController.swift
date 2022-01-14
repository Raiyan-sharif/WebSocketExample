//
//  TermsAndConditionsViewController.swift
//  PockeTalk
//
//  Created by BJIT on 4/1/22.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bulletPointOneLabel: UILabel!
    @IBOutlet weak var bulletPointTwoLabel: UILabel!
    @IBOutlet weak var checkTermsButton: UIButton!
    @IBOutlet weak var acceptTermsButton: UIButton!
    
    let yourAttributes: [NSAttributedString.Key: Any] = [
          .font: UIFont.systemFont(ofSize: 17),
          .foregroundColor: UIColor.black,
          .underlineStyle: NSUnderlineStyle.single.rawValue
      ]
    
    func initialUISetUp() {
        titleLabel.text = "kTermsAndConditionsVCTitle".localiz()
        bulletPointOneLabel.text = "kTermsAndConditionsVCBulletPointOneTitle".localiz()
        bulletPointTwoLabel.text = "kTermsAndConditionsVCBulletPointTwoTitle".localiz()
        acceptTermsButton.setTitle("kTermsAndConditionsVCAcceptTermsButtonButtonTitle".localiz(), for: .normal)
        
        let attributeString = NSMutableAttributedString(
                string: "kTermsAndConditionsVCCheckTermsButtonTitle".localiz(),
                attributes: yourAttributes
             )
        checkTermsButton.setAttributedTitle(attributeString, for: .normal)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetUp()
    }
    
    @IBAction func checkTermsButtonAction(_ sender: Any) {
        let settingsUrl = NSURL(string:TERMS_AND_CONDITIONS_URL)! as URL
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }
    
    @IBAction func acceptTermsButtonAction(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let initialPermissionSettingsViewController = mainStoryBoard.instantiateViewController(withIdentifier: String(describing: InitialPermissionSettingsViewController.self)) as? InitialPermissionSettingsViewController {
            let transition = CATransition()
            transition.duration = kSettingsScreenTransitionDuration
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(initialPermissionSettingsViewController, animated: false)
        }
    }
}

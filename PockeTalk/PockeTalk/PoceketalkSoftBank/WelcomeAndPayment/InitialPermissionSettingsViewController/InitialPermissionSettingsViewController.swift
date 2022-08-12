//
//  InitialPermissionSettingsViewController.swift
//  PockeTalk
//
//  Created by BJIT on 3/1/22.
//

import UIKit

class InitialPermissionSettingsViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var microphoneLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var micIconImageView: UIImageView!
    @IBOutlet weak var cameraIconImageView: UIImageView!
    @IBOutlet weak var notificationIconImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!

    func nextButtonUI() {
        nextButton.layer.cornerRadius = 10
        nextButton.layer.borderColor = UIColor.black.cgColor
        nextButton.layer.borderWidth = 1.0
    }

    func initialUISetUp() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        nextButtonUI()
        titleLabel.text = "kInitialPermissionSettingsVCTitle".localiz()
        microphoneLabel.text = "kInitialPermissionSettingsVCMicrophoneLabel".localiz()
        cameraLabel.text = "kInitialPermissionSettingsVCCameraLabel".localiz()
        notificationLabel.text = "kInitialPermissionSettingsVCNotificationLabel".localiz()
        nextButton.setTitle("kNextButtonTitle".localiz(), for: .normal)
    }

    func checkPermissions() {
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)

        dispatchQueue.async {
            AppsPermissionCheckingManager.shared.checkPermissionFor(permissionTypes: .microphone) { (isPermissionOn, _) in
                DispatchQueue.main.async {
                    if isPermissionOn == true {
                        self.micIconImageView.image = UIImage(named: "check-markIcon")
                    } else {
                        self.micIconImageView.image = UIImage(named: "questionIcon")
                    }
                }
                semaphore.signal()
            }
            semaphore.wait()

            AppsPermissionCheckingManager.shared.checkPermissionFor(permissionTypes: .camera) { (isPermissionOn, _) in
                DispatchQueue.main.async {
                    if isPermissionOn == true {
                        self.cameraIconImageView.image = UIImage(named: "check-markIcon")
                    } else {
                        self.cameraIconImageView.image = UIImage(named: "questionIcon")
                    }
                }
                semaphore.signal()
            }
            semaphore.wait()

            AppsPermissionCheckingManager.shared.checkPermissionFor(permissionTypes: .notification) { (isPermissionOn, _) in
                DispatchQueue.main.async {
                    if isPermissionOn == true {
                        self.notificationIconImageView.image = UIImage(named: "check-markIcon")
                    } else {
                        self.notificationIconImageView.image = UIImage(named: "questionIcon")
                    }
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetUp()
        checkPermissions()
    }
    
    @IBAction func nextButtonAction(_ sender: Any) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        if let paidPlanViewController = mainStoryBoard.instantiateViewController(withIdentifier: String(describing: PaidPlanViewController.self)) as? PaidPlanViewController {
            let transition = CATransition()
            transition.duration = kSettingsScreenTransitionDuration
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromRight
            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(paidPlanViewController, animated: false)
        }
    }
}

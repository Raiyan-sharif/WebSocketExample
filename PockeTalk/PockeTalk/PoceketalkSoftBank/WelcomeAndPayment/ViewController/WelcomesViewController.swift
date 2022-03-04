//
//  WelcomesViewController.swift
//  PockeTalk
//

import UIKit

class WelcomesViewController: UIViewController {
    @IBOutlet weak private var nextBtn: UIButton!

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    //MARK: - Initial setup
    private func setupUI() {
        setupView()
        setupButtonProperty()
    }

    private func setupView() {
        view.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setupButtonProperty() {
        nextBtn.setButtonAttributes(
            cornerRadius: InitialFlowHelper().nextButtonCornerRadius,
            title: "kWelcomeVCStartUsingButtonTitle".localiz(),
            backgroundColor:  UIColor._royalBlueColor())
    }

    //MARK: - IBActions
    @IBAction private func nextButtonTap(_ sender: UIButton) {
        UserDefaultsUtility.setBoolValue(false, forKey: isTermAndConditionTap)
        PrintUtility.printLog(tag: "initalFlow", text: "Tap on next Btn")
        if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeViewController.self)) as? HomeViewController {
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(viewController, animated: false)
        }
    }
}

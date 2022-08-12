//
//  WelcomesViewController.swift
//  PockeTalk
//

import UIKit

class WelcomesViewController: BaseViewController {
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
        UserDefaultsProperty<Bool>(kPermissionCompleted).value = true
    }

    private func setupView() {
        view.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setupButtonProperty() {
        nextBtn.setButtonAttributes(
            cornerRadius: InitialFlowHelper().nextButtonCornerRadius,
            title: "kStartPocketalkApp".localiz(),
            backgroundColor:  UIColor._royalBlueColor())
    }

    //MARK: - IBActions
    @IBAction private func nextButtonTap(_ sender: UIButton) {
        nextButtonLogEvent()
        goToHomeVC()
    }

    //MARK: - View Transactions
    private func goToHomeVC() {
        if let viewController = UIStoryboard(name: KStoryboardMain, bundle: nil).instantiateViewController(withIdentifier: String(describing: HomeViewController.self)) as? HomeViewController {
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.setViewControllers([viewController], animated: false)
        }
    }
}

//MARK: - Google analytics log events
extension WelcomesViewController {
    private func nextButtonLogEvent() {
        analytics.buttonTap(screenName: analytics.firstStart,
                            buttonName: analytics.buttonStart)
    }
}

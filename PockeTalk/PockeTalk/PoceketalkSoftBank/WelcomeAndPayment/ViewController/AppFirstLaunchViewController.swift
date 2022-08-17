//
//  AppFirstLaunchViewController.swift
//  PockeTalk
//

import UIKit

class AppFirstLaunchViewController: UIViewController {
    @IBOutlet weak private var topView: UIView!
    @IBOutlet weak private var termAndConditionButton: UIButton!
    @IBOutlet weak private var acceptAndStartButton: UIButton!

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        ScreenTracker.sharedInstance.screenPurpose = .InitialFlow
    }

    //MARK: - Initial setup
    private func setupUI() {
        setupView()
        setupButtonProperty()
    }

    private func setupView() {
        view.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        topView.backgroundColor = UIColor._lightYellowColor()
    }

    private func setupButtonProperty() {
        termAndConditionButton.setAttributedTitle(InitialFlowHelper().getTermAndConditionBtnAttributedString(), for: .normal)
        termAndConditionButton.backgroundColor = UIColor._royalBlueColor()
        termAndConditionButton.layer.cornerRadius = InitialFlowHelper().nextButtonCornerRadius
        termAndConditionButton.titleLabel?.textAlignment = .center
        termAndConditionButton.setPaddingByWordWrappingButtons(left: 10, right: 10, bottom: 0, top: 0)

        acceptAndStartButton.setAttributedTitle(InitialFlowHelper().getAcceptAndStartBtnAttributedString(), for: .normal)
        acceptAndStartButton.titleLabel?.textAlignment = .center
        acceptAndStartButton.addRightIcon(
            image: UIImage(named: "icon_arrow_right") ?? UIImage(),
            edgeInsetRight: 10,
            width: 8,
            height: 12,
            leadingAnchor: 10)
    }

    //MARK: - View Transactions
    private func goTOPurchaseScene() {
        DispatchQueue.main.async {
            PrintUtility.printLog(tag: "initalFlow", text: "Tap on accept and start Btn")
            if let viewController = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PurchasePlanViewController.self)) as? PurchasePlanViewController{
                let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(viewController, animated: false)
            }
        }
    }

    //MARK: - View Transactions
    private func goToWalkThroughScreen() {
        UserDefaults.standard.set(true, forKey: kUserPassedTc)
        DispatchQueue.main.async {
            PrintUtility.printLog(tag: "initalFlow", text: "Tap on accept and start Btn")
            if let viewController = UIStoryboard(name: KBoarding, bundle: nil).instantiateViewController(withIdentifier: String(describing: WalkThroughViewController.self)) as? WalkThroughViewController{
                let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
                //viewController.purchasePlanVM = self.purchasePlanVM
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(viewController, animated: false)
            }
        }
    }

    //MARK: - Utils
    private func showSingleAlert(withMessage message: String) {
        DispatchQueue.main.async {
            self.present( InitialFlowHelper().showSingleAlert(
                message: message),
                animated: true,
                completion: nil)
        }
    }

    //MARK: - IBActions
    @IBAction private func termAndConditionButtonTap(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork(){
            goToWalkThroughScreen()
        } else {
            InitialFlowHelper().showNoInternetAlert(on: self)
        }
    }

    @IBAction private func acceptAndStartButtonTap(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            let settingsUrl = NSURL(string: GlobalMethod.getURLString().termsAndConditionsURL)! as URL
            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
        } else {
            InitialFlowHelper().showNoInternetAlert(on: self)
        }
    }
}

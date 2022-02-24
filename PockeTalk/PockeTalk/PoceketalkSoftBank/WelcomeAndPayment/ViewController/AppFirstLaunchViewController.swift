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
    }

    //MARK: - Initial setup
    private func setupUI(){
        setupView()
        setupButtonProperty()
    }

    private func setupView(){
        view.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        topView.backgroundColor = UIColor._lightYellowColor()
    }

    private func setupButtonProperty(){
        termAndConditionButton.setAttributedTitle(InitialFlowHelper().getTermAndConditionBtnAttributedString(), for: .normal)
        termAndConditionButton.backgroundColor = UIColor._royalBlueColor()
        termAndConditionButton.layer.cornerRadius = InitialFlowHelper().nextButtonCornerRadius

        acceptAndStartButton.setAttributedTitle(InitialFlowHelper().getAcceptAndStartBtnAttributedString(), for: .normal)
        acceptAndStartButton.addRightIcon(
            image: UIImage(named: "icon_arrow_right") ?? UIImage(),
            edgeInsetRight: 10,
            width: 8,
            height: 12,
            leadingAnchor: 10)
    }

    //MARK: - IBActions
    @IBAction private func termAndConditionButtonTap(_ sender: UIButton) {
        PrintUtility.printLog(tag: "initalFlow", text: "Tap on term and condition Btn")
        let settingsUrl = NSURL(string:TERMS_AND_CONDITIONS_URL)! as URL
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }

    @IBAction private func acceptAndStartButtonTap(_ sender: UIButton) {
        PrintUtility.printLog(tag: "initalFlow", text: "Tap on accept and start Btn")
        if let viewController = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PurchasePlanViewController.self)) as? PurchasePlanViewController{
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(viewController, animated: false)
        }
    }
}

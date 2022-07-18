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
            title: "kStartPocketalkApp".localiz(),
            backgroundColor:  UIColor._royalBlueColor())
    }

    //MARK: - IBActions
    @IBAction private func nextButtonTap(_ sender: UIButton) {
        GlobalMethod.appdelegate().navigateToViewController(.home)
    }
}

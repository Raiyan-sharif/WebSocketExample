//
//  CustomAlertDailogViewController.swift
//  PockeTalk
//
//  Created by Kenedy Joy on 22/9/21.
//

import UIKit

class CustomAlertDailogViewController: BaseViewController {
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet var baseView: UIView!
    var alertTitle = String()
    var alertMessage = String()
    var alertButton = String()
    var noTitleShown = Bool()
    var noActionButton = Bool()
    var buttonAction:(() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        setupUI()
    }

    func setupUI() {
        alertView.layer.cornerRadius = 12
        titleView.layer.cornerRadius = 12
        cancelButton.setTitle("cancel".localiz(), for: .normal)
        titleLable.text = alertTitle
        messageLable.text = alertMessage
        actionButton.setTitle(alertButton, for: .normal)
        titleView.visiblity(gone: noTitleShown, dimension: 60)
        actionButton.visiblity(gone: noActionButton)
    }

    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true)
    }

    @IBAction func onAction(_ sender: Any) {
        dismiss(animated: true)
        buttonAction?()
    }
}

extension UIView {

    func visiblity(gone: Bool, dimension: CGFloat = 0.0, attribute: NSLayoutConstraint.Attribute = .height) -> Void {
        if let constraint = (self.constraints.filter{$0.firstAttribute == attribute}.first) {
            constraint.constant = gone ? 0.0 : dimension
            self.layoutIfNeeded()
            self.isHidden = gone
        }
    }
}

//
//  CustomAlertDailogViewController.swift
//  PockeTalk
//

import UIKit

class CustomAlertDailogViewController: BaseViewController {
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var messageLable: UILabel!
    @IBOutlet weak var alertView: UIView!
//    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet var bottomDevider: UIView!
    @IBOutlet var horizontalDevicer: UIView!
    @IBOutlet var baseView: UIView!
    var alertTitle = String()
    var alertMessage = String()
    var alertButton = String()
    var cancelButtonTitle = String()
    var noTitleShown = Bool()
    var noActionButton = Bool()
    var buttonAction:(() -> Void)?
    var hideCancelButton:Bool = false
    let window = UIApplication.shared.keyWindow!
    var talkButtonImageView: UIImageView!
    var flagTalkButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        baseView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        talkButtonImageView = window.viewWithTag(109) as! UIImageView
        flagTalkButton = talkButtonImageView.isHidden
        if(!flagTalkButton){
            talkButtonImageView.isHidden = true
            HomeViewController.dummyTalkBtnImgView.isHidden = false
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(!flagTalkButton){
            talkButtonImageView.isHidden = false
        }
    }
    deinit{
        if(!flagTalkButton){
            HomeViewController.dummyTalkBtnImgView.isHidden = true
        }
    }
    func setupUI() {
        alertView.layer.cornerRadius = 12
//        titleView.layer.cornerRadius = 12

        titleLable.text = alertTitle
        titleLable.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .bold)
        titleLable.textAlignment = .center
        titleLable.numberOfLines = 0
        titleLable.lineBreakMode = .byWordWrapping

        messageLable.text = alertMessage
        messageLable.font = UIFont.systemFont(ofSize: FontUtility.getFontSize(), weight: .regular)
        messageLable.textAlignment = .center
        messageLable.numberOfLines = 0
        messageLable.lineBreakMode = .byWordWrapping

        if cancelButtonTitle.isEmpty {
            cancelButton.setTitle("cancel".localiz(), for: .normal)
        } else {
            cancelButton.setTitle(cancelButtonTitle, for: .normal)
        }
        cancelButton.setTitleColor(UIColor.systemBlue, for: .normal)

        actionButton.setTitle(alertButton, for: .normal)
        actionButton.setTitleColor(UIColor.systemBlue, for: .normal)
//        titleView.visiblity(gone: noTitleShown, dimension: 60)
        actionButton.visiblity(gone: noActionButton)
        if hideCancelButton{
            self.cancelButton.isHidden = true
            self.horizontalDevicer.isHidden = true
            self.bottomDevider.isHidden = true
        }
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

class CustomSizeButton: UIButton {
    override var intrinsicContentSize: CGSize {
        let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude)) ?? .zero
        let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)

        return desiredButtonSize
    }
}

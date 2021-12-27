//
//  CameraTTSContextMenu.swift
//  PockeTalk
//


import UIKit

protocol CameraTTSContextMenuProtocol: AnyObject {
    func cameraTTSContextMenuSendMail()
}

class CameraTTSContextMenu: UIView {

    //Outlet Properties
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var placeHolderView: UIView!

    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    @IBOutlet weak var separatorLabel: UILabel!

    weak var delegate: CameraTTSContextMenuProtocol?


    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        styleViewWithAttributes()
        setUpFontAttribute()
        setUpDataInput()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        styleViewWithAttributes()
        setUpFontAttribute()
        setUpDataInput()
    }

    func commonInit() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: containerView.topAnchor),
            self.bottomAnchor.constraint(equalTo:containerView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }

    func styleViewWithAttributes() {

        //Set color
        self.containerView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        self.placeHolderView.backgroundColor = .white
        self.sendEmailButton.backgroundColor = .white
        self.cancelButton.backgroundColor = .white
        if #available(iOS 13.0, *) {
            self.separatorLabel.backgroundColor = .separator
        } else {
            // Fallback on earlier versions
            self.separatorLabel.backgroundColor = .seperatorColor
        }
        //set Corner Radius
        self.placeHolderView.layer.cornerRadius = DIALOG_CORNER_RADIUS
        self.placeHolderView.layer.masksToBounds = true
    }

    //Set UI font and Update if needed
    func setUpFontAttribute() {
        self.sendEmailButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        self.cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }

    func setUpDataInput() {
        self.sendEmailButton.setTitle("share".localiz(), for: .normal)
        self.cancelButton.setTitle("cancel".localiz(), for: .normal)
    }

    func dismissContextMenu() {
        self.removeFromSuperview()
    }

    @IBAction func didTapOnSendMailButton(_ sender: UIButton) {
        self.delegate?.cameraTTSContextMenuSendMail()
        dismissContextMenu()
    }

    @IBAction func didTapOnCancelButton(_ sender: UIButton) {
        dismissContextMenu()
    }

    override func layoutSubviews() {
        changeFontSize()
    }

}

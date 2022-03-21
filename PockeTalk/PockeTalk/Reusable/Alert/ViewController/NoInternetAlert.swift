//
// NoInternetAlert.swift
// PockeTalk
//

import UIKit

class NoInternetAlert: BaseViewController {
    @IBOutlet weak private var noInternetAlertTableView: UITableView!
    @IBOutlet weak private var tableViewHeightConstraint: NSLayoutConstraint!
    
    private let cellHeight: CGFloat = 60.0
    private let cornerRadius: CGFloat = 15.0
    private let viewAlpha: CGFloat = 0.8
    private let window = UIApplication.shared.keyWindow!
    private var talkButtonImageView: UIImageView!
    private var flagTalkButton = false
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        talkButtonImageView = window.viewWithTag(109) as? UIImageView
        
        flagTalkButton = talkButtonImageView.isHidden
        FloatingMikeButton.sharedInstance.isHidden(true)
        if(!flagTalkButton){
            talkButtonImageView.isHidden = true
            HomeViewController.dummyTalkBtnImgView.isHidden = false
        }

        self.tableViewHeightConstraint.constant = cellHeight * CGFloat(4)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        FloatingMikeButton.sharedInstance.hideFloatingMicrophoneBtnInCustomViews()
    }
    
    deinit{
        if(!flagTalkButton){
            talkButtonImageView?.isHidden = false
            HomeViewController.dummyTalkBtnImgView.isHidden = true
        }
    }
    
    //MARK: - Initial setup
    private func setUpUI () {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(viewAlpha)
        self.noInternetAlertTableView.layer.cornerRadius = cornerRadius
        self.noInternetAlertTableView.layer.masksToBounds = true
        self.noInternetAlertTableView.rowHeight = UITableView.automaticDimension
        self.noInternetAlertTableView.estimatedRowHeight = cellHeight
        self.noInternetAlertTableView.register(UINib(nibName: KNoInternetAlertTableViewCell, bundle: nil), forCellReuseIdentifier: KNoInternetAlertTableViewCell)
    }

    //MARK: - View Transactions
    private func moveToSettings () {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    //MARK: - Utils
    private func updateTableViewHeight () {
        UIView.animate(withDuration: 0, animations: {
            self.noInternetAlertTableView.layoutIfNeeded()
        }) { (complete) in
            var heightOfTableView: CGFloat = 0.0
            let cells = self.noInternetAlertTableView.visibleCells
            for cell in cells {
                heightOfTableView += cell.frame.height
            }
            self.tableViewHeightConstraint.constant = heightOfTableView
        }
    }
}

//MARK: - UITableViewDataSource
extension NoInternetAlert: UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: KNoInternetAlertTableViewCell) as! NoInternetAlertTableViewCell
       
        switch indexPath.row {
        case 0:
            defaultCell.configureCell(title: "internet_connection_error".localiz())
        case 1:
            defaultCell.configureCell(title: "connect_via_wifi".localiz())
        case 2:
            defaultCell.configureCell(title: "cancel".localiz())
        default:
            break
        }
        updateTableViewHeight()
        return defaultCell
    }
}

//MARK: - UITableViewDelegate
extension NoInternetAlert: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            self.dismiss(animated: false, completion: nil)
            self.moveToSettings()
        case 2:
            self.dismiss(animated: false, completion: nil)
        default:
            break
        }
    }
}

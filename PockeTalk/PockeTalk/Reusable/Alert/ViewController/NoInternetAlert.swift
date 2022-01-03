//
// NoInternetAlert.swift
// PockeTalk
//

import UIKit

class NoInternetAlert: BaseViewController {
    /// Views
    @IBOutlet weak var noInternetAlertTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    ///Properties
    let cellHeight : CGFloat = 60.0
    let cornerRadius : CGFloat = 15.0
    let viewAlpha : CGFloat = 0.8
    let window = UIApplication.shared.keyWindow!
    var talkButtonImageView: UIImageView!
    var flagTalkButton = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        talkButtonImageView = window.viewWithTag(109) as! UIImageView
        flagTalkButton = talkButtonImageView.isHidden
        if(!flagTalkButton){
            talkButtonImageView.isHidden = true
            HomeViewController.dummyTalkBtnImgView.isHidden = false
        }

        self.tableViewHeightConstraint.constant = cellHeight * CGFloat(3)
    }
    
    deinit{
        if(!flagTalkButton){
            talkButtonImageView?.isHidden = false
            HomeViewController.dummyTalkBtnImgView.isHidden = true
        }
    }

    func setUpUI () {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(viewAlpha)
        self.noInternetAlertTableView.layer.cornerRadius = cornerRadius
        self.noInternetAlertTableView.layer.masksToBounds = true
        self.noInternetAlertTableView.rowHeight = UITableView.automaticDimension
        self.noInternetAlertTableView.estimatedRowHeight = cellHeight
        self.noInternetAlertTableView.register(UINib(nibName: KNoInternetAlertTableViewCell, bundle: nil), forCellReuseIdentifier: KNoInternetAlertTableViewCell)
    }

    func moveToSettings () {
        if let url = URL(string:UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    /// Dynamically update table view height
    func updateTableViewHeight () {
        UIView.animate(withDuration: 0, animations: {
            self.noInternetAlertTableView.layoutIfNeeded()
        }) { (complete) in
            var heightOfTableView: CGFloat = 0.0
            // Get visible cells and sum up their heights
            let cells = self.noInternetAlertTableView.visibleCells
            for cell in cells {
                heightOfTableView += cell.frame.height
            }
            // Edit heightOfTableViewConstraint's constant to update height of table view
            self.tableViewHeightConstraint.constant = heightOfTableView
        }
    }

}

extension NoInternetAlert: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Obtain table view cells.
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: KNoInternetAlertTableViewCell) as! NoInternetAlertTableViewCell
        //internet_connection_error
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

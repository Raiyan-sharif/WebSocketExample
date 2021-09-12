//
// NoInternetAlert.swift
// PockeTalk
//

import UIKit

class NoInternetAlert: UIViewController {
    /// Views
    @IBOutlet weak var noInternetAlertTableView: UITableView!

    ///Properties
    let cellHeight : CGFloat = 60.0
    let cornerRadius : CGFloat = 15.0
    let viewAlpha : CGFloat = 0.8

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpUI()
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
            defaultCell.configureCell(title: NSLocalizedString("internet_connection_error", comment:""))
        case 1:
            defaultCell.configureCell(title: NSLocalizedString("connect_via_wifi", comment: ""))
        case 2:
            defaultCell.configureCell(title: NSLocalizedString("cancel", comment: ""))
        default:
            break
        }
        return defaultCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            break
        case 1:
            self.moveToSettings()
        case 2:
            self.dismiss(animated: false, completion: nil)
        default:
            break
        }
    }
}

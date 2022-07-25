//
//  InformationSettingViewController.swift
//  PockeTalk
//

import UIKit

class InformationSettingViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelTopBarTitle: UILabel!

    private let TAG = "\(InformationSettingViewController.self)"
    private let settingsTableViewCellName = "SettingsTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        PrintUtility.printLog(tag: TAG, text: "InformationSettingViewController[+]")

        self.navigationController?.navigationBar.isHidden = true
        labelTopBarTitle.text = "information".localiz()

        let nib = UINib(nibName: settingsTableViewCellName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: settingsTableViewCellName)
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return InformationSettingsItemType.settingItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: settingsTableViewCellName, for: indexPath) as! SettingsTableViewCell

        cell.labelTitle.text = InformationSettingsItemType.settingItems[indexPath.row].localiz()
        cell.selectionStyle = .none
        cell.labelTitle.textAlignment = .center
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let infoType =  InformationSettingsItemType.settingItems[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.black
            cell.selectedBackgroundView?.backgroundColor = .clear
        }

        switch infoType
        {
        case InformationSettingsItemType.appVersion.rawValue:
            let appVersion = getAppVersion()
            PrintUtility.printLog(tag: TAG, text: "appVersion - \(appVersion)")
            let alertService = CustomAlertViewModel()
            let alert = alertService.alertDialogWithTitleWithOkButtonWithNoAction(title: "application_version".localiz(), message: appVersion) {
                // handle action
            }
            self.present(alert, animated: true, completion: nil)

        case InformationSettingsItemType.licenseInfo.rawValue:
            PrintUtility.printLog(tag: TAG, text: "Open LicenseInfo view")
            let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "LicenseInfoViewController") as! LicenseInfoViewController
            self.navigationController?.pushViewController(viewController, animated: true)

        default:
            break
        }
    }

    @IBAction func actionBack(_ sender: UIButton) {
        PrintUtility.printLog(tag: TAG, text: "actionBack from InformationSettingViewController")
        if (self.navigationController == nil) {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func getAppVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] {
            return version as? String ?? ""
        }
        return ""
    }
}

//
//  SettingsViewController.swift
//  PockeTalk
//

import UIKit

class SettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, fontSizeChanged {
    
    func fontSizeChanged(value: Bool) {
        labelTopBarTitle.font = UIFont.boldSystemFont(ofSize: FontUtility.getFontSize())
        tableView.reloadData()
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var labelTopBarTitle: UILabel!
    @IBOutlet weak var imageViewOk: UIImageView!

    @IBAction func actionBack(_ sender: UIButton) {
        let transition = CATransition()
        transition.duration = kSettingsScreenTransitionDuration
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        if(self.navigationController == nil){
            self.dismiss(animated: false, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: false)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.tableView.reloadData()
        labelTopBarTitle?.text = "menu".localiz()
        self.title = kTitleOk.localiz()
    }

    override var prefersStatusBarHidden: Bool{
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "SettingsTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingsItemType.settingsItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath) as! SettingsTableViewCell
            
        cell.labelTitle.text = SettingsItemType.settingsItems[indexPath.row].localiz()
        return cell
            
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingsType =  SettingsItemType.settingsItems[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.contentView.backgroundColor = UIColor.black
            cell.selectedBackgroundView?.backgroundColor = .clear
            
        }

        switch settingsType
        {
        case SettingsItemType.textSize.rawValue:
            let textSizeVC = TextSizeViewController()
            textSizeVC.modalPresentationStyle = .overCurrentContext
            textSizeVC.delegate = self
            self.navigationController?.present(textSizeVC, animated: false, completion: nil)
        case SettingsItemType.languageChange.rawValue:
            PrintUtility.printLog(tag: "LanguageChange: ", text: "LanguageChange")
            self.navigationController?.pushViewController(SystemLanguageViewController(), animated: true)
//        case SettingsItemType.softBank.rawValue:
//            PrintUtility.printLog(tag: "softBank: ", text: "softBank")
//            GlobalMethod.showAlert("Todo: Goto softBank screen.")
        case SettingsItemType.support.rawValue:
            PrintUtility.printLog(tag: "support: ", text: "support")
            GlobalMethod.openUrlInBrowser(url: SUPPORT_URL)
        case SettingsItemType.userManual.rawValue:
            PrintUtility.printLog(tag: "userManual: ", text: "userManual")
            GlobalMethod.openUrlInBrowser(url: USER_MANUAL_URL)
        case SettingsItemType.promotion.rawValue:
            PrintUtility.printLog(tag: "promotion: ", text: "promotion")
            GlobalMethod.openUrlInBrowser(url: PROMOTION_URL)
        case SettingsItemType.reset.rawValue:
            let storyboard = UIStoryboard.init(name: "Reset", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ResetViewController") as! ResetViewController
            self.navigationController?.pushViewController(viewController, animated: true)
            PrintUtility.printLog(tag: "Reset: ", text: "Reset")
        default:
            break

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

protocol fontSizeChanged : AnyObject {
    func fontSizeChanged(value: Bool)
}

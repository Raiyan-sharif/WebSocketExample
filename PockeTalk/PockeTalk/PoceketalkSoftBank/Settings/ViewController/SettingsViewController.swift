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
    var talkButtonImageView: UIImageView!
    let window = UIApplication.shared.keyWindow!

    @IBAction func actionBack(_ sender: UIButton) {
        analytics.buttonTap(screenName: analytics.setting,
                            buttonName: analytics.buttonBack)
        let transition = CATransition()
        transition.duration = kSettingsScreenTransitionDuration
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        if(self.navigationController == nil){
            self.dismiss(animated: false, completion: nil)
            talkButtonImageView.isHidden = false
        }else{
            self.navigationController?.popViewController(animated: false)
            talkButtonImageView.isHidden = false
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        talkButtonImageView = window.viewWithTag(109) as! UIImageView
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
        cell.labelTitle.restartLabel()
        cell.labelTitle.type = .continuous
        cell.labelTitle.trailingBuffer = kMarqueeLabelTrailingBufferForLanguageScreen
        cell.labelTitle.speed = .rate(kMarqueeLabelScrollingSpeenForLanguageScreen)
        cell.selectionStyle = .none
        return cell
            
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
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
            analytics.buttonTap(screenName: analytics.setting,
                                buttonName: analytics.buttonTextSize)
            let textSizeVC = TextSizeViewController()
            textSizeVC.modalPresentationStyle = .overCurrentContext
            textSizeVC.delegate = self
            self.navigationController?.present(textSizeVC, animated: false, completion: nil)
        case SettingsItemType.languageChange.rawValue:
            analytics.buttonTap(screenName: analytics.setting,
                                buttonName: analytics.buttonSysLang)
            PrintUtility.printLog(tag: "LanguageChange: ", text: "LanguageChange")
            self.navigationController?.pushViewController(SystemLanguageViewController(), animated: true)
        case SettingsItemType.support.rawValue:
            analytics.buttonTap(screenName: analytics.setting,
                                buttonName: analytics.buttonSupport)
            PrintUtility.printLog(tag: "support: ", text: "support")
            GlobalMethod.openUrlInBrowser(url: GlobalMethod.getURLString().supportURL)
        case SettingsItemType.userManual.rawValue:
            analytics.buttonTap(screenName: analytics.setting,
                                buttonName: analytics.buttonManual)
            PrintUtility.printLog(tag: "userManual: ", text: "userManual")
            GlobalMethod.openUrlInBrowser(url: GlobalMethod.getURLString().userManuelURL)
        case SettingsItemType.information.rawValue:
            analytics.buttonTap(screenName: analytics.setting,
                                buttonName: analytics.buttonInfo)
            PrintUtility.printLog(tag: "information: ", text: "Information 2nd depth")
            let storyboard = UIStoryboard.init(name: "Settings", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "InformationSettingViewController") as! InformationSettingViewController
            self.navigationController?.pushViewController(viewController, animated: true)
        case SettingsItemType.reset.rawValue:
            analytics.buttonTap(screenName: analytics.setting,
                                buttonName: analytics.buttonReset)
            let storyboard = UIStoryboard.init(name: "Reset", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "ResetViewController") as! ResetViewController
            self.navigationController?.pushViewController(viewController, animated: true)
            PrintUtility.printLog(tag: "Reset: ", text: "Reset")
        case SettingsItemType.response.rawValue:
            self.navigationController?.pushViewController(NetworkLoggerViewController(), animated: true)
        default:
            break
        }
    }

}

protocol fontSizeChanged : AnyObject {
    func fontSizeChanged(value: Bool)
}

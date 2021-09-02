//
//  SettingsViewController.swift
//  PockeTalk
//
//  Created by Khairuzzaman Shipon on 9/2/21.
//  Copyright © 2021 Bjit ltd. on All rights reserved.
//

import UIKit

class SettingsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonBack: UIButton!
    @IBOutlet weak var labelTopBarTitle: UILabel!
    @IBOutlet weak var imageViewOk: UIImageView!
    
    
    enum SettingsItemType: String, CaseIterable {
        case languageChange = "Language Change"
        case softBank = "SoftBank"
        case support = "Support"
        case userManual = "User Manual"
        case promotion = "Pocketalk Promotion"
        
        static var settingsItems: [String] {
            return SettingsItemType.allCases.map { $0.rawValue }
          }
    }
    
    @IBAction func actionBack(_ sender: UIButton) {
        navigationController?.popToViewController(ofClass: HomeViewController.self)
    }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
            self.navigationController?.navigationBar.isHidden = true
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
            
        cell.labelTitle.text = SettingsItemType.settingsItems[indexPath.row]
        return cell
            
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingsType =  SettingsItemType.settingsItems[indexPath.row]
        
        switch settingsType
        {
        case SettingsItemType.languageChange.rawValue:
            print("languageChange")
            GlobalMethod.showAlert("Todo: Goto language change screen.")
        case SettingsItemType.softBank.rawValue:
            print("softBank")
            GlobalMethod.showAlert("Todo: Goto softBank screen.")
        case SettingsItemType.support.rawValue:
            print("support")
            GlobalMethod.openUrlInBrowser(url: SUPPORT_URL)
        case SettingsItemType.userManual.rawValue:
            print("userManual")
            GlobalMethod.openUrlInBrowser(url: USER_MANUAL_URL)
        case SettingsItemType.promotion.rawValue:
            print("promotion")
            GlobalMethod.openUrlInBrowser(url: PROMOTION_URL)
        default:
            print("def")

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

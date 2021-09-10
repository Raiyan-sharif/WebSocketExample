//
//  SystemLanguageViewController.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/2/21.
//  Copyright © 2021 ___. All rights reserved.
//

import UIKit
import SwiftyXMLParser

class SystemLanguageViewController: UIViewController {
    
    /// tableview to show list
    var tableView:UITableView!
    
    ///languageList for all languages
    var languageList = [SystemLanguages]()

    /// load viewLanguages.ja.rawValue
    override func loadView() {
        view = UIView()
        view.backgroundColor = .black
    }
    private var selectedLanguage:String?
    
    private var rightBtn:UIButton!{
        let okBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        okBtn.setTitle("OK", for: .normal)
        okBtn.titleLabel?.textColor = .white
        okBtn.backgroundColor = UIColor(hex:"#008FE8")
        okBtn.layer.cornerRadius = 10
        okBtn.clipsToBounds = true
        okBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return okBtn
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Get data from XML
        getData()
        //Set the UI
        setUpUI()
    }
    ///Get data from XML
    private func getData(){
        if let path = Bundle.main.path(forResource: "system_languages", ofType: "xml") {
            do {
                    let contents = try String(contentsOfFile: path)
                    let xml =  try XML.parse(contents)
                
                // enumerate child Elements in the parent Element
                for item in xml["language","child", "item"] {
                    let attributes = item.attributes
                    languageList.append(SystemLanguages(langName: attributes["name"]!, lanType: attributes["code"]!) )
                }
                } catch {
                    print("Parse Error")
                }
        }
    
    }
    
    /// Setup all the UI here
    private func setUpUI() {
        tableView = UITableView(frame: .zero, style: .plain)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            .isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.black
        // Register SystemLanguageCell
        tableView.register(cellType: SystemLanguageCell.self)
        tableView.tableFooterView = UIView()
        
        //Check selected language
        if let isSelected = UserDefaultsProperty<Bool>(KFirstInitialized).value, isSelected{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView:rightBtn)
            self.title = "Language".localiz()
        }else{
            self.title = "Language"
        }
        
        //Add Gesture in tableview Cell
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)

    }
    
    ///Handle gesture for tableview cell
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        let touchPoint = sender.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: touchPoint) {
            let cell  = tableView.cellForRow(at: indexPath)
            switch sender.state {
            case .began:
                cell?.contentView.backgroundColor = UIColor(hex: "#59BFFF")
            case .ended:
                
                let languageItem = languageList[indexPath.row]
                if let language = selectedLanguage, language == languageItem.lanType{
                    cell?.contentView.backgroundColor = UIColor(hex: "#008FE8")
                    return
                }else{
                    cell?.contentView.backgroundColor = .black
                    tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
                }
            default:
                break
            }
        }
    }
    
    ///Move to next screeen
    @objc func nextAction () {
        LanguageSelectionManager.shared.setLanguageAccordingToSystemLanguage()
        CameraLanguageSelectionViewModel.shared.setDefaultLanguage()
        if UserDefaultsProperty<Bool>(kIsShownLanguageSettings).value == nil{
            UserDefaultsProperty<Bool>(kIsShownLanguageSettings).value = true
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "HomeViewController")as! HomeViewController
            self.navigationController?.pushViewController(controller, animated: true);
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension SystemLanguageViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let languageItem = languageList[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SystemLanguageCell.self)
        cell.selectionStyle = .none
        cell.nameLabel.text = languageItem.langName
        if UserDefaultsProperty<String>(KSelectedLanguage).value == languageItem.lanType{
            cell.imgView.image = #imageLiteral(resourceName: "selection_icon")
            cell.contentView.backgroundColor = UIColor(hex: "#008FE8")
        }else{
            cell.imgView.image = nil
            cell.contentView.backgroundColor = .black
        }
        return cell
    }

    
}
extension SystemLanguageViewController:UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let languageItem = languageList[indexPath.row]
        if UserDefaultsProperty<String>(KSelectedLanguage).value == nil{
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView:rightBtn)
        }
        UserDefaultsProperty<Bool>(KFirstInitialized).value = true
        UserDefaultsProperty<String>(KSelectedLanguage).value = languageItem.lanType
        LanguageManager.shared.setLanguage(language: Languages(rawValue: languageItem.lanType) ?? .en)
        self.title = "Language".localiz()
        selectedLanguage = languageItem.lanType
        self.tableView.reloadData()
    }
}

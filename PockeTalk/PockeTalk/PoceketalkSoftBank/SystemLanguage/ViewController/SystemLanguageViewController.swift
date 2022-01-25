//
//  SystemLanguageViewController.swift
//  PockeTalk
//

import UIKit
import SwiftyXMLParser

class SystemLanguageViewController: BaseViewController {

    private var tableView:UITableView!
    var languageList = [SystemLanguages]()
    var currentSelectedLanguage = String()
    var mIndexPath = IndexPath()
    private let TAG = "\(SystemLanguageViewController.self)"
    private var selectedLanguage:String?
    
    private var leftBtn:UIButton!{
        let okBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        okBtn.changeFontSize()
        okBtn.setTitle("OK", for: .normal)
        okBtn.setImage(UIImage(named: "icon_arrow_left.9"), for: .normal)
        okBtn.titleLabel?.textColor = .white
        okBtn.clipsToBounds = true
        okBtn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return okBtn
    }

    //MARK: - Lifecycle methods
    override func loadView() {
        view = UIView()
        view.backgroundColor = .black
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController!.navigationBar.barStyle = .black
        self.navigationController!.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .white
        if #available(iOS 13.0, *) {
            let navBarAppearance = UINavigationBarAppearance()
            let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontUtility.getFontSize())]
            navBarAppearance.titleTextAttributes = attributes
            navBarAppearance.buttonAppearance.normal.titleTextAttributes = attributes
            navBarAppearance.doneButtonAppearance.normal.titleTextAttributes = attributes
            navBarAppearance.backgroundColor = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)
            self.navigationController?.navigationBar.standardAppearance = navBarAppearance
        } else {
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontUtility.getFontSize())]
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        setUpUI()
        currentSelectedLanguage = LanguageManager.shared.currentLanguage.rawValue
        selectedLanguage = currentSelectedLanguage
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Language".localiz()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - Initial setup
    private func setUpUI() {
        tableView = UITableView(frame: .zero, style: .plain)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            .isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.black
        
        tableView.register(cellType: SystemLanguageCell.self)
        tableView.tableFooterView = UIView()
        
        if let isSelected = UserDefaultsProperty<Bool>(KFirstInitialized).value, isSelected{
            self.title = "Language".localiz()
        }else{
            self.title = "Language"
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        tableView.addGestureRecognizer(longPress)
    }
    
    //MARK: - Load data
    private func getData(){
        if let path = Bundle.main.path(forResource: "system_languages", ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: path)
                let xml =  try XML.parse(contents)
                
                for item in xml["language","child", "item"] {
                    let attributes = item.attributes
                    languageList.append(SystemLanguages(langName: attributes["name"]!, lanType: attributes["code"]!) )
                }
            } catch {
                PrintUtility.printLog(tag: TAG, text: "Parse Error")
            }
        }
    }
    
    //MARK: - IBActions
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
        if selectedLanguage != nil && currentSelectedLanguage != selectedLanguage{
            let languageItem = languageList[mIndexPath.row]
            let langCode = Languages(rawValue: languageItem.lanType) ?? .en
            LanguageManager.shared.setLanguage(language: langCode)
            
            UserDefaultsProperty<Bool>(KFirstInitialized).value = true
            UserDefaultsProperty<String>(KSelectedLanguage).value = languageItem.lanType
            LanguageSelectionManager.shared.loadLanguageListData()
            //LanguageSelectionManager.shared.setLanguageAccordingToSystemLanguage()
            let isLanguageChanged:[String: Bool] = ["isLanguageChanged": true]
            NotificationCenter.default.post(name: .languageChangeFromSettingsNotification, object: nil, userInfo: isLanguageChanged)
        }
    }
    
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
}

//MARK: - UITableViewDataSource
extension SystemLanguageViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let languageItem = languageList[indexPath.row]
        let currentLangType = selectedLanguage

        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SystemLanguageCell.self)
        cell.selectionStyle = .none
        cell.nameLabel.text = languageItem.langName
        if languageItem.lanType == currentLangType {
            cell.imgView.image = #imageLiteral(resourceName: "ic_check_circle_white_selected")
            cell.contentView.backgroundColor = UIColor(hex: "#008FE8")
        } else {
            cell.imgView.image = nil
            cell.contentView.backgroundColor = .black
        }
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SystemLanguageViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mIndexPath = indexPath
        let languageItem = languageList[indexPath.row]
        selectedLanguage = languageItem.lanType
        self.tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GlobalMethod.standardTableViewCellHeight
    }
}


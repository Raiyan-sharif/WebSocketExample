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
        let navBarAppearance = UINavigationBarAppearance()
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: FontUtility.getFontSize())]
        navBarAppearance.titleTextAttributes = attributes
        navBarAppearance.buttonAppearance.normal.titleTextAttributes = attributes
        navBarAppearance.doneButtonAppearance.normal.titleTextAttributes = attributes
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.07058823529, green: 0.07058823529, blue: 0.07058823529, alpha: 1)
        self.navigationController?.navigationBar.standardAppearance = navBarAppearance
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        setUpUI()
        currentSelectedLanguage = LanguageManager.shared.currentLanguage.rawValue
        selectedLanguage = currentSelectedLanguage
        self.navigationController?.setNavigationBarHidden(true, animated: false)
//        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftBtn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        self.title = "Language".localiz()

        self.navigationController?.navigationBar.isHidden = false

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.getSelectedItemPosition(), section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .none, animated: false)
        }
    }

    private func getSelectedItemPosition() -> Int{
        let selectedLangCode = UserDefaultsProperty<String>(KSelectedLanguage).value
        for i in 0...languageList.count - 1{
            let item = languageList[i]
            if  selectedLangCode == item.lanType{
                return i
            }
        }
        return 0
    }

    //MARK: - Initial setup
    private func setUpNavBarBackButton(navViewHeight: Int) -> UIButton {
        let okButton = UIButton(frame: CGRect(x: backButtonOffsetX, y: ((navViewHeight - backButtonHeight/2) - 2), width: backButtonWidth, height: backButtonHeight))
        okButton.changeFontSize()
        okButton.contentHorizontalAlignment = .left
        okButton.setTitle("OK", for: .normal)
        okButton.setImage(UIImage(named: "icon_arrow_left.9"), for: .normal)
        okButton.titleLabel?.textColor = .white
        okButton.clipsToBounds = true
        okButton.backgroundColor = .clear
        let highlightedButtonColor = UIColor(red: 90.0/255.0, green: 200.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        okButton.setTitleColor(highlightedButtonColor, for: .highlighted)

        let origImage = UIImage(named: "icon_arrow_left.9")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        okButton.setImage(tintedImage, for: .highlighted)
        okButton.tintColor = highlightedButtonColor

        okButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return okButton
    }

    private func setUpNavBarTitle(navView: UIView) -> UILabel {
        let navTitle = UILabel(frame: CGRect(x: 0, y: (Int(navView.frame.size.height)/2 - navTitleHeight/2), width: navTitleWidth, height: navTitleHeight))
        navTitle.textAlignment = .center
        navTitle.changeFontSize()
        navTitle.backgroundColor = .clear
        navTitle.center.x = navView.center.x
        navTitle.text = "Language".localiz()
        navTitle.textColor = .white
        return navTitle
    }

    private func setUpUI() {
        let window = UIApplication.shared.keyWindow
        let safeAreaHeight = window?.safeAreaInsets.top ?? 20
        let navView = UIView(frame: CGRect(x: navigationBarOffsetX, y: safeAreaHeight, width: UIScreen.main.bounds.size.width, height: Double(navigationBarHeight)))
        navView.addSubview(setUpNavBarBackButton(navViewHeight: Int(navView.frame.size.height)/2))
        navView.addSubview(setUpNavBarTitle(navView: navView))
        navView.backgroundColor = UIColor(red: 18.0/255.0, green: 18.0/255.0, blue: 18.0/255.0, alpha: 1.0)
        view.addSubview(navView)

        tableView = UITableView(frame: .zero, style: .plain)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
            .isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: navView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.black
        
        tableView.register(cellType: SystemLanguageCell.self)
        tableView.tableFooterView = UIView()
        
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


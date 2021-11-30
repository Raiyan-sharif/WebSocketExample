//
//  TextSizeViewController.swift
//  PockeTalk
//

import UIKit

class TextSizeViewController: BaseViewController {

    private let dataSource = ["Smallest", "Small", "Medium", "Large", "Largest"]
    private var tableHeight:CGFloat =  0
    private var selecteText:String!
    private let  tableHeaderAndFooterHeight:CGFloat = 60.0
    weak var delegate: fontSizeChanged?

    private lazy var tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = 2
        tableView.register(cellType: FontSelectionCell.self)
        return tableView
    }()

    override func loadView() {
        super.loadView()
        selecteText = UserDefaultsProperty<String>(KFontSelection).value
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        tableHeight = CGFloat(dataSource.count) * 50.0  + tableHeaderAndFooterHeight*2
        setUpUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UserDefaultsProperty<String>(KFontSelection).value = selecteText
    }

    private func setUpUI(){
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        tableView.heightAnchor.constraint(equalToConstant:tableHeight).isActive = true
        tableView.widthAnchor.constraint(equalToConstant: SIZE_WIDTH*0.7).isActive = true
    }
}

extension TextSizeViewController : UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: FontSelectionCell.self)
        cell.nameLabel?.text = dataSource[indexPath.row].localiz()
        cell.nameLabel.textColor = UIColor.init(red: 51, green: 51, blue: 51)
        cell.selectionStyle = .none
        if selecteText == dataSource[indexPath.row]{
            cell.imgView.tintColor = UIColor.init(red: 30, green: 168, blue: 148)
            cell.imgView.image = #imageLiteral(resourceName: "Radio_On")
            delegate?.fontSizeChanged(value: true)
        }else{
            cell.imgView.tintColor = UIColor.init(red: 51, green: 51, blue: 51)
            cell.imgView.image = #imageLiteral(resourceName: "Radion_Off")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selecteText = dataSource[indexPath.row]
        FontUtility.setFontSize(selectedFont: selecteText)
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: false, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableHeaderAndFooterHeight))
        view.backgroundColor = .white
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        let label = UILabel(frame: CGRect(x: view.bounds.minY + 35, y: 0, width: view.bounds.width, height: tableHeaderAndFooterHeight))
        label.textAlignment = .left
        label.text = "font_size".localiz()
        label.font = UIFont.boldSystemFont(ofSize: FontUtility.getFontSize())
        label.textColor = UIColor.init(red: 38, green: 38, blue: 38)
        view.addSubview(label)
        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableHeaderAndFooterHeight))
        view.backgroundColor = .white
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        let btn = UIButton(frame: CGRect(x: 0 , y: 0, width: view.bounds.width-20, height: 40))
        btn.setTitle("cancel".localiz(), for:.normal)
        btn.changeFontSize()
        btn.setTitleColor(UIColor.init(red: 30, green: 168, blue: 148), for: .normal)
        btn.contentHorizontalAlignment = .right
        btn.addTarget(self, action: #selector(cancelEvent(sender:)), for: .touchUpInside)
        view.addSubview(btn)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableHeaderAndFooterHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableHeaderAndFooterHeight
    }

    // Cancel event
    @objc func cancelEvent (sender:UIButton) {
        self.dismiss(animated: false, completion: nil)
    }

}

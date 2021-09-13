//
// AlertReusable.swift
// PockeTalk
//

import UIKit
protocol ReverseDelegate {
    func transitionFromReverse()
}

class AlertReusableViewController: BaseViewController {
    static var nib: UINib =  UINib.init(nibName: KAlertReusable, bundle: nil)
    /// Views
    @IBOutlet weak var alertTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    /// Properties
    var items : [AlertItems] = []
    let cellHeight : CGFloat = 58.0
    let cornerRadius : CGFloat = 15.0
    let viewAlpha : CGFloat = 0.8
    var reverseDelegate : ReverseDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.tableViewHeightConstraint.constant = cellHeight * CGFloat(items.count)
    }

    func setUpUI () {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(viewAlpha)
        self.alertTableView.layer.cornerRadius = cornerRadius
        self.alertTableView.layer.masksToBounds = true
        self.alertTableView.rowHeight = UITableView.automaticDimension
        self.alertTableView.estimatedRowHeight = cellHeight
        alertTableView.register(UINib(nibName: KAlertTableViewCell, bundle: nil), forCellReuseIdentifier: KAlertTableViewCell)
    }

    /// Add to favorites
    func addFavorite (index : IndexPath) {
        let cell = self.alertTableView.cellForRow(at: index) as! AlertTableViewCell
        if UserDefaultsUtility.getBoolValue(forKey: kIsAlreadyFavorite) == true {
            UserDefaultsUtility.setBoolValue(false, forKey: kIsAlreadyFavorite)
            cell.imgView.image = UIImage(named: items[index.row].imageName)
        } else {
            UserDefaultsUtility.setBoolValue(true, forKey: kIsAlreadyFavorite)
            cell.imgView.image = UIImage(named:"icon_favorite_select_popup.png")
        }
    }

    func showPracticeView () {
        let storyboard = UIStoryboard(name: "PronunciationPractice", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "PronunciationPracticeViewController") as! PronunciationPracticeViewController
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func reverseTranslation () {
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true, completion: nil)
            self.reverseDelegate?.transitionFromReverse()
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

extension AlertReusableViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Obtain table view cells.
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: KAlertTableViewCell) as! AlertTableViewCell
        var imageName = ""
        if items[indexPath.row].menuType == .favorite {
            if UserDefaultsUtility.getBoolValue(forKey: kIsAlreadyFavorite) == true {
                imageName = "icon_favorite_select_popup.png"
            } else {
                imageName = items[indexPath.row].imageName
            }
        } else {
            imageName = items[indexPath.row].imageName
        }
        defaultCell.configureCell(title: items[indexPath.row].title, imageName: imageName)
        return defaultCell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = items[indexPath.row].menuType
        switch type {
        case .favorite:
            self.addFavorite(index: indexPath)
        case .retranslation :
            break
        case .reverse:
            self.reverseTranslation()
            break
        case .practice :
            showPracticeView()
            break
        case .sendMail :
            break
        case .cancel :
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension AlertReusableViewController : DismissPronunciationDelegate {
    func dismissPro() {
        self.dismiss(animated: true, completion: nil)
        if let transitionView = self.view{
            UIView.transition(with:transitionView, duration: 0.2, options: .showHideTransitionViews, animations: nil, completion: nil)
        }
    }
}

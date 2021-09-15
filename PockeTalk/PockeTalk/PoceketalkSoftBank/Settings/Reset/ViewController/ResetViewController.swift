

import UIKit

class ResetViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelTopBarTilte: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    
    
    @IBAction func actionBack(_ sender: Any) {
        navigationController?.popToViewController(ofClass: SettingsViewController.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
            self.navigationController?.navigationBar.isHidden = true
            //self.tableView.reloadData()
            self.labelTopBarTilte?.text = "Reset".localiz()
        }
    
    override var prefersStatusBarHidden: Bool{
        return true
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ResetTableViewCell", bundle: nil), forCellReuseIdentifier: "ResetTableViewCell")
        tableView.separatorColor = .gray
        tableView.tableFooterView = UIView()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ResetItemType.resetItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResetTableViewCell") as! ResetTableViewCell
        cell.titleLabel?.text = ResetItemType.resetItems[indexPath.row].localiz()
        print(ResetItemType.resetItems[indexPath.row].localiz())
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor._skyBlueColor()
        cell.selectedBackgroundView = bgColorView
        return cell
    }

}

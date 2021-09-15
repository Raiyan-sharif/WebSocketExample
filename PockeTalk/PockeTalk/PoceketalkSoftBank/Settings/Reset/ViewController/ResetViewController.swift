

import UIKit

class ResetViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelTopBarTilte: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    private let TAG:String = "ResetViewController"
    
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let resetDataType =  ResetItemType.resetItems[indexPath.row]
        switch resetDataType {
        case ResetItemType.clearTranslationHistory.rawValue:
            let alert = AlertDialogUtility.showTranslationHistoryDialog()
            self.present(alert, animated: true, completion: nil)
            deSelectTableCell()
            PrintUtility.printLog(tag: TAG, text: "Translation History")
        case ResetItemType.deleteCameraHistory.rawValue:
            let alert = AlertDialogUtility.showCameraTranslationHistoryDialog()
            self.present(alert, animated: true, completion: nil)
            deSelectTableCell()
            PrintUtility.printLog(tag: TAG, text: "Camera History")
        case ResetItemType.clearFavourite.rawValue:
            let alert = AlertDialogUtility.showFavouriteHistoryDialog()
            self.present(alert, animated: true, completion: nil)
            deSelectTableCell()
            PrintUtility.printLog(tag: TAG, text: "Favourite Data")
        case ResetItemType.deleteAllData.rawValue:
            let alert = AlertDialogUtility.showDeleteAllDataDialog()
            self.present(alert, animated: true, completion: nil)
            deSelectTableCell()
            PrintUtility.printLog(tag: TAG, text: "Delete all data")
        default:
            PrintUtility.printLog(tag: TAG, text: "Default click")
        }
    }
    func deSelectTableCell(){
        if let selectedIndexPaths = tableView.indexPathsForSelectedRows {
            for indexPath in selectedIndexPaths {
                 tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }

}

//
//  ResetViewController.swift
//  PockeTalk
//

import UIKit

class ResetViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
   
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var labelTopBarTilte: UILabel!
    
    @IBOutlet weak var btnBack: UIButton!
    private let TAG:String = "ResetViewController"

    @IBAction func actionBack(_ sender: Any) {
        if self.navigationController != nil{
            navigationController?.popToViewController(ofClass: SettingsViewController.self)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
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
        tableView.register(UINib(nibName: "ResetListTableViewCell", bundle: nil), forCellReuseIdentifier: "ResetTableViewCell")
        tableView.separatorColor = .gray
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        tableView.tableFooterView = UIView()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ResetItemType.resetItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResetTableViewCell") as! ResetListTableViewCell
        cell.titleLabel?.text = ResetItemType.resetItems[indexPath.row].localiz()
        cell.titleLabel.font = UIFont.systemFont(ofSize: FontUtility.getFontSize())
        cell.titleLabel.type = .continuous
        cell.titleLabel.trailingBuffer = kMarqueeLabelTrailingBufferForLanguageScreen
        cell.titleLabel.speed = .rate(kMarqueeLabelScrollingSpeenForLanguageScreen)
        PrintUtility.printLog(tag: "IndexPath", text: ResetItemType.resetItems[indexPath.row].localiz())
        cell.backgroundColor = .black
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor._skyBlueColor()
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let resetDataType =  ResetItemType.resetItems[indexPath.row]
        switch resetDataType {
        case ResetItemType.clearTranslationHistory.rawValue:
            let alertService = CustomAlertViewModel()
            let alert = alertService.alertDialogWithoutTitleWithActionButton(message: "msg_history_del_dialog".localiz(), buttonTitle: "clear".localiz()) {
                PrintUtility.printLog(tag: self.TAG, text: "Handle Ok logic here")
                FileUtility.deleteAllHistoryTTSAudioFiles()
                _ = ChatDBModel().deleteAllChatHistory(removeStatus: .removeHistory)
                self.showSuccessAlert(title: "history_cleared".localiz())
                NotificationCenter.default.post(name: .resetChatHistoryNotification, object: nil)
            }
            present(alert, animated: true, completion: nil)
//            let alert = AlertDialogUtility.showTranslationHistoryDialog()
//            self.present(alert, animated: true, completion: nil)
            deSelectTableCell()
            PrintUtility.printLog(tag: TAG, text: "Translation History")
        case ResetItemType.deleteCameraHistory.rawValue:
            let alertService = CustomAlertViewModel()
            let alert = alertService.alertDialogWithoutTitleWithActionButton(message: "msg_camera_history_del_dialog".localiz(), buttonTitle: "clear".localiz()) {
                PrintUtility.printLog(tag: self.TAG, text: "Handle Ok logic here")
                _ = try? CameraHistoryDBModel().deleteAll()
                self.showSuccessAlert(title: "camera_history_cleared".localiz())
            }
            present(alert, animated: true, completion: nil)
//            let alert = AlertDialogUtility.showCameraTranslationHistoryDialog()
//            self.present(alert, animated: true, completion: nil)
            deSelectTableCell()
            PrintUtility.printLog(tag: TAG, text: "Camera History")
        case ResetItemType.clearFavourite.rawValue:
            let alertService = CustomAlertViewModel()
            let alert = alertService.alertDialogWithoutTitleWithActionButton(message: "msg_history_del_dialog_favorite".localiz(), buttonTitle: "clear".localiz()) {
                PrintUtility.printLog(tag: self.TAG, text: "Handle Ok logic here")
                FileUtility.deleteAllFavoriteTTSAudioFiles()
                _ = ChatDBModel().deleteAllChatHistory(removeStatus: .removeFavorite)
                // Favorite limit flag update
                UserDefaultsProperty<Bool>("FAVORITE_LIMIT_FLAG_KEY").value = false
                self.showSuccessAlert(title: "favorite_history_cleared".localiz())
            }
            present(alert, animated: true, completion: nil)
//            let alert = AlertDialogUtility.showFavouriteHistoryDialog()
//            self.present(alert, animated: true, completion: nil)
            deSelectTableCell()
            PrintUtility.printLog(tag: TAG, text: "Favourite Data")
        case ResetItemType.deleteAllData.rawValue:

            if let coupon =  UserDefaults.standard.string(forKey: kCouponCode), !coupon.isEmpty {
                LocalNotificationManager.sharedInstance.removeScheduledNotification()
                CustomLocalNotification.sharedInstance.removeView()
            }
            ResponseLogger.shareInstance.clean()
            let alertService = CustomAlertViewModel()
            let alert = alertService.alertDialogWithoutTitleWithActionButton(message: "msg_all_data_reset".localiz(), buttonTitle: "delete_all_data".localiz()) {
                PrintUtility.printLog(tag: self.TAG, text: "Handle Ok logic here")
                
                do {
                    /// Delete all from tables
                    try CameraHistoryDBModel().deleteAll()
                    try ChatDBModel().deleteAll()
                    try LanguageSelectionDBModel().deleteAll()
                    try LanguageMapDBModel().deleteAll()
                } catch _ {

                }
                ///Delete all TTS audio files
                FileUtility.deleteTTSAudioDirectory()
                
                /// Clear UserDefautlts
                UserDefaultsUtility.resetDefaults()
                
                ///Removing floating mike button from window before reset data
                if FloatingMikeButton.sharedInstance.isMikeButtonExistOnWindow(){
                    FloatingMikeButton.sharedInstance.remove()
                }

                ///Removing loader if exist from window before reset data
                ActivityIndicator.sharedInstance.hide()

                ///Remove local notification manager schedule & view from window if exist
                PrintUtility.printLog(tag: TagUtility.sharedInstance.localNotificationTag, text: "Removing scheduled Notification when delete all data")
                /// Relaunch Application
                GlobalMethod.appdelegate().relaunchApplication()
//                self.navigationController?.popToRootViewController(animated: false)
            }
            present(alert, animated: true, completion: nil)
//            let alert = AlertDialogUtility.showDeleteAllDataDialog()
//            self.present(alert, animated: true, completion: nil)
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

    func showSuccessAlert(title: String){
        let successAlert = CustomAlertViewModel()
        let dialog = successAlert.alertDialogWithoutTitleWithOkButton(message: title)
        self.present(dialog, animated: true, completion: nil)
    }

}

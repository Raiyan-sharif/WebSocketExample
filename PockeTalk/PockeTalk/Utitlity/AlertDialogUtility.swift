
import Foundation

public class AlertDialogUtility {
    private static let TAG:String = "AlertDialogUtility"
    public static func showTranslationHistoryDialog()->UIAlertController{
        // create the alert
        let alert = UIAlertController(title: "", message: "msg_history_del_dialog".localiz(), preferredStyle:UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "clear".localiz(), style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) in
                PrintUtility.printLog(tag: TAG, text: "Handle Ok logic here")
                }))
        alert.addAction(UIAlertAction(title: "cancel".localiz(), style: UIAlertAction.Style.cancel, handler: nil))
            return alert
    }
    public static func showCameraTranslationHistoryDialog()->UIAlertController{
        // create the alert
        let alert = UIAlertController(title: "", message: "msg_camera_history_del_dialog".localiz(), preferredStyle:UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "clear".localiz(), style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) in
                PrintUtility.printLog(tag: TAG, text: "Handle Ok logic here")
                }))
        alert.addAction(UIAlertAction(title: "cancel".localiz(), style: UIAlertAction.Style.cancel, handler: nil))
            return alert
    }
    public static func showFavouriteHistoryDialog()->UIAlertController{
        // create the alert
        let alert = UIAlertController(title: "", message: "msg_history_del_dialog_favorite".localiz(), preferredStyle:UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "clear".localiz(), style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) in
                PrintUtility.printLog(tag: TAG, text: "Handle Ok logic here")
                }))
        alert.addAction(UIAlertAction(title: "cancel".localiz(), style: UIAlertAction.Style.cancel, handler: nil))
            return alert
    }
    public static func showDeleteAllDataDialog()->UIAlertController{
        let alert = UIAlertController(title: "", message: "msg_all_data_reset".localiz(), preferredStyle:UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "delete_all_data".localiz(), style: UIAlertAction.Style.default, handler:{ (action: UIAlertAction!) in
                PrintUtility.printLog(tag: TAG, text: "Handle Ok logic here")
                }))
        alert.addAction(UIAlertAction(title: "cancel".localiz(), style: UIAlertAction.Style.cancel, handler: nil))
            return alert
    }
}

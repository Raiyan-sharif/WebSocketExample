//
//  CustomAlertViewModel.swift
//  PockeTalk
//

import UIKit

class CustomAlertViewModel:BaseModel {

    func alertDialogWithoutTitleWithActionButton(message:String, buttonTitle:String, completion:@escaping () -> Void) -> CustomAlertDailogViewController {
        let storyboard = UIStoryboard(name: "CustomAlertDialog", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertDailogViewController
        //alertVC.alertTitle = "title"
        alertVC.alertMessage = message
        alertVC.alertButton = buttonTitle
        alertVC.noTitleShown = true
        alertVC.noActionButton = false
        alertVC.buttonAction = completion

        return alertVC
    }

    func alertDialogWithoutTitleWithoutActionButton(message:String) -> CustomAlertDailogViewController {
        let storyboard = UIStoryboard(name: "CustomAlertDialog", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertDailogViewController
        //alertVC.alertTitle = "title"
        alertVC.alertMessage = message
        alertVC.alertButton = "buttonTitle"
        alertVC.noTitleShown = true
        alertVC.noActionButton = true

        return alertVC
    }


    func alertDialogWithoutTitleWithOkButton(message:String) -> CustomAlertDailogViewController {
        let storyboard = UIStoryboard(name: "CustomAlertDialog", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertDailogViewController
        //alertVC.alertTitle = "title"
        alertVC.alertMessage = message
        alertVC.alertButton = "OK".localiz()
        alertVC.hideCancelButton = true
        return alertVC
    }

    func alertDialogWithTitleWithActionButton(title:String, message:String, buttonTitle:String,cancelTitle : String, completion:@escaping () -> Void) -> CustomAlertDailogViewController {
        let storyboard = UIStoryboard(name: "CustomAlertDialog", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertDailogViewController
        alertVC.alertTitle = title
        alertVC.alertMessage = message
        alertVC.alertButton = buttonTitle
        alertVC.noTitleShown = false
        alertVC.noActionButton = false
        alertVC.buttonAction = completion
        alertVC.cancelButtonTitle = cancelTitle
        return alertVC
    }

    func alertDialogWithTitleWithoutActionButton(title:String, message:String) -> CustomAlertDailogViewController {
        let storyboard = UIStoryboard(name: "CustomAlertDialog", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertDailogViewController
        alertVC.alertTitle = title
        alertVC.alertMessage = message
        alertVC.alertButton = "buttonTitle"
        alertVC.noTitleShown = false
        alertVC.noActionButton = true

        return alertVC
    }
    
    func alertDialogWithoutTitleWithOkButtonAction(message:String, completion:@escaping () -> Void) -> CustomAlertDailogViewController {
        let storyboard = UIStoryboard(name: "CustomAlertDialog", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertDailogViewController
        //alertVC.alertTitle = "title"
        alertVC.alertMessage = message
        alertVC.alertButton = "OK".localiz()
        alertVC.hideCancelButton = true
        alertVC.noActionButton = false
        alertVC.buttonAction = completion
        
        return alertVC
    }
    
    func alertDialogWithTitleWithOkButtonWithNoAction(title: String, message:String, completion:@escaping () -> Void) -> CustomAlertDailogViewController {
        let storyboard = UIStoryboard(name: "CustomAlertDialog", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertDailogViewController
        alertVC.alertTitle = title
        alertVC.alertMessage = message
        alertVC.alertButton = "OK".localiz()
        alertVC.hideCancelButton = true
        alertVC.noActionButton = false
        alertVC.buttonAction = completion
        
        return alertVC
    }

    func alertDialogSoftbank(message:String, completion: @escaping() -> Void) -> CustomAlertDailogViewController {
        let storyboard = UIStoryboard(name: "CustomAlertDialog", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertDailogViewController
        alertVC.alertMessage = message
        alertVC.alertButton = "OK".localiz()
        alertVC.softbankAlert = true
        alertVC.noActionButton = false
        alertVC.softbankShowError = false
        alertVC.okButtonAction = completion

        return alertVC
    }

    func alertDialogSoftbankWithError(message:String, errorMessage:String, completion:@escaping () -> Void) -> CustomAlertDailogViewController {
        let storyboard = UIStoryboard(name: "CustomAlertDialog", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "CustomAlertVC") as! CustomAlertDailogViewController
        alertVC.alertMessage = message
        alertVC.alertButton = "OK".localiz()
        alertVC.softbankAlert = true
        alertVC.noActionButton = false
        if errorMessage.isEmpty{
            alertVC.softbankShowError = false
        }else{
            alertVC.softbankShowError = true
            alertVC.errorMessage = errorMessage
        }
        alertVC.okButtonAction = completion

        return alertVC
    }

}

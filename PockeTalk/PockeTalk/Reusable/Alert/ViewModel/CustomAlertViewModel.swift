//
//  CustomAlertViewModel.swift
//  PockeTalk
//
//  Created by Kenedy Joy on 22/9/21.
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
        alertVC.alertButton = "OK"
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

}

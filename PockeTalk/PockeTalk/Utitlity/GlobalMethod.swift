//
//  GlobalMethod.swift
//  PockeTalk
//

import Foundation
import UIKit

class GlobalMethod {
    // MARK: - Constants
    static let mainWindow: UIWindow? = UIApplication.shared.delegate?.window as? UIWindow
    static let screenSize: CGRect = UIScreen.main.bounds
    static let isWideScreen: Bool = GlobalMethod.screenSize.height >= 568.0
    static let displayScale: CGFloat = GlobalMethod.screenSize.width / 375.0
    static let standardTableViewCellHeight: CGFloat = 65.0 * displayScale

    // Fonts
    static let mainFont: UIFont = UIFont.systemFont(ofSize: 15.0 * GlobalMethod.displayScale)

    static var isAppInProduction:Bool {
        #if PRODUCTION || MULTISERVER_PRODUCTION
        return true
        #else
        return false
        #endif

    }
    // Get top padding
    static func getTopPadding() -> CGFloat {
        var topPadding: CGFloat = 20.0
        if #available(iOS 11.0, *) {
            if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
                topPadding = max(appDelegate.window?.safeAreaInsets.top ?? 0.0, 20.0)
            }
        }
        return topPadding
    }

    // Get bottom padding
    static func getBottomPadding() -> CGFloat {
        var bottomPadding: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
                bottomPadding = max(appDelegate.window?.safeAreaInsets.bottom ?? 0.0, 0.0)
            }
        }
        return bottomPadding
    }


    // Check date in this year
    static func isDateOfThisYear(of date: Date) -> Bool {
        let myCalendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        let yearOfDate: Int = myCalendar.component(Calendar.Component.year, from: date)
        let yearOfToday: Int = myCalendar.component(Calendar.Component.year, from: Date())
        return (yearOfDate == yearOfToday)
    }


    static func showAlert(_ alertMessage: String, in viewController: UIViewController? = nil, completion: (() -> Void)? = nil) {
        if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
            // Init alert
            let alertController: UIAlertController = UIAlertController(title: nil, message: alertMessage, preferredStyle: .alert)
            let okActionAlert = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                completion?()
            })
            okActionAlert.setValue(UIColor.black, forKey: "titleTextColor")
            alertController.addAction(okActionAlert)

            // Show alert
            if viewController != nil {
                viewController?.present(alertController, animated: true, completion: nil)
            } else if let _visibleViewController = self.getVisibleViewController(nil) {
                _visibleViewController.present(alertController, animated: true, completion: nil)
            } else {
                if let _window = appDelegate.window, let _rootViewController = _window.rootViewController {
                    _rootViewController.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    static func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }

    static func getCurrentTimeStamp(with offset:Int) -> Int {
        let time = Date().timeIntervalSince1970
        PrintUtility.printLog(tag: "Time", text: "\(Int(time))")
        return Int(time)

    }

    static func getAttributeString(fromString string:String, withDictionary1 dict1:[NSAttributedString.Key:Any], onRange1 range1:NSRange,
                                   withDictionary2 dict2:[NSAttributedString.Key:Any], onRange2 range2:NSRange) -> NSMutableAttributedString {
        let attribute = NSMutableAttributedString(string: string)
        attribute.addAttributes(dict1, range: range1)
        attribute.addAttributes(dict2, range: range2)
        return attribute
    }

    static func customPrint(printObject: Any?) {
        #if DEBUG
        if let _printObject = printObject {
            print(_printObject)
        }
        #endif
    }

    static func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {

        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }

        if rootVC?.presentedViewController == nil {
            return rootVC
        }

        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }

            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }

            return getVisibleViewController(presented)
        }
        return nil
    }

    static func refreshVisibleViewController() {
        if let _visibleViewController = self.getVisibleViewController(nil) {
            let parent = _visibleViewController.view.superview

            let image = getScreenshot()
            if let _image = image {
                let imageView = UIImageView(image: _image)
                parent?.addSubview(imageView)
            }
            _visibleViewController.view.removeFromSuperview()
            _visibleViewController.view = nil
            parent?.addSubview(_visibleViewController.view)
        }
    }

    static func getScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        for window in UIApplication.shared.windows {
            window.layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    static func openUrlInBrowser(url: String){
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }

    // floating microphone button
    static func setUpMicroPhoneIcon (view : UIView, width : CGFloat, height : CGFloat)-> UIButton {
        let floatingButton = UIButton()
        floatingButton.setImage(UIImage(named: "talk_button"), for: .normal)
        floatingButton.backgroundColor = UIColor.clear
        floatingButton.layer.cornerRadius = width/2
        floatingButton.clipsToBounds = true
        view.addSubview(floatingButton)
        floatingButton.translatesAutoresizingMaskIntoConstraints = false
        floatingButton.widthAnchor.constraint(equalToConstant: width).isActive = true
        floatingButton.heightAnchor.constraint(equalToConstant: width).isActive = true
        floatingButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        floatingButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        return floatingButton
    }

    // No internet alert
    static func showNoInternetAlert(in viewController: UIViewController? = nil){
        if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
            let vc = NoInternetAlert.init()
            vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            vc.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            if viewController != nil {
                viewController?.present(vc, animated: true, completion: nil)
            } else if let _visibleViewController = self.getVisibleViewController(nil) {
                _visibleViewController.present(vc, animated: true, completion: nil)
            } else {
                if let _window = appDelegate.window, let _rootViewController = _window.rootViewController {
                    _rootViewController.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    // TTS alert
    static func showTtsAlert (viewController: UIViewController?, chatItemModel: HistoryChatItemModel, hideMenuButton: Bool, hideBottmSection: Bool, saveDataToDB: Bool, fromHistory:Bool, ttsAlertControllerDelegate: TtsAlertControllerDelegate?, isRecreation: Bool, hideTalkButton: Bool = false) {
        let chatItem = chatItemModel.chatItem!
        if saveDataToDB == true{
            do {
                let row = try ChatDBModel.init().insert(item: chatItem)
                chatItem.id = row
                UserDefaultsProperty<Int64>(kLastSavedChatID).value = row
            } catch _ {}
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KTtsAlertController)as! TtsAlertController
        controller.delegate = viewController as? SpeechControllerDismissDelegate
        controller.chatItemModel = chatItemModel
        controller.hideMenuButton = hideMenuButton
        controller.hideBottomView = hideBottmSection
        controller.isFromHistory = fromHistory
        controller.ttsAlertControllerDelegate = ttsAlertControllerDelegate
        controller.isRecreation = isRecreation
        controller.hideTalkButton = hideTalkButton
        if(viewController?.navigationController != nil){
            let navController = UINavigationController.init(rootViewController: controller)
            navController.modalPresentationStyle = .fullScreen
            controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController?.navigationController?.present(navController, animated: true, completion: nil)
        }else{
            controller.modalPresentationStyle = .fullScreen
            viewController?.present(controller, animated: true, completion: nil)
        }
    }

    /// Accessing Appdelegate instance
    static func appdelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    // Show alert when runtime permission is disabled

    static func showAlert(title : String, message: String, in viewController: UIViewController? = nil, compleationHandler: @escaping () -> Void ) {
        if let appDelegate: AppDelegate = UIApplication.shared.delegate as? AppDelegate {
            // Init alert
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let allowAccessAction = UIAlertAction(title: kActionAllowAccess, style: .default, handler: {action in
                compleationHandler()
            })

            let cancelAction = UIAlertAction(title: kActionCancel, style: .default, handler: nil)

            alertController.addAction(cancelAction)
            alertController.addAction(allowAccessAction)


            alertController.preferredAction = allowAccessAction

            // Show alert
            if viewController != nil {
                viewController?.present(alertController, animated: true, completion: nil)
            } else if let visibleViewController = self.getVisibleViewController(nil) {
                visibleViewController.present(alertController, animated: true, completion: nil)
            } else {
                if let _window = appDelegate.window, let rootViewController = _window.rootViewController {
                    rootViewController.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    // Open app permission in Setting Application

    static func openSettingsApplication() {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }

    /// show microphone, camera, photo library permission alert
    static func showPermissionAlert (viewController : UIViewController?, title : String, message : String) {
        let alertService = CustomAlertViewModel()
        let alert = alertService.alertDialogWithTitleWithActionButton(title: title.localiz(), message:message.localiz(), buttonTitle: kTitleOk.localiz(), cancelTitle: kNotAllow.localiz()) {
        }
        alert.buttonAction = {
            GlobalMethod.openSettingsApplication()
        }
        alert.modalPresentationStyle = .overCurrentContext
        alert.modalTransitionStyle = .crossDissolve
        viewController?.present(alert, animated: true, completion: nil)
    }

    static func removeQuotationMark (input : String) -> String {
        var output = Array(input)
        var index = 0
        while index < output.count {
            let element = output[index]
            if element == "\"" {
                if index == 0 || index == output.count - 1 {
                    output.remove(at: index)
                    index -= 1
                } else if (index > 0) && output[index - 1] == " " {
                    output.remove(at: index)
                    index -= 1
                } else if (index < output.count - 1) && output[index + 1] == " " {
                    output.remove(at: index)
                    index -= 1
                } else {
                    output[index] = " "
                }
            }
            index += 1
        }
        return String(output)
    }
    
    static func getRetranslationAndReverseTranslationData(sttdata: String, srcLang: String, destlang: String)-> String {
           PrintUtility.printLog(tag: "TTT SRC TEXT", text: sttdata)
           PrintUtility.printLog(tag: "TTT SRC LANG", text: srcLang)
           PrintUtility.printLog(tag: "TTT DEST LANG", text: destlang)
           let jsonData = try! JSONEncoder().encode(["stt": sttdata, "srclang": srcLang,"destlang": destlang])
           return String(data: jsonData, encoding: .utf8)!
    }
    
    static func addMoveInTransitionAnimatation(duration: Double, animationStyle: CATransitionSubtype)-> CATransition{
        let transition = CATransition()
        transition.duration = duration
        transition.type = CATransitionType.moveIn
        transition.subtype = animationStyle
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        return transition
    }
    
    static func addMoveOutTransitionAnimatation(duration: Double, animationStyle: CATransitionSubtype)-> CATransition{
        let transition = CATransition()
        transition.duration = duration
        transition.type = CATransitionType.reveal
        transition.subtype = animationStyle
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        return transition
    }
    
    static func removePunctuation(of text: String) -> String{
        let punctuationList = [".", "。", "·", "։", "჻", "।", "‧", ",", "，", "、", "،", "\"", "!", "！", "¡", "՜", ";", "՝", "_", "〜", "~", "～", "|", "॥", "՚", "’", "-", "֊", "?", "？", ":", "：", "․", "׃", "՞", "¿", "」", "「", "'", "『", "』", "〝", "〟", "«", "»", "׀", "؟", "‘", "־", "״", "׳", "။"]
        var textWithoutPronounciations = text
        for pronounciationItem in punctuationList{
            textWithoutPronounciations = textWithoutPronounciations.replacingOccurrences(
                of: pronounciationItem,
                with: "",
                options: NSString.CompareOptions.literal,
                range: nil
            )
        }
        return textWithoutPronounciations
    }
    
    static func getAlternativeSystemLanguageCode(of sysLangCode: String) -> String{
        var convertedLangCode = sysLangCode
        
        if sysLangCode == SystemLanguageCode.zhHans.rawValue {
            convertedLangCode = AlternativeSystemLanguageCode.zh.rawValue
        } else if sysLangCode == SystemLanguageCode.zhHant.rawValue {
            convertedLangCode = AlternativeSystemLanguageCode.zhTW.rawValue
        } else if sysLangCode == SystemLanguageCode.ptPT.rawValue {
            convertedLangCode = AlternativeSystemLanguageCode.pt.rawValue
        }
        
        return convertedLangCode
    }
    
    static func getCountryCodeFrom(_ countryListItem: CountryListItemElement?, and langCode: String) -> String{
        var countryCode = String()
        let countryEnName = countryListItem?.countryName.en ?? "en"
        
        if langCode == SystemLanguageCode.ja.rawValue {
            countryCode = countryListItem?.countryName.ja ?? countryEnName
        } else if langCode == SystemLanguageCode.es.rawValue {
            countryCode = countryListItem?.countryName.es ?? countryEnName
        } else if langCode == SystemLanguageCode.fr.rawValue {
            countryCode = countryListItem?.countryName.fr ?? countryEnName
        } else if langCode == SystemLanguageCode.zhHans.rawValue {
            countryCode = countryListItem?.countryName.zh ?? countryEnName
        } else if langCode == SystemLanguageCode.ko.rawValue {
            countryCode = countryListItem?.countryName.ko ?? countryEnName
        } else if langCode == SystemLanguageCode.de.rawValue {
            countryCode = countryListItem?.countryName.de ?? countryEnName
        } else if langCode == SystemLanguageCode.it.rawValue{
            countryCode = countryListItem?.countryName.it ?? countryEnName
        } else if langCode == SystemLanguageCode.zhHant.rawValue {
            countryCode = countryListItem?.countryName.zhTW ?? countryEnName
        } else if langCode == SystemLanguageCode.ru.rawValue {
            countryCode = countryListItem?.countryName.ru ?? countryEnName
        } else if langCode == SystemLanguageCode.ms.rawValue {
            countryCode = countryListItem?.countryName.ms ?? countryEnName
        } else if langCode == SystemLanguageCode.th.rawValue {
            countryCode = countryListItem?.countryName.th ?? countryEnName
        } else if langCode == SystemLanguageCode.ptPT.rawValue {
            countryCode = countryListItem?.countryName.pt ?? countryEnName
        } else {
            countryCode = countryEnName
        }
        
        return countryCode
    }

    static func getURLString() -> (supportURL: String, userManuelURL: String, termsAndConditionsURL: String) {
        let schemeName = Bundle.main.infoDictionary![currentSelectedSceme] as! String
        switch (schemeName) {
        case BuildVarientScheme.PRODUCTION.rawValue:
            return (PRODUCTION_SUPPORT_URL, PRODUCTION_USER_MANUEL_URL, PRODUCTION_TERMS_AND_CONDITIONS_URL)
        case BuildVarientScheme.STAGING.rawValue:
            return (STAGING_SUPPORT_URL, STAGING_USER_MANUEL_URL, STAGING_TERMS_AND_CONDITIONS_URL)
        case BuildVarientScheme.LOAD_ENGINE_FROM_ASSET.rawValue, BuildVarientScheme.APP_STORE_BJIT.rawValue, BuildVarientScheme.SERVER_API_LOG.rawValue, BuildVarientScheme.APP_STORE_SN.rawValue:
            return (STAGING_SUPPORT_URL, STAGING_USER_MANUEL_URL, STAGING_TERMS_AND_CONDITIONS_URL)
        default:
            return (STAGING_SUPPORT_URL, STAGING_USER_MANUEL_URL, STAGING_TERMS_AND_CONDITIONS_URL)
        }
    }
}

class GlobalAlternative{

    func showTtsAlert(viewController: UIViewController?, chatItemModel: HistoryChatItemModel, hideMenuButton: Bool, hideBottmSection: Bool, saveDataToDB: Bool, fromHistory:Bool, ttsAlertControllerDelegate: TtsAlertControllerDelegate?, isRecreation: Bool, fromSpeech: Bool = false) {
       let chatItem = chatItemModel.chatItem!
       if saveDataToDB == true{
           do {
               let row = try ChatDBModel.init().insert(item: chatItem)
               chatItem.id = row
               UserDefaultsProperty<Int64>(kLastSavedChatID).value = row
           } catch _ {}
       }

       let storyboard = UIStoryboard(name: "Main", bundle: nil)
       let controller = storyboard.instantiateViewController(withIdentifier: KTtsAlertController)as! TtsAlertController
       controller.delegate = viewController as? SpeechControllerDismissDelegate
       controller.chatItemModel = chatItemModel
       controller.hideMenuButton = hideMenuButton
       controller.hideBottomView = hideBottmSection
       controller.isFromHistory = fromHistory
       controller.ttsAlertControllerDelegate = ttsAlertControllerDelegate
       controller.isRecreation = isRecreation
       controller.isFromSpeechProcessing = fromSpeech
       //controller.currentTSDelegate = viewController as? CurrentTSDelegate
       //controller.speechProDismissDelegateFromTTS = viewController as? SpeechProcessingDismissDelegate
       if(viewController?.navigationController != nil){
           if fromHistory {
               controller.modalPresentationStyle = .fullScreen
            viewController?.navigationController?.pushViewController(controller, animated: true)
           } else {
               let navController = UINavigationController.init(rootViewController: controller)
               controller.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
               controller.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
               viewController?.navigationController?.present(navController, animated: true, completion: nil)
           }
           
       }else{
           controller.modalPresentationStyle = .fullScreen
           viewController?.present(controller, animated: true, completion: nil)
       }
   }
}

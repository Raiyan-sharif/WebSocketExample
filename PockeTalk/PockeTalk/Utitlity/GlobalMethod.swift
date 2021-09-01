//
//  GlobalMethod.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/1/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import Foundation
import UIKit

class GlobalMethod {
    // MARK: - Constants
    static let mainWindow: UIWindow? = UIApplication.shared.delegate?.window as? UIWindow
    static let screenSize: CGRect = UIScreen.main.bounds
    static let isWideScreen: Bool = GlobalMethod.screenSize.height >= 568.0
    static let displayScale: CGFloat = GlobalMethod.screenSize.width / 375.0

    // Fonts
    static let mainFont: UIFont = UIFont.systemFont(ofSize: 15.0 * GlobalMethod.displayScale)

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
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                completion?()
            }))

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
        print("Time : \(Int(time))")

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
}

//
//  AppDelegate.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 8/31/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Set initial view controller
        if UserDefaultsProperty<Bool>(kIsShownLanguageSettings).value == nil{
            let navVC = NavigationViewController()
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = navVC
            window?.makeKeyAndVisible()
            navVC.pushViewController(SystemLanguageViewController(), animated: false)
        }else{
            LanguageSelectionManager.shared.getLanguageSelectionData()
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
            let navigationController = UINavigationController.init(rootViewController: viewController)
            self.window?.rootViewController = navigationController
            self.window?.makeKeyAndVisible()
        }
        return true
    }
}


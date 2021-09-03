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
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let homeViewController = mainStoryboard.instantiateViewController(withIdentifier: String(describing: HomeViewController.self))
        let navVC = NavigationViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
        navVC.pushViewController(homeViewController, animated: false)
        return true
    }
}


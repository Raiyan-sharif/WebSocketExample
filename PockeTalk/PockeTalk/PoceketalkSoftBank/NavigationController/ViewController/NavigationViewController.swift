//
//  NavigationViewController.swift
//  PockeTalk
//

import UIKit

class NavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.backgroundColor = .white
        self.navigationBar.barTintColor = UIColor.black
        self.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

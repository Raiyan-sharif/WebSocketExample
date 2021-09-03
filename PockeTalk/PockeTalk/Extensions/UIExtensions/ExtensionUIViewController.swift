//
// ExtensionUIViewController.swift
// PockeTalk
//
// Created by Shymosree on 9/2/21.
// Copyright © 2021 BJIT Inc. All rights reserved.
//

import UIKit

extension UIViewController{
    // Define toast message and duration
    func showToast(message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.9
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
}

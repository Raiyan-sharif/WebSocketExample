//
//  ExtensionUINavigationController.swift
//  PockeTalk
//
//  Created by Khairuzzaman Shipon on 9/2/21.
//  Copyright © 2021 Bjit ltd. on All rights reserved.
//

import UIKit

extension UINavigationController {
  func popToViewController(ofClass: AnyClass, animated: Bool = true) {
    if let vc = viewControllers.last(where: { $0.isKind(of: ofClass) }) {
      popToViewController(vc, animated: animated)
    }
  }
}

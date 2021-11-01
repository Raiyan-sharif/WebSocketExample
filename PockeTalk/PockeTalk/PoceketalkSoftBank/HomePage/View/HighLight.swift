//
//  HighLight.swift
//  PockeTalk
//

import Foundation
import UIKit

class HighlightedButton: UIButton {

    override var isHighlighted: Bool {
        didSet {
            if isHighlighted{
                setBackgroundImage(#imageLiteral(resourceName: "tap_home_bg"), for: .highlighted)
            }else{
                setBackgroundImage(UIImage(), for: .normal)
            }
        }
    }
}

//
//  HighLight.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/15/21.
//

import Foundation

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

//
//  CustomShapeButton.swift
//  PockeTalk
//
//  Created by Md. Moshiour Rahman on 6/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import Foundation

import UIKit

@IBDesignable class RoundButtonWithBorder: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }

    
    // borderWidth
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    // border color
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    
    @IBInspectable var cornerRadious: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadious
        }
    }

    
    

}

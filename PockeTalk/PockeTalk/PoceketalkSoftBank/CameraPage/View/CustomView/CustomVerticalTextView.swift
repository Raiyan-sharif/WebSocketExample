//
//  CustomVerticalTextView.swift
//  gfgjjkkjn
//
//  Created by BJIT LTD on 27/9/21.
//
//

import UIKit

class VerticalTextView: UILabel {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    func commonInit(){
        var radians = CGFloat()
        radians = (90 / 180.0 * CGFloat.pi)
        let rotation = self.transform.rotated(by: radians)
        self.transform = rotation
        self.numberOfLines = 0
        self.backgroundColor = .gray
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.5
    }
}

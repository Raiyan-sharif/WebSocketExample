//
//  ColorProgressStrokeAnimation.swift
//  Custom Loader
//
//

import UIKit

class ColorProgressStrokeAnimation: CAKeyframeAnimation {
    
    override init() {
        super.init()
    }
    
    init(listOfcolors: [CGColor], colorProgressAnimationDuration: Double) {
        
        super.init()
        
        self.keyPath = "strokeColor"
        self.values = listOfcolors
        self.duration = colorProgressAnimationDuration
        self.repeatCount = .greatestFiniteMagnitude
        self.timingFunction = .init(name: .easeInEaseOut)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

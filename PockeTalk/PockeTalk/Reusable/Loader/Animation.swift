//  Animation.swift
//  PockeTalk
//
//

import UIKit

class Animation: CABasicAnimation {
    
    override init() {
        super.init()
    }
    
    init(type: StrokeType,
         progressBeginTime: Double = 0.0,
         progressFromValue: CGFloat,
         progressToValue: CGFloat,
         progressTotalDuration: Double) {
        
        super.init()
        
        self.keyPath = type == .start ? "strokeStart" : "strokeEnd"
        
        self.beginTime = progressBeginTime
        self.fromValue = progressFromValue
        self.toValue = progressToValue
        self.duration = progressTotalDuration
        self.timingFunction = .init(name: .easeInEaseOut)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum StrokeType {
        case start
        case end
    }
}

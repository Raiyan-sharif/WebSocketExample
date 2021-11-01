//
//  RotationProgress.swift
//  PockeTalk
//


import UIKit

class RotationProgress: CABasicAnimation {
    
    enum Direction: String {
        case x, y, z
    }
    
    override init() {
        super.init()
    }
    
    public init(
        animation_direction: Direction,
        animation_from_Value: CGFloat,
        animation_to_Value: CGFloat,
        animationDuration: Double,
        animationRepeatCount: Float
    ) {

        super.init()
        
        self.keyPath = "transform.rotation.\(animation_direction.rawValue)"
        
        self.fromValue = fromValue
        self.toValue = toValue
        
        self.duration = duration
        
        self.repeatCount = repeatCount
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

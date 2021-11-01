//
//  CustomLoaderProgressView.swift
//  PockeTalk


import UIKit

class CustomLoaderProgressView: UIView {
    
    private lazy var animationShape: AnimatedSLayer = {
        return AnimatedSLayer(strokeColor: listOfcolors.first!, lineWidth: lineWidth)
    }()

    let listOfcolors: [UIColor]
    let lineWidth: CGFloat

    init(frame: CGRect,
         listOfcolors: [UIColor],
         widthOfLine: CGFloat
    ) {
        self.listOfcolors = listOfcolors
        self.lineWidth = widthOfLine
        
        super.init(frame: frame)
        
        self.backgroundColor = .clear
    }
    
    convenience init(colors: [UIColor], widthOfLine: CGFloat) {
        self.init(frame: .zero, listOfcolors: colors, widthOfLine: widthOfLine)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.width / 2
        
        let path = UIBezierPath(ovalIn:
            CGRect(
                x: 0,
                y: 0,
                width: self.bounds.width,
                height: self.bounds.width
            )
        )
        
        animationShape.path = path.cgPath
    }
    
    func getAnimatingStroke() {
        
        let start = Animation(type: .start, progressBeginTime: 0.25, progressFromValue: 0.0, progressToValue: 1.0, progressTotalDuration: 0.75)

        
        let end = Animation(type: .end, progressFromValue: 0.0, progressToValue: 1.0, progressTotalDuration: 0.75)
        
        let circleAniGroup = CAAnimationGroup()
        circleAniGroup.duration = 1
        circleAniGroup.repeatDuration = .infinity
        circleAniGroup.animations = [start, end]
        
        animationShape.add(circleAniGroup, forKey: nil)
        
        let colorAnimation = ColorProgressStrokeAnimation(
            listOfcolors: listOfcolors.map { $0.cgColor },
            colorProgressAnimationDuration: circleAniGroup.duration * Double(listOfcolors.count)
        )

        animationShape.add(colorAnimation, forKey: nil)
        
        self.layer.addSublayer(animationShape)
    }
    
    func getAnimationRotation() {
        let rotation = RotationProgress(animation_direction: .z, animation_from_Value: 0, animation_to_Value: CGFloat.pi * 2, animationDuration: 2, animationRepeatCount: .greatestFiniteMagnitude)
        
        
        self.layer.add(rotation, forKey: nil)
    }
            
    var isAnimating: Bool = false {
        didSet {
            if !isAnimating {
                self.animationShape.removeFromSuperlayer()
                self.layer.removeAllAnimations()
                
            } else {
                self.getAnimatingStroke()
                self.getAnimationRotation()
            }
        }
    }
}

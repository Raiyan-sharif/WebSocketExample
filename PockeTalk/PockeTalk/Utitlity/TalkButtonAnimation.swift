//
//  TalkButtonAnimation.swift
//  PockeTalk
//
//  Created by Raiyan on 10/11/21.
//

import UIKit


class TalkButtonAnimation{
    static var isTalkBtnAnimationExist: Bool = false
    
    static func startTalkButtonAnimation(pulseGrayWave: UIView, pulseLayer: CAShapeLayer, midCircleViewOfPulse: UIView, bottomImageView: UIImageView){
        DispatchQueue.main.async {
            if (ScreenTracker.sharedInstance.screenPurpose == .PronunciationPractice || ScreenTracker.sharedInstance.screenPurpose == .HistroyPronunctiation){
                bottomImageView.isHidden = true
            }
            else{
                bottomImageView.isHidden = false
            }
        }
        let width = 100
        let window = UIApplication.shared.keyWindow ?? UIWindow()
        let imageView = window.viewWithTag(109) as! UIImageView
        pulseGrayWave.frame = CGRect(x: Int(imageView.frame.midX) - width/2, y: Int(imageView.frame.midY) - width/2, width: width, height: width)
        pulseGrayWave.layer.cornerRadius = 50
        pulseGrayWave.backgroundColor = UIColor(displayP3Red: 154/255, green: 154/255, blue: 154/255, alpha: 0.4)
        
        let scaleAnimation2:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
                
        scaleAnimation2.duration = 1
        scaleAnimation2.repeatCount = Float.infinity
        scaleAnimation2.fromValue = 0.5
        scaleAnimation2.toValue = 1.7
        
        pulseGrayWave.layer.add(scaleAnimation2, forKey: "scale")
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 50, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        pulseLayer.path = circularPath.cgPath
        pulseLayer.lineWidth = 2.0
        pulseLayer.fillColor = UIColor.clear.cgColor
        pulseLayer.strokeColor = UIColor.white.cgColor
        pulseLayer.opacity = 0.9
        pulseLayer.lineCap = CAShapeLayerLineCap.round
        pulseLayer.frame = CGRect(x: imageView.frame.midX , y: imageView.frame.midY, width: 2, height: 0)
        let scaleAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = 1
        scaleAnimation.repeatCount = Float.infinity
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = 0.8
        scaleAnimation.toValue = 1.4
        pulseLayer.add(scaleAnimation, forKey: "scale")
        midCircleViewOfPulse.frame = CGRect(x: imageView.frame.midX - 50, y: imageView.frame.midY - 50, width: 100, height: 100)
        midCircleViewOfPulse.layer.cornerRadius = 50
        midCircleViewOfPulse.backgroundColor = UIColor(displayP3Red: 62/255, green: 140/255, blue: 224/255, alpha: 1.0)
        let scaleAnimation1:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation1.duration = 1
        scaleAnimation1.repeatCount = Float.infinity
        scaleAnimation1.autoreverses = true
        scaleAnimation1.fromValue = 0.8
        scaleAnimation1.toValue = 1.1
        midCircleViewOfPulse.layer.add(scaleAnimation1, forKey: "scale")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            pulseLayer.isHidden = false
        })
        pulseGrayWave.isHidden = false
        midCircleViewOfPulse.isHidden = false
        bottomImageView.isHidden = false
    }
    static func stopAnimation(bottomView: UIView, pulseGrayWave: UIView, pulseLayer: CAShapeLayer, midCircleViewOfPulse: UIView, bottomImageView: UIImageView){
        bottomView.subviews.forEach({
            $0.layer.removeAllAnimations()})
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            pulseLayer.isHidden = true
            bottomView.subviews.forEach({
                $0.layer.removeAllAnimations()})
        })
        pulseGrayWave.isHidden = true
        pulseLayer.isHidden = true
        midCircleViewOfPulse.isHidden = true
        bottomImageView.isHidden = true
    }
}

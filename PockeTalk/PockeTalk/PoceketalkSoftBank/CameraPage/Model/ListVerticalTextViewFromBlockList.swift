//
//  ListVerticalTextViewFromBlockList.swift
//  PockeTalk
//
//  Created by BJIT LTD on 13/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import Foundation


class ListVerticalTextViewFromBlockList {
    
    func getListVerticalTextViewFromBlockList(detectedBlockList: [BlockDetection], completion: @escaping(_ data: [VerticalTextViewWithCoordinator])-> Void) {
        var x = 0
        var y = 0
        var listBlockVerticalTextView = [VerticalTextViewWithCoordinator]()
        
        
//        let blockView1 = UITextView(frame:CGRect(x: 0, y: 0, width: 150, height: 75))
//        let textView1 = UITextView()
//        textView1.contentInsetAdjustmentBehavior = .automatic
//        textView1.center = .zero
//        textView1.textAlignment = NSTextAlignment.justified
//        textView1.textColor = UIColor.red
//        textView1.font = .systemFont(ofSize: 14)
//        textView1.backgroundColor = UIColor.green
//        textView1.isUserInteractionEnabled = false
//
//        textView1.frame.origin.x = 0.0
//        textView1.frame.origin.y = 0.0
//        textView1.frame.size.height = 200
//        textView1.frame.size.width = 200
//
//        blockView1.frame.size.height = 200
//        blockView1.frame.size.width = 200
//
//        textView1.text = "verticalTextView.setText(mListBlockDetection.get(i).getBlockText())"
//        blockView1.addSubview(textView1)
//        listBlockVerticalTextView.append(VerticalTextViewWithCoordinator(view: blockView1, X1: 0, Y1: 0))
        

        for (index, each) in detectedBlockList.enumerated() {
            let blockView = UITextView(frame:CGRect(x: 0, y: 0, width: 150, height: 75))
            blockView.backgroundColor = .clear
            //view.addSubview(blockView)

            let textView = UITextView()
            textView.contentInsetAdjustmentBehavior = .automatic
            textView.center = blockView.center
            textView.textAlignment = NSTextAlignment.justified
            textView.textColor = UIColor.red
            textView.font = .systemFont(ofSize: 14)
            textView.backgroundColor = UIColor.green
            textView.isUserInteractionEnabled = false

            textView.text = each.text
            
            textView.translatesAutoresizingMaskIntoConstraints = true
                textView.sizeToFit()
            textView.isScrollEnabled = false
            
    
            var width = CGFloat()
            var height = CGFloat()
            
            var angle = PointUtils.getAngleFromVerticalLine(A: CGPoint(x: each.X1!,y: each.Y1!),  B: CGPoint(x: each.X2!,y: each.Y2!))
            
            if(PointUtils.isVerticalBlock(CGPoint(x: each.X1!,y: each.Y1!), CGPoint(x: each.X2!,y: each.Y2!))) { //!Arrays.asList(CameraConstants.RIGHT_TO_LEFT_TEXT).contains(lanCode)
                
                width = PointUtils.distanceBetweenPoints(CGPoint(x: each.X1!, y: each.Y1!), CGPoint(x: each.X4!, y: each.Y4!))
                
                height = PointUtils.distanceBetweenPoints(CGPoint(x: each.X1!, y: each.Y1!), CGPoint(x: each.X2!, y: each.Y2!))
                
                
                if(each.bottomTopBlock == index){
                    if(angle != 0){
                        angle = 90 - abs(angle);
                    }
                    x = each.X2!
                    y = each.Y2!
                    
                   // verticalTextView.setGravity(Gravity.BOTTOM);

                }else{
                    if(angle != 0) {
                        angle = abs(angle) - 90;
                    }
                    x = each.X4!
                    y = each.Y4!
                }


            }
            
            blockView.frame.size.width =  height
            blockView.frame.size.height = width
            print("angle calculation: \(angle)")
            blockView.transform = CGAffineTransform(rotationAngle: .pi/2)
            
            textView.frame.origin.x = blockView.bounds.origin.x
            textView.frame.origin.y = blockView.bounds.origin.y
            
            blockView.addSubview(textView)
            
            listBlockVerticalTextView.append(VerticalTextViewWithCoordinator(view: blockView, X1: x, Y1: y))
            print("coordinator: \(each.X1!),  \(each.Y1!)")
            
        }
        
       completion(listBlockVerticalTextView)
    }

}

struct VerticalTextViewWithCoordinator {
    var view: UIView
    var X1, Y1: Int
}

//
//  ParseTextDetection.swift
//  PockeTalk
//

import Foundation
import UIKit

class ParseTextDetection: BaseModel {
    
    func getListVerticalTextViewFromBlockList(detectedBlockList: [BlockDetection], arrTranslatedText: [String], completion: @escaping(_ data: [TextViewWithCoordinator])-> Void) {
        var x = 0
        var y = 0
        var listBlockVerticalTextView = [TextViewWithCoordinator]()
        
        for ttext in arrTranslatedText {
            PrintUtility.printLog(tag: "ParseTextDetection() >> getListHorizontalTextViewFromBlockList() >> ", text: "TranslatedText: \(ttext)")
        }
        // TO DO: Delete it when camera functionality implementation is complete
        
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
        //
        //        blockView1.frame.size.height = 200
        //        blockView1.frame.size.width = 200
        //
        //        blockView1.transform = CGAffineTransform(rotationAngle: (CGFloat(70) * CGFloat.pi/180))
        //
        //        textView1.text = "verticalTextView.setText(mListBlockDetection.get(i).getBlockText())"
        //        blockView1.addSubview(textView1)
        //        listBlockVerticalTextView.append(VerticalTextViewWithCoordinator(view: blockView1, X1: 0, Y1: 0))
        
        
        for (index, each) in detectedBlockList.enumerated() {
            
            var textView = UILabel()
            
            var width = CGFloat()
            var height = CGFloat()
            
            var angle = PointUtils.getAngleFromVerticalLine(A: CGPoint(x: each.X1!,y: each.Y1!),  B: CGPoint(x: each.X2!,y: each.Y2!))
            PrintUtility.printLog(tag: "Angle Detected: ", text: "\(angle)")
            PrintUtility.printLog(tag: " isVerticalBlock .......>>>", text: "\(PointUtils.isVerticalBlock(CGPoint(x: each.X1!,y: each.Y1!), CGPoint(x: each.X2!,y: each.Y2!)))")
            
            if(PointUtils.isVerticalBlock(CGPoint(x: each.X1!,y: each.Y1!), CGPoint(x: each.X2!,y: each.Y2!))) { // !Arrays.asList(CameraConstants.RIGHT_TO_LEFT_TEXT).contains(lanCode)
                
                width = PointUtils.distanceBetweenPoints(CGPoint(x: each.X1!, y: each.Y1!), CGPoint(x: each.X4!, y: each.Y4!))
                
                height = PointUtils.distanceBetweenPoints(CGPoint(x: each.X1!, y: each.Y1!), CGPoint(x: each.X2!, y: each.Y2!))
                
                
                if(each.bottomTopBlock != BLOCK_DIRECTION){
                    PrintUtility.printLog(tag: "BLOCK_DIRECTION", text: "Bottom-to-top Block")
                    angle = angle * -1
                    x = each.X2!
                    y = each.Y2!
                    textView = BottomToTopVerticalTextView()
                    // verticalTextView.setGravity(Gravity.BOTTOM);
                    
                }else{
                    PrintUtility.printLog(tag: "BLOCK_DIRECTION", text: "Top-to-bottom Block")
                    //angle = abs(angle)
                    x = each.X4!
                    y = each.Y4!
                    textView = VerticalTextView()
                }
                
                textView.textColor = .red
                textView.backgroundColor = .gray
                textView.numberOfLines = 0
                textView.adjustsFontSizeToFitWidth = true
                textView.minimumScaleFactor = 0.5
                textView.text = arrTranslatedText[index]
                textView.sizeToFit()

                PrintUtility.printLog(tag: "angle", text: "\(angle)")
                PrintUtility.printLog(tag: "angle calculation", text: "\(CGFloat(angle))")
                
                //TO DO: Need To Update
                //                if (angle != 90 || angle != -90) {
                //                    textView.setAnchorPoint(CGPoint(x: 0, y: 1))
                //                    textView.transform = CGAffineTransform(rotationAngle: ((CGFloat(angle) * CGFloat.pi/180) + (90 / 180.0 * CGFloat.pi)))
                //                }
                
                textView.frame = CGRect(x: CGFloat(x), y: CGFloat(y), width: width, height: height)
                
                if angle > 0 {
                    //
                } else {
                    angle = abs(angle)
                    angle = -90 + angle
                }
                
                if(each.bottomTopBlock != BLOCK_DIRECTION){

                    let  transA = CGAffineTransform(translationX: textView.frame.size.width/2,y: textView.frame.size.height/2)
                    let  rotation = CGAffineTransform(rotationAngle: (CGFloat(angle * -1) * CGFloat.pi/180))
                    let  transB = CGAffineTransform(translationX: -textView.frame.size.width/2,y: -textView.frame.size.height/2)
                    let transform = transA.concatenating(rotation).concatenating(transB)
                    textView.transform = textView.transform.concatenating(transform)
                    
                } else {
                
                let  transA = CGAffineTransform(translationX: textView.frame.size.width/2,y: textView.frame.size.height/2)
                let  rotation = CGAffineTransform(rotationAngle: (CGFloat(angle) * CGFloat.pi/180))
                let  transB = CGAffineTransform(translationX: -textView.frame.size.width/2,y: -textView.frame.size.height/2)
                    
                    let transform = transA.concatenating(rotation).concatenating(transB)
                    textView.transform = textView.transform.concatenating(transform)
                }

                PrintUtility.printLog(tag: "BLOCK width:\(height)", text: "height: \(width)")
                PrintUtility.printLog(tag: "BLOCK x:\(x)", text: "y: \(y)")
                listBlockVerticalTextView.append(TextViewWithCoordinator(view: textView, X1: x, Y1: y, translatedText: arrTranslatedText[index], detectedText: each.text!, detectedLanguage: each.detectedLanguage!))
            }
        }
        
        completion(listBlockVerticalTextView)
    }
    
    func getListHorizontalTextViewFromBlockList(detectedBlockList: [BlockDetection], arrTranslatedText: [String], completion: @escaping(_ data: [TextViewWithCoordinator])-> Void) {
        var listBlockVerticalTextView = [TextViewWithCoordinator]()
        
        for ttext in arrTranslatedText {
            PrintUtility.printLog(tag: "ParseTextDetection() >> getListHorizontalTextViewFromBlockList() >> ", text: "TranslatedText: \(ttext)")
        }
        
        for (index, each) in detectedBlockList.enumerated() {
            
            let textView = UILabel()
            textView.textColor = .red
            textView.backgroundColor = .gray
            textView.numberOfLines = 0
            textView.adjustsFontSizeToFitWidth = true
            textView.minimumScaleFactor = 0.5
            
            //textView.text = each.text
            textView.text = arrTranslatedText[index]
            textView.sizeToFit()
            textView.isUserInteractionEnabled = true
            textView.tag = index
            var width = CGFloat()
            var height = CGFloat()
            
            let angle = PointUtils.getAngleFromVerticalLine(A: CGPoint(x: each.X1!,y: each.Y1!),  B: CGPoint(x: each.X2!,y: each.Y2!))
            
            PrintUtility.printLog(tag: " isHorizontalBlock .......>>>", text: "\(PointUtils.isVerticalBlock(CGPoint(x: each.X1!,y: each.Y1!), CGPoint(x: each.X2!,y: each.Y2!)))")
            if(!PointUtils.isVerticalBlock(CGPoint(x: each.X1!,y: each.Y1!), CGPoint(x: each.X2!,y: each.Y2!))) { // !Arrays.asList(CameraConstants.RIGHT_TO_LEFT_TEXT).contains(lanCode)
                
                width = PointUtils.distanceBetweenPoints(CGPoint(x: each.X1!, y: each.Y1!), CGPoint(x: each.X2!, y: each.Y2!))
                
                height = PointUtils.distanceBetweenPoints(CGPoint(x: each.X1!, y: each.Y1!), CGPoint(x: each.X4!, y: each.Y4!))
                
                if(each.rightLeftBlock != BLOCK_DIRECTION){
                    //textView.transform = CGAffineTransform(rotationAngle: .pi * -1)
                    PrintUtility.printLog(tag: "ParseTextDetection", text: "left to right")
                    // verticalTextView.setGravity(Gravity.BOTTOM);
                } else {
                    PrintUtility.printLog(tag: "ParseTextDetection", text: "right to left")
                }
                
                PrintUtility.printLog(tag: "angle", text: "\(angle)")
                PrintUtility.printLog(tag: "angle calculation horizontal", text: "\(CGFloat(angle))")
                textView.frame = CGRect(x: CGFloat(each.X1!), y: CGFloat(each.Y1!), width: width, height: height)
                
                let view1 = UIView()
                view1.frame = CGRect(x: CGFloat(each.X1!), y: CGFloat(each.Y1!), width: width, height: height)
                
                //                view1.setAnchorPoint(CGPoint(x: 0, y: 0))
                //                view1.transform = CGAffineTransform(rotationAngle: (CGFloat(angle * -1) * CGFloat.pi/180))
                
                view1.addSubview(textView)
                textView.backgroundColor = .clear
                textView.translatesAutoresizingMaskIntoConstraints = false
                textView.leadingAnchor.constraint(equalTo: view1.leadingAnchor, constant: 0).isActive = true
                textView.trailingAnchor.constraint(equalTo: view1.trailingAnchor, constant: 0).isActive = true
                textView.topAnchor.constraint(equalTo: view1.topAnchor, constant: 0).isActive = true
                textView.bottomAnchor.constraint(equalTo: view1.bottomAnchor, constant: 0).isActive = true
                
                
                let  transA = CGAffineTransform(translationX: view1.frame.size.width/2,y: view1.frame.size.height/2)
                let  rotation = CGAffineTransform(rotationAngle: (CGFloat(angle * -1) * CGFloat.pi/180))
                let  transB = CGAffineTransform(translationX: -view1.frame.size.width/2,y: -view1.frame.size.height/2)
                
                
                let transform = transA.concatenating(rotation).concatenating(transB)
                view1.transform = view1.transform.concatenating(transform)
                
                listBlockVerticalTextView.append(TextViewWithCoordinator(view: view1, X1: each.X1!, Y1: each.Y1!, translatedText: arrTranslatedText[index], detectedText: each.text!, detectedLanguage: each.detectedLanguage!))
            }
            
        }
        
        completion(listBlockVerticalTextView)
    }
    
    func getTextArrayFromJSON(){
        
    }
    
}


struct TextViewWithCoordinator {
    var view: UIView
    var X1, Y1: Int
    var translatedText: String
    var detectedText : String
    var detectedLanguage: String
}


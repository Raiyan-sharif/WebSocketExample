//
//  PointUtils.swift
//  PockeTalk
//
//

import Foundation
import UIKit

public class PointUtils {
    static func parseResponseForBlock( dataToParse: FullTextAnnotation!, mDetectedLanguageCode: String, xFactor: Float, yFactor: Float) -> BlockClass{
        var blockClass: BlockClass = BlockClass(languageCodeFrom: "", blocks: [])
        //print("xFactor: \(xFactor), yFactor: \(yFactor)")
        if let dataToParse = dataToParse {
            var detectedLanCode: String = ""
            let pages = dataToParse.pages
            let numOfPages: Int = pages!.count
            PrintUtility.printLog(tag: "# of pages ", text: "\(numOfPages)")
            for page in pages!{
                let blocks = page.blocks
                var pageText: String = ""
                var intBlockIndex:Int = 0
                var bottomTopBlock: Int = -1, rightLeftBlock: Int = -1
                var arrBlockElement: Array<BlockElement> = []
                for block in blocks!{
                    let paragraps = block.paragraphs
                    var blockText: String = ""
                    var listLanguageCodes: Array<String> = []
                    var x1:Int = 0, y1:Int = 0, x2:Int = 0, y4:Int = 0, x3:Int = 0, x4:Int = 0, y2:Int = 0, y3:Int = 0
                    if let verticeX1 = block.boundingBox?.vertices![0].x{
                        x1 = nonMinusPoint(Int(Float(verticeX1) * xFactor))
                    }
                    if let verticeY1 = block.boundingBox?.vertices![0].y{
                        y1 = nonMinusPoint(Int(Float(verticeY1) * yFactor))
                    }
                    if let verticeX2 = block.boundingBox?.vertices![1].x{
                        x2 = nonMinusPoint(Int(Float(verticeX2) * xFactor))
                    }
                    if let verticeY2 = block.boundingBox?.vertices![1].y{
                        y2 = nonMinusPoint(Int(Float(verticeY2) * yFactor))
                    }
                    if let verticeX3 = block.boundingBox?.vertices![2].x{
                        x3 = nonMinusPoint(Int(Float(verticeX3) * xFactor))
                    }
                    if let verticeY3 = block.boundingBox?.vertices![2].y{
                        y3 = nonMinusPoint(Int(Float(verticeY3) * yFactor))
                    }
                    if let verticeX4 = block.boundingBox?.vertices![3].x{
                        x4 = nonMinusPoint(Int(Float(verticeX4) * xFactor))
                    }
                    if let verticeY4 = block.boundingBox?.vertices![3].y{
                        y4 = nonMinusPoint(Int(Float(verticeY4) * yFactor))
                    }
                    var blockText1: String = "(x1,y1)(\(x1),\(y1))(x2,y2)(\(x2),\(y2))(x3,y3)(\(x3),\(y3))(x4,y4)(\(x4),\(y4))"
                    let blockBoundingBoxes = BoundingBoxs(vertices: [Vertexs(x: x1, y: y1), Vertexs(x: x2, y:y2), Vertexs(x:x3,y:y3), Vertexs(x:x4, y:y4)])
                    
                    //PrintUtility.printLog(tag: " Bounding Box: ", text: "\(blockText1)")
                    
                    if(isVerticalBlock(CGPoint(x:x1, y:y1), CGPoint(x: x2, y: y2))){
                        if isBottomTop(y1, y2){
                            bottomTopBlock = intBlockIndex
                        } else{
                            bottomTopBlock = -1
                        }
                        rightLeftBlock = -1
                    } else{
                        if isRightLeft(x1, x3){
                            rightLeftBlock = intBlockIndex
                        } else{
                            rightLeftBlock = -1
                        }
                        bottomTopBlock = -1
                    }
                    for paragraph in paragraps!{
                        var paraText: String = ""
                        let words = paragraph.words
                        for word in words!{
                            var wordText: String = "", breakStr: String = "", strBreak: String = ""
                            let symbols = word.symbols
                            for symbol in symbols!{
                                wordText = wordText + symbol.text!
                                if let detectedBreak = symbol.property?.detectedBreak{
                                    if detectedBreak != nil {
                                        breakStr = detectedBreak.type!
                                    }
                                }
                                if let detectedLanguage = symbol.property?.detectedLanguages {
                                    if let languageCode: String = detectedLanguage[0].languageCode {
                                        if languageCode != nil {
                                            listLanguageCodes.append(languageCode)
                                        }
                                    }
                                }
                            }
                            strBreak = getBreakType(breakStr)
                            paraText = paraText + wordText + strBreak
                        }
                        blockText = blockText + paraText;
                    }
                    for element in listLanguageCodes {
                        //
                    }
                    detectedLanCode = getMaxOccurrenceLanguage(listLanguageCodes, mDetectedLanguageCode)
                    detectedLanCode = getValidCode(detectedLanCode)
                    var blockElement = BlockElement(boundingBox: blockBoundingBoxes, bottomTopBlock: bottomTopBlock, rightLeftBlock: rightLeftBlock, text: blockText, detectedLanguage: detectedLanCode)
                    arrBlockElement.append(blockElement)
                    intBlockIndex += intBlockIndex
                    pageText += blockText
                }
                blockClass = BlockClass(languageCodeFrom: mDetectedLanguageCode, blocks: arrBlockElement)
            }
        }
        PrintUtility.printLog(tag: " data parse.text ", text: "\(dataToParse.text)")
        return blockClass
    }
    static func parseResponseForLine( dataToParse: FullTextAnnotation!, mDetectedLanguageCode: String, xFactor: Float, yFactor: Float) -> BlockClass{
        var blockClass: BlockClass = BlockClass(languageCodeFrom: "", blocks: [])
        if let dataToParse = dataToParse {
            var detectedLanCode: String = ""
            let pages = dataToParse.pages
            let numOfPages: Int = pages!.count
            
            for page in pages!{
                var pageText: String = ""
                var intBlockIndex:Int = 0
                var bottomTopBlock: Int = -1, rightLeftBlock: Int = -1
                var arrBlockElement: Array<BlockElement> = []
                let blocks = page.blocks
                for block in blocks!{
                    var blockText: String = ""
                    let paragraps = block.paragraphs
                    for paragraph in paragraps!{
                        var paraText: String = ""
                        var lineText: String = ""
                        var listLanguageCodes: Array<String> = []
                        var x1:Int = 0, y1:Int = 0, x2:Int = 0, y4:Int = 0, x3:Int = 0, x4:Int = 0, y2:Int = 0, y3:Int = 0
                        let words = paragraph.words
                        for word in words!{
                            var wordText: String = "", breakStr: String = "", strBreak: String = ""
                            let symbols = word.symbols
                            for symbol in symbols!{
                                
                                //var blockText2: String = "(x1,y1)(\(x1),\(y1))(x2,y2)(\(x2),\(y2))(x3,y3)(\(x3),\(y3))(x4,y4)(\(x4),\(y4))"
                                //PrintUtility.printLog(tag: "Value of points: ", text: blockText2)
                                
                                if(x1==0 && y1 == 0 && x4 == 0 && y4 == 0 && x2 == 0 && y2 == 0 && x3 == 0 && y3 == 0) {
                                    if let verticeX1 = symbol.boundingBox?.vertices![0].x{
                                        x1 = nonMinusPoint(Int(Float(verticeX1) * xFactor))
                                    }
                                    if let verticeY1 = symbol.boundingBox?.vertices![0].y{
                                        y1 = nonMinusPoint(Int(Float(verticeY1) * yFactor))
                                    }
                                    if let verticeX2 = symbol.boundingBox?.vertices![1].x{
                                        x2 = nonMinusPoint(Int(Float(verticeX2) * xFactor))
                                    }
                                    if let verticeY2 = symbol.boundingBox?.vertices![1].y{
                                        y2 = nonMinusPoint(Int(Float(verticeY2) * yFactor))
                                    }
                                    if let verticeX3 = symbol.boundingBox?.vertices![2].x{
                                        x3 = nonMinusPoint(Int(Float(verticeX3) * xFactor))
                                    }
                                    if let verticeY3 = symbol.boundingBox?.vertices![2].y{
                                        y3 = nonMinusPoint(Int(Float(verticeY3) * yFactor))
                                    }
                                    if let verticeX4 = symbol.boundingBox?.vertices![3].x{
                                        x4 = nonMinusPoint(Int(Float(verticeX4) * xFactor))
                                    }
                                    if let verticeY4 = symbol.boundingBox?.vertices![3].y{
                                        y4 = nonMinusPoint(Int(Float(verticeY4) * yFactor))
                                    }
                                    var blockText3: String = "(x1,y1)(\(x1),\(y1))(x2,y2)(\(x2),\(y2))(x3,y3)(\(x3),\(y3))(x4,y4)(\(x4),\(y4))"
                                    PrintUtility.printLog(tag: "Starting points: ", text: blockText3)
                                }
                                wordText = wordText + symbol.text!
                                if let detectedBreak = symbol.property?.detectedBreak{
                                    if detectedBreak != nil {
                                        breakStr = detectedBreak.type!
                                    }
                                }
                                if(getBreakType(breakStr).contains("\n")) {
                                    PrintUtility.printLog(tag: "Symbol: ", text: symbol.text!)
                                    var lastX1:Int = 0, lastY1:Int = 0;
                                    if let verticeX1 = symbol.boundingBox?.vertices![0].x{
                                        lastX1 = nonMinusPoint(Int(Float(verticeX1) * xFactor))
                                    }
                                    if let verticeY1 = symbol.boundingBox?.vertices![0].y{
                                        lastY1 = nonMinusPoint(Int(Float(verticeY1) * yFactor))
                                    }
                                    //let a = area(x1, y1, x4, y4, lastX1, lastY1)
                                    //let b = area(x1, y1, x2, y2, lastX1, lastY1)
                                    //print("area(x1, y1, x4, y4, lastX1, lastY1): \(a) area(x1, y1, x2, y2, lastX1, lastY1): \(b)")
                                    if (area(x1, y1, x4, y4, lastX1, lastY1) == (area(x1, y1, x2, y2, lastX1, lastY1))) {
                                        // top-to-bottom text
                                        if (distanceBetweenPoints(CGPoint(x:x1, y:y1), CGPoint(x:lastX1, y:lastY1)) < distanceBetweenPoints(CGPoint(x:x2, y:y2), CGPoint(x:lastX1, y:lastY1))) {
                                            x1 = lastX1
                                            y1 = lastY1
                                            if let verticeX4 = symbol.boundingBox?.vertices![3].x{
                                                x4 = nonMinusPoint(Int(Float(verticeX4) * xFactor))
                                            }
                                            if let verticeY4 = symbol.boundingBox?.vertices![3].y{
                                                y4 = nonMinusPoint(Int(Float(verticeY4) * yFactor))
                                            }
                                        } else{
                                            if let verticeX2 = symbol.boundingBox?.vertices![1].x{
                                                x2 = nonMinusPoint(Int(Float(verticeX2) * xFactor))
                                            }
                                            if let verticeY2 = symbol.boundingBox?.vertices![1].y{
                                                y2 = nonMinusPoint(Int(Float(verticeY2) * yFactor))
                                            }
                                            if let verticeX3 = symbol.boundingBox?.vertices![2].x{
                                                x3 = nonMinusPoint(Int(Float(verticeX3) * xFactor))
                                            }
                                            if let verticeY3 = symbol.boundingBox?.vertices![2].y{
                                                y3 = nonMinusPoint(Int(Float(verticeY3) * yFactor))
                                            }
                                        }
                                        var blockText4: String = "(x1,y1)(\(x1),\(y1))(x2,y2)(\(x2),\(y2))(x3,y3)(\(x3),\(y3))(x4,y4)(\(x4),\(y4))"
                                        PrintUtility.printLog(tag: "End points if: ", text: blockText4)
                                    } else {
                                        // left-to-right, bottom-to-top text
//                                        x4 = x1
//                                        y4 = y1
//                                        x1 = x2
//                                        y1 = y2
                                        if let verticeX3 = symbol.boundingBox?.vertices![1].x{
                                            x2 = nonMinusPoint(Int(Float(verticeX3) * xFactor))
                                        }
                                        if let verticeY3 = symbol.boundingBox?.vertices![1].y{
                                            y2 = nonMinusPoint(Int(Float(verticeY3) * yFactor))
                                        }
                                        if let verticeX4 = symbol.boundingBox?.vertices![2].x{
                                            x3 = nonMinusPoint(Int(Float(verticeX4) * xFactor))
                                        }
                                        if let verticeY4 = symbol.boundingBox?.vertices![2].y{
                                            y3 = nonMinusPoint(Int(Float(verticeY4) * yFactor))
                                        }
                                        
                                        
                                        var blockText4: String = "(x1,y1)(\(x1),\(y1))(x2,y2)(\(x2),\(y2))(x3,y3)(\(x3),\(y3))(x4,y4)(\(x4),\(y4))"
                                        PrintUtility.printLog(tag: "End points else: ", text: blockText4)
                                    }
                                    var blockText1: String = "(x1,y1)(\(x1),\(y1))(x2,y2)(\(x2),\(y2))(x3,y3)(\(x3),\(y3))(x4,y4)(\(x4),\(y4))"
                                    let blockBoundingBoxes = BoundingBoxs(vertices: [Vertexs(x: x1, y: y1), Vertexs(x: x2, y:y2), Vertexs(x:x3,y:y3), Vertexs(x:x4, y:y4)])
                                    PrintUtility.printLog(tag: "Bounding Box:",text: blockText1)
                                    if(isVerticalBlock(CGPoint(x:x1, y:y1), CGPoint(x: x2, y: y2))){
                                        if isBottomTop(y1, y2){
                                            bottomTopBlock = intBlockIndex
                                        } else{
                                            bottomTopBlock = -1
                                        }
                                        rightLeftBlock = -1
                                    } else{
                                        if isRightLeft(x1, x3){
                                            rightLeftBlock = intBlockIndex
                                        } else{
                                            rightLeftBlock = -1
                                        }
                                        bottomTopBlock = -1
                                    }
                                    x1 = 0; y1 = 0; x4 = 0; y4 = 0;
                                    x2 = 0; y2 = 0; x3 = 0; y3 = 0;
                                    lineText = paraText + wordText + strBreak;
                                    detectedLanCode = getMaxOccurrenceLanguage(listLanguageCodes, mDetectedLanguageCode);
                                    detectedLanCode = getValidCode(detectedLanCode);
                                    /*if(detectedLanCode.equals(Constants.CHINESE_LANGUAGE_CODE) || detectedLanCode.equals(Constants.UNDETECTED_LANGUAGE_CODE)){
                                     detectedLanCode = new PointUtils().getLanguageCode(activity,lineText);
                                     PTLog.d(TAG,"PointUtils Detected Language Code: " + detectedLanCode);
                                     } */
                                    var blockElement = BlockElement(boundingBox: blockBoundingBoxes, bottomTopBlock: bottomTopBlock, rightLeftBlock: rightLeftBlock, text: lineText, detectedLanguage: detectedLanCode)
                                    arrBlockElement.append(blockElement)
                                    intBlockIndex += intBlockIndex
                                    paraText = ""
                                    wordText = ""
                                    break
                                }
                                if let detectedLanguage = symbol.property?.detectedLanguages {
                                    if let languageCode: String = detectedLanguage[0].languageCode {
                                        if languageCode != nil {
                                            listLanguageCodes.append(languageCode)
                                        }
                                    }
                                }
                            }
                            strBreak = getBreakType(breakStr)
                            if(strBreak != "\n") {
                                paraText = paraText + wordText + strBreak
                            }
                        }
                        blockText = blockText + paraText
                    }
                    pageText = pageText + blockText
                    blockClass = BlockClass(languageCodeFrom: mDetectedLanguageCode, blocks: arrBlockElement)
                }
            }
        }
        return blockClass
    }
    static func getBreakType(_ strBreak: String!) -> String! {
        if strBreak == nil {
            return ""
        }
        var result: String! = ""
        if strBreak == "SPACE" {
            result = " "
        } else {
            if strBreak=="SURE_SPACE" {
                result = "  "
            } else {
                if strBreak == "HYPHEN" {
                    result = "-\n"
                } else {
                    if strBreak == "LINE_BREAK" {
                        result = "\n"
                    } else {
                        if strBreak == "EOL_SURE_SPACE" {
                            result = "\n"
                        } else {
                            result = ""
                        }
                    }
                }
            }
        }
        return result
    }
    static func getMaxOccurrenceLanguage(_ listLanguageCodes: Array<String>!, _ pageLanguageCode: String!) -> String! {
        if listLanguageCodes != nil && (listLanguageCodes.count > 0) {
            if verifyAllEqual(listLanguageCodes) {
                return listLanguageCodes[0]
            } else {
                return pageLanguageCode
            }
        } else {
            return pageLanguageCode
        }
    }
    static func verifyAllEqual(_ list: Array<String>!) -> Bool {
        return Set(list).count <= 1
    }
    static func getValidCode(_ languageCode: String!) -> String! {
        if languageCode == nil {
            return ""
        }
        if EXCEPTION_LANGUAGE_CODES.contains(languageCode) {
            //return languageCode.prefix(2)
            let index = languageCode.index(languageCode.startIndex, offsetBy: 2)
            let substring = languageCode[..<index]
            return String(substring)
        }
        // Filipino has the code 'fil' and 'tl'(Tagalog). Our language mapping files uses 'tl' only. So in case we get 'fil' it need to converted to 'tl'
        
        if languageCode == FILIPINO_FIL_LANGUAGE_CODE {
            return FILIPINO_TL_LANGUAGE_CODE
        }
        return languageCode
    }
    static func nonMinusPoint(_ point: Int) -> Int {
        return (point > 0 ? point : 0)
    }
    static func getAngleFromLine(_ A: CGPoint!, _ B: CGPoint!) -> Double {
        var result: Double = 0.0
        let angle1: Double = Double(atan2(B.y - A.y, B.x - A.x))
        result = radToDegree(angle1)
        return result
    }
    static func radToDegree(_ number: Double) -> Double {
        return number * 180 / .pi
    }
    static func isVerticalBlock(_ A: CGPoint!, _ B: CGPoint!) -> Bool {
        var isVertical: Bool = false
        let angle: Double = getAngleFromLine(A, B)
        if ((angle > 45) && (angle < 135)) || ((angle < (-45)) && (angle > (-135))) {
            isVertical = true
        }
        return isVertical
    }
    static func isBottomTop(_ y1: Int, _ y2: Int) -> Bool {
        var result: Bool = false
        if y1 > y2 {
            result = true
        } else {
            result = false
        }
        return result
    }
    static func isRightLeft(_ x1: Int, _ x2: Int) -> Bool {
        var result: Bool = false
        if x1 > x2 {
            result = true
        } else {
            result = false
        }
        return result
    }
    static func area(_ x1: Int, _ y1: Int, _ x2: Int, _ y2: Int, _ x3: Int, _ y3: Int) -> Decimal! {
        let a:Int = x1 * (y2 - y3)
        let b:Int = x2 * (y3 - y1)
        let c:Int = x3 * (y1 - y2)
        let result: Decimal = Decimal(abs((a + b + c) / 2))
        return result
    }
    static func distanceBetweenPoints(_ A: CGPoint!, _ B: CGPoint!) -> CGFloat {
        let x = (B.x - A.x) * (B.x - A.x)
        let y = (B.y - A.y) * (B.y - A.y)
        return sqrt(y + x)
    }
    static func getAngleFromVerticalLine( A: CGPoint!,  B: CGPoint!) -> Float32 {
            var result: Float32 = 0.0
            let angle1: Float32 = Float32(((atan2(A.y - B.y, B.x - A.x))))
            // y1-y2//x2-x1
            result = Float32(((radToDegree(Double(angle1)))))
            return result
        }
    static func degreeToRadian(_ number: Double) -> CGFloat {
        return (CGFloat(number) * .pi) / 180
    }
    
    static func radians(_ degrees: CGFloat) -> CGFloat {
        return degrees / 180 * .pi
    }

}

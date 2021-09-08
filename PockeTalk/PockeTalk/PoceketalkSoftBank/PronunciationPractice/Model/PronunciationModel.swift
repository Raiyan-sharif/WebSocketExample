//
//  PronunciationUtils.swift
//  PockeTalk
//
//  Created by Kenedy Joy on 7/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

//for ViewController
//import SwiftRichString
//let styleColor = Style({
//    $0.color = UIColor.red
//})
//let aaa = StyleXML(base: nil, ["b" : styleColor])
//let a = "?Hello.Are ? You?"
//let b = "hello, are yu."
//let ss = PronunciationModel()
//let res = ss.generateDiff(original: a, practice: b, languageCode: "ja")
//print("result orginal : \(res[1])")
//print("result practice : \(res[2])")
//self.mLabelWelcome.attributedText = res[1].set(style: aaa)

import Foundation
import Differ

public class PronunciationUtils {

    private let PUNCTUATION_LIST:[Character] = [".", "。", "·", "։", "჻", "।", "‧", ",", "，", "、", "،", "\"", "!", "！", "¡", "՜", ";", "՝", "_", "〜", "~", "～", "|", "॥", "՚", "’", "-", "֊", "?", "？", ":", "：", "․", "׃", "՞", "¿", "」", "「", "'", "『", "』", "〝", "〟", "«", "»", "׀", "؟", "‘", "־", "״", "׳", "။"]
    private let PUNCTUATION_SPACE_NOT_NEEDED_LIST:[Character] = ["՚", "’", "'"]
    private let LANGUAGE_NOT_SPACE_SEPARATED:[String] = ["my", "zh-CN", "zh-TW", "ja", "km", "lo", "th", "yue"]
    private var mLanguageCode:String = ""
    private let DIFF_STRING_MATCHED = "Matched"
    private let DIFF_STRING_NOT_MATCHED = "Not Matched"

    public func generateDiff(original:String, practice:String, languageCode:String) -> [String] {
        let diffMode = diffMode(languageCode: languageCode)
        var modifiedOrginal = Array(original)
        var modifiedPractice = Array(practice)
        var orginalPunctuation = [Int:String]()
        var practicePunctuation = [Int:String]()
        var caseSensitiveOrginal = [Int]()
        var caseSensitivePractice = [Int]()
        var removeSpaceOrginal = [Int]()
        var removeSpacePractice = [Int]()
        var addSpaceOrginal = [Int]()
        var addSpacePractice = [Int]()
        var punctuationList = Array(PUNCTUATION_LIST)
        mLanguageCode = languageCode

        // PT_SK-4921
        if !diffMode {
            punctuationList.append(" ")
            // Khmer and Lao contains this space '\u200B'(whitespace without character)
            punctuationList.append("\u{200B}")
        }

        // PT_SK-4941 add space after punctuations, which is needed
        if diffMode {
            var loopIndex = modifiedOrginal.count - 2
            while loopIndex > 0 {
                if punctuationList.contains(modifiedOrginal[loopIndex]) && !(PUNCTUATION_SPACE_NOT_NEEDED_LIST.contains(modifiedOrginal[loopIndex])) {
                    if !(modifiedOrginal[loopIndex + 1] == " " || modifiedOrginal[loopIndex - 1] == " ") {
                        modifiedOrginal.insert(" ", at: loopIndex + 1)
                        addSpaceOrginal.append(loopIndex + 1)
                        loopIndex -= 1
                    }
                }
                loopIndex -= 1
            }

            loopIndex = modifiedPractice.count - 2
            while loopIndex > 0 {
                if punctuationList.contains(modifiedPractice[loopIndex]) && !(PUNCTUATION_SPACE_NOT_NEEDED_LIST.contains(modifiedPractice[loopIndex])) {
                    if !(modifiedPractice[loopIndex + 1] == " " || modifiedPractice[loopIndex - 1] == " ") {
                        modifiedPractice.insert(" ", at: loopIndex + 1)
                        addSpacePractice.append(loopIndex + 1)
                        loopIndex -= 1
                    }
                }
                loopIndex -= 1
            }
        }

        // caseInsensitive
        for (index, element) in modifiedOrginal.enumerated() {
            if element.isUppercase {
                caseSensitiveOrginal.append(index)
                modifiedOrginal[index] = Character(String(modifiedOrginal[index]).lowercased())
            }
        }

        for (index, element) in modifiedPractice.enumerated() {
            if element.isUppercase {
                caseSensitivePractice.append(index)
                modifiedPractice[index] = Character(String(modifiedPractice[index]).lowercased())
            }
        }

        // Punctuation removed
        var index = modifiedOrginal.count - 1
        while index >= 0 {
            if punctuationList.contains(modifiedOrginal[index]) {
                orginalPunctuation[index] = String(modifiedOrginal[index])
                modifiedOrginal.remove(at: index)
            }
            index -= 1
        }

        index = modifiedPractice.count - 1
        while index >= 0 {
            if punctuationList.contains(modifiedPractice[index]) {
                practicePunctuation[index] = String(modifiedPractice[index])
                modifiedPractice.remove(at: index)
            }
            index -= 1
        }

        // PT_SK-4941 remove extra space which is not needed
        if diffMode {
            var loop = 0
            while loop < modifiedOrginal.count - 1 {
                if modifiedOrginal[loop] == " " && modifiedOrginal[loop + 1] == " " {
                    removeSpaceOrginal.append(loop)
                    modifiedOrginal.remove(at: loop)
                }
                loop += 1
            }

            loop = 0
            while loop < modifiedPractice.count - 1 {
                if modifiedPractice[loop] == " " && modifiedPractice[loop + 1] == " " {
                    removeSpacePractice.append(loop)
                    modifiedPractice.remove(at: loop)
                }
                loop += 1
            }
        }

        var originalText = [String]()
        var practiceText = [String]()

        // false = character mode
        // true = word mode
        print("Diffmode(true = word mode) :", diffMode)
        if diffMode {
            originalText = String(modifiedOrginal).components(separatedBy: " ")
            practiceText = String(modifiedPractice).components(separatedBy: " ")
        } else {
            originalText = String(modifiedOrginal).map {String($0)}
            practiceText = String(modifiedPractice).map {String($0)}
        }

        print("before algorithm call orginalText : ", originalText)
        print("before algorithm call practiceText : ", practiceText)

        let output = textDiff(original: originalText, practice: practiceText, diffMode: diffMode)

        print("Algorithm output orginalText : ", output[0])
        print("Algorithm output practiceText : ", output[1])
        let okMark = originalText.joined().trimmingCharacters(in: .whitespaces) == practiceText.joined().trimmingCharacters(in: .whitespaces)

        var result = [String]()
        result.append((okMark) ? DIFF_STRING_MATCHED : DIFF_STRING_NOT_MATCHED)
        result.append(postDiffProcess(output: output[0], punctuationList: orginalPunctuation, caseSensitive: caseSensitiveOrginal, addSpaceList: addSpaceOrginal, removeSpaceList: removeSpaceOrginal))
        result.append(postDiffProcess(output: output[1], punctuationList: practicePunctuation, caseSensitive: caseSensitivePractice, addSpaceList: addSpacePractice, removeSpaceList: removeSpacePractice))

        return result
    }

    private func textDiff(original:[String] , practice:[String], diffMode:Bool) -> [String] {

        var delete = [Int]()
        var insert = [Int]()
        let diff = original.nestedDiff(to: practice)
        let diffElements = diff.elements
        for element in diffElements{
            let str:String = "\(element)"
            let conditon:Character = Array(str)[0]
            let stringArray = str.components(separatedBy:CharacterSet.decimalDigits.inverted)
            for item in stringArray {
                if let number = Int(item) {
                    if conditon == "D" {
                        delete.append(number)
                    } else {
                        insert.append(number)
                    }
                }
            }
        }

        print("diff algorithm raw output : ", diff)

        var outputOrginal = String()
        for (index, element) in original.enumerated() {
            if delete.contains(index) {
                outputOrginal.append("\""+element+"\"")
            } else {
                outputOrginal.append(element)
            }
            if diffMode && (index < original.count - 1) {
                outputOrginal.append(" ")
            }
        }

        var outputPractice = String()
        for (index, element) in practice.enumerated() {
            if insert.contains(index) {
                outputPractice.append("\""+element+"\"")
            } else {
                outputPractice.append(element)
            }
            if diffMode && (index < practice.count - 1) {
                outputPractice.append(" ")
            }
        }

        var result = [String]()
        result.append(outputOrginal)
        result.append(outputPractice)

        return result
    }

    private func postDiffProcess(output:String, punctuationList:Dictionary<Int, String>, caseSensitive:[Int], addSpaceList:[Int], removeSpaceList:[Int]) -> String {
        let diffMode = diffMode(languageCode: mLanguageCode)
        var tempStr = output

        if diffMode {
            var loop = removeSpaceList.count - 1
            while loop >= 0 {
                var addRange = removeSpaceList[loop]
                var innerLoop = 0
                while innerLoop <= addRange {
                    if tempStr[tempStr.index(tempStr.startIndex, offsetBy: innerLoop)] == "\"" {
                        addRange += 1
                    }
                    innerLoop += 1
                }
                tempStr.insert(" ", at: tempStr.index(tempStr.startIndex, offsetBy: addRange))
                loop -= 1
            }
        }

        for (key, value) in punctuationList.sorted(by: {$0.0 < $1.0}) {
            print("Dict : ", key, ":", value)
            var range = key
            for (index, charcter) in tempStr.enumerated() {
                if index == range {
                    break
                }
                if charcter == "\"" {
                    range += 1
                }
            }
            if (range == tempStr.count - 1) && (tempStr.last == "\"") {
                tempStr.insert(Character(value), at: tempStr.index(tempStr.startIndex, offsetBy: range + 1))
            } else {
                tempStr.insert(Character(value), at: tempStr.index(tempStr.startIndex, offsetBy: range))
            }
        }

        var tempCharArray = Array(tempStr)
        for index in caseSensitive {
            var caseOffset = 0
            var caseRange = index
            var loopIndex = 0
            while loopIndex <= caseRange {
                if tempCharArray[loopIndex] == "\"" {
                    caseOffset += 1
                    caseRange += 1
                }
                loopIndex += 1
            }
            tempCharArray[index + caseOffset] = Character(String(tempCharArray[index + caseOffset]).uppercased())
        }

        tempStr = String(tempCharArray)
        // PT_SK-4941 remove the added space after punctuations
        if diffMode {
            var loop = addSpaceList.count - 1
            while loop >= 0 {
                var removeRange = addSpaceList[loop]
                var innerLoop = 0
                while innerLoop <= removeRange {
                    if tempStr[tempStr.index(tempStr.startIndex, offsetBy: innerLoop)] == "\"" {
                        removeRange += 1
                    }
                    innerLoop += 1
                }
                tempStr.remove(at: tempStr.index(tempStr.startIndex, offsetBy: removeRange))
                loop -= 1
            }
        }

        var str = String(tempStr).map {String($0)}
        var openTag = true
        for (index, element) in str.enumerated() {
            if element == "\"" {
                if openTag {
                    str[index] = "<b>"
                    openTag = false
                } else {
                    str[index] = "</b>"
                    openTag = true
                }
            }
        }

        print("final output : ", str.joined())
        let result = str.joined()
        return result
    }

    private func diffMode(languageCode:String) -> Bool {
        for element in LANGUAGE_NOT_SPACE_SEPARATED {
            if element.contains(languageCode) {
                return false
            }
        }
        return true
    }

}

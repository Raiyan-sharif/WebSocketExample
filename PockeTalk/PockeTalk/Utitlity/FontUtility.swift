//
//  FontUtility.swift
//  PockeTalk
//
//  Created by Kenedy Joy on 17/9/21.
//

import Foundation

class FontUtility {

    static func setFontSizeIndex (index:Int) {
        UserDefaults.standard.set(index, forKey: FONT_SIZE_KEY)
    }

    static func setInitialFontSize () {
        UserDefaults.standard.set(DEFAULT_FONTSIZE_INDEX, forKey: FONT_SIZE_KEY)
    }

    static func getFontSizeIndex () -> Int {
        UserDefaults.standard.integer(forKey: FONT_SIZE_KEY)
    }

    static func getFontSize () -> CGFloat {
        return DEFAULT_FONTSIZE * FONTSIZE[getFontSizeIndex()]
    }

    static func getBiggerFontSize () -> CGFloat {
        return DEFAULT_FONTSIZE * FONTSIZE[getFontSizeIndex() + 1]
    }

    static func setFontSize (selectedFont:String) {
        UserDefaultsProperty<String>(KFontSelection).value = selectedFont
        switch selectedFont {
        case "Smallest":
            FontUtility.setFontSizeIndex(index: 0)
        case "Small":
            FontUtility.setFontSizeIndex(index: 1)
        case "Medium":
            FontUtility.setFontSizeIndex(index: 2)
        case "Large":
            FontUtility.setFontSizeIndex(index: 3)
        case "Largest":
            FontUtility.setFontSizeIndex(index: 4)
        default:
            FontUtility.setFontSizeIndex(index: 2)
        }
    }

}

//
//  Extension+AttibutedString.swift
//  PockeTalk
//

import Foundation
import UIKit

// mutable attributed string
extension NSMutableAttributedString{
    func setColor(_ text: String, with color: UIColor) {
        let range = self.mutableString.range(of: text, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }

    func setFont(_ text: String, with font: UIFont) {
        let range = self.mutableString.range(of: text, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
    }
}

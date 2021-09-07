//
// ExtensionUILabel.swift
// PockeTalk
//
// Created by Shymosree on 9/6/21.
// Copyright © 2021 BJIT Inc. All rights reserved.
//

import UIKit

extension UILabel {

    func setLineHeight(lineHeight: CGFloat) {
        let text = self.text
        if let text = text {
            let attributeString = NSMutableAttributedString(string: text)
            let style = NSMutableParagraphStyle()

            style.lineSpacing = lineHeight
            attributeString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSMakeRange(0, attributeString.length))
            self.attributedText = attributeString
        }
    }

}

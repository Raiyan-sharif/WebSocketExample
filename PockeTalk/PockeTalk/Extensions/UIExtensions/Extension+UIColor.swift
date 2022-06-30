//
//  Extension+UIColor.swift
//  PockeTalk
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }

    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt32 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt32(&rgb) else { return nil }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            return nil
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }

    convenience init(rgbValue: Int) {
        self.init(red: CGFloat(rgbValue) / 255.0, green: CGFloat(rgbValue) / 255.0, blue: CGFloat(rgbValue) / 255.0, alpha: 1.0)
    }

    class func _lightGrayColor() -> UIColor {
        return UIColor.init(red: 248.0 / 255.0, green: 248.0 / 255.0, blue: 248.0 / 255.0, alpha: 1.0)
    }

    class func _semiDarkGrayColor() -> UIColor {
        return UIColor.init(red: 157 / 255.0, green: 156 / 255.0, blue: 156 / 255.0, alpha: 1.0)
    }

    // greyishBrown color.
    class func _greyishBrown() -> UIColor {
        return UIColor.init(hex: "#444444")!
//        return UIColor.init(red: 68, green: 68, blue: 68)
    }

    // BlackText color Alpha 20%.
    class func _blackLineColor() -> UIColor {
        return UIColor(red: 68/255, green: 68/255, blue: 68/255, alpha: 0.2)
    }

    // BlackText color.
    class func _ashTextColor() -> UIColor {
        return UIColor.init(red: 143, green: 143, blue: 143)
    }

    // BlackBackground color.
    class func _black20() -> UIColor {
        return UIColor(red: 35 / 255, green: 25 / 255, blue: 22 / 255, alpha: 0.2)
    }

    // AshBackground color.
    class func _ashBackgroundColor() -> UIColor {
        return UIColor(red: 216, green: 216, blue: 216)
    }


    //SkyBlue Color
    class func _skyBlueColor() -> UIColor {
        return UIColor.init(red: 112, green: 187, blue: 252)
    }

    //Mango Color
    class func _mangoColor() -> UIColor {
        return UIColor.init(red: 255, green: 140, blue: 25)
    }

    //Pastel red Color
    class func _pastelRedColor() -> UIColor {
        return UIColor.init(red: 204, green: 20, blue: 26)
    }

    //Blue Color
    class func _blueColor() -> UIColor {
        return UIColor.init(red: 74, green: 106, blue: 222)
    }

    //Black Color
    class func _blackColor() -> UIColor {
        return UIColor.init(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 1.0)
    }

    //Light Yellow Color
    class func _lightYellowColor() -> UIColor {
        return UIColor.init(red:  251 / 255, green: 224 / 255, blue: 75 / 255, alpha: 1.0)
    }

    //Semi Dark Yellow Color
    class func _semiDarkYellowColor() -> UIColor {
        return UIColor.init(red:  230 / 255, green: 149 / 255, blue: 53 / 255, alpha: 1.0)
    }

    //Dark Yellow Color
    class func _darkYellowColor() -> UIColor {
        return UIColor.init(red:  244 / 255, green: 174 / 255, blue: 61 / 255, alpha: 1.0)
    }

    //Dixie Yellow Color
    class func _dixieYellowColor() -> UIColor {
        return UIColor.init(red:  230 / 255, green: 143 / 255, blue: 27 / 255, alpha: 1.0)
    }

    //Royal blue Color
    class func _royalBlueColor() -> UIColor {
        return UIColor.init(red:  63 / 255, green: 140 / 255, blue: 224 / 255, alpha: 1.0)
    }

    //light blue Color
    class func _lightBlueColor() -> UIColor {
        return UIColor.init(red:  234 / 255, green: 244 / 255, blue: 248 / 255, alpha: 1.0)
    }

    //semi dark blue Color
    class func _semiDarkBlueColor() -> UIColor {
        return UIColor.init(red:  179 / 255, green: 213 / 255, blue: 239 / 255, alpha: 1.0)
    }

    //White Color
    class func _whiteColor() -> UIColor {
        return UIColor.init(red: 255 / 255, green: 255 / 255, blue: 255 / 255, alpha: 1.0)
    }

    //buttonBackgroundColor Color
    class func _buttonBackgroundColor() -> UIColor {
        return UIColor.init(red: 0 / 255, green: 143 / 255, blue: 232 / 255, alpha: 1.0)
    }

    //Black Color
    class func _alertTitleColor() -> UIColor {
        return UIColor.init(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 0.8)
    }

    // Loader background
    class func _loaderBackgroundColor() -> UIColor {
        return UIColor.init(red: 0 / 255, green: 0 / 255, blue: 0 / 255, alpha: 0.5)
    }

    // Official Apple placeholder gray
    static var officialApplePlaceholderGray: UIColor {
        return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
    }

    // Sepreator color bellow iOS 13
    static var seperatorColor: UIColor {
        return UIColor(red: 198.0/255.0, green: 198.0/255.0, blue: 200.0/255.0, alpha: 1.0)
    }
    
    static var freeTrailColor: UIColor {
        return UIColor.init(hex: "#F26E00")!
    }
}

//
//  PrintUtility.swift
//  PockeTalk
//
//

import Foundation

// This class is used to print any log data
public class PrintUtility {
    static var isPrintingOn = true
    
    public static func printLog(tag : String, text : String) {
        if isPrintingOn && !GlobalMethod.isAppInProduction{
            
            print(tag + " " + text)
        }
    }
    
    public static func debugPrintLog(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        if isPrintingOn && !GlobalMethod.isAppInProduction {
            debugPrintLog(items, separator, terminator)
        }
    }
}

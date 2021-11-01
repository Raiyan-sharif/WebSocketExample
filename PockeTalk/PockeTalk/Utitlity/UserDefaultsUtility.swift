//
//  UserDefaultsUtility.swift
//  PockeTalk
//

import Foundation
struct  UserDefaultsUtility {

    static func setBoolValue(_ value: Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func getBoolValue(forKey key: String) -> Bool{
       return UserDefaults.standard.bool(forKey: key)
    }

    static func setIntValue(_ value: Int, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func getIntValue(forKey key: String) -> Int{
        return UserDefaults.standard.integer(forKey: key)
    }

    static func setFloadValue(_ value: Float, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func getFloatValue(forKey key: String) -> Float {
        return UserDefaults.standard.float(forKey: key)
    }

    static func setDoubleValue(_ value: Double, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func getDoubleValue(forKey key: String) -> Double {
        return UserDefaults.standard.double(forKey: key)
    }

    static func setStringValue(_ value: String, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func getStringValue(forKey key: String) -> String {
        return UserDefaults.standard.string(forKey: key) ?? ""
    }

    /// Reset UseDefaults
    static func resetDefaults() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}

@objc final class PlanGridUserDefaults: NSObject {

    /// Keeps track of whether or not a user has already used the annotation filter feature.
    static var hasUsedAnnotationFilterFeature = UserDefaultsProperty<Bool>("HasUsedAnnotationFilterFeature")
}

/// A property that wraps around a value that is persisted to NSUserDefaults.
final class UserDefaultsProperty<T> {

    let identifier: String

    init(_ identifier: String) {
        self.identifier = identifier
    }

    var value: T? {
        set {
            UserDefaults.standard.set(newValue, forKey: self.identifier)
        }
        get {
            return UserDefaults.standard.object(forKey: self.identifier) as? T
        }
    }

}
enum UserDefaultsKeys:String {
    case firstTime
}

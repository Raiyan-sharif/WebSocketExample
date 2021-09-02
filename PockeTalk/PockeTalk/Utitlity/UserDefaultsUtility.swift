//
//  UserDefaultsUtility.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/1/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import Foundation
struct  UserDefaultsUtility {

    static func setBoolValue(_ value: Bool, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func getBoolValue(forKey key: String) {
        UserDefaults.standard.bool(forKey: key)
    }

    static func setIntValue(_ value: Int, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func getIntValue(forKey key: String) {
        UserDefaults.standard.integer(forKey: key)
    }

    static func setFloadValue(_ value: Float, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func getFloatValue(forKey key: String) {
        UserDefaults.standard.float(forKey: key)
    }

    static func setDoubleValue(_ value: Double, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func getDoubleValue(forKey key: String) {
        UserDefaults.standard.double(forKey: key)
    }

    static func setStringValue(_ value: String, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    static func getStringValue(forKey key: String) {
        UserDefaults.standard.string(forKey: key)
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

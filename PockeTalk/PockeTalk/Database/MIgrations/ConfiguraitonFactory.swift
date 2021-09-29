//
//  ConfiguraitonFactory.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/29/21.
//

import Foundation

protocol DBConfiguraion {
    func execute() throws
}

class ConfiguraitonFactory {
    func getConfiguraitonFactory(oldVersion: Int? , newVersion: Int) -> DBConfiguraion? {

        PrintUtility.printLog(tag: String(describing: type(of: self)), text: "DB old version \(oldVersion as Optional)____New Version \(newVersion) ")
        if oldVersion == nil {
            let initialDBConfiguration =  InitialDBConfiguration()
            UserDefaultsProperty<Int>(kUserDefaultDatabaseOldVersion).value = newVersion
            return initialDBConfiguration
        } else if oldVersion == newVersion {
            return nil
        } else {
            return nil
        }
    }
}


//
//  InitialDBConfiguration.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/29/21.
//

import Foundation
struct InitialDBConfiguration: DBConfiguraion {
    func execute() throws {
        do {
            try CameraHistoryDBModel().createTable()
            try ChatDBModel().createTable()
            try LanguageMapDBModel().createTable()
            try LanguageSelectionDBModel().createTable()
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
    }
}

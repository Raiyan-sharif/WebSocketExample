//
//  InitialDBConfiguration.swift
//  PockeTalk
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

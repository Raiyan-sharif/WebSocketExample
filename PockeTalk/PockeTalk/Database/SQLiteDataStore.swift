//
//  SqliteDataStore.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/6/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import Foundation
import SQLite
class SQLiteDataStore {
    static let sharedInstance = SQLiteDataStore()
    let dataBaseConnection: Connection?

    private init() {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
        ).first!

        let dbPath = ("\(documentDirectory)/\(DataBaseConstant.DATABASE_NAME)")
        print(dbPath)

        do {
            dataBaseConnection = try Connection(dbPath)
        } catch _ {
            dataBaseConnection = nil
        }
    }

    func createTables() throws{
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

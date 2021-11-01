//
//  SqliteDataStore.swift
//  PockeTalk
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
        PrintUtility.printLog(tag: String(describing: type(of: self)), text: "DataBase path: \(dbPath)")
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

//
//  LanguageSelectionDataHelper.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/7/21.
//

import SQLite

class LanguageSelectionDBHelper: BaseModel, DataHelperProtocol {
    let TABLE_NAME = "LanguageSelectionTable"
    let table: Table

    let id: Expression<Int64>
    let textLanguageCode: Expression<String>
    let cameraOrVoice: Expression<Int64>

    override init() {
        self.id = Expression<Int64>("id")
        self.textLanguageCode = Expression<String>("txt_language_code")
        self.cameraOrVoice = Expression<Int64>("camera_or_voice")
        self.table = Table(TABLE_NAME)
    }

     func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            _ = try DB.run(table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: .autoincrement)
                t.column(textLanguageCode)
                t.column(cameraOrVoice)
                })
        } catch _ {
            // Error thrown when table exists
        }
    }

    func insert(item: BaseModel) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        if let languageSelectionTable = item as? LanguageSelectionTable {
            let insert = table.insert(textLanguageCode <- languageSelectionTable.textLanguageCode!, cameraOrVoice <- languageSelectionTable.cameraOrVoice!)
            do {
                let rowId = try DB.run(insert)
                guard rowId >= 0 else {
                    throw DataAccessError.Insert_Error
                }
                return rowId
            } catch _ {
                throw DataAccessError.Insert_Error
            }
        }
        throw DataAccessError.Nil_In_Data
    }

    func delete (item: BaseModel) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        guard let languageSelectionTable = item as? LanguageSelectionTable else {
            return
        }

        if let findId = languageSelectionTable.id {
            let query = table.filter(id == findId)
            do {
                let tmp = try DB.run(query.delete())
                guard tmp == 1 else {
                    throw DataAccessError.Delete_Error
                }
            } catch _ {
                throw DataAccessError.Delete_Error
            }
        }

    }

     func find(idToFind: Int64) throws -> BaseModel? {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(id == idToFind)
        let items = try DB.prepare(query)
        for item in  items {
            return LanguageSelectionTable.init(id: item[id], textLanguageCode: item[textLanguageCode], cameraOrVoice: item[cameraOrVoice])
        }

        return nil

    }

     func findAll() throws -> [BaseModel]? {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [BaseModel]()
        let items = try DB.prepare(table)
        for item in items {
            retArray.append(LanguageSelectionTable.init(id: item[id], textLanguageCode: item[textLanguageCode], cameraOrVoice: item[cameraOrVoice]))
        }

        return retArray
    }
}

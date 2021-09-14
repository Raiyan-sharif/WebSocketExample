//
//  LanguageMapDataHelper.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/7/21.
//

import SQLite

class LanguageMapDBHelper: BaseModel, DataHelperProtocol {
    let TABLE_NAME = "LanguageMapTable"
    let table: Table

    let id: Expression<Int64>
    let textCode: Expression<String>
    let textCodeTr: Expression<String>
    let textValueOne: Expression<String>
    let textValueTwo: Expression<String>
    let textValueThree: Expression<String>
    let textValueFour:  Expression<String>
    let textValueFive: Expression<String>
    let textValueSix: Expression<String>
    let textValueSeven: Expression<String>

    override init() {
        self.table = Table(TABLE_NAME)
        self.id = Expression<Int64>("id")
        self.textCode = Expression<String>("txt_code")
        self.textCodeTr = Expression<String>("txt_code_tr")
        self.textValueOne = Expression<String>("txt_value_one")
        self.textValueTwo = Expression<String>("txt_value_two")
        self.textValueThree = Expression<String>("txt_value_three")
        self.textValueFour = Expression<String>("txt_value_four")
        self.textValueFive = Expression<String>("txt_value_five")
        self.textValueSix = Expression<String>("txt_value_six")
        self.textValueSeven = Expression<String>("txt_value_seven")
    }

     func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            _ = try DB.run(table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: .autoincrement)
                t.column(textCode)
                t.column(textCodeTr)
                t.column(textValueOne)
                t.column(textValueTwo)
                t.column(textValueThree)
                t.column(textValueFour)
                t.column(textValueFive)
                t.column(textValueSix)
                t.column(textValueSeven)

                })
        } catch _ {
            // Error thrown when table exists
        }
    }

    func insert(item: BaseEntity) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        if let languageMapTable = item as? LanguageMapEntity {
            let insert = table.insert(textCode <- languageMapTable.textCode!, textCodeTr <- languageMapTable.textCodeTr!, textValueOne <- languageMapTable.textValueOne!, textValueTwo <- languageMapTable.textValueTwo!, textValueThree <- languageMapTable.textValueThree!, textValueFour <- languageMapTable.textValueFour!, textValueFive <- languageMapTable.textValueFive!, textValueSix <- languageMapTable.textValueSix!, textValueSeven <- languageMapTable.textValueSeven! )
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

     func delete (item: BaseEntity) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        guard let languageMapTable = item as? LanguageMapEntity else {
            return
        }

        if let findId = languageMapTable.id {
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

     func find(idToFind: Int64) throws -> BaseEntity? {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(id == idToFind)
        let items = try DB.prepare(query)
        for item in  items {
            return LanguageMapEntity.init(id: item[id], textCode: item[textCode], textCodeTr: item[textCodeTr], textValueOne: item[textValueOne], textValueTwo: item[textValueTwo], textValueThree: item[textValueThree], textValueFour: item[textValueFour], textValueFive: item[textValueFive], textValueSix: item[textValueSix], textValueSeven: item[textValueSeven])
        }

        return nil

    }

     func findAll() throws -> [BaseEntity]? {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [BaseEntity]()
        let items = try DB.prepare(table)
        for item in items {
            retArray.append(LanguageMapEntity.init(id: item[id], textCode: item[textCode], textCodeTr: item[textCodeTr], textValueOne: item[textValueOne], textValueTwo: item[textValueTwo], textValueThree: item[textValueThree], textValueFour: item[textValueFour], textValueFive: item[textValueFive], textValueSix: item[textValueSix], textValueSeven: item[textValueSeven]))
        }

        return retArray
    }
}

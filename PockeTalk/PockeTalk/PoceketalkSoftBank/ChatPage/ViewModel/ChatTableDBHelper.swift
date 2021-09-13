//
//  ChatTableDataHelper.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/6/21.
//

import SQLite

class ChatTableDBHelper: BaseModel, DataHelperProtocol {
    let TABLE_NAME = "ChatTable"
    let table: Table

    let id: Expression<Int64>
    let textNative: Expression<String>
    let textTranslated: Expression<String>
    let textTranslatedLanguage: Expression<String>
    let textNativeLanguage: Expression<String>
    let chatIsLiked: Expression<Int64>
    let chatIsTop: Expression<Int64>
    let chatIsDelete: Expression<Int64>
    let chatIsFavorite: Expression<Int64>

    override init() {
        self.table = Table(TABLE_NAME)
        self.id = Expression<Int64>("id")
        self.textNative = Expression<String>("txt_native")
        self.textTranslated = Expression<String>("txt_translated")
        self.textTranslatedLanguage = Expression<String>("txt_translated_language")
        self.textNativeLanguage = Expression<String>("txt_native_language")
        self.chatIsLiked = Expression<Int64>("int_is_liked")
        self.chatIsTop = Expression<Int64>("int_is_top")
        self.chatIsDelete = Expression<Int64>("int_is_delete")
        self.chatIsFavorite = Expression<Int64>("int_is_favorite")
    }

    func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            _ = try DB.run(table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: .autoincrement)
                t.column(textNative)
                t.column(textTranslated)
                t.column(textTranslatedLanguage)
                t.column(textNativeLanguage)
                t.column(chatIsLiked)
                t.column(chatIsTop)
                t.column(chatIsDelete)
                t.column(chatIsFavorite)
            })
        } catch _ {
            // Error thrown when table exists
        }
    }

    func insert(item: BaseModel) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        if let chatTableModel = item as? ChatTable {
            let insert = table.insert(textNative <- chatTableModel.textNative!, textTranslated <- chatTableModel.textTranslated!, textTranslatedLanguage <- chatTableModel.textTranslatedLanguage!, textNativeLanguage <- chatTableModel.textNativeLanguage!, chatIsLiked <- chatTableModel.chatIsLiked!, chatIsTop <- chatTableModel.chatIsTop!, chatIsDelete <- chatTableModel.chatIsDelete!, chatIsFavorite <- chatTableModel.chatIsFavorite! )
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

        guard let chatTableModel = item as? ChatTable else {
            return
        }

        if let findId = chatTableModel.id {
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
            return ChatTable.init(id: item[id], textNative: item[textNative], textTranslated: item[textTranslated], textTranslatedLanguage: item[textTranslatedLanguage], textNativeLanguage: item[textNativeLanguage], chatIsLiked: item[chatIsLiked], chatIsTop: item[chatIsTop], chatIsDelete: item[chatIsDelete], chatIsFavorite: item[chatIsFavorite])
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
            retArray.append(ChatTable.init(id: item[id], textNative: item[textNative], textTranslated: item[textTranslated], textTranslatedLanguage: item[textTranslatedLanguage], textNativeLanguage: item[textNativeLanguage], chatIsLiked: item[chatIsLiked], chatIsTop: item[chatIsTop], chatIsDelete: item[chatIsDelete], chatIsFavorite: item[chatIsFavorite]))
        }
        return retArray
    }
}

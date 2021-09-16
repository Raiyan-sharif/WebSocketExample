//
//  ChatTableDataHelper.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/6/21.
//

import SQLite

enum IsLiked: Int64 {
    case noLike
    case like
}

enum IsDeleted: Int64 {
    case noDelete
    case delete
}

enum IsTop: Int64 {
    case noTop
    case top
}

enum IsFavourite: Int64 {
    case noFavourite
    case favourite
}

enum RemoveStatus {
    case removeFavorite
    case removeHistory
}

class ChatTableDBHelper: BaseModel, DataHelperProtocol {

    //MARK: - Properties

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

    var getAllChatTables: [ChatEntity]? {
        if let chatTables = try? findAll() as? [ChatEntity] {
            return chatTables
        }
        return nil
    }

    //MARK: - Initaializers

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
        super.init()
    }

    //MARK: - DBHelper Method

    func createTable() throws -> Void {
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

    func insert(item: BaseEntity) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        if let chatTableModel = item as? ChatEntity {
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

    func delete (item: BaseEntity) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        guard let chatTableModel = item as? ChatEntity else {
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

    func findAll() throws -> [BaseEntity]? {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [BaseEntity]()
        let items = try DB.prepare(table)
        for item in items {
            retArray.append(ChatEntity.init(id: item[id], textNative: item[textNative], textTranslated: item[textTranslated], textTranslatedLanguage: item[textTranslatedLanguage], textNativeLanguage: item[textNativeLanguage], chatIsLiked: item[chatIsLiked], chatIsTop: item[chatIsTop], chatIsDelete: item[chatIsDelete], chatIsFavorite: item[chatIsFavorite]))
        }

        return retArray
    }

    func find(idToFind: Int64) throws -> BaseEntity? {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let query = table.filter(id == idToFind)
        let items = try DB.prepare(query)
        for item in  items {
            return ChatEntity.init(id: item[id], textNative: item[textNative], textTranslated: item[textTranslated], textTranslatedLanguage: item[textTranslatedLanguage], textNativeLanguage: item[textNativeLanguage], chatIsLiked: item[chatIsLiked], chatIsTop: item[chatIsTop], chatIsDelete: item[chatIsDelete], chatIsFavorite: item[chatIsFavorite])
        }

        return nil

    }

    func update(item: BaseEntity) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        guard let chatTableModel = item as? ChatEntity else {
            return
        }
        if let findId = chatTableModel.id {
            let query = table.filter(id == findId)
            do {
                try DB.run(query.update(textNative <- chatTableModel.textNative!, textTranslated <- chatTableModel.textTranslated!, textTranslatedLanguage <- chatTableModel.textTranslatedLanguage!, textNativeLanguage <- chatTableModel.textNativeLanguage!, chatIsLiked <- chatTableModel.chatIsLiked!, chatIsTop <- chatTableModel.chatIsTop!, chatIsDelete <- chatTableModel.chatIsDelete!, chatIsFavorite <- chatTableModel.chatIsFavorite!))
            } catch _ {
                throw DataAccessError.Update_Error
            }
        }
    }

    func pickListedItems(isFavorite: Bool) throws -> [BaseEntity]? {
        let lowLimit = getAllChatTables?.count ?? 0
        let rowFaced = rowFetchPerScroll

        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        var query = table.filter(chatIsDelete == IsDeleted.noDelete.rawValue)
            .order(id.asc)
          //  .limit(lowLimit, offset: rowFaced)

        if isFavorite {
            query = table.filter(chatIsLiked == IsLiked.like.rawValue)
                .order(chatIsFavorite.desc)
            //    .limit(lowLimit, offset: rowFaced)
        }

        var retArray = [BaseEntity]()
        let items = try DB.prepare(query)
        for item in items {
            retArray.append(ChatEntity.init(id: item[id], textNative: item[textNative], textTranslated: item[textTranslated], textTranslatedLanguage: item[textTranslatedLanguage], textNativeLanguage: item[textNativeLanguage], chatIsLiked: item[chatIsLiked], chatIsTop: item[chatIsTop], chatIsDelete: item[chatIsDelete], chatIsFavorite: item[chatIsFavorite]))
        }

        return retArray
    }

    func updateLikeValue(isliked: IsLiked = .noLike, idToCompare: Int64) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        let maxFav = try getMaxFavouriteId()!
        let query = table.filter(idToCompare == id)
        
        PrintUtility.printLog(tag: "DB", text: "\(isliked.rawValue)")

        do {
            try DB.run(query.update(chatIsLiked <- isliked.rawValue, chatIsFavorite <- (maxFav + 1)))
        } catch _ {
            throw DataAccessError.Update_Error
        }
    }

    func updateDeleteValue(isDelete: IsDeleted = .noDelete, idToCompare: Int64) throws -> Void {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        let query = table.filter(idToCompare == id)
        do {
            try DB.run(query.update(chatIsDelete <- isDelete.rawValue))
        } catch _ {
            throw DataAccessError.Update_Error
        }
    }


    func delete(id: Int64, isFavorite: Bool) -> Bool {
        var isDeleted = false
        if getLikeStatus(id: id) == .like {
            if getDeletedStatus(id: id) == .delete {
                _ = try? delete(idToDelte: id)
                isDeleted = true
            } else {
                if isFavorite {
                    _ = try? updateLikeValue(isliked: .noLike, idToCompare: id)
                } else {
                    _ = try? updateDeleteValue(isDelete: .delete, idToCompare: id)
                }
            }
        } else {
            _ = try? delete(idToDelte: id)
            isDeleted = true
        }

        return isDeleted
    }

    func delete(idToDelte: Int64) throws {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        let query = table.filter(id == idToDelte)
        do {
            try DB.run(query.delete())
        } catch _ {

        }
    }

    func getLikeStatus(id: Int64) -> IsLiked {
        if  let chatTables = try? findAll() as? [ChatEntity] {
            for item in chatTables {
                if item.id == id {
                    if item.chatIsLiked == IsLiked.like.rawValue {
                        return .like
                    }
                    break
                }
            }
        }

        return .noLike
    }

    func getDeletedStatus(id: Int64) -> IsDeleted {
        if  let chatTables = try? findAll() as? [ChatEntity] {
            for item in chatTables {
                if item.id == id {
                    if item.chatIsDelete == IsDeleted.delete.rawValue {
                        return .delete
                    }
                    break
                }
            }
        }

        return .noDelete
    }

    func getRowCount(isFavorite: Bool) throws -> Int {
        var totalCount = 0

        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        var query = table.filter(chatIsDelete == IsDeleted.noDelete.rawValue)
        if isFavorite {
            query = table.filter(chatIsLiked == IsLiked.like.rawValue)
        }

        totalCount = try DB.scalar(query.select(chatIsLiked.count))

        return totalCount
    }

    func getMinId() throws -> Int {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let minId =  try DB.scalar(table.select(id.min))
        return Int(minId!)
    }

    func getMaxFavouriteId() throws  -> Int64? {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let max = try? DB.scalar(table.select(chatIsFavorite.max))
        return max;
    }

    func deleteAllChatHistory(removeStatus: RemoveStatus) {
        switch removeStatus {
        case .removeHistory:
            _ = try? removeHistory()
        case .removeFavorite:
            _ = try? removeFavorite()
        }
    }

    func removeHistory() throws {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        let deleteQuery = table.filter(chatIsLiked == IsLiked.noLike.rawValue)
        do {
            try DB.run(deleteQuery.delete())
            try DB.run(table.update(chatIsDelete <- IsDeleted.delete.rawValue))
        } catch _ {

        }
    }

    func removeFavorite() throws {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        let deleteQuery = table.filter(chatIsDelete == IsDeleted.delete.rawValue)
        do {
            try DB.run(deleteQuery.delete())
            try DB.run(table.update(chatIsLiked <- IsLiked.noLike.rawValue))
        } catch _ {

        }
    }

    func deleteChatHistory() throws {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        do {
            try DB.run(table.delete())
        } catch _ {

        }
    }
}

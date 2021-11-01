//
//  LanguageSelectionDataHelper.swift
//  PockeTalk
//

import SQLite

enum LanguageType: Int64 {
    case voice
    case camera
}

class LanguageSelectionDBModel: BaseDBModel {
    let TAG = "\(LanguageSelectionDBModel.self)"
    let TABLE_NAME = "LanguageSelectionTable"

    let textLanguageCode: Expression<String>
    let cameraOrVoice: Expression<Int64>

    init() {
        self.textLanguageCode = Expression<String>("txt_language_code")
        self.cameraOrVoice = Expression<Int64>("camera_or_voice")
        super.init(id: Expression<Int64>("id"), table: Table(TABLE_NAME))
    }

    func createTable() throws {
        do {
            let createTableQueryString = table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: .autoincrement)
                t.column(textLanguageCode)
                t.column(cameraOrVoice)
            }
            try createTable(queryString: createTableQueryString)
        } catch _ {
            // Error thrown when table exists
        }
    }

    func insert(item: BaseEntity) throws -> Int64 {
        if let languageSelectionTable = item as? LanguageSelectionEntity {

            if let itemInDb = try? find(entity: languageSelectionTable) as? LanguageSelectionEntity {
                PrintUtility.printLog(tag: TAG, text: "LanguageListFromDb item \(String(describing: itemInDb.textLanguageCode)) found in db as \(String(describing: itemInDb.cameraOrVoice))")
                return -1
            }

            let insertStatement = table.insert(textLanguageCode <- languageSelectionTable.textLanguageCode!, cameraOrVoice <- languageSelectionTable.cameraOrVoice!)

            _ = try insert(queryString: insertStatement)
        }
        throw DataAccessError.Nil_In_Data
    }

    func delete (item: BaseEntity) throws -> Void {
        guard let languageSelectionTable = item as? LanguageSelectionEntity else {
            return
        }

        if let findId = languageSelectionTable.id {
            try delete(idToDelte: findId)
        }
    }

     func find(idToFind: Int64) throws -> BaseEntity? {
        let items = try find(findId: idToFind)
        for item in  items {
            return LanguageSelectionEntity.init(id: item[id], textLanguageCode: item[textLanguageCode], cameraOrVoice: item[cameraOrVoice])
        }

        return nil

    }

     func find(entity: BaseEntity) throws -> BaseEntity? {
        guard let itemEntity = entity as? LanguageSelectionEntity else {
            return nil
        }
        let filterQuery = table.filter(textLanguageCode == itemEntity.textLanguageCode!  && cameraOrVoice == itemEntity.cameraOrVoice!)
        let items = try find(filter: filterQuery)
        for item in  items {
            return LanguageSelectionEntity.init(id: item[id], textLanguageCode: item[textLanguageCode], cameraOrVoice: item[cameraOrVoice])
        }
        return nil
    }

    func findAll(findFor: Int64) throws -> [BaseEntity]? {
       guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
           throw DataAccessError.Datastore_Connection_Error
       }
       let query = table.filter(cameraOrVoice == findFor)
       var retArray = [BaseEntity]()
       let items = try DB.prepare(query)
       for item in items {
           retArray.append(LanguageSelectionEntity.init(id: item[id], textLanguageCode: item[textLanguageCode], cameraOrVoice: item[cameraOrVoice]))
       }

       return retArray
   }

     func findAllEntities() throws -> [BaseEntity]? {
        var retArray = [BaseEntity]()
        let items = try findAll()
        for item in items {
            retArray.append(LanguageSelectionEntity.init(id: item[id], textLanguageCode: item[textLanguageCode], cameraOrVoice: item[cameraOrVoice]))
        }

        return retArray
    }
}

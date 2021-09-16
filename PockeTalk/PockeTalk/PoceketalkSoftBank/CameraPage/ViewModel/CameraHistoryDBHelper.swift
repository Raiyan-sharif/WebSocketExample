//
//  CameraHistoryDataHelper.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/6/21.
//

import SQLite

class CameraHistoryDBHelper: BaseModel, DataHelperProtocol {
    let TABLE_NAME = "CameraHistoryTable"
    let table: Table

    let id: Expression<Int64>
    let detectedData: Expression<String>
    let translatedData: Expression<String>
    let image: Expression<String>
    
    var getAllCameraHistoryTables: [CameraEntity]? {
        if let cameraHistoryTables = try? findAll() as? [CameraEntity] {
            return cameraHistoryTables
        } else {
            
        }
        return nil
    }

    override init() {
        self.table = Table(TABLE_NAME)
        self.id = Expression<Int64>("id")
        self.detectedData = Expression<String>("detected_data")
        self.translatedData = Expression<String>("translated_data")
        self.image = Expression<String>("image")
    }

    func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            let _ = try DB.run( table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: .autoincrement)
                t.column(detectedData)
                t.column(translatedData)
                t.column(image)
            })

        } catch _ {
            // Error throw if table already exists
        }
    }

    func insert(item: BaseEntity) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        if let cameraHistoryModel = item as? CameraEntity {
            let insert = table.insert(detectedData <- cameraHistoryModel.detectedData!, translatedData <- cameraHistoryModel.translatedData!, image <- cameraHistoryModel.image!)
            do {
                let rowId = try DB.run(insert)
                guard rowId > 0 else {
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
        guard let cameraHistoryModel = item as? CameraEntity else {
            return
        }
        if let findId = cameraHistoryModel.id {
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
            return CameraEntity.init(id: item[id], detectedData: item[detectedData], translatedData: item[translatedData], image: item[image])
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
            retArray.append(CameraEntity(id: item[id], detectedData: item[detectedData], translatedData: item[translatedData], image: item[image]))
        }
        
        return retArray
    }

    func deleteCameraHistory() throws {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }

        do {
            try DB.run(table.delete())
        } catch _ {

        }
    }
}

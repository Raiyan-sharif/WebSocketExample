//
//  CameraHistoryDataHelper.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/6/21.
//

import SQLite

class CameraHistoryDBModel: BaseDBModel {
    let TABLE_NAME = "CameraHistoryTable"

    let detectedData: Expression<String>
    let translatedData: Expression<String>
    let image: Expression<String>

    var getAllCameraHistoryTables: [CameraEntity]? {
        if let cameraHistoryTables = try? findAllEntities() as? [CameraEntity] {
            return cameraHistoryTables
        } else {

        }
        return nil
    }

    init() {
        self.detectedData = Expression<String>("detected_data")
        self.translatedData = Expression<String>("translated_data")
        self.image = Expression<String>("image")
        super.init(id: Expression<Int64>("id"), table: Table(TABLE_NAME))

    }

    func createTable() throws {
        do {
            let createTableQueryString = table.create(ifNotExists: true) {t in
                t.column(id, primaryKey: .autoincrement)
                t.column(detectedData)
                t.column(translatedData)
                t.column(image)
            }

            try createTable(queryString: createTableQueryString)

        } catch _ {
            // Error throw if table already exists
        }
    }

    func insert(item: BaseEntity) throws -> Int64 {
        if let cameraHistoryModel = item as? CameraEntity {
            let insertStatement = table.insert(detectedData <- cameraHistoryModel.detectedData!, translatedData <- cameraHistoryModel.translatedData!, image <- cameraHistoryModel.image!)

            _ = try? insert(queryString: insertStatement)
        }
        throw DataAccessError.Nil_In_Data
    }

    func delete (item: BaseEntity) throws -> Void {
        guard let cameraHistoryModel = item as? CameraEntity else {
            return
        }

        if let findId = cameraHistoryModel.id {
            try delete(idToDelte: findId)
        }
    }

    func find(idToFind: Int64) throws -> BaseEntity? {
        let items = try find(findId: idToFind)
        for item in  items {
            return CameraEntity.init(id: item[id], detectedData: item[detectedData], translatedData: item[translatedData], image: item[image])
        }

        return nil
    }

    func findAllEntities() throws -> [BaseEntity]? {
        var retArray = [BaseEntity]()
        let items = try findAll()
        for item in items {
            retArray.append(CameraEntity(id: item[id], detectedData: item[detectedData], translatedData: item[translatedData], image: item[image]))
        }
        
        return retArray
    }
}

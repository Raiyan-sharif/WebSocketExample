//
//  CameraHistoryDataHelper.swift
//  PockeTalk
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
    
    func updateTranslatedData(data: String, idToCompare: Int64) throws -> Void {
        
        let query = table.filter(idToCompare == id)
        
        do {
            let updateQuery = query.update(translatedData <- data)
            try update(queryUpdate: updateQuery)
        } catch _ {
            throw DataAccessError.Update_Error
        }
    }
    
    func findAllEntities() throws -> [BaseEntity]? {
        var retArray = [BaseEntity]()
        let items = try findAll()
        for item in items {
            retArray.append(CameraEntity(id: item[id], detectedData: item[detectedData], translatedData: item[translatedData], image: item[image]))
        }
        
        return retArray
    }
    
    func getTranslatedData(id: Int64) -> TranslatedTextJSONModel {
        var data: TranslatedTextJSONModel?
        if  let cameraTables = try? findAllEntities() as? [CameraEntity] {
            for item in cameraTables {
                if item.id == id {
                    data = try? JSONDecoder().decode(TranslatedTextJSONModel.self, from: Data(item.translatedData!.utf8))
                    
                    break
                }
            }
        }

        return data!
    }
    
    func getDetectedData(id: Int64) -> DetectedJSON {
        var data: DetectedJSON?
        if  let cameraTables = try? findAllEntities() as? [CameraEntity] {
            for item in cameraTables {
                if item.id == id {
                    data = try? JSONDecoder().decode(DetectedJSON.self, from: Data(item.detectedData!.utf8))
                }
            }
        }
       
        return data!
    }
    
    func getMaxId() throws -> Int {
        guard let DB = SQLiteDataStore.sharedInstance.dataBaseConnection else {
            throw DataAccessError.Datastore_Connection_Error
        }
        let minId =  try DB.scalar(table.select(id.max))
        return Int(minId!)
    }


}

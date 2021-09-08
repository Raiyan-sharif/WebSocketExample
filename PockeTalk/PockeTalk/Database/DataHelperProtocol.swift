//
//  DataHelperProtocol.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/6/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import Foundation

enum DataAccessError: Error {
    case Datastore_Connection_Error
    case Insert_Error
    case Delete_Error
    case Search_Error
    case Nil_In_Data
}

protocol DataHelperProtocol {
    func createTable() throws -> Void
    func insert(item: BaseModel) throws -> Int64
    func delete(item: BaseModel) throws -> Void
    func findAll() throws -> [BaseModel]?
}

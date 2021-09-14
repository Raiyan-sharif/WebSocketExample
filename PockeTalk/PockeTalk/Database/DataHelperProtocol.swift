//
//  DataHelperProtocol.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/6/21.

import Foundation

enum DataAccessError: Error {
    case Datastore_Connection_Error
    case Insert_Error
    case Update_Error
    case Delete_Error
    case Search_Error
    case Nil_In_Data
}

protocol DataHelperProtocol {
    func createTable() throws -> Void
    func insert(item: BaseEntity) throws -> Int64
    func delete(item: BaseEntity) throws -> Void
    func findAll() throws -> [BaseEntity]?
}

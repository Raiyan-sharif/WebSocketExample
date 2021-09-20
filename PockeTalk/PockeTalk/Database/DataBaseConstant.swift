//
//  DataBaseConstant.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/8/21.

import Foundation

enum DataAccessError: Error {
    case Datastore_Connection_Error
    case Insert_Error
    case Update_Error
    case Delete_Error
    case Search_Error
    case Nil_In_Data
}

struct DataBaseConstant {
    static let DATABASE_NAME = "pocketalksoftbank.db";
    static let DATABASE_VERSION = 1
}

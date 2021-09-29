//
//  TTTJSONModel.swift
//  PockeTalk
//

import Foundation

// MARK: - TTTJSONModel
struct TTTJSONModel: Codable {
    let data: DataClass
}

// MARK: - DataClass
struct DataClass: Codable {
    let translations: [Translation]
}

// MARK: - Translation
struct Translation: Codable {
    let translatedText: String
}

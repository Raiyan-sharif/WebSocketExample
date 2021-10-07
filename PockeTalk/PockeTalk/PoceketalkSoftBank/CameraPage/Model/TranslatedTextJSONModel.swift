//
//  TranslatedTextJSONModel.swift
//  PockeTalk
//
//   let welcome = try? newJSONDecoder().decode(TranslatedTextJSONModel.self, from: jsonData)

import Foundation

// MARK: - TranslatedTextJSONModel
struct TranslatedTextJSONModel: Codable {
    let block: BlockData?
    let line: BlockData?

    enum CodingKeys: String, CodingKey {
        case block = "Block"
        case line = "Line"
    }
}

// MARK: - Block
struct BlockData: Codable {
    let translatedText: [String]
    let languageCodeTo: String
}

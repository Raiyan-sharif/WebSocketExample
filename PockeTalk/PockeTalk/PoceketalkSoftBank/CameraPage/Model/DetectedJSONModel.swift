//
//  DetectedJSONModel.swift
//  PockeTalk
//
// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(DetectedJSON.self, from: jsonData)

import Foundation

// MARK: - DetectedJSON
struct DetectedJSON: Codable {
    let block: BlockClass?
    let line: BlockClass?

    enum CodingKeys: String, CodingKey {
        case block = "Block"
        case line = "Line"
    }
}

// MARK: - BlockClass
struct BlockClass: Codable {
    let languageCodeFrom: String?
    let blocks: [BlockElement]?
}

// MARK: - BlockElement
struct BlockElement: Codable {
    let boundingBox: BoundingBoxs
    let bottomTopBlock, rightLeftBlock: Int
    let text: String
    let detectedLanguage: String

    enum CodingKeys: String, CodingKey {
        case boundingBox
        case bottomTopBlock = "BottomTopBlock"
        case rightLeftBlock = "RightLeftBlock"
        case text = "Text"
        case detectedLanguage
    }
}

// MARK: - BoundingBox
struct BoundingBoxs: Codable {
    let vertices: [Vertexs]
}

// MARK: - Vertex
struct Vertexs: Codable {
    let x, y: Int
}

//
//  VisionResponseJSONModel.swift
//  PockeTalk
//

import Foundation

// MARK: - GoogleCloudOCRResponse
struct GoogleCloudOCRResponse: Codable {
    let responses: [Response]?
}

// MARK: - Response
struct Response: Codable {
    let fullTextAnnotation: FullTextAnnotation?
    let textAnnotations: [TextAnnotation]?
}

// MARK: - FullTextAnnotation
struct FullTextAnnotation: Codable {
    let pages: [Page]?
    let text: String?
}

// MARK: - Page
struct Page: Codable {
    let blocks: [Block]?
    let height: Int?
    let property: ParagraphProperty?
    let width: Int?
}

// MARK: - Block
struct Block: Codable {
    let blockType: String?
    let boundingBox: Bounding?
    let confidence: Double?
    let paragraphs: [Paragraph]?
    let property: ParagraphProperty?
}

// MARK: - Bounding
struct Bounding: Codable {
    let vertices: [Vertex]?
    let confidence: Double?
}

// MARK: - Vertex
struct Vertex: Codable {
    let x: Int?
    let y: Int?
}

// MARK: - Paragraph
struct Paragraph: Codable {
    let boundingBox: Bounding?
    let confidence: Double?
    let property: ParagraphProperty?
    let words: [Word]?
}

// MARK: - ParagraphProperty
struct ParagraphProperty: Codable {
    let detectedLanguages: [PurpleDetectedLanguage]?

}

// MARK: - PurpleDetectedLanguage
struct PurpleDetectedLanguage: Codable {
    let confidence: Double?
    let languageCode: String?
}

// MARK: - Word
struct Word: Codable {
    let boundingBox: Bounding?
    let confidence: Double?
    let property: ParagraphProperty?
    let symbols: [Symbol]?
}

// MARK: - FluffyDetectedLanguage
struct FluffyDetectedLanguage: Codable {
    let languageCode: String?
}

// MARK: - Symbol
struct Symbol: Codable {
    let boundingBox: Bounding?
    let confidence: Double?
    let property: SymbolProperty?
    let text: String?
}

// MARK: - SymbolProperty
struct SymbolProperty: Codable {
    let detectedLanguages: [FluffyDetectedLanguage]?
    let detectedBreak: DetectedBreak?
}

//// MARK: - DetectedBreak
struct DetectedBreak: Codable {
    let type: String?
}
// MARK: - TextAnnotation
struct TextAnnotation: Codable {
    let boundingPoly: Bounding?
    let textAnnotationDescription: String?
    let locale: String?

    enum CodingKeys: String, CodingKey {
        case boundingPoly
        case textAnnotationDescription = "description"
        case locale
    }
}

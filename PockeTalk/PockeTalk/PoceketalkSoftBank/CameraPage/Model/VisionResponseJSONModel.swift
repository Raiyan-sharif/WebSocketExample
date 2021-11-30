//
//  VisionResponseJSONModel.swift
//  PockeTalk
//

import Foundation

// MARK: - GoogleCloudOCRResponse
struct GoogleCloudOCRResponse: Codable {
    let result_code: String
    let ocr_response: Ocr_Response

    enum CodingKeys: String, CodingKey {
        case result_code
        case ocr_response
    }
}

// MARK: - OcrResponse
struct Ocr_Response: Codable {
    let responses: [Response]
}

// MARK: - Response
struct Response: Codable {
    let full_text_annotation: Full_Text_Annotation?
    let text_annotations: [Text_Annotation]?
}

// MARK: - FullTextAnnotation
struct Full_Text_Annotation: Codable {
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
    let block_type: String?
    let bounding_box: Bounding?
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
    let bounding_box: Bounding?
    let confidence: Double?
    let property: ParagraphProperty?
    let words: [Word]?
}

// MARK: - ParagraphProperty
struct ParagraphProperty: Codable {
    let detected_languages: [PurpleDetectedLanguage]?

}

// MARK: - PurpleDetectedLanguage
struct PurpleDetectedLanguage: Codable {
    let confidence: Double?
    let language_code: String?
}

// MARK: - Word
struct Word: Codable {
    let bounding_box: Bounding?
    let confidence: Double?
    let property: ParagraphProperty?
    let symbols: [Symbol]?
}

// MARK: - FluffyDetectedLanguage
struct FluffyDetectedLanguage: Codable {
    let language_code: String?
}

// MARK: - Symbol
struct Symbol: Codable {
    let bounding_box: Bounding?
    let confidence: Double?
    let property: SymbolProperty?
    let text: String?
}

// MARK: - SymbolProperty
struct SymbolProperty: Codable {
    let detected_languages: [FluffyDetectedLanguage]?
    let detected_break: DetectedBreak?
}

//// MARK: - DetectedBreak
struct DetectedBreak: Codable {
    let type: String?
}
// MARK: - TextAnnotation
struct Text_Annotation: Codable {
    let bounding_poly: Bounding?
    let text_Annotation_Description: String?
    let locale: String?

    enum CodingKeys: String, CodingKey {
        case bounding_poly
        case text_Annotation_Description = "description"
        case locale
    }
}

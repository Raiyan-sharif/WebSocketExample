//
//  LangDetectionResponseModel.swift
//  PockeTalk
//
//  Created by BJIT LTD on 14/12/21.
//

import Foundation

// MARK: - Language Detection Response Model
struct LanguageDeteectionResponseModel: Codable {
    let result_code: String?
    let detect_response: DetectResponse?
}

// MARK: - DetectResponse
struct DetectResponse: Codable {
    let languages: [Language]?
}

// MARK: - Language
struct Language: Codable {
    let language_code: String?
    //let confidence: String?
}

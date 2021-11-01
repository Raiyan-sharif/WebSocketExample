//
//  TempoEngineModel.swift
//  PockeTalk
//

import UIKit

struct Normal: Decodable {
    let tempo_rate: String
}
struct Slow: Decodable {
    let tempo_rate: String
}
struct VerySlow: Decodable {
    let tempo_rate: String
}

struct EngineValue: Decodable {
    let engine_name: String
    let normal: Normal
    let slow: Slow
    let verySlow: VerySlow
}

struct EngineTempoValue: Decodable {
    let engine_value: [EngineValue]
}

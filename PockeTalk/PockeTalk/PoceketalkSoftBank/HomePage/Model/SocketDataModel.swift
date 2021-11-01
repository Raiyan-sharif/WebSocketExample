//
//  SocketDataModel.swift
//  PockeTalk
//

import Foundation

struct SocketDataModel : Codable {

    let destlang : String?
    let isFinal : Bool?
    let resultCode : String?
    let srclang : String?
    let stt : String?
    let ttt : String?

    enum CodingKeys: String, CodingKey {
        case destlang = "destlang"
        case isFinal = "is_final"
        case resultCode = "result_code"
        case srclang = "srclang"
        case stt = "stt"
        case ttt = "ttt"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        destlang = try values.decodeIfPresent(String.self, forKey: .destlang)
        isFinal = try values.decodeIfPresent(Bool.self, forKey: .isFinal)
        resultCode = try values.decodeIfPresent(String.self, forKey: .resultCode)
        srclang = try values.decodeIfPresent(String.self, forKey: .srclang)
        stt = try values.decodeIfPresent(String.self, forKey: .stt)
        ttt = try values.decodeIfPresent(String.self, forKey: .ttt)
    }

}

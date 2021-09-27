//
//  NetworkServiceAPI.swift
//  PockeTalk
//

import Foundation
import Moya

enum NetworkServiceAPI {
    case authkey(params:[String:Any])
    case changeLanguage(params:[String:Any])

}
extension NetworkServiceAPI:TargetType{

    var baseURL: URL {
        return URL(string:base_url)!
        }


    var path: String {
        switch self {
        case .authkey:
            return stream_auth_key_url
        case .changeLanguage:
            return language_channge_url
        }
    }
    var method: Moya.Method {
        switch self {
        case .authkey, .changeLanguage:
            return .post
        }
    }
    var task: Task {
        switch self {

        case let .authkey(params) :
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case let .changeLanguage(params) :
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)

        }
    }

    var sampleData: Data {
        switch self {
        case let .authkey(config) :
            return "{\"description is \": \"\(config)\"}".utf8Encoded
        case let .changeLanguage(value) :
            return "{\"description is \": \"\(value)\"}".utf8Encoded
        }
    }
    var headers: [String: String]? {
        switch self {
        case .authkey:
            return  ["Content-type": "application/x-www-form-urlencoded"]
        default :
           return nil
        }
    }
}
// MARK: - Helpers

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }

    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}




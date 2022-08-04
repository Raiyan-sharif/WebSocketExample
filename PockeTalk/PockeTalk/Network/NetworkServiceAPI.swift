//
//  NetworkServiceAPI.swift
//  PockeTalk
//

import Foundation
import Moya

enum NetworkServiceAPI {
    case authkey(params:[String:Any])
    case changeLanguage(params:[String:Any])
    case tts(params:[String:Any])
    case liscense(params:[String:Any])
    case licenseConfirmation(params:[String:Any])
    case localNotificationURL
}

extension NetworkServiceAPI: TargetType{
    var baseURL: URL {
        switch self {
        case .authkey, .changeLanguage, .tts, .liscense, .licenseConfirmation:
            return URL(string:base_url)!
        case .localNotificationURL:
            return URL(string: notification_base_url)!
        }
    }

    var path: String {
        switch self {
        case .authkey:
            return stream_auth_key_url
        case .changeLanguage:
            return language_channge_url
        case .tts:
            return tts_url
        case .liscense:
            return liscense_token_url
        case .licenseConfirmation:
            return license_confirmation_url
        case .localNotificationURL:
            return LocalNotificationManager.sharedInstance.getLocalNotificationUrlPath()
        }
    }

    var method: Moya.Method {
        switch self {
        case .authkey, .changeLanguage, .tts, .liscense, .licenseConfirmation:
            return .post
        case .localNotificationURL:
            return .get
        }
    }

    var task: Task {
        switch self {
        case let .authkey(params) :
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case let .changeLanguage(params) :
            return .requestParameters(parameters: params, encoding: URLEncoding.httpBody)
        case let .tts(params) :
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case let .liscense(params) :
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case let .licenseConfirmation(params) :
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .localNotificationURL:
            return .requestPlain
        }
    }

    var sampleData: Data {
        switch self {
        case let .authkey(config) :
            return "{\"description is \": \"\(config)\"}".utf8Encoded
        case let .changeLanguage(value) :
            return "{\"description is \": \"\(value)\"}".utf8Encoded
        case let .tts(value) :
            return "{\"description is \": \"\(value)\"}".utf8Encoded
        case let .liscense(value):
            return "{\"description is \": \"\(value)\"}".utf8Encoded
        case let .licenseConfirmation(value):
            return "{\"description is \": \"\(value)\"}".utf8Encoded
        case .localNotificationURL:
            return "{\"Called local notification URL \"}".utf8Encoded
        }
    }

    var headers: [String: String]? {
        switch self {
        case .authkey, .tts:
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




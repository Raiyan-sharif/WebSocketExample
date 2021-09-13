//
//  URLRequest+Request.swift
//  PockeTalk
//
//  Created by Md. Moshiour Rahman on 12/26/20.
//

import Foundation

extension URLRequest{
    
    static func requestWith(resource:Resource)-> URLRequest{
        var request = URLRequest(url: resource.url)
        request.httpMethod = resource.httpMethod.rawValue
        request.httpBody = resource.body
        request.addValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
//        if let authorizationToken = resource.jwt {
//            print("token:",authorizationToken)
//            request.setValue(authorizationToken, forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
//        }
        
        if let res = resource.body {
            
            if let json = try? JSONSerialization.jsonObject(with: res, options: .mutableContainers),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                print("review json data : ",String(decoding: jsonData, as: UTF8.self))
            } else {
                print("json data malformed")
            }
            
        }
        
        return request
    }
}



enum HTTPHeaderField: String {
    case authentication  = "Authorization"
    case contentType     = "Content-Type"
    case acceptType      = "Accept"
    case acceptEncoding  = "Accept-Encoding"
    case acceptLangauge  = "Accept-Language"
}


enum ContentType: String {
    case json            = "application/json"
    case multipart       = "multipart/form-data"
    case ENUS            = "en-us"
}

//
//  URLRequest+Request.swift
//  PockeTalk
//
//

import Foundation

extension URLRequest{
    
    static func requestWith(resource:Resource)-> URLRequest{
        var request = URLRequest(url: resource.url)
        request.httpMethod = resource.httpMethod.rawValue
        request.httpBody = resource.body
        request.addValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        // TO DO: Need to delete if any jwt will not implement
        
//        if let authorizationToken = resource.jwt {
//            print("token:",authorizationToken)
//            request.setValue(authorizationToken, forHTTPHeaderField: HTTPHeaderField.authentication.rawValue)
//        }
        
        if let res = resource.body {
            
            if let json = try? JSONSerialization.jsonObject(with: res, options: .mutableContainers),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                PrintUtility.printLog(tag: "review json data : ", text: "\(String(decoding: jsonData, as: UTF8.self))")
            } else {
                PrintUtility.printLog(tag: "json", text: "json data malformed")
                
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

//
//  LangDetectionSN.swift
//  PockeTalk
//
//  Created by BJIT LTD on 13/12/21.
//

import Foundation
import Alamofire


class LanguageDetection {
    
    private var apiURL: URL {
        return URL(string: "https://test.pt-v.com/handsfree/api/pub/detect_lang")!
    }
    private var okResultCode = "OK"
    
    func getDetectedLanguage(with content: String, completion: @escaping (String?) -> Void) {
        print("")
        
        let parameters: [String: Any] = ["imei": imeiCode, "content": content]

        PrintUtility.printLog(tag: "parameters parameters", text: "\(apiURL)")
        let headers: HTTPHeaders = ["X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? "",]
        
        AF.request(
            apiURL,
            method: .post,
            parameters: parameters,
            encoding:  URLEncoding.httpBody,
            headers: headers
        )
        .responseData { response in
            if ((response.error?.isInvalidURLError) != nil) {
                completion(nil)
                return
            }
            
            guard let data = response.value else {
                completion(nil)
                return
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                PrintUtility.printLog(tag: "LanguageDetection", text: "Get detected Language: \(json)")
            }
            
            if let data = try? JSONDecoder().decode(LanguageDeteectionResponseModel.self, from: data) {
                if data.result_code == self.okResultCode {
                    if let detectResponse = data.detect_response {
                        if let languages = detectResponse.languages {
                            if let langCode = languages[0].language_code {
                                completion(langCode)
                            }
                        }
                    }
                }
            } else {
                completion(nil)
            }
        }
        
    }

    
}

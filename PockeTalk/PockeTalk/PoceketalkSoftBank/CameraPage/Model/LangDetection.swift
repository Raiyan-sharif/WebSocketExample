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
        return URL(string:base_url + detect_lang_url)!
    }
    private var okResultCode = "OK"
    
    func getDetectedLanguage(with content: String, completion: @escaping (String?) -> Void) {
        var licenseToken = ""
        if let token =  UserDefaults.standard.string(forKey: licenseTokenUserDefaultKey) {
            licenseToken = token
        }
        
        let parameters: [String: Any] = [license_token: licenseToken, "content": content]

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
                } else if data.result_code == INFO_INVALID_AUTH {
                    PrintUtility.printLog(tag: "Language Detection : ", text: "License Token Credentials do not exist")
                    NetworkManager.shareInstance.startTokenRefreshProcedure()
                    
                    completion(nil)
                } else if data.result_code == WARN_INPUT_PARAM {
                    PrintUtility.printLog(tag: "Language Detection : ", text: "Wrong Parameter")
                    completion(nil)
                } else if data.result_code == ERR_API_FAILED {
                    PrintUtility.printLog(tag: "Language Detection : ", text: "Language Detection API Errors")
                    completion(nil)
                } else {
                    PrintUtility.printLog(tag: "Language Detection : ", text: "Unknown error")
                    completion(nil)
                }
                
            } else {
                completion(nil)
            }
        }.responseDebugPrint()
        
    }

    
}

extension Alamofire.DataRequest {
    func responseDebugPrint() {
        response { res in
            ResponseLogger.shareInstance.insertData(response:res)
            PrintUtility.printLog(tag: "Endpoint_Path", text:res.request?.url?.absoluteString ?? "")
            PrintUtility.printLog(tag: "Endpoint_base_url", text:base_url)
            PrintUtility.printLog(tag: "Endpoint_imeiNumber", text:imeiNumber)
            PrintUtility.printLog(tag: "Endpoint_bundle", text: Bundle.main.bundleIdentifier ?? "")
            PrintUtility.printLog(tag: "Endpoint_Audio_Stream_Url", text: AUDIO_STREAM_URL)
            PrintUtility.printLog(tag: "Endpoint_Close", text: "**************************")
        }
    }
}




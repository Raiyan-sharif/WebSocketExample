//
//  GoogleCloudOCR.swift
//  PockeTalk
//
//

import Foundation
import Alamofire

class ITTSN { //TODO GoogleCloudOCR will be changed later
    
    private let TAG = "\(ITTSN.self)"
    private let apiKey = googleOCRKey
    private var apiURL: URL {
        return URL(string: image_annotate_url)!
        
    }
    
    func detect(from image: UIImage, langCode: String, completion: @escaping (GoogleCloudOCRResponse?) -> Void) {
        guard let base64Image = base64EncodeImage(image) else {
            PrintUtility.printLog(tag: self.TAG, text: "GoogleCloudOCR() >> detect() >> Error while base64 encoding image.")
            completion(nil)
            return
        }
                
        callITTSNAPI(with: base64Image, langCode: langCode, completion: completion)
    }
    
    
    private func callITTSNAPI(with base64EncodedImage: String,langCode: String, completion: @escaping (GoogleCloudOCRResponse?) -> Void) {
        PrintUtility.printLog(tag: TAG, text: "Calling vision api.........ImageBytes: \(base64EncodedImage.lengthOfBytes(using: .utf8))")
        
        var lanCode = String()
        if langCode.contains(",") {
            lanCode = ""
        } else {
            lanCode = langCode
        }
        
        var licenseToken = ""
        if let token =  UserDefaults.standard.string(forKey: licenseTokenUserDefaultKey) {
            licenseToken = token
        }
        
        let parameters: [String: Any] = [license_token: licenseToken, "lang_code": lanCode, "image_string": base64EncodedImage]
        
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
                    PrintUtility.printLog(tag: self.TAG, text: "GoogleCloudOCR() >> callGoogleVisionAPI() >> InvalidURLError")
                    completion(nil)
                    return
                }
                
                guard let data = response.value else {
                    PrintUtility.printLog(tag: self.TAG, text: "GoogleCloudOCR() >> callGoogleVisionAPI() >> data ")
                    completion(nil)
                    return
                }
                
                PrintUtility.printLog(tag: self.TAG, text: " 11111 GoogleCloudOCR() >> callGoogleVisionAPI() >> got response \(data)")
                
                if let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if result["result_code"] as! String == response_ok {
                        // Decode the JSON data into a `GoogleCloudOCRResponse` object.
                        let ocrResponse = try? JSONDecoder().decode(GoogleCloudOCRResponse.self, from: data)
                        PrintUtility.printLog(tag: "OCR RESPONSE :", text: "\(ocrResponse)")
                        completion(ocrResponse)
                    } else if result["result_code"] as! String == WARN_INVALID_AUTH {
                        NetworkManager.shareInstance.startTokenRefreshProcedure()
                        completion(nil)
                    } else {
                        completion(nil)
                    }
                }
                
                
            }
        
    }
    private func base64EncodeImage(_ image: UIImage) -> String? {
        return image.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}

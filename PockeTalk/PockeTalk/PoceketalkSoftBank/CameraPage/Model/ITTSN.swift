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
        return URL(string: "https://test.pt-v.com/handsfree/api/pub/images_annotate")!

    }
    
    func detect(from image: UIImage, langCode: String, completion: @escaping (GoogleCloudOCRResponse?) -> Void) {
        guard let base64Image = base64EncodeImage(image) else {
            print("")
            PrintUtility.printLog(tag: self.TAG, text: "GoogleCloudOCR() >> detect() >> Error while base64 encoding image.")
            completion(nil)
            return
        }
        
        //print("Base64Image: \(base64Image)")
        
        
        callITTSNAPI(with: base64Image, langCode: langCode, completion: completion)
    }
    
    
    private func callITTSNAPI(with base64EncodedImage: String,langCode: String, completion: @escaping (GoogleCloudOCRResponse?) -> Void) {
        print("")
        PrintUtility.printLog(tag: TAG, text: "Calling vision api.........ImageBytes: \(base64EncodedImage.lengthOfBytes(using: .utf8))")
        
        var lanCode = String()
        if langCode.contains(",") {
           lanCode = ""
        } else {
            lanCode = langCode
        }
        let parameters: [String: Any] = ["imei": imeiCode, "lang_code": lanCode, "image_string": base64EncodedImage]

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
            
            if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("json: \(json)")
            }
            
            // Decode the JSON data into a `GoogleCloudOCRResponse` object.
            let ocrResponse = try? JSONDecoder().decode(GoogleCloudOCRResponse.self, from: data)
            print("ocrResponse: \(ocrResponse)")
            completion(ocrResponse)
        }
        
    }
    private func base64EncodeImage(_ image: UIImage) -> String? {
        return image.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}

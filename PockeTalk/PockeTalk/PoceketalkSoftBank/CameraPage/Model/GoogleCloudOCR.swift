//
//  GoogleCloudOCR.swift
//  PockeTalk
//
//

import Foundation
import Alamofire

class GoogleCloudOCR { //TODO GoogleCloudOCR will be changed later
    private let TAG = "\(GoogleCloudOCR.self)"
    private let apiKey = ""
    private var apiURL: URL {
        return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(apiKey)")!
    }
    
    func detect(from image: UIImage, completion: @escaping (GoogleCloudOCRResponse?) -> Void) {
        guard let base64Image = base64EncodeImage(image) else {
            print("")
            PrintUtility.printLog(tag: self.TAG, text: "GoogleCloudOCR() >> detect() >> Error while base64 encoding image.")
            completion(nil)
            return
        }
        //print("Base64Image: \(base64Image)")
        
        
        callGoogleVisionAPI(with: base64Image, completion: completion)
    }
    
    private func callGoogleVisionAPI(with base64EncodedImage: String, completion: @escaping (GoogleCloudOCRResponse?) -> Void) {
        print("")
        PrintUtility.printLog(tag: TAG, text: "Calling vision api.........ImageBytes: \(base64EncodedImage.lengthOfBytes(using: .utf8))")
        let parameters: Parameters = [
            "requests": [
                [
                    "image": [
                        "content": base64EncodedImage
                    ],
                    "features": [
                        [
                            "type": "DOCUMENT_TEXT_DETECTION"
                        ]
                    ]
                ]
            ]
        ]
        let headers: HTTPHeaders = ["X-Ios-Bundle-Identifier": Bundle.main.bundleIdentifier ?? "",]
        
        AF.request(
            apiURL,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default
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
            PrintUtility.printLog(tag: self.TAG, text: "GoogleCloudOCR() >> callGoogleVisionAPI() >> got response \(data.description)")
            // Decode the JSON data into a `GoogleCloudOCRResponse` object.
            let ocrResponse = try? JSONDecoder().decode(GoogleCloudOCRResponse.self, from: data)
            completion(ocrResponse)
        }
        
    }
    
    private func base64EncodeImage(_ image: UIImage) -> String? {
        return image.pngData()?.base64EncodedString(options: .endLineWithCarriageReturn)
    }
}

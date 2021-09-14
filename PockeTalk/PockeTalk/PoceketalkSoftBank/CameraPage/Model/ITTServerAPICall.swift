//
//  PockeTalk
//

import Foundation

public class ITTServerAPICall: BaseModel {
    var mXFactor:Float = 1
    var mYFactor:Float = 1
    public func callAPI(){
        var request = URLRequest(url: ITTServerURL) //TODO set server url
        request.httpMethod = "GET"
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            //if let response = response {
            //let res: String = "\(response)"
            //self.responseTV.text = res
            //print("Response from server: ", response)
            //}
            do{
                //let ocrResponse = try? JSONDecoder().decode(GoogleCloudOCRResponse.self, from: data)
                if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    //self.responseTV.text = json as? String
                    //print("JSON: ", json)
                }
            }
            if let data = data {
                self.getScreenProperties()
                //let jsonString = String(data: data, encoding: .utf8)
                //print("JSON String: \(String(data:data, encoding: .ascii))")
                //print("Data: ",data as? String)
                let ocrResponse = try? JSONDecoder().decode(GoogleCloudOCRResponse.self, from: data)
                //print("ocrResponse: ", ocrResponse)
                let response = ocrResponse?.responses![0]
                //print("Response: ",response)
                let lanCode = response?.textAnnotations![0].locale
                //print("mDetectedLanguageCode: \(lanCode!)")
                //print("fullTextAnnotation: ", response?.fullTextAnnotation)
                let blockBlockClass = PointUtils.parseResponseForBlock(dataToParse: response?.fullTextAnnotation, mDetectedLanguageCode: lanCode!, xFactor:self.mXFactor, yFactor:self.mYFactor)
                var lineBlockClass = PointUtils.parseResponseForLine(dataToParse: response?.fullTextAnnotation, mDetectedLanguageCode: lanCode!, xFactor:self.mXFactor, yFactor:self.mYFactor)
                let detectedJSON = DetectedJSON(block: blockBlockClass, line: lineBlockClass)
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                let data = try? encoder.encode(detectedJSON)
                //print("DetectedJSON: ", String(data: data!, encoding: .utf8)!)
                //TODO call ParseTextDetection
            }
        }.resume()
    }
    private func getScreenProperties() {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        let w:Int = Int(screenWidth)
        let h:Int = Int(screenHeight)
        //print("screenWidth: \(screenWidth), screenHeight: \(screenHeight)")
        //print("screenWidth: \(w), screenHeight: \(h)")
        if 640 >= IMAGE_WIDTH {
            mXFactor = Float(screenWidth) / Float(640)
        } else {
            mXFactor = 1
        }
        if 860 >= IMAGE_HEIGHT {
            mXFactor = Float(screenHeight) / Float(860)
        } else {
            mYFactor = 1
        }
        //print("mXFactor \(mXFactor), mYFactor: \(mYFactor)")
    }
}

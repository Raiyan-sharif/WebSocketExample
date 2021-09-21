

import Foundation
import Alamofire

class WebsocketApiModel {
    private let TAG:String = "WebsocketApiModel"
    func getAuthenticationKey(){
        let urlString = STREAM_ID_ISSURANCE_URL
        let format = "PCM";
        let samplingRate = "44100";
        let samplingSize = "16";
        let channel = "1";
        let endian = "L";
        let codec = format + ", " + samplingRate + ", " + samplingSize + ", " + channel + ", " + endian
        PrintUtility.printLog(tag: "CodecValue", text: codec)
        let languageManager = LanguageSelectionManager.shared
        let nativeLangCode = languageManager.nativeLanguage
        let targetLangCode = languageManager.targetLanguage
        PrintUtility.printLog(tag: "Native", text: nativeLangCode)
        PrintUtility.printLog(tag: "Target", text: targetLangCode)
        let param:Parameters=[
            imei : "862793051345020", //Todo Have to remove IMEI number
            codec_param : codec,
            srclang : nativeLangCode,
            destlang : targetLangCode]
           let headers:HTTPHeaders=[
                "Content-Type":"application/x-www-form-urlencoded; charset=UTF-8"]
            AF.request(urlString,method: .post,parameters: param,encoding: URLEncoding.httpBody, headers: headers).responseJSON{response in
                switch response.result {
                        case .success(let data) :
                            PrintUtility.printLog(tag: self.TAG, text: "Success with JSON: \(data)")
                            let response = data as! NSDictionary
                            let key = response.object(forKey: access_key)!
                            PrintUtility.printLog(tag: self.TAG, text: key as! String)
                            UserDefaultsUtility.setStringValue(key as! String, forKey: authentication_key)
                            //SocketManager.sharedInstance.updateRequestKey(auth_key: key as! String)
                            break
                        case .failure(let error):
                            PrintUtility.printLog(tag: self.TAG, text: "Failure with JSON: \(error)")
                        }
         }
    }
}



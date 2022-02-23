//
//  NetworkManager.swift
//  PockeTalk
//

import Foundation
import Moya
import Kronos


protocol Network {
    var provider: MoyaProvider<NetworkServiceAPI> { get }
    func getAuthkey(completion:@escaping (Data?)->Void)
    func changeLanguageSettingApi(completion:@escaping (Data?)->Void)
    func ttsApi(params:[String:String],completion:@escaping (Data?)->Void)
}

let endpointClosure = { (target: NetworkServiceAPI) -> Endpoint in
    let defaultEndpoint = MoyaProvider.defaultEndpointMapping(for: target)
          PrintUtility.printLog(tag: "Endpoint_Path", text: target.baseURL.absoluteString+target.path)
          PrintUtility.printLog(tag: "Endpoint_base_url", text:target.baseURL.absoluteString)
          PrintUtility.printLog(tag: "Endpoint_imeiNumber", text:imeiNumber)
          PrintUtility.printLog(tag: "Endpoint_bundle", text: Bundle.main.bundleIdentifier ?? "")
          PrintUtility.printLog(tag: "Endpoint_Audio_Stream_Url", text: AUDIO_STREAM_URL)
          PrintUtility.printLog(tag: "Endpoint_Close", text: "**************************")
        return defaultEndpoint
}

struct LoggerPlugIn:PluginType{
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {

        switch result {
        case .success(let respose):
            ResponseLogger.shareInstance.insertData(response: respose)
        case .failure(let error):
            ResponseLogger.shareInstance.insertData(response: error.response)
        }
    }
}

struct NetworkManager:Network {
    let TAG = "\(NetworkManager.self)"
    static let APIKEY = "APIKEY"
    let serialQueue = DispatchQueue(label: "swiftlee.serial.queue")

    static let shareInstance = NetworkManager()

    let provider =  MoyaProvider<NetworkServiceAPI>(endpointClosure:endpointClosure, plugins: GlobalMethod.isAppInProduction ? [LoggerPlugIn()] : [ NetworkLoggerPlugin(configuration: .init(logOptions: .verbose)), LoggerPlugIn()])

    func getAuthkey(completion: @escaping (Data?) -> Void) {
        let format = "PCM";
        let samplingRate = "44100";
        let samplingSize = "16";
        let channel = "1";
        let endian = "L";
        let codec = format + ", " + samplingRate + ", " + samplingSize + ", " + channel + ", " + endian
        var licenseToken = ""
        if let token =  UserDefaults.standard.string(forKey: licenseTokenUserDefaultKey) {
            licenseToken = token
        }
        let params = [
            "license_token": licenseToken,
            codec_param : codec,
            srclang : LanguageSelectionManager.shared.bottomLanguage,
            destlang : LanguageSelectionManager.shared.topLanguage
        ]
        
        PrintUtility.printLog(tag: TAG, text:" AuthKey srclang \(LanguageSelectionManager.shared.bottomLanguage) desLang \(LanguageSelectionManager.shared.topLanguage)")
        provider.request(.authkey(params: params)){ result in
            
            switch result  {
            case let .success(response):
                do {
                    let successResponse = try response.filterSuccessfulStatusCodes()
                    let result = try JSONDecoder().decode(ResultModel.self, from: successResponse.data)
                    if let result_code = result.resultCode {
                        if result_code == response_ok {
                            completion(successResponse.data)
                            
                        } else if result_code == WARN_INPUT_PARAM {
                            
                            startTokenRefreshProcedure()
                            
                        } else if result_code == WARN_NO_DEVICE {
                            PrintUtility.printLog(tag: "GET AUTH KEY", text: "Cannot find the specified terminal")
                            completion(nil)
                        } else if result_code == ERR_CREATE_FAILED {
                            PrintUtility.printLog(tag: "GET AUTH KEY", text: "Stream ID issuance failure error")
                            completion(nil)
                        } else if result_code == ERR_UNKNOWN {
                            PrintUtility.printLog(tag: "GET AUTH KEY", text: "Unknown error")
                            completion(nil)
                        } else {
                            PrintUtility.printLog(tag: "GET AUTH KEY", text: "Error not Specified")
                            completion(nil)
                        }
                    }
                    
                } catch let err {
                    completion(nil)
                }
            case let .failure(error):
                completion(nil)
            }
        }
    }
    
    func changeLanguageSettingApi(completion: @escaping (Data?) -> Void) {
        var srcLang = ""
        var desLang = ""
        if LanguageSelectionManager.shared.isArrowUp {
            srcLang = LanguageSelectionManager.shared.bottomLanguage
            desLang = LanguageSelectionManager.shared.topLanguage
        }else{
            srcLang = LanguageSelectionManager.shared.topLanguage
            desLang = LanguageSelectionManager.shared.bottomLanguage
        }
        
        if let src = LanguageSelectionManager.shared.tempSourceLanguage {
            if src == SystemLanguageCode.zhHans.rawValue{
                srcLang = AlternativeSystemLanguageCode.zhCN.rawValue
            } else if src == SystemLanguageCode.zhHant.rawValue{
                srcLang = AlternativeSystemLanguageCode.zhTW.rawValue
            } else if src == SystemLanguageCode.ptPT.rawValue{
                srcLang = AlternativeSystemLanguageCode.pt.rawValue
            } else {
                srcLang = src
            }
        }
        
        guard let accesKey = UserDefaultsProperty<String>(authentication_key).value, accesKey.count > 0 else {
            completion(nil)
            return
        }
        var licenseToken = ""
        if let token =  UserDefaults.standard.string(forKey: licenseTokenUserDefaultKey) {
            licenseToken = token
        }
        let params:[String:String]  = [
            language_token: licenseToken,
            access_key:accesKey,
            srclang : srcLang,
            destlang : desLang
        ]
        
        PrintUtility.printLog(tag: TAG, text:" langChangeApi srclang \(srcLang) desLang \(desLang) key \(access_key)")
        provider.request(.changeLanguage(params: params)){ result in
            
            switch result  {
            case let .success(response):
                do {
                    let successResponse = try response.filterSuccessfulStatusCodes()
                    let result = try JSONDecoder().decode(ResultModel.self, from: successResponse.data)
                    if let result_code = result.resultCode {
                        if result_code == response_ok {
                            completion(successResponse.data)
                            
                        } else if result_code == WARN_INVALID_KEY {
                            
                            serialQueue.async { startTokenRefreshProcedure() }
                            serialQueue.async {}
                            
                        } else if result_code == WARN_INPUT_PARAM {
                            PrintUtility.printLog(tag: "Language Setting API", text: "Input parameter error")
                            completion(nil)
                        } else if result_code == WARN_INVALID_LANG {
                            PrintUtility.printLog(tag: "Language Setting API", text: "Language code does not exist")
                            completion(nil)
                        } else if result_code == ERR_SETTING_FAILED {
                            PrintUtility.printLog(tag: "Language Setting API", text: "LANGUAGE SETTING FAILURE ERROR")
                            completion(nil)
                        } else if result_code == ERR_UNKNOWN {
                            PrintUtility.printLog(tag: "Language Setting API", text: "Unknown error")
                            completion(nil)
                        } else {
                            PrintUtility.printLog(tag: "Language Setting API", text: "Error not Specified")
                            completion(nil)
                        }
                    }
                    
                } catch let err {
                    completion(nil)
                }
            case let .failure(error):
                completion(nil)
            }
        }
    }
    
    func ttsApi(params:[String:String],completion:@escaping (Data?)->Void){
        provider.request(.tts(params: params)){ result in
            switch result  {
            case let .success(response):
                do {
                    let successResponse = try response.filterSuccessfulStatusCodes()
                    let result = try JSONDecoder().decode(ResultModel.self, from: successResponse.data)
                    if let result_code = result.resultCode {
                        if result_code == response_ok {
                            completion(successResponse.data)
                            
                        } else if result_code == WARN_INVALID_AUTH {
                            serialQueue.async {
                                startTokenRefreshProcedure()
                            }
                        } else if result_code == WARN_INPUT_PARAM {
                            PrintUtility.printLog(tag: "TTS API", text: "Input parameter error")
                            completion(nil)
                        } else if result_code == WARN_INVALID_LANG {
                            PrintUtility.printLog(tag: "TTS API", text: "Language code does not exist")
                            completion(nil)
                        } else if result_code == ERR_UNKNOWN {
                            PrintUtility.printLog(tag: "TTS API", text: "TTS row failure error")
                            completion(nil)
                        } else if result_code == ERR_UNKNOWN {
                            PrintUtility.printLog(tag: "TTS API", text: "Unknown error")
                            completion(nil)
                        } else {
                            PrintUtility.printLog(tag: "TTS API", text: "Error not Specified")
                            completion(nil)
                        }
                    }
                    
                } catch let err {
                    completion(nil)
                }
            case let .failure(error):
                completion(nil)
            }
        }
    }
    
    func requestCompletion(target:NetworkServiceAPI,result:Result<Moya.Response, MoyaError>,completion:@escaping (Data?)->Void){
        switch result {
        case let .success(response):
            do {
                
                let successResponse = try response.filterSuccessfulStatusCodes()
                let result = try JSONDecoder().decode(ResultModel.self, from: successResponse.data)
                if let result_code = result.resultCode {
                    if result_code == response_ok {
                        completion(successResponse.data)
                    } else {
                        PrintUtility.printLog(tag: "License Token API", text: "License Token API Failed")
                        completion(nil)
                    }
                }
                
            } catch let err {
                completion(nil)
            }
        case let .failure(error):
            completion(nil)
        }
    }
    
    
    
    func makeRequestForToken(completion : @escaping (Bool)->Void){
        self.getAuthkey { data in
            guard let data = data else {
                completion(false)
                return
            }
            do {
                let result = try JSONDecoder().decode(ResultModel.self, from: data)
                if result.resultCode == response_ok{
                    UserDefaultsProperty<String>(authentication_key).value = result.accessKey
                    completion(true)
                }
            }catch{
                completion(false)
            }
        }
    }
    
    func getLicenseToken(completion: @escaping (Data?) -> Void) {
        
        let params:[String:String]  = [
            "imei": imeiNumber,
        ]
        
        provider.request(.liscense(params: params)){ result in
            self.requestCompletion(target: .liscense(params: params), result: result) { data in
                completion(data)
            }
        }
        
    }
    
    func handleLicenseToken(completion : @escaping (Bool)->Void) {
        
        getLicenseToken { data in
            guard let data = data else {return}
            do {
                let data = try JSONDecoder().decode(LiscenseTokenModel.self, from: data)
                if data.result_code == response_ok {
                    if let liscense_token = data.token {
                        PrintUtility.printLog(tag: "Liscense key", text: "\(liscense_token)")
                        UserDefaults.standard.set(liscense_token, forKey: licenseTokenUserDefaultKey)
                        
                        Clock.sync(completion:  { date, offset in
                            if let getResDate = date {
                                PrintUtility.printLog(tag: "get Response Date", text: "\(getResDate)")
                                let tokenCreationTimeInMiliSecond = getResDate.millisecondsSince1970
                                UserDefaults.standard.set(tokenCreationTimeInMiliSecond, forKey: tokenCreationTime)
                                completion(true)
                            }
                        })
                        
                    }
                }
            } catch{}
        }
    }
    
    func startTokenRefreshProcedure() {
        handleLicenseToken { result in
            if result {
                AppDelegate.generateAccessKey()
            }
        }
    }
    
}


struct ResultModel : Codable {
    
    let accessKey : String?
    let resultCode : String?
    
    enum CodingKeys: String, CodingKey {
        case accessKey = "access_key"
        case resultCode = "result_code"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        accessKey = try values.decodeIfPresent(String.self, forKey: .accessKey)
        resultCode = try values.decodeIfPresent(String.self, forKey: .resultCode)
    }
    
}

struct TTSModel : Codable {
    
    let tts : String?
    let codec : String?
    let tempo : String?
    let resultCode : String?
    
    enum CodingKeys: String, CodingKey {
        case tts = "tts"
        case codec = "codec"
        case tempo = "tempo"
        case resultCode = "result_code"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        tts = try values.decodeIfPresent(String.self, forKey: .tts)
        codec = try values.decodeIfPresent(String.self, forKey: .codec)
        tempo = try values.decodeIfPresent(String.self, forKey: .tempo)
        resultCode = try values.decodeIfPresent(String.self, forKey: .resultCode)
    }
    
}

struct LiscenseTokenModel: Codable {
    let token: String?
    let result_code: String?
}

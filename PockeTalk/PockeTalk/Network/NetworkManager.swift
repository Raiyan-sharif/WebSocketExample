//
//  NetworkManager.swift
//  PockeTalk
//

import Foundation
import Moya


protocol Network {
    var provider: MoyaProvider<NetworkServiceAPI> { get }
    func getAuthkey(completion:@escaping (Data?)->Void)
    func changeLanguageSettingApi(completion:@escaping (Data?)->Void)
    func ttsApi(params:[String:String],completion:@escaping (Data?)->Void)
}


struct NetworkManager:Network {
    let TAG = "\(NetworkManager.self)"
    static let APIKEY = "APIKEY"

    static let shareInstance = NetworkManager()

    let provider =  MoyaProvider<NetworkServiceAPI>(plugins: [NetworkLoggerPlugin(configuration:.init(logOptions: .verbose))])

    func getAuthkey(completion: @escaping (Data?) -> Void) {
        let format = "PCM";
        let samplingRate = "44100";
        let samplingSize = "16";
        let channel = "1";
        let endian = "L";
        let codec = format + ", " + samplingRate + ", " + samplingSize + ", " + channel + ", " + endian
        let params = [
            imei : "862793051345020", //Todo Have to remove IMEI number
            codec_param : codec,
            srclang : LanguageSelectionManager.shared.bottomLanguage,
            destlang : LanguageSelectionManager.shared.topLanguage]
        PrintUtility.printLog(tag: TAG, text:" AuthKey srclang \(LanguageSelectionManager.shared.bottomLanguage) desLang \(LanguageSelectionManager.shared.topLanguage)")
        provider.request(.authkey(params: params)){ result in
            self.requestCompletion(target: .authkey(params: params), result: result) { data in
                completion(data)
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
            srcLang = src
        }

        let params:[String:String]  = [
            access_key:UserDefaultsProperty<String>(authentication_key).value! ,
            srclang : srcLang,
            destlang : desLang
        ]

        PrintUtility.printLog(tag: TAG, text:" langChangeApi srclang \(srcLang) desLang \(desLang) key \(access_key)")
        provider.request(.changeLanguage(params: params)){ result in
            self.requestCompletion(target: .changeLanguage(params: params), result: result) { data in
                completion(data)
            }
        }
    }
    
    func ttsApi(params:[String:String],completion:@escaping (Data?)->Void){
        provider.request(.tts(params: params)){ result in
            self.requestCompletion(target: .tts(params: params), result: result) { data in
                completion(data)
            }
        }
    }

    func requestCompletion(target:NetworkServiceAPI,result:Result<Moya.Response, MoyaError>,completion:@escaping (Data?)->Void){
        switch result {
        case let .success(response):
            do {
                let successResponse = try response.filterSuccessfulStatusCodes()
                completion(successResponse.data)
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

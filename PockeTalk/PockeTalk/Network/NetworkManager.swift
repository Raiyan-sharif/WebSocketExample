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
        var srcLangCode = ""
        var desLangCode = ""
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
        if LanguageSelectionManager.shared.isArrowUp {
            srcLangCode = LanguageSelectionManager.shared.bottomLanguage
            desLangCode = LanguageSelectionManager.shared.topLanguage
        }else{
            srcLangCode = LanguageSelectionManager.shared.topLanguage
            desLangCode = LanguageSelectionManager.shared.bottomLanguage
        }
        let params = [
            "license_token": licenseToken,
            codec_param : codec,
            srclang : srcLangCode,
            destlang : desLangCode
        ]

        PrintUtility.printLog(tag: TAG, text:" AuthKey srclang \(srcLangCode) desLang \(desLangCode)")
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

        PrintUtility.printLog(tag: TAG, text:" langChangeApi srclang \(srcLang) desLang \(desLang) key \(accesKey)")
        provider.request(.changeLanguage(params: params)){ result in

            switch result  {
            case let .success(response):
                do {
                    let successResponse = try response.filterSuccessfulStatusCodes()
                    let result = try JSONDecoder().decode(ResultModel.self, from: successResponse.data)
                    if let result_code = result.resultCode {
                        if result_code == response_ok {
                            PrintUtility.printLog(tag: "Language Setting API", text: "")
                            completion(successResponse.data)

                        } else if result_code == WARN_INVALID_KEY {
                            PrintUtility.printLog(tag: "Language Setting API", text: "Warn Invalid Key")
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
                //IAPManager.shared.setScheduleExecution = 0
                let successResponse = try response.filterSuccessfulStatusCodes()
                let result = try JSONDecoder().decode(ResultModel.self, from: successResponse.data)
                PrintUtility.printLog(tag: "RTC", text: "requestCompletion >> result code: \(result.resultCode)")
                if let result_code = result.resultCode {
                    if result_code == response_ok {
                        PrintUtility.printLog(tag: "License Token API", text: "License Token api calling successfully")
                        completion(successResponse.data)
                    } else if result_code == WARN_INVALID_AUTH {
                        if let _ =  UserDefaults.standard.string(forKey: kCouponCode) {
                            UserDefaults.standard.removeObject(forKey: kCouponCode)
                        }
                        if UserDefaults.standard.bool(forKey: kFreeTrialStatus) == true {
                            UserDefaults.standard.removeObject(forKey: kFreeTrialStatus)
                        }
                        GlobalMethod.appdelegate().navigateToViewController(.purchasePlan)
                        TokenApiStateObserver.shared.updateState(state: .failed)
                        PrintUtility.printLog(tag: "License Token API", text: "There is no license information.")
                        completion(nil)
                    } else if result_code == WARN_INPUT_PARAM {
                        PrintUtility.printLog(tag: "License Token API", text: "Input parameter error")
                        TokenApiStateObserver.shared.updateState(state: .failed)
                        completion(nil)
                    } else if result_code == ERR_CREATE_FAILED {
                        PrintUtility.printLog(tag: "License Token API", text: "License token issuance error")
                        TokenApiStateObserver.shared.updateState(state: .failed)
                        completion(nil)
                    } else if result_code == ERR_UNKNOWN {
                        PrintUtility.printLog(tag: "License Token API", text: "Unknown error")
                        TokenApiStateObserver.shared.updateState(state: .failed)
                        completion(nil)
                    } else {
                        TokenApiStateObserver.shared.updateState(state: .failed)
                        PrintUtility.printLog(tag: "License Token API", text: "License info over")
                            let alertVC = UIAlertController(title: "" , message: "kUnknownError".localiz(), preferredStyle: UIAlertController.Style.alert)
                            alertVC.view.tintColor = UIColor.black
                            let okAction = UIAlertAction(title: "OK".localiz(), style: UIAlertAction.Style.cancel) { (alert) in
                                // add ok action functionality
                                IAPManager.shared.alreadyAlertVisible = false
                                exit(0)
                            }
                            alertVC.addAction(okAction)
                            DispatchQueue.main.async {
                                IAPManager.shared.getTopVisibleViewController { topViewController in
                                    if let viewController = topViewController {
                                        var presentVC = viewController
                                        while let next = presentVC.presentedViewController {
                                            presentVC = next
                                        }
                                        if IAPManager.shared.alreadyAlertVisible == false {
                                            ActivityIndicator.sharedInstance.hide()
                                            presentVC.present(alertVC, animated: true, completion: nil)
                                            IAPManager.shared.alreadyAlertVisible = true
                                        }
                                    }
                                }
                            completion(nil)
                        }
                        PrintUtility.printLog(tag: "License Token API", text: "License Token API Failed")
                        completion(nil)
                    }
                }

            } catch let err {
                TokenApiStateObserver.shared.updateState(state: .failed)
                //IAPManager.shared.setScheduleExecution = 0
                completion(nil)
            }
        case let .failure(error):
            TokenApiStateObserver.shared.updateState(state: .failed)
            //IAPManager.shared.setScheduleExecution = 0
            completion(nil)
        }
    }

    func requestLicenseConfirmationCompletion(target:NetworkServiceAPI,result:Result<Moya.Response, MoyaError>,completion:@escaping (Data?)->Void){
        switch result {
        case let .success(response):
            do{
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
                    UserDefaultsProperty<String>(authentication_key).value = result.token
                    completion(true)
                }
            }catch{
                completion(false)
            }
        }
    }

    func getLicenseToken(completion: @escaping (Data?) -> Void) {
        TokenApiStateObserver.shared.updateState(state: .running)
        let params = getLicenseTokenParam()
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "getLicenseToken => params => \(params)")
        provider.request(.liscense(params: params)){ result in
            self.requestCompletion(target: .liscense(params: params), result: result) { data in
                completion(data)
            }
        }
    }

    func getLicenseTokenParam() -> [String: String]{
        var params = [String: String]()
        let defaultParam = [kImei: imeiNumber, kClientInfo: kClientInfo, kAppUdid: udid ?? ""]
        if let couponCode = UserDefaults.standard.string(forKey: kCouponCode), couponCode != "" {
            params = [
                kAppUdid: getUUID() ?? "",
                kClientInfo: kPocketalk_app_ios,
                couponCodeParamName: couponCode
            ]
            return params
        } else if UserDefaults.standard.bool(forKey: kFreeTrialStatus) == true{
            params = [
                kAppUdid: getUUID() ?? "",
                kClientInfo: kPocketalk_app_ios,
                kTrialKey: getUUID() ?? "",
                kTrialType: kIosTrialType
            ]
            return params
        }else{
            let schemeName = Bundle.main.infoDictionary![currentSelectedSceme] as! String
            let iosReceipt = UserDefaults.standard.string(forKey: kiOSReceipt)
            let iosOriginalTransactionID = UserDefaults.standard.string(forKey: kiOSOriginalTransactionID)

            switch (schemeName) {
            case BuildVarientScheme.PRODUCTION_WITH_PRODUCTION_URL.rawValue, BuildVarientScheme.PRODUCTION_WITH_STAGE_URL.rawValue,BuildVarientScheme.PRODUCTION_WITH_LIVE_URL.rawValue:
                params = [
                    kAppUdid: getUUID() ?? "",
                    kClientInfo: kPocketalk_app_ios,
                    kIosReceipt: iosReceipt ?? "",
                    kOriginalTransactionID: iosOriginalTransactionID ?? ""
                ]
                return params

            case BuildVarientScheme.STAGING.rawValue :

                if iosReceipt != "" && iosOriginalTransactionID != "" {
                    params = [
                        kAppUdid: getUUID() ?? "",
                        kClientInfo: kPocketalk_app_ios,
                        kIosReceipt: iosReceipt ?? "",
                        kOriginalTransactionID: iosOriginalTransactionID ?? ""
                    ]
                    return params
                }
            case BuildVarientScheme.LOAD_ENGINE_FROM_ASSET.rawValue, BuildVarientScheme.SERVER_API_LOG.rawValue:
                params = [
                    kImei: imeiNumber,
                    kClientInfo: kClientInfo,
                    kAppUdid: udid ?? ""
                ]
                return params
            default:
                return defaultParam
            }
        }
        return defaultParam
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

                        let tokenCreationTimeInMiliSecond = Date().millisecondsSince1970
                        UserDefaults.standard.set(tokenCreationTimeInMiliSecond, forKey: tokenCreationTime)
                        completion(true)

//                        Clock.sync(completion:  { date, offset in
//                            if let getResDate = date {
//                                PrintUtility.printLog(tag: "get Response Date", text: "\(getResDate)")
//                                let tokenCreationTimeInMiliSecond = getResDate.millisecondsSince1970
//                                UserDefaults.standard.set(tokenCreationTimeInMiliSecond, forKey: tokenCreationTime)
//                                completion(true)
//                            }
//                        })
                    } else {
                        completion(false)
                    }
                }
            } catch{
                completion(false)
            }
        }
    }

    func startTokenRefreshProcedure() {
        PrintUtility.printLog(tag: "RTC", text: "startTokenRefreshProcedure >> call token api")
        handleLicenseToken { result in
            if result {
                AppDelegate.generateAccessKey { result in
                    if result == true {
                        SocketManager.sharedInstance.connect()
                    }
                }
            }
        }
    }

    func getLicenseConfirmation(coupon: String, completion: @escaping (Data?) -> Void) {
        let params:[String:String]  = [
            "coupon_code": coupon
        ]
        provider.request(.licenseConfirmation(params: params)){ result in
            self.requestLicenseConfirmationCompletion(target: .licenseConfirmation(params: params), result: result) { data in
                completion(data)
            }
        }
    }
    
    func callTokenIssuanceApiForFreeTrial(completion: @escaping (Data?) -> Void) {
        let params = [
                kAppUdid: getUUID() ?? "",
                kClientInfo: kPocketalk_app_ios,
                kTrialKey: getUUID() ?? "",
                kTrialType: kIosTrialType
            ]
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"License Token API Params = \(params)")
        provider.request(.liscense(params: params)){ result in
            switch result {
            case let .success(response):
                do{
                    let successResponse = try response.filterSuccessfulStatusCodes()
                    completion(successResponse.data)
                } catch _ {
                    completion(nil)
                }
            case .failure(_):
                completion(nil)
            }
        }
    }
    
    func callLicenseConfirmationForFreeTrial(completion: @escaping (Data?) -> Void) {
        let params:[String:String]  = [
            kTrialKey: getUUID() ?? "",
            kTrialType: kIosTrialType
        ]
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"License Confirmation API Params = \(params)")
        provider.request(.licenseConfirmation(params: params)){ result in
            self.requestLicenseConfirmationCompletion(target: .licenseConfirmation(params: params), result: result) { data in
                completion(data)
            }
        }
    }
}

struct ResultModel : Codable {
    let access_key: String?
    let token : String?
    let resultCode : String?

    enum CodingKeys: String, CodingKey {
        case access_key = "access_key"
        case token = "token"
        case resultCode = "result_code"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        access_key = try values.decodeIfPresent(String.self, forKey: .access_key)
        token = try values.decodeIfPresent(String.self, forKey: .token)
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

struct LicenseConfirmationModel: Codable {
    let result_code: String?
    let license_exp: String?
    let license_str: String?
}

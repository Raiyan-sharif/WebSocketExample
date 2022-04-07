//
//  ResponseLogger.swift
//  PockeTalk
//


import Foundation
import Moya
import Alamofire

struct LoggerModel {
    let date:Date
    let url : String
    let params : String
    let response: String
}

class ResponseLogger {

    static let shareInstance = ResponseLogger()
    private (set) var dataArray = [LoggerModel]()

    private var isResponeLoggerAvailable: Bool {
        let schemeName = Bundle.main.infoDictionary![currentSelectedSceme] as! String
        if schemeName == BuildVarientScheme.SERVER_API_LOG.rawValue {
            return true
        }
      return false
    }
    
    func clean(){
        dataArray.removeAll()
    }

    func insertData(response:Response?) {
        guard let response = response else {
            return
        }
        if isResponeLoggerAvailable{
            let url = response.request?.url?.absoluteString ?? ""
            var params = ""
            if let httpBody = response.request?.httpBody{
                if !url.contains(tts_url){
                    params = String(data: httpBody, encoding: .utf8) ?? ""
                }
            }
            var res = ""
            if !url.contains(tts_url){
                res = String(data: response.data, encoding: .utf8) ?? ""
            }
            dataArray.append(LoggerModel(date: Date(), url: url, params: params, response: res))
        }
    }

    func insertData(response:AFDataResponse<Data?>){
        if let data = response.data, isResponeLoggerAvailable {
            let url = response.request?.url?.absoluteString ?? ""
            var params = ""
            if let httpBody = response.request?.httpBody{
                if !url.contains(image_annotate_url){
                    params = String(data: httpBody, encoding: .utf8) ?? ""
                }
            }
            var res = ""
            if !url.contains(image_annotate_url){
                res = String(data: data, encoding: .utf8) ?? ""
            }
            dataArray.append(LoggerModel(date: Date(), url: url, params: params, response: res))
        }
    }

}

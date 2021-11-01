//
//  TTTGoogle.swift
//  PockeTalk
//

import Foundation

public class TTTGoogle {
    
    static func translate(source: String,target: String,text: String, completion: @escaping(_ translatedText: String?)-> Void) {
        let url = getURL(source: source, target: target, text: text)
        var translatedText: String = ""
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let data = data {
                
                let tttJson = try? JSONDecoder().decode(TTTJSONModel.self, from: data)
                
                if let text =  tttJson?.data.translations[0].translatedText {
                    translatedText = text
                } else {
                    translatedText = ""
                }
                PrintUtility.printLog(tag: "TTTGoogle() >> translate() >> ", text: "translatedText: \(translatedText)")
                completion(translatedText)
            }
            
            }.resume()
        
    }
    
    static func getURL(source: String,target: String,text: String) -> URL {
        var url: URL = URL(string: "www.googleapis.com")!
        let scheme = "https"
        let host = "www.googleapis.com"
        let path = "/language/translate/v2"
        let queryItem = URLQueryItem(name: "key", value: queryItemApiKey)
        let queryItem2 = URLQueryItem(name: "target", value: target)
        let queryItem1 = URLQueryItem(name: "source", value: source)
        let queryItem3 = URLQueryItem(name: "q", value: text)


        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = [queryItem, queryItem1, queryItem2, queryItem3]

        if let url1 = urlComponents.url {
            url = url1
            PrintUtility.printLog(tag: "TTTGoogle() >> translate() >> ", text: "Prepared URL: \(url)")
        }
        return url
    }
}

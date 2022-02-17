//
//  WebService.swift
//  PockeTalk
//
//

import Foundation

enum NetworkError: Error {
    case decodingError
    case domainError
    case offline
    case invalidURL
    case undefined
    
}

enum Result2<T,H> {
    case success(T,H)
    case failure(H)
}

enum HttpMethod: String {
    case get = "GET"
}

typealias HandlerResult = Result2<Data,Error>

struct Resource {
    let url: URL
    var httpMethod: HttpMethod = .get
    var body: Data? = nil
}

extension Resource{
    //    init(url: URL) {
    //        self.url = url
    //    }
}

class WebService {
    
    static func load(resource:Resource,completion:@escaping(HandlerResult)->Void )  {
        
        URLSession.shared.dataTask(with: URLRequest.requestWith(resource: resource)) {(data, reponse, error) in
            
            guard let data = data, error == nil else {
                completion(.failure(NetworkError.offline))
                return
            }
            
            if let statusCode = reponse?.getStatusCode(){
                
                if let status = HTTPStatusCodes.init(rawValue: statusCode){
                    PrintUtility.printLog(tag: "Status", text: status.localizedDescription)
                    do {
                        
//                        if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
//
//                        }
                    }
                    catch let error {
                        PrintUtility.printLog(tag: "ERROR", text: error.localizedDescription)
                    }
                    
                    completion(.success(data, status))
                }
            }
        }.resume()
    }
    
}


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

enum Result<T,H> {
    case success(T,H)
    case failure(H)
}

enum HttpMethod: String {
    case get = "GET"
}

typealias HandlerResult = Result<Data,Error>

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
                    print("statusCode of \(resource.url):",statusCode)
//                    print("resource.authorization : \(resource.authorization)")
                    do {
                        
//                        if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
//                            print("json data: \(json)")
//                        }
                    }
                    catch let error {
                        print("error in catch block")
                        print(error)
                    }
                    
                    completion(.success(data, status))
                }
            }
        }.resume()
    }
    
}


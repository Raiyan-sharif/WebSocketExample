//
//  JSONDecoder+Reusable.swift
//  PockeTalk
//
//  Created by Md. Moshiour Rahman on 10/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import Foundation

enum ParseResult<T,H> {
    case success(T)
    case failure(H)
}

extension JSONDecoder{
    
    static func decodeData<T:Decodable>(model: T.Type,_ data: Data?,completion: @escaping(ParseResult<T, Error>)->Void){
        let decoder = JSONDecoder()
        do {
            let data = try decoder.decode(model, from: data!)
            completion(.success(data))
        } catch {
            completion(.failure(error))
        }
    }
}

//
//  URLResponse+Extension.swift
//  Raffek
//
//  Created by Asraful Alam on 19/2/21.
//

import Foundation

extension URLResponse {

    func getStatusCode() -> Int? {
        if let httpResponse = self as? HTTPURLResponse {
            return httpResponse.statusCode
        }
        return nil
    }
}

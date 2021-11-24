//
//  FileDownloader.swift
//  PockeTalk
//

import Foundation

class FileDownloader {

    private static let TAG = "FileDownloader"
    private static let errorNoDirectory = "No Directory"
    private static let errorFailedResponse = "Failed Response"
    private static let errorNilData = "Nil Data"
    private static let errorDownloadFailed = "Download Failed"
    private static let errorSaveFailed = "Save Failed"
    private static let defaultErrorCode = 0

    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void)
    {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)

        if FileManager().fileExists(atPath: destinationUrl.path)
        {
            PrintUtility.printLog(tag: TAG, text: "File already exists in document directory")
            completion(destinationUrl.path, nil)
        }

        else if let dataFromURL = NSData(contentsOf: url)
        {
            if dataFromURL.write(to: destinationUrl, atomically: true)
            {
                PrintUtility.printLog(tag: TAG, text: "file saved to document directory")
                completion(destinationUrl.path, nil)
            }
            else
            {
                PrintUtility.printLog(tag: TAG, text: "error saving file")
                let error = NSError(domain: errorSaveFailed, code: defaultErrorCode, userInfo:nil)
                completion(destinationUrl.path, error)
            }
        }
        else
        {
            let error = NSError(domain: errorDownloadFailed, code: defaultErrorCode, userInfo:nil)
            completion(destinationUrl.path, error)
        }
    }

    static func getFilePath(fileName: String) -> String? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            PrintUtility.printLog(tag: TAG, text: "Document directory not found")
            return nil
        }
        let destinationUrl = documentsUrl.appendingPathComponent(fileName)
        if (FileManager().fileExists(atPath: destinationUrl.path)) {
            return destinationUrl.path
        }
        PrintUtility.printLog(tag: TAG, text: "\(fileName) not exist")
        return nil
    }

    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void) {

        guard let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            PrintUtility.printLog(tag: TAG, text: "Couldn't find document directory")
            completion(nil, NSError(domain: errorNoDirectory, code: defaultErrorCode, userInfo: nil))
            return
        }
        let destinationUrl = documentsUrl.appendingPathComponent(LanguageEngineFileName)

        let session = URLSession(configuration: .ephemeral)
        var request = URLRequest(url: url)
        request.httpMethod = HttpMethod.get.rawValue

        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                PrintUtility.printLog(tag: TAG, text: "Error is not nil : \(String(describing: error?.localizedDescription))")
                completion(nil, error)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                PrintUtility.printLog(tag: TAG, text: "Response is nil")
                completion(nil, NSError(domain: errorFailedResponse, code: defaultErrorCode, userInfo: nil))
                return
            }
            guard response.statusCode == 200 else {
                PrintUtility.printLog(tag: TAG, text: "Response isn't success : \(response.statusCode)")
                completion(nil, NSError(domain: errorFailedResponse, code: defaultErrorCode, userInfo: nil))
                return
            }
            guard let data = data else {
                PrintUtility.printLog(tag: TAG, text: "Data is nil")
                completion(nil, NSError(domain: errorNilData, code: defaultErrorCode, userInfo: nil))
                return
            }
            guard let decodedData = Data(base64Encoded: data) else {
                PrintUtility.printLog(tag: TAG, text: "Failed to decode response data")
                return
            }

            do {
                try decodedData.write(to: destinationUrl, options: .atomic)
                completion(destinationUrl.path, error)
            }
            catch {
                PrintUtility.printLog(tag: TAG, text: "Failed to save data")
                completion(nil, error)
            }
        })
        task.resume()
    }
}

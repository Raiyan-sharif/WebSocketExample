//
//  FileUtility.swift
//  PockeTalk
//

import Foundation

class FileUtility {

    private static let TAG = "FileUtility"
    private static let fileManager = FileManager.default

    ///Get TTS audio file path from Document/TtsAudioFiles directory. Returns nil if file not found
    static func getTtsAudioFilePath(_ fileName: String) -> String? {
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            PrintUtility.printLog(tag: TAG, text: "Document directory not found")
            return nil
        }
        let ttsFolderURL = documentsUrl.appendingPathComponent(kTTSAudioFolderName, isDirectory: true)
        if !isDirectoryExists(atPath: ttsFolderURL.path) {
            PrintUtility.printLog(tag: TAG, text: "\(kTTSAudioFolderName) folder not exist yet")
            return nil
        }
        let destinationUrl = ttsFolderURL.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: destinationUrl.path) {
            PrintUtility.printLog(tag: TAG, text: "TTS audio file exist at \(destinationUrl.path)")
            return destinationUrl.path
        }
        PrintUtility.printLog(tag: TAG, text: "\(fileName) not exist")
        return nil
    }

    ///Save TTS audio data as WAV format in Document/TtsAudioFiles directory
    static func saveTtsAudioData(data: Data, fileName: String) {
        guard let documentsUrl =  fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            PrintUtility.printLog(tag: TAG, text: "Couldn't find document directory")
            return
        }
        do {
            let ttsFolderURL = documentsUrl.appendingPathComponent(kTTSAudioFolderName, isDirectory: true)
            if !isDirectoryExists(atPath: ttsFolderURL.path) {
                PrintUtility.printLog(tag: TAG, text: "\(kTTSAudioFolderName) directory not exist, creating")
                try fileManager.createDirectory(at: ttsFolderURL, withIntermediateDirectories: false)
            }
            let destinationUrl = ttsFolderURL.appendingPathComponent(fileName)
            try data.write(to: destinationUrl, options: .atomic)
            PrintUtility.printLog(tag: TAG, text: "TTS audio file saved at \(destinationUrl.path)")
        }
        catch {
            PrintUtility.printLog(tag: TAG, text: "Failed to save TTS data - \(fileName)")
        }
    }

    ///Delete TTS audio directory with all of its contents
    static func deleteTTSAudioDirectory() {
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            PrintUtility.printLog(tag: TAG, text: "Document directory not found")
            return
        }
        let ttsFolderURL = documentsUrl.appendingPathComponent(kTTSAudioFolderName, isDirectory: true)
        if self.isDirectoryExists(atPath: ttsFolderURL.path) {
            do {
                try fileManager.removeItem(atPath: ttsFolderURL.path)
                PrintUtility.printLog(tag: TAG, text: "\(kTTSAudioFolderName) directory deleted with its contents")
            }
            catch {
                PrintUtility.printLog(tag: TAG, text: "Couldn't delete directory - \(kTTSAudioFolderName)")
            }
        }
    }

    ///Delete history items only (Excluded favorite items)
    static func deleteAllHistoryTTSAudioFiles() {
        do {
            let historyEntities = try ChatDBModel().getAllHistoryItemsToDelete()
            for entity in historyEntities {
                deleteTtsAudioFile(chatEntity: entity)
            }
            PrintUtility.printLog(tag: TAG, text: "All history items deleted")
        }
        catch let error {
            PrintUtility.printLog(tag: TAG, text: "Failed to delete history items - \(error.localizedDescription)")
        }
    }

    ///Delete favorite items only (Excluded history items)
    static func deleteAllFavoriteTTSAudioFiles() {
        do {
            let historyEntities = try ChatDBModel().getAllFavoriteItemsToDelete()
            for entity in historyEntities {
                deleteTtsAudioFile(chatEntity: entity)
            }
            PrintUtility.printLog(tag: TAG, text: "All favorite items deleted")
        }
        catch let error {
            PrintUtility.printLog(tag: TAG, text: "Failed to delete favorite items - \(error.localizedDescription)")
        }
    }

    ///Delete a specific file from TTS audio directory
    static func deleteTtsAudioFile(chatEntity: ChatEntity) {
        let fileName = chatEntity.textFileName ?? ""
        if let path = getTtsAudioFilePath(fileName) {
            do {
                try fileManager.removeItem(atPath: path)
                PrintUtility.printLog(tag: TAG, text: "File deleted - \(fileName)")
            }
            catch {
                PrintUtility.printLog(tag: TAG, text: "Failed to delete file - \(fileName)")
            }
        }
    }

    ///Check whether the directory exists in given path
    static func isDirectoryExists(atPath path: String) -> Bool {
        var isDirectory : ObjCBool = true
        let exist = fileManager.fileExists(atPath: path, isDirectory:&isDirectory)
        return exist && isDirectory.boolValue
    }

    ///Generate audio file name with current time (milliseconds) and extension (.wav)
    static func generateAudioFileName() -> String {
        return String(Date().millisecondsSince1970) + kTTSAudioFileNameExtenstion
    }
}

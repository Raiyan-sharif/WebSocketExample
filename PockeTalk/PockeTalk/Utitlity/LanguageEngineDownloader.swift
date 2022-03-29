//
//  LanguageEngineDownloader.swift
//  PockeTalk
//

import Foundation
import Kronos

class LanguageEngineDownloader: NSObject {
    private let TAG = "\(LanguageEngineDownloader.self)"
    public static let shared = LanguageEngineDownloader()
    private var fileDownloadTimer = Timer()
    private let thresholdTimeInMilliSecondForFileDownload : Double = 86400000 //24hrs = 24*60*60*1000

    private override init() {
        super.init()
    }

    public func checkTimeAndDownloadLanguageEngineFile() {
        Clock.sync(completion:  { [weak self] date, _ in
            guard let self = self, let curDate = date else {
                PrintUtility.printLog(tag: "LANGUAGE ENGINE", text: "Failed to get current time")
                return
            }
            let savedTimeInMilliSecond = UserDefaults.standard.double(forKey: KLanguageEngineFileCreationTime)
            if (savedTimeInMilliSecond == 0) {
                PrintUtility.printLog(tag: self.TAG, text: "Saved time is nil, downloading file from server")
                self.downloadFileFromServer()
                return
            }
            let expiryTime = savedTimeInMilliSecond + self.thresholdTimeInMilliSecondForFileDownload
            let curTimeInMilliSecond = Double(curDate.millisecondsSince1970)
            if (curTimeInMilliSecond >= expiryTime) {
                PrintUtility.printLog(tag: self.TAG, text: "Threshold time passed, downloading file from server")
                self.downloadFileFromServer()
            }
            else {
                let remainingTimeInSecond = (expiryTime - curTimeInMilliSecond)/1000
                self.setFileDownloadTimer(interval: remainingTimeInSecond)
            }
        })
    }

    private func setFileDownloadTimer(interval: Double) {
        DispatchQueue.main.async {
            PrintUtility.printLog(tag: self.TAG, text: "The timer will fire after \(interval) seconds")
            self.fileDownloadTimer.invalidate()
            self.fileDownloadTimer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.fileDownloadTimerFired(_:)), userInfo: nil, repeats: false)
        }
    }

    @objc func fileDownloadTimerFired(_ timer: Timer) {
        PrintUtility.printLog(tag: self.TAG, text: "Language engine file download timer fired")
        self.downloadFileFromServer()
    }

    private func downloadFileFromServer() {
        guard let url = URL(string: getLanguageEngineURL()) else {
            PrintUtility.printLog(tag: self.TAG, text: "URL is nil")
            return
        }
        PrintUtility.printLog(tag: self.TAG, text: "Language engine file download URL: \(url)")
        FileDownloader.loadFileAsync(url: url) { [weak self] path, error in
            guard let self = self else {
                PrintUtility.printLog(tag: "LANGUAGE ENGINE", text: "self is nil")
                return
            }
            //set timer for next download
            self.setFileDownloadTimer(interval: self.thresholdTimeInMilliSecondForFileDownload/1000)
            guard let path = path else {
                PrintUtility.printLog(tag: self.TAG, text: "Failed to save file")
                return
            }
            PrintUtility.printLog(tag: self.TAG, text: "File downloaded to directory - \(path)")
            let currentTimeInMilliSecond = Double(Clock.now?.millisecondsSince1970 ?? 0)
            UserDefaults.standard.set(currentTimeInMilliSecond, forKey: KLanguageEngineFileCreationTime)
        }
    }

    private func getLanguageEngineURL() -> String {
        #if PRODUCTION || MULTISERVER_PRODUCTION || PRODUCTION_WITH_STAGE_URL
            return LanguageEngineUrlForProductionBuild
        #else
            return LanguageEngineUrlForStageBuild
        #endif
    }
}

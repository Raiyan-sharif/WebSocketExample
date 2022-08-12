//
//  GoogleAnalyticsServiceInfo.swift
//  PockeTalk
//

import Foundation

struct GoogleAnalyticsServiceInfo {
    func logGoogleServiceInfo() {
        guard let googleServiceInfoPlistPath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.googleAnalyticsTag, text: "Couldn't locate GoogleService-Info.plist")
            return
        }

        do {
            let plistData = try Data.init(contentsOf: URL(fileURLWithPath: googleServiceInfoPlistPath))

            let plistDecoder = PropertyListDecoder()
            let googleServiceInfo = try plistDecoder.decode(GoogleServiceInfo.self, from: plistData)

            let rawAppId = googleServiceInfo.appId
            let projectId = googleServiceInfo.projectId

            guard let appId = FirebaseAppId(rawValue: rawAppId) else {
                PrintUtility.printLog(tag: TagUtility.sharedInstance.googleAnalyticsTag, text: "Invalid appId: \(rawAppId)")
                return
            }

            PrintUtility.printLog(tag: TagUtility.sharedInstance.googleAnalyticsTag, text: buildAppIdStatusText(from: appId))
            PrintUtility.printLog(tag: TagUtility.sharedInstance.googleAnalyticsTag, text: "Firebase ProjectId: \(projectId)")
        } catch {
            PrintUtility.printLog(tag: TagUtility.sharedInstance.googleAnalyticsTag, text: "Error: \(error)")
        }
    }

    private func buildAppIdStatusText(from appId: FirebaseAppId) -> String {
        return "Firebase AppId: " + appId.rawValue + ", ENV: " + "\(appId.environment)"
    }
}

enum FirebaseAppId: String {
    case dev = "1:958429054171:ios:29d71a1365d6e8777cf8fe"
    case prod = "1:180111879719:ios:aeef784ae461a427e2a802"

    var environment: String {
        switch self {
        case .dev:
            return "Dev"
        case .prod:
            return "Prod"
        }
    }
}

struct GoogleServiceInfo: Decodable {
    let appId: String
    let projectId: String

    private enum CodingKeys: String, CodingKey {
        case appId = "GOOGLE_APP_ID"
        case projectId = "PROJECT_ID"
    }
}

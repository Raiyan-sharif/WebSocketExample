//
//  TokenApiState.swift
//  PockeTalk
//

import Foundation

@objc enum ApiState: Int {
    case notStarted
    case running
    case success
    case failed
}

@objc class TokenApiStateObserver: NSObject {
    public static let shared = TokenApiStateObserver()
    private override init() {
        super.init()
    }

    @objc dynamic var apiState : ApiState = .notStarted

    @objc func updateState(state: ApiState) {
        self.apiState = state
    }
}

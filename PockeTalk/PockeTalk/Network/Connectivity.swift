//
//  Connectivity.swift
//  PockeTalk
//
//  Created by Sadikul on 26/10/21.
//

import Foundation
import Network

enum ConnectionState: String {
    case notConnected = "Internet connection not avalable"
    case connected = "Internet connection avalable"
    case slowConnection = "Internet connection poor"
}

protocol ConnectivityDelegate: class {
    func checkInternetConnection(_ state: ConnectionState, isLowDataMode: Bool)
}

class Connectivity: NSObject {

    private let monitor = NWPathMonitor()
    weak var delegate: ConnectivityDelegate? = nil
    private let queue = DispatchQueue.global(qos: .background)
    private var isLowDataMode = false
    static let shareInstance = Connectivity()

    private override init() {
        super.init()
        monitor.start(queue: queue)
    }

     func startMonitorNetwork() {
        monitor.pathUpdateHandler = { path in
            if #available(iOS 13.0, *) {
                self.isLowDataMode = path.isConstrained
            } else {
                // Fallback on earlier versions
                self.isLowDataMode = false
            }

            if path.status == .requiresConnection {
                self.delegate?.checkInternetConnection(.slowConnection, isLowDataMode: self.isLowDataMode)
            } else if path.status == .satisfied {
                self.delegate?.checkInternetConnection(.connected, isLowDataMode: self.isLowDataMode)
            } else if path.status == .unsatisfied {
                self.delegate?.checkInternetConnection(.notConnected, isLowDataMode: self.isLowDataMode)
            }
        }

    }

    func stopMonitorNetwork() {
        monitor.cancel()
    }
}

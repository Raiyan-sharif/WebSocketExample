
import Foundation
import UIKit
import Starscream
import AVFoundation

protocol SocketManagerDelegate:class{
    func getText(text : String)
    func getData(data : Data)
}

 class SocketManager: NSObject {
    private let TAG:String = "SocketManager"
   //static let sharedInstance = SocketManager()
   var socket: WebSocket!
   var isConnected = false
   weak var socketManagerDelegate : SocketManagerDelegate?
   //public override init()
   override init() {
    super.init()
    //var request = URLRequest(url:URL(string: SOCKET_CONNECTION_URL)!)
    PrintUtility.printLog(tag: TAG, text: UserDefaultsUtility.getStringValue(forKey: authentication_key))
    var request = URLRequest(url: URL(string: AUDIO_STREAM_URL)!)
    request.timeoutInterval = 5 // Sets the timeout for the connection
    request.setValue(UserDefaultsUtility.getStringValue(forKey: authentication_key), forHTTPHeaderField: access_token_key)
    //request.setValue("false", forHTTPHeaderField: "X-Push-Mode")
    //request.setValue("false", forHTTPHeaderField: "X-Auto-Detect")
    //request.setValue("permessage-deflate", forHTTPHeaderField: "Sec-WebSocket-Extensions")
    request.addValue(AUDIO_STREAM_URL_ORIGIN, forHTTPHeaderField: origin)
    socket = WebSocket(request: request)
    socket.delegate = self
    socket.connect()
    }
    func sendVoiceData(data: Data) {
        PrintUtility.printLog(tag: TAG, text: "send data(\(data)")
        socket.write(data: data)
   }
    func sendTextData(text:String){
        socket.write(string: text)
    }
    func updateRequestKey(auth_key : String){
        PrintUtility.printLog(tag: TAG, text: auth_key)
        //socket.request.setValue(auth_key, forHTTPHeaderField: "X-Access-Key")
    }
}

extension SocketManager : WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            PrintUtility.printLog(tag: TAG, text: "websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            PrintUtility.printLog(tag: TAG, text: "websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            PrintUtility.printLog(tag: TAG, text: socket.request.value(forHTTPHeaderField: "X-Access-Key") ?? "Nothing")
            socketManagerDelegate?.getText(text: string)
            PrintUtility.printLog(tag: TAG, text: "Received text: \(string)")
        case .binary(var data):
            socketManagerDelegate?.getData(data: data)
            //let str = String(decoding: data, as: UTF8.self)
            PrintUtility.printLog(tag: TAG, text: "Received data: \(data)")
            //var mutData = NSMutableData(data: data)
            //service?.setData(mutData)
            //service?.play()
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            PrintUtility.printLog(tag: TAG, text: "websocket encountered an error: \(e.message)")
        } else if let e = error {
            PrintUtility.printLog(tag: TAG, text: "websocket encountered an error: \(e.localizedDescription)")
        } else {
            PrintUtility.printLog(tag: TAG, text: "websocket encountered an error")
        }
    }
}


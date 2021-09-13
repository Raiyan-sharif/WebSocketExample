
import Foundation
import UIKit
import Starscream
import AVFoundation

protocol SocketManagerDelegate{
    func getText(text : String)
    func getData(data : Data)
}

 class SocketManager: NSObject {
   static let sharedInstance = SocketManager()
   var socket: WebSocket!
   var isConnected = false
   var socketManagerDelegate : SocketManagerDelegate!
   private override init() {
    super.init()
    var request = URLRequest(url:URL(string: SOCKET_CONNECTION_URL)!)
    request.timeoutInterval = 5
    socket = WebSocket(request: request)
    socket.delegate = self
    socket.connect()
    }
    func sendVoiceData(data: Data) {
        socket.write(data: data)
   }
    func sendTextData(text:String){
        socket.write(string: text)
    }
}

extension SocketManager : WebSocketDelegate {
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            socketManagerDelegate.getText(text: string)
            //print("Received text: \(string)")
        case .binary(var data):
            socketManagerDelegate.getData(data: data)
            //let str = String(decoding: data, as: UTF8.self)
            //print("Received data: \(data)")
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
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }
}


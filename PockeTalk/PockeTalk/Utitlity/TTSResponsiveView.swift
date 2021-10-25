//
//  TTSResponsiveView.swift
//  PockeTalk
//
//  Created by Jishnu on 5/10/21.
//

import WebKit
import UIKit

protocol TTSResponsiveViewDelegate : AnyObject {
    func speakingStatusChanged(isSpeaking: Bool)
    func onVoiceEnd()
    func onReady()
}

class TTSResponsiveView : UIView {
    var wkView:WKWebView!
    var ttsResponsiveViewDelegate : TTSResponsiveViewDelegate?
    private let TAG:String = "TTSResponsiveView"
    public let engineName = "Responsive"

    init(){
        super.init(frame: .zero)
        let contentController = WKUserContentController()
        contentController.add(
            self as WKScriptMessageHandler,
            name: iosListener
        )
        contentController.add(
            self as WKScriptMessageHandler,
            name: speakingListener
        )
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        wkView = WKWebView(frame: .zero, configuration: config)
        self.addSubview(wkView)

        wkView.translatesAutoresizingMaskIntoConstraints = false

        wkView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        wkView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        wkView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        wkView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        wkView.isHidden = true


        wkView.navigationDelegate = self

        let htmlPath = Bundle.main.url(forResource: "resv_1.8.1", withExtension: "html")!
        let request = URLRequest(url: htmlPath)
        wkView.load(request)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
        
    func TTSPlay(voice:String, text:String ) {
        
        wkView.evaluateJavaScript("play(\"\(voice)\", \"\(text)\")")  { (result, error) in
            guard error == nil else {
                return
            }
            // PrintUtility.printLog(tag: self.TAG, text: result as Any as! String)
        }
    }
    
    func setRate(rate:String) {
        PrintUtility.printLog(tag: "Pitch rate", text: rate)
        wkView.evaluateJavaScript("setPitchRate('\(rate)')")  { (result, error) in
            guard error == nil else {
                return
            }
            // PrintUtility.printLog(tag: self.TAG, text: result as Any as! String)
        }
    }
    
    func stopEngineProcess() {
        self.ttsResponsiveViewDelegate?.speakingStatusChanged(isSpeaking: false)
        wkView.evaluateJavaScript("cancel()")  { (result, error) in
            guard error == nil else {
                return
            }
            // PrintUtility.printLog(tag: self.TAG, text: result as Any as! String)
        }
    }
    
    func stopTTS(){
        stopEngineProcess()
    }
    
    func checkSpeakingStatus() {
        wkView.evaluateJavaScript("isSpeaking()")  { (result, error) in
            guard error == nil else {
                return
            }
        }
    }
    
    
    
}

extension TTSResponsiveView: WKScriptMessageHandler, WKNavigationDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        switch message.name {
            case iosListener:
                    
            PrintUtility.printLog(tag: TAG, text: "iosListener: \(message.body)")
            if message.body as! String == "Start"{
                self.ttsResponsiveViewDelegate?.speakingStatusChanged(isSpeaking: true)
            }
            if message.body as! String == "end"{
                stopEngineProcess()
                self.ttsResponsiveViewDelegate?.onVoiceEnd()
            }
            
            case speakingListener:
            PrintUtility.printLog(tag: TAG, text: "iosListener speaking: \(message.body)")
            if(message.body as! Bool == true){
                self.ttsResponsiveViewDelegate?.speakingStatusChanged(isSpeaking: false)
                PrintUtility.printLog(tag: TAG, text: "iosListener speaking: \("playing")")
            }else{
                self.ttsResponsiveViewDelegate?.speakingStatusChanged(isSpeaking: true)
                PrintUtility.printLog(tag: TAG, text: "iosListener speaking: \("not playing")")
            }
            default:
                break;
            }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.ttsResponsiveViewDelegate?.onReady()
    }
}

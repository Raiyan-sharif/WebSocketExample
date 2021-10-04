//
//  TTSResponsiveView.swift
//  PockeTalk
//
//  Created by Jishnu on 5/10/21.
//

import WebKit
import UIKit

protocol TTSResponsiveViewDelegate : class {
    func userContentController(message : WKScriptMessage)
    func webView()
}

class TTSResponsiveView : UIView {
    var wkView:WKWebView!
    var ttsResponsiveViewDelegate : TTSResponsiveViewDelegate?
    init(){
        super.init(frame: .zero)
        let contentController = WKUserContentController()
             contentController.add(
                 self as WKScriptMessageHandler,
                 name: "iosListener"
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
    
}

extension TTSResponsiveView: WKScriptMessageHandler, WKNavigationDelegate {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.ttsResponsiveViewDelegate?.userContentController(message: message)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.ttsResponsiveViewDelegate?.webView()
    }
}

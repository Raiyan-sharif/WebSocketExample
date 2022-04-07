//
//  TTTGoogle.swift
//  PockeTalk
//

import Foundation


struct AsciiChar {
    var asciiData = [["ascii": "&#32;", "val" : " "], ["ascii": "&#33;", "val" : "!"],["ascii": "&#34;", "val" : "\""], ["ascii": "&#35;", "val" : "#"],["ascii": "&#36;", "val" : "$"], ["ascii": "&#37;", "val" : "%"],["ascii": "&#38;", "val" : "&"], ["ascii": "&#39;", "val" : "'"],["ascii": "&#40;", "val" : "("], ["ascii": "&#41;", "val" : ")"],["ascii": "&#42;", "val" : "*"], ["ascii": "&#43;", "val" : "+"],["ascii": "&#44;", "val" : ","], ["ascii": "&#45;", "val" : "-"],["ascii": "&#46;", "val" : "."], ["ascii": "&#47;", "val" : "/"],["ascii": "&#58;", "val" : ":"], ["ascii": "&#59;", "val" : ";"],["ascii": "&#60;", "val" : "<"], ["ascii": "&#61;", "val" : "="],["ascii": "&#62;", "val" : ">"], ["ascii": "&#63;", "val" : "?"],["ascii": "&#64;", "val" : "@"], ["ascii": "&#91;", "val" : "["],["ascii": "&#92;", "val" : "\\"], ["ascii": "&#93;", "val" : "]"],["ascii": "&#94;", "val" : "^"], ["ascii": "&#95;", "val" : "_"],["ascii": "&#96;", "val" : "`"], ["ascii": "&#123;", "val" : "{"],["ascii": "&#124;", "val" : "|"], ["ascii": "&#125;", "val" : "}"],["ascii": "&#126;", "val" : "~"], ["ascii": "&#127;", "val" : "DEL"],["ascii": "&gt;", "val" : ">"],["ascii": "&quot;", "val" : " \""],["ascii": "&amp;", "val" : "&"]]
}

extension ITTServerViewModel: SocketManagerDelegate {
    
    func translate(source: String,target: String,text: String) {
        
        //let url = TTTGoogle.getURL(source: source, target: target, text: text)
        var translatedText: String = ""
        
        let textFrameData = GlobalMethod.getRetranslationAndReverseTranslationData(sttdata: text,srcLang: source, destlang: target)
        
        socketManager?.sendTextData(text: textFrameData, completion: nil)
    }
    
    func getText(text: String) {
        speechProcessingVM.setTextFromScoket(value: text)
        PrintUtility.printLog(tag: "TTTGoogle() >> Socket response() >> ", text: "translatedText: \(text)")
        PrintUtility.printLog(tag: "block count", text: "\(tttCount)")
        timer?.invalidate()
        timer = nil
        timeInterval = 30
        
        startCountdown()
    }
    
    func getData(data: Data) {
        //
    }
    
    func faildSocketConnection(value: String) {
        //
    }
    
    func bindData(){
        speechProcessingVM.isFinal.bindAndFire{[weak self] isFinal  in
            guard let `self` = self else { return }
            if isFinal{
                //PrintUtility.printLog(tag: "TTT text: ",text: self.speechProcessingVM.getTTT_Text)
                //PrintUtility.printLog(tag: "TTT src: ", text: self.speechProcessingVM.getSrcLang_Text)
                //PrintUtility.printLog(tag: "TTT dest: ", text: self.speechProcessingVM.getDestLang_Text)
                
                let modeSwitchTypes = UserDefaults.standard.string(forKey: modeSwitchType)
                if modeSwitchTypes == blockMode {
                    let data = AsciiChar()
                    var text = self.speechProcessingVM.getTTT_Text
                    for each in data.asciiData {
                        if text.contains(each["ascii"]!) {
                            text = text.replacingOccurrences(of: each["ascii"]!, with: each["val"]!)
                        }
                    }
                    self.blockTranslatedText.append(text)
                    PrintUtility.printLog(tag: "Block mode socket response :", text: "\(self.speechProcessingVM.getTTT_Text)")
                } else {
                    let data = AsciiChar()
                    var text = self.speechProcessingVM.getTTT_Text
                    for each in data.asciiData {
                        if text.contains(each["ascii"]!) {
                            text = text.replacingOccurrences(of: each["ascii"]!, with: each["val"]!)
                        }
                    }
                    self.lineTranslatedText.append(text)
                    PrintUtility.printLog(tag: "Line mode socket response :", text: "\(self.speechProcessingVM.getTTT_Text)")
                }
                self.tttCount = self.tttCount + 1
                if self.tttCount == self.totalBlockCount {
                    self.commandToGenerateTextView()
                } else {
                    UserDefaults.standard.set(false, forKey: isTransLationSuccessful)
                }
            }
        }
    }
    // Start this counter to track while internet connection lost
    func startCountdown() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.timeInterval -= 1
            if self?.timeInterval == 0 {
                timer.invalidate()
                self?.timer = nil
                self?.loaderdelegate?.hideLoader()
                self?.delegate?.showNetworkError()
            } else if let seconds = self?.timeInterval {
                if self?.tttCount == self?.totalBlockCount {
                    self?.timer?.invalidate()
                    self?.timer = nil
                }
            }
        }
    }
}

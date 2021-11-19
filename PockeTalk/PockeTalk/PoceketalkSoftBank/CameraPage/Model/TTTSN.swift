//
//  TTTGoogle.swift
//  PockeTalk
//

import Foundation

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
                    self.blockTranslatedText.append(self.speechProcessingVM.getTTT_Text)
                } else {
                    self.lineTranslatedText.append(self.speechProcessingVM.getTTT_Text)
                }
                self.tttCount = self.tttCount + 1
                if self.tttCount == self.totalBlockCount {
                    self.commandToGenerateTextView()
                }

            }
        }
    }

}

import UIKit
import SwiftyXMLParser

public class TTSEngine{
    public static let shared: TTSEngine = TTSEngine()
    let TAG = "\(LanguageSelectionManager.self)"
    var languageEngineList = [LangueEngineModel]()
    let fileName = "language_engine"
    let fileType = "xml"
    let parentElement = "engine"
    let childElement = "item"
    let code = "code"
    let sttEngine = "stt_engine"
    let ttsValue = "tts_value"
    let errorTitle = "Error :"
    let errorDescription = "Parse Error"
    
    private init() {
        self.getData()
    }
    
    ///Get data from XML
func getData () {
    if let path = Bundle.main.path(forResource: fileName, ofType: fileType) {
        do {
            let contents = try String(contentsOfFile: path)
            let xml =  try XML.parse(contents)

            // enumerate child Elements in the parent Element
            for item in xml[parentElement,childElement] {
                let attributes = item.attributes
                languageEngineList.append(LangueEngineModel(code: attributes[code], sttEngine: attributes[sttEngine],ttsValue: attributes[ttsValue]))
            }
        } catch {
            PrintUtility.printLog(tag: errorTitle, text: errorDescription)
        }
    }
}
    public func getTtsValue(langCode: String) -> (voice: String, rate: String) {
        var voice : String = ""
        var rate : String = "1.0"
        
        if let value = TTSEngine.shared.getTtsValueByCode(code: langCode) {
            voice = value
        }

        /// Multiple tts_value will be seperated by # in future.
        if !voice.isEmpty && voice.contains(KMultipleTtsValueSeparator){
            voice = voice.components(separatedBy: KMultipleTtsValueSeparator)[0]
            if voice.contains(KVoiceAndTempoSeparator){
                let ttsValue = voice
                voice = ttsValue.components(separatedBy: KVoiceAndTempoSeparator)[0]
                rate = ttsValue.components(separatedBy: KVoiceAndTempoSeparator)[1]
            }
        } else {
            /// For now if any tts value contains "_", after splitting, the first portion will be counted as voice and the other portioin will be counted as rate
            if !voice.isEmpty && voice.contains(KVoiceAndTempoSeparator){
                let ttsValue = voice
                voice = ttsValue.components(separatedBy: KVoiceAndTempoSeparator)[0]
                rate = ttsValue.components(separatedBy: KVoiceAndTempoSeparator)[1]
            }
        }
        return ( voice, rate)
    }
    
    // This method is called to retrive tts value from respective language code
    public func  getTtsValueByCode(code: String) -> String? {
        for item in languageEngineList{
            if(code == item.code){
                return item.ttsValue
            }
        }
        return nil
    }
}

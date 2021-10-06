//
// TtsAlertViewModel.swift
// PockeTalk
//

import UIKit
import SwiftyXMLParser

class TtsAlertViewModel: BaseModel {
    var savedDataID : Int64?
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

        override init() {
            super.init()
            self.getData()
        }
    /// this method takes the id of last saved chat and returns respective ChatEntity
    func findLastSavedChat (id : Int64) -> ChatEntity?{
        do {
            let baseEntity = try ChatDBModel.init().find(idToFind: id)
            return baseEntity as? ChatEntity
        } catch _ { return nil}
    }
    
    func saveChatItem(chatItem: ChatEntity){
        do {
            _ = try ChatDBModel.init().insert(item: chatItem)
        } catch _ {}
    }
    
    func deleteChatItemFromHistory(chatItem: ChatEntity){
        if(chatItem.id == nil){
            chatItem.id = UserDefaultsProperty<Int64>(kLastSavedChatID).value
        }
        do{
            try ChatDBModel().updateDeleteValue(isDelete: IsDeleted.delete, idToCompare: chatItem.id!)
        } catch {}
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

    /// This method is called to retrive tts value from respective language code
    func  getTtsValueByCode(code: String) -> String? {
        for item in languageEngineList{
            if(code == item.code){
                return item.ttsValue
            }
        }
        return nil
    }
}

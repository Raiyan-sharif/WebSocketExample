//
// SpeechProcessingViewModel.swift
// PockeTalk
//

import UIKit
import SwiftyXMLParser

protocol SpeechProcessingViewModeling {
    var getSST_Text:Bindable<String>{ get }
    var getTTT_Text:String{ get }
    var isFinal:Bindable<Bool> { get }
    func getTextFrame() -> String
    func getSpeechLanguageInfoByCode(langCode: String) -> SpeechProcessingLanguages?
    func setTextFromScoket(value:String)
    var isUpdatedAPI:Bindable<Bool>{ get}
    func updateLanguage()
}

class SpeechProcessingViewModel: SpeechProcessingViewModeling {

    var isUpdatedAPI: Bindable<Bool> = Bindable(false)

    var getSST_Text: Bindable<String> = Bindable("")

    var isFinal: Bindable<Bool> = Bindable(false)

    var getTTT_Text: String = ""

    var isSSTavailable: Bool = false

    var speechProcessingLanList = [SpeechProcessingLanguages]()

    init() {
        self.getData()
    }
    ///Get data from XML
    func getData () {
        if let path = Bundle.main.path(forResource: "hello_mapping_new", ofType: "xml") {
            do {
                let contents = try String(contentsOfFile: path)
                let xml =  try XML.parse(contents)

                // enumerate child Elements in the parent Element
                for item in xml["mapping","item"] {
                    let attributes = item.attributes
                    speechProcessingLanList.append(SpeechProcessingLanguages(code: attributes["code"]!, initText: attributes["init_text"]!, exampleText : attributes["ex_text"]!, secText : attributes["sec_text"]!) )
                }
            } catch {
                PrintUtility.printLog(tag: "LanguageChage: ", text: "Parse Error")
            }
        }
    }

    func  getSpeechLanguageInfoByCode(langCode: String) -> SpeechProcessingLanguages? {
        for item in speechProcessingLanList{
            if(langCode == item.code){
                return item
            }
        }
        return nil
    }

    func getTextFrame()-> String {
        let jsonData = try! JSONEncoder().encode(["final": true])
        return String(data: jsonData, encoding: .utf8)!
    }

    func setTextFromScoket(value:String){
        if let data = value.data(using: .utf8) {
            do{
                let socketData = try JSONDecoder().decode(SocketDataModel.self, from: data)
                if let sstText = socketData.stt
                {
                   // isSSTavailable = true
                    getSST_Text.value = sstText
                }
                if let tttText = socketData.ttt
                {
                    getTTT_Text =  tttText
                }
                if let is_Final = socketData.isFinal{
                    isFinal.value = is_Final
                }

            }catch (let err) {
                print(err.localizedDescription)
            }
        }
    }

    func updateLanguage() {
        NetworkManager.shareInstance.changeLanguageSettingApi{ [weak self ]data in
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(ResultModel.self, from: data)
                    self?.isUpdatedAPI.value = result.resultCode == "OK"
                }catch{
                    self?.isUpdatedAPI.value = false
                }
            }
        }
    }
}

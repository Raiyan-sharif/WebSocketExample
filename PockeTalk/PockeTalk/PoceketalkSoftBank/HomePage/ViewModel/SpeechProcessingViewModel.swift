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
    var getSrcLang_Text:String{ get }
    var getDestLang_Text:String{ get }
    func getTextFrame() -> String
    func getSpeechLanguageInfoByCode(langCode: String) -> SpeechProcessingLanguages?
    func setTextFromScoket(value:String)
    var isUpdatedAPI:Bindable<Bool>{ get}
    var isGettingActualData:Bool {set get}
    func updateLanguage()
    func animateLeftImage (leftImage : UIImageView, yPos : CGFloat, xPos : CGFloat)
    func animateRightImage (leftImage: UIImageView, rightImage : UIImageView, yPos : CGFloat, xPos : CGFloat)
    var startTime:Date? { set get }
    func getTimeDifference(endTime:Date)->Int

}

class SpeechProcessingViewModel: SpeechProcessingViewModeling {
    var startTime: Date? = nil

    var isGettingActualData:Bool = false

    var isUpdatedAPI: Bindable<Bool> = Bindable(false)

    var getSST_Text: Bindable<String> = Bindable("")

    var isFinal: Bindable<Bool> = Bindable(false)

    var getTTT_Text: String = ""

    var getSrcLang_Text:String = ""
    
    var getDestLang_Text:String = ""
    
    var isSSTavailable: Bool = false

    var speechProcessingLanList = [SpeechProcessingLanguages]()

    let animationDuration = 0.6

    let animationDelay = 0
    
    static var isLoading = false

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
                
                if let srcLang = socketData.srclang
                {
                    getSrcLang_Text = srcLang
                }
                
                if let destLang = socketData.destlang
                {
                    getDestLang_Text = destLang
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
                    PrintUtility.printLog(tag: "SpeechViewController", text: "result.resultCode \(result.resultCode)")
                }catch{
                    self?.isUpdatedAPI.value = false
                }
            }
        }
    }

    func animateLeftImage (leftImage : UIImageView, yPos : CGFloat, xPos : CGFloat) {
        /// Set frame for expanded postion. 'x' will be left shifted, 'y' will be in a bit higher positiion, 'width' will be adjusted with the changed x position, 'height' will be increased according to the changed 'y' posiition.
        let expandedFrame = CGRect(x: leftImage.frame.origin.x - xPos, y: leftImage.frame.origin.y - yPos, width: leftImage.frame.size.width + xPos, height: leftImage.frame.size.height + yPos)

        /// Set frame for shrinked postion. 'x' will be right shifted, 'y' will be in a lower positiion, 'width' will be adjusted with the changed x position, 'height' will be deccreased according to the changed 'y' posiition.
        let shrinkedFrame = CGRect(x: leftImage.frame.origin.x + xPos , y: leftImage.frame.origin.y + yPos  , width: leftImage.frame.size.width - xPos  , height: leftImage.frame.size.height - yPos )

        UIView.animate(withDuration: TimeInterval(animationDuration), delay: TimeInterval(animationDelay), options: [.repeat, .autoreverse], animations: {
            leftImage.frame = expandedFrame
        })
        UIView.animate(withDuration: TimeInterval(animationDuration), delay: TimeInterval(animationDelay), options: [.repeat, .autoreverse], animations: {
            leftImage.frame = shrinkedFrame
        })
    }

    func animateRightImage (leftImage : UIImageView, rightImage : UIImageView, yPos : CGFloat, xPos : CGFloat) {
        /// Set frame for expanded postion. 'x' will be right shifted, 'y' will be in a bit higher positiion, 'width' will be adjusted with the changed x position, 'height' will be increased according to the changed 'y' posiition.
        let expandedFrame = CGRect(x: leftImage.frame.origin.x - xPos, y: leftImage.frame.origin.y - yPos, width: leftImage.frame.size.width + xPos, height: leftImage.frame.size.height + yPos)
        let expandedFrame2 = CGRect(x: rightImage.frame.origin.x, y: rightImage.frame.origin.y - yPos, width: rightImage.frame.size.width + xPos, height: rightImage.frame.size.height + yPos)
        let rotateForwardAnimationDuration: TimeInterval = 0.35
        let rotateBackAnimationDuration: TimeInterval = 0.35
            let animationDuration: TimeInterval = rotateForwardAnimationDuration + rotateBackAnimationDuration
        UIView.animateKeyframes(withDuration: animationDuration, delay: 0, options: [], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: rotateForwardAnimationDuration) {
                    leftImage.frame = expandedFrame
                }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: rotateForwardAnimationDuration) {
    
                rightImage.frame = expandedFrame2
                }

                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: rotateBackAnimationDuration) {
                    leftImage.transform = .identity
                    rightImage.transform = .identity
                    
                }
            }) { (isFinished) in
                if(!SpeechProcessingViewModel.isLoading){
                    self.animateRightImage(leftImage: leftImage, rightImage: rightImage, yPos: yPos, xPos: xPos)
                }
            }
    }

    func getTimeDifference(endTime:Date)->Int{
        if let startTime = self.startTime{
                let diff = endTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
                    self.startTime = nil
                 return Int(diff)
                }
                return 0
    }
}

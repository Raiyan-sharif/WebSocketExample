//
//  CameraHistoryViewModel.swift
//  PockeTalk
//
//  Created by BJIT LTD on 15/9/21.
//

import Foundation
import UIKit


protocol CameraHistoryViewModelDelegates {
    func updateViewWithImages()
}

class CameraHistoryViewModel: BaseModel {
    
    var cameraHistoryImages =  [CameraHistoryDataModel]() {
        didSet {
            self.delegate?.updateViewWithImages()
        }
    }
    
    var detectedData: DetectedJSON! {
        didSet {
            PrintUtility.printLog(tag: "detected data from sqlite : ", text: "\(String(describing: detectedData))")
        }
    }
    var translatedData: TranslatedTextJSONModel! {
        didSet {
            PrintUtility.printLog(tag: "translated data from sqlite : ", text: "\(String(describing: translatedData))")
        }
    }
    
    
    
    private(set) var delegate: CameraHistoryViewModelDelegates?
    
    func viewDidLoad<T>(_ vc: T) {
        self.delegate = vc.self as? CameraHistoryViewModelDelegates
    }
    
    
    func fetchCameraHistoryImages() {
        
        cameraHistoryImages.removeAll()
        if let cameraHistoryData = try? CameraHistoryDBModel().getAllCameraHistoryTables {
            
            for index in stride(from: cameraHistoryData.count-1, to: -1, by: -1) {
                if let imageData = cameraHistoryData[index].image {
                    let image = UIImage.convertBase64ToImage(imageString: imageData)
                    cameraHistoryImages.append(CameraHistoryDataModel.init(image: image, dbID: cameraHistoryData[index].id))
                }
                
            }
        }
    }
    
    func getIDWiseTranslatedAndDetectedData(id: Int64)  -> String{
        
        var sharedText = ""
        var sharedTranslatedtext = ""
        var sharedDetectedText = ""
        let translatedData: TranslatedTextJSONModel? = CameraHistoryDBModel().getTranslatedData(id: id)
        let detectedData: DetectedJSON? = CameraHistoryDBModel().getDetectedData(id: id)
        
        if let detectedData = detectedData, let translatedData = translatedData {
            
            let data = translatedData
            let lineData = data.line
            let blockData = data.block
            if lineData!.translatedText.count > 0 {
                
                let detectedData = detectedData.line?.blocks
                for each in lineData!.translatedText{
                    sharedTranslatedtext = sharedTranslatedtext + each + "\n"
                }
                for each in detectedData!{
                    sharedDetectedText = sharedDetectedText + each.text + "\n"
                }
                
                sharedText = "Translated language: \(getLanguageTitle(lanCode: lineData!.languageCodeTo))\n" + "\(sharedTranslatedtext) \n" +
                "Original language: \(getLanguageTitle(lanCode: detectedData![0].detectedLanguage))\n" + "\(sharedDetectedText)"
                
            } else if (blockData!.translatedText.count>0){
                let translatedData = data.block
                let detectedData = detectedData.block?.blocks
                for each in translatedData!.translatedText{
                    sharedTranslatedtext = sharedTranslatedtext + each + "\n\n"
                }
                
                for each in detectedData! {
                    sharedDetectedText = sharedDetectedText + each.text + "\n"
                }
                
                sharedText = "Translated language: \(getLanguageTitle(lanCode: translatedData!.languageCodeTo))\n" + "\(sharedTranslatedtext) \n\n" +
                "Original language: \(getLanguageTitle(lanCode: detectedData![0].detectedLanguage))\n" + "\(sharedDetectedText)"
            }
        }
        
        return sharedText
    }
    
    func getLanguageTitle(lanCode: String)  -> String {
        let lan = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: lanCode)
        
        return lan!.sysLangName
    }

}






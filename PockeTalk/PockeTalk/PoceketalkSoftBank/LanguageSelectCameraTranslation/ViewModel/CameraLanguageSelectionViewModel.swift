//
//  LanguageSelectionViewModel.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 10/9/21.
//

import UIKit
import SwiftyXMLParser

class CameraLanguageSelectionViewModel:BaseModel{
    public static let shared: CameraLanguageSelectionViewModel = CameraLanguageSelectionViewModel()
    let TAG = CameraLanguageSelectionViewModel.self
    private var detectedLanguageItemsCamera = [LanguageItem]()
    public var targetLanguageItemsCamera: [LanguageItem] {
        get{
            return LanguageSelectionManager.shared.languageItems
        }
    }
    private var mDefaultLanguageFile = "default_languages"
    private var mCameraLanguageCodes = [String]()
    private var autoRecognitionNames = ["en": "Automatic Recognition", "ja": "自動認識"]

    struct DetectionCodes: Codable {
        let detectionCodes: [String]

        enum CodingKeys: String, CodingKey {
            case detectionCodes = "detection_codes"
        }
    }

    public var fromLanguage: String {
      get {
        guard let langCode = UserDefaults.standard.string(forKey: KCameraNativeLanguageCode) else {
          fatalError("Did you set the default language for the app?")
        }
        return langCode
      }
      set {
        UserDefaults.standard.set(newValue, forKey: KCameraNativeLanguageCode)
      }
    }

    public var targetLanguage: String {
      get {
        guard let langCode = UserDefaults.standard.string(forKey: KCameraTargetLanguageCode) else {
          fatalError("Did you set the default language for the app?")
        }
        return langCode
      }
      set {
        UserDefaults.standard.set(newValue, forKey: KCameraTargetLanguageCode)
      }
    }


    func  getLanguageInfoByCode(langCode: String, languageList: [LanguageItem]) -> LanguageItem? {
        for item in languageList{
            print("\(CameraLanguageSelectionViewModel.self) langcode \(langCode) item.code \(item.code)")
            if(langCode == item.code){
                return item
            }
        }
        return nil
    }

//    public var isArrowUp: Bool? {
//      get {
//        return UserDefaults.standard.bool(forKey: kIsArrowUp)
//      }
//      set {
//        UserDefaults.standard.set(newValue, forKey: kIsArrowUp)
//      }
//    }

    func  getLanguageInfoByCode(langCode: String,list: [LanguageItem]) -> LanguageItem? {
        for item in list{
            if(langCode == item.code){
                return item
            }
        }
        return nil
    }

    override init() {
        super.init()
        mCameraLanguageCodes = loadCameraLanguageList()!
        //getLanguageSelectionCameraData()
    }

    public func getFromLanguageLanguageList() -> [LanguageItem]{
        print("\(TAG) item-code getLanguageSelectionCameraData")
        let autoRecogItem: LanguageItem?
        detectedLanguageItemsCamera.removeAll()
        if(LanguageManager.shared.currentLanguage.rawValue == systemLanguageCodeEN){
            autoRecogItem = LanguageItem(name: autoRecognitionNames["en"]!, code: mCameraLanguageCodes[0], englishName: autoRecognitionNames["en"]!, sysLangName: autoRecognitionNames["en"]!)
            detectedLanguageItemsCamera.append(autoRecogItem!)
        }else if(LanguageManager.shared.currentLanguage.rawValue == systemLanguageCodeJP){
            autoRecogItem = LanguageItem(name: autoRecognitionNames["en"]!, code: mCameraLanguageCodes[0], englishName: autoRecognitionNames["en"]!, sysLangName: autoRecognitionNames["ja"]!)
            detectedLanguageItemsCamera.append(autoRecogItem!)
        }
        for item in LanguageSelectionManager.shared.languageItems{
            print("\(TAG) item-code \(item.code) camra-contains \(mCameraLanguageCodes.contains(item.code))")
            if mCameraLanguageCodes.contains(item.code){
                detectedLanguageItemsCamera.append(item)
            }
        }
        return detectedLanguageItemsCamera
    }

    func loadCameraLanguageList() -> [String]?{
        print("\(TAG) loadCameraLanguageList called")
        //let sysLangCode = LanguageManager.shared.currentLanguage.rawValue
        print("\(TAG) getdata for \(cameraLanguageDetectionCodeJsonFile)")
        if let url = Bundle.main.url(forResource: cameraLanguageDetectionCodeJsonFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(DetectionCodes.self, from: data) as DetectionCodes
                print("\(TAG) cameraDetectionCoded \(jsonData.detectionCodes.count) first-item \(String(describing: jsonData.detectionCodes.first))")
                return jsonData.detectionCodes
            } catch {
                print("error:\(error)")
                return nil
            }
        }
        return nil
    }

    func setDefaultLanguage(){
        getFromLanguageLanguageList()
        CameraLanguageSelectionViewModel.shared.fromLanguage = detectedLanguageItemsCamera[0].code
        CameraLanguageSelectionViewModel.shared.targetLanguage =  "en"
    }
}


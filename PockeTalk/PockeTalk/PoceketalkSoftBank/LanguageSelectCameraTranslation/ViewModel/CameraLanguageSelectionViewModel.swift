//
//  LanguageSelectionViewModel.swift
//  PockeTalk
//

import UIKit
import SwiftyXMLParser

class CameraLanguageSelectionViewModel:BaseModel{
    public static let shared: CameraLanguageSelectionViewModel = CameraLanguageSelectionViewModel()
    let TAG = "\(CameraLanguageSelectionViewModel.self)"
    private var detectedLanguageItemsCamera = [LanguageItem]()
    public var targetLanguageItemsCamera: [LanguageItem] {
        get{
            return LanguageSelectionManager.shared.languageItems
        }
    }
    private var mDefaultLanguageFile = "default_languages"
    private var mCameraLanguageCodes = [String]()
    private var autoRecognitionNames = [SystemLanguageCode.en.rawValue: "Automatic Recognition",
                                        SystemLanguageCode.ja.rawValue: "自動認識",
                                        SystemLanguageCode.de.rawValue: "Automatische Erkennung",
                                        SystemLanguageCode.es.rawValue: "Reconocimiento automático",
                                        SystemLanguageCode.fr.rawValue: "Reconnaissance automatique",
                                        SystemLanguageCode.it.rawValue: "Riconoscimento automatico",
                                        SystemLanguageCode.ko.rawValue: "자동 인식",
                                        SystemLanguageCode.ms.rawValue: "Pengecaman Automatik",
                                        SystemLanguageCode.ptPT.rawValue: "Reconhecimento Automático",
                                        SystemLanguageCode.ru.rawValue: "Автоматическое распознавание",
                                        SystemLanguageCode.th.rawValue:"ระบบตรวจจับอัตโนมัติ",
                                        SystemLanguageCode.zhHans.rawValue: "自动识别",
                                        SystemLanguageCode.zhHant.rawValue: "自動辨識"
    ]

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
            PrintUtility.printLog(tag: TAG,text: "langcode \(langCode) item.code \(item.code)")
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
        PrintUtility.printLog(tag: TAG,text: " item-code getLanguageSelectionCameraData")
        detectedLanguageItemsCamera.removeAll()
        
        let currentLangCode = LanguageManager.shared.currentLanguage.rawValue
        let englishLangCode = autoRecognitionNames[systemLanguageCodeEN] ?? ""
        let firstCameraLangCode = mCameraLanguageCodes[0]
        let systemLangCode = autoRecognitionNames[currentLangCode] ?? ""
        
        let autoRecogItem = LanguageItem(
            name: englishLangCode,
            code: firstCameraLangCode,
            englishName: englishLangCode,
            sysLangName: systemLangCode
        )
        
        detectedLanguageItemsCamera.append(autoRecogItem)
        
        for item in LanguageSelectionManager.shared.languageItems{
            PrintUtility.printLog(tag: TAG,text: "item-code \(item.code) camra-contains \(mCameraLanguageCodes.contains(item.code))")
            if mCameraLanguageCodes.contains(item.code){
                detectedLanguageItemsCamera.append(item)
            }
        }
        return detectedLanguageItemsCamera
    }

    func loadCameraLanguageList() -> [String]?{
        PrintUtility.printLog(tag: TAG,text: "loadCameraLanguageList called")
        //let sysLangCode = LanguageManager.shared.currentLanguage.rawValue
        PrintUtility.printLog(tag: TAG,text: "getdata for \(cameraLanguageDetectionCodeJsonFile)")
        if let url = Bundle.main.url(forResource: cameraLanguageDetectionCodeJsonFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(DetectionCodes.self, from: data) as DetectionCodes
                PrintUtility.printLog(tag: TAG,text: "cameraDetectionCoded \(jsonData.detectionCodes.count) first-item \(String(describing: jsonData.detectionCodes.first))")
                return jsonData.detectionCodes
            } catch {
                PrintUtility.printLog(tag: TAG,text: "error:\(error)")
                return nil
            }
        }
        return nil
    }

    func insertIntoDb(entity: LanguageSelectionEntity){
        if let rowid = try? LanguageSelectionDBModel().insert(item: entity){
            PrintUtility.printLog(tag: TAG, text: "LanguageListFromDb \(String(describing: rowid)) inserted")
        }
    }

    func getSelectedLanguageListFromDb() -> [LanguageItem]{
        PrintUtility.printLog(tag: TAG,text: "\(LanguageSelectionManager.self) LanguageListFromDb getSelectedLanguageListFromDb")
        var langList = [LanguageItem]()
        guard let langListFromDb = try? LanguageSelectionDBModel().findAll(findFor: LanguageType.camera.rawValue) as? [LanguageSelectionEntity] else {
            return langList
        }
        for item in langListFromDb {
            //let lang = item as! LanguageSelectionTable
            PrintUtility.printLog(tag: TAG,text: "LanguageListFromDb cameraOrVocie \(String(describing: item.cameraOrVoice))")
            let code = item.textLanguageCode
            let langItem: LanguageItem?
            if code == getFromLanguageLanguageList()[0].code{
                langItem = getFromLanguageLanguageList()[0]
            }else{
                langItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: code!)
            }
            PrintUtility.printLog(tag: TAG,text: "LanguageListFromDb code \(String(describing: code)) langItem = \(String(describing: langItem?.name))")
            langList.append(langItem!)

        }
        return langList
    }

    func setDefaultLanguage(){
        let langList = getFromLanguageLanguageList()
        CameraLanguageSelectionViewModel.shared.fromLanguage = langList[0].code
        CameraLanguageSelectionViewModel.shared.targetLanguage =  "en"
        let fromLangItem = getLanguageInfoByCode(langCode: CameraLanguageSelectionViewModel.shared.fromLanguage, languageList: langList)
        let targetLangItem = getLanguageInfoByCode(langCode: CameraLanguageSelectionViewModel.shared.targetLanguage, languageList: langList)

        insertIntoDb(entity: LanguageSelectionEntity(id: 0, textLanguageCode: fromLangItem?.code, cameraOrVoice: LanguageType.camera.rawValue))
        insertIntoDb(entity: LanguageSelectionEntity(id: 0, textLanguageCode: targetLangItem?.code, cameraOrVoice: LanguageType.camera.rawValue))
    }


    func findLanugageCodeAndSelect(_ text: String) {
        PrintUtility.printLog(tag: TAG, text: "delegate SpeechProcessingVCDelegates called text = \(text)")
        let systemLanguage = LanguageManager.shared.currentLanguage.rawValue
        var stringFromSpeech = GlobalMethod.removePunctuation(of: text).trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if systemLanguage == SystemLanguageCode.ru.rawValue{
            stringFromSpeech = stringFromSpeech.capitalizingFirstLetter()
        }
        
        let codeFromLanguageMap = LanguageMapViewModel.sharedInstance.findTextFromDb(languageCode: systemLanguage, text: stringFromSpeech) as? LanguageMapEntity
        PrintUtility.printLog(tag: TAG, text: "delegate SpeechProcessingVCDelegates stringFromSpeech \(stringFromSpeech) codeFromLanguageMap = \(String(describing: codeFromLanguageMap?.textCodeTr))")
        
        if let langCode = codeFromLanguageMap?.textCodeTr{
            let langItem = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: langCode)
            if langItem != nil {
                UserDefaultsProperty<String>(KSelectedLanguageCamera).value = langItem?.code
            }
        }
    }
}


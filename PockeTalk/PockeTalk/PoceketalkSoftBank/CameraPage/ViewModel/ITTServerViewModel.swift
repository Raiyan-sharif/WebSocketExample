//
//  ITTServerViewModel.swift
//  PockeTalk
//

import Foundation
import UIKit

protocol ITTServerViewModelDelegates {
    func updateView()
    func showErrorAlert()
    func showNetworkError()
}

class ITTServerViewModel: BaseModel {
    
    private let TAG = "\(ITTServerViewModel.self)"
    var capturedImage: UIImage?
    var imageWidth = CGFloat()
    var imageHeight = CGFloat()
    var timer: Timer? = nil
    var timeInterval: TimeInterval = 60
    
    var mXFactor:Float = 1
    var mYFactor:Float = 1
    
    private(set) var loaderdelegate: LoaderDelegate?
    private(set) var parseTextDetection = ParseTextDetection()
    private(set) var delegate: ITTServerViewModelDelegates?
    
    func viewDidLoad<T>(_ vc: T) {
        self.loaderdelegate = vc.self as? LoaderDelegate
        self.delegate = vc.self as? ITTServerViewModelDelegates
        
    }
    
    var detectedBlockList = [BlockDetection]()
    var detectedLineList = [BlockDetection]()
    
    var historyID = Int64()
    var fromHistoryVC = Bool()
    
    let dispatchQueue = DispatchQueue(label: "myQueue", qos: .background)
    let semaphore = DispatchSemaphore(value: 0)
    let dispatchGroup = DispatchGroup()
    
    var blockModeTextViewList = [TextViewWithCoordinator]() {
        didSet{
            self.delegate?.updateView()
        }
    }
    
    var lineModetTextViewList = [TextViewWithCoordinator]() {
        didSet{
            self.delegate?.updateView()
        }
    }
    
    var totalBlockCount = 0
    var tttCount = 0
    var detectedJSON: DetectedJSON?
    var blockTranslatedText = [String]()
    var lineTranslatedText = [String]()
    var blockListFromJson = [BlockDetection]()
    var lineListFromJson = [BlockDetection]()
    var mBlockData: BlockData = BlockData(translatedText: [], languageCodeTo: "")
    var mLineData: BlockData = BlockData(translatedText: [], languageCodeTo: "")
    
    var mTranslatedJSON = TranslatedTextJSONModel(block: BlockData(translatedText: [], languageCodeTo: ""), line: BlockData(translatedText: [], languageCodeTo: ""))
    
    var socketManager: SocketManager?
    var speechProcessingVM: SpeechProcessingViewModeling!
    
    func createRequest()-> Resource{
        
        guard let url = URL(string: URL.ITTServerURL) else {
            fatalError("URl was incorrect")
        }
        var resource = Resource(url: url)
        
        resource.httpMethod = HttpMethod.get
        return resource
    }
    
    func getITTData(from image: UIImage, completion: @escaping(_ blockData: DetectedJSON?, _ error: Error?)-> Void) {
        PrintUtility.printLog(tag: "ITTServerViewModel", text: "screen image\(image.size)")
        if Reachability.isConnectedToNetwork() {
            self.loaderdelegate?.showLoader()
            
            let langCode = UserDefaults.standard.value(forKey: KCameraNativeLanguageCode)
            ITTSN().detect(from: image, langCode: langCode as! String) { ocrResult in
                guard let ocrResponse = ocrResult else {
                    self.loaderdelegate?.hideLoader()
                    PrintUtility.printLog(tag: self.TAG, text: "Network error")
                    let error = NSError(domain: "Camera", code: 001, userInfo: [ NSLocalizedDescriptionKey: "error_network"])
                    completion(nil, error as Error)
                    return
                }
                
                //PrintUtility.printLog(tag: "OCR Response: ", text: "\(ocrResponse)")
                self.getScreenProperties(from: image)
                
                let response = ocrResponse.ocr_response.responses[0]
                
                if let fullTextAnnotation = response.full_text_annotation {
                    let lanCode = response.text_annotations![0].locale
                    //PrintUtility.printLog(tag: "mDetectedLanguageCode: ", text: "\(lanCode!)")
                    let blockBlockClass = PointUtils.parseResponseForBlock(dataToParse: response.full_text_annotation, mDetectedLanguageCode: lanCode!, xFactor: self.mXFactor, yFactor: self.mYFactor) { blockresult in

                        PointUtils.parseResponseForLine(dataToParse: response.full_text_annotation, mDetectedLanguageCode: lanCode!, xFactor: self.mXFactor, yFactor: self.mYFactor) { lineResult in
                            
                            self.detectedJSON = DetectedJSON(block: blockresult, line: lineResult)
                            
                            let encoder = JSONEncoder()
                            encoder.outputFormatting = .prettyPrinted
                            let data = try? encoder.encode(self.detectedJSON)
                            //PrintUtility.printLog(tag: "DetectedJSON: ", text: "\(String(data: data!, encoding: .utf8)!)")
                            
                            completion(self.detectedJSON, nil)

                        }
                    }
                    //self.saveDataOnDatabase()
                } else {
                    self.loaderdelegate?.hideLoader()
                    PrintUtility.printLog(tag: self.TAG, text: "No text detected from image.")
                    let error = NSError(domain: "Camera", code: 001, userInfo: [ NSLocalizedDescriptionKey: "error_no_text_detected"])
                    completion(nil, error as Error)
                }
                
                
            }
        }
    }
    
    func getblockAndLineModeData(_ detectedJSON: DetectedJSON?, _for mode: String, isFromHistoryVC: Bool) {
        
        self.speechProcessingVM = SpeechProcessingViewModel()
        if let socketManager = socketManager {
            socketManager.socketManagerDelegate = self
        }
        bindData()

        if let detectionData = detectedJSON {
            
            if mode == blockMode {
                self.blockListFromJson = self.getBlockListFromJson(data: detectionData)
                PrintUtility.printLog(tag: "blockListFromJson", text: "\(blockListFromJson.count)")
                
                var sourceLan: String = ""
                for (index,block) in blockListFromJson.enumerated() {
                    sourceLan = block.detectedLanguage!
                    if sourceLan == LANGUAGE_CODE_UND || sourceLan == CHINESE_LANGUAGE_CODE_ZH {
                        break
                    }
                }
                if sourceLan == LANGUAGE_CODE_UND || sourceLan == CHINESE_LANGUAGE_CODE_ZH {
                    self.delegate?.showErrorAlert()
                }
                else{
                    self.translateText(arrayBlocks: blockListFromJson, type: "blockMode", isFromHistoryVC: isFromHistoryVC)
                }
                
            } else {
                
                self.lineListFromJson = self.getLineListFromJson(data: detectionData)
                PrintUtility.printLog(tag: "lineListFromJson lineListFromJson", text: "\(self.lineListFromJson)")
                
                var sourceLan: String = ""
                for (index,block) in lineListFromJson.enumerated() {
                    sourceLan = block.detectedLanguage!
                    if sourceLan == LANGUAGE_CODE_UND || sourceLan == CHINESE_LANGUAGE_CODE_ZH {
                        break
                    }
                }
                if sourceLan == LANGUAGE_CODE_UND || sourceLan == CHINESE_LANGUAGE_CODE_ZH {
                    self.delegate?.showErrorAlert()
                }
                else{
                    self.translateText(arrayBlocks: lineListFromJson, type: "lineMode", isFromHistoryVC: isFromHistoryVC)
                }
                
            }
            
        } else {
            PrintUtility.printLog(tag: "Error : ", text: "Unable to get block or line mode data")
        }
    }
    /*
    func translateText(arrayBlocks: [BlockDetection], type: String, isFromHistoryVC: Bool) {
        //var mTranslatedText = [String]()
        
        dispatchQueue.async {
            
            for (index,block) in arrayBlocks.enumerated() {
                let detectedText = block.text
                let sourceLan = block.detectedLanguage
                let targetLan = UserDefaults.standard.string(forKey: KCameraTargetLanguageCode)
                
                if Reachability.isConnectedToNetwork() {
                    TTTGoogle.translate(source: sourceLan!, target: targetLan!, text: detectedText!) { [self] text in
                        
                        if type == blockMode {
                            blockTranslatedText.append(text!)
                        } else {
                            lineTranslatedText.append(text!)
                        }
                        
                        if index == arrayBlocks.count-1 {
                            
                            PrintUtility.printLog(tag: TAG, text: "blockTranslatedText size: \(blockTranslatedText.count), lineTranslatedText size: \(lineTranslatedText.count)")
                            if type == "blockMode" {
                                mBlockData = BlockData(translatedText: blockTranslatedText, languageCodeTo: targetLan!)
                                self.getTextViewWithCoordinator(detectedBlockOrLineList: blockListFromJson, arrTranslatedText: self.blockTranslatedText, completion: {[weak self] textView in
                                    self?.blockModeTextViewList = textView
                                })
                            } else {
                                mLineData = BlockData(translatedText: lineTranslatedText, languageCodeTo: targetLan!)
                                self.getTextViewWithCoordinator(detectedBlockOrLineList: lineListFromJson, arrTranslatedText: self.lineTranslatedText, completion: { textView in
                                    self.lineModetTextViewList = textView
                                    self.loaderdelegate?.hideLoader()
                                })
                                
                            }
                            if isFromHistoryVC {
                                PrintUtility.printLog(tag: "index", text: "\(historyID)")
                                updateDataOnDatabase(id: historyID)
                            } else {
                                self.mTranslatedJSON = TranslatedTextJSONModel(block: self.mBlockData, line: self.mLineData)
                                let encoder = JSONEncoder()
                                encoder.outputFormatting = .prettyPrinted
                                let data = try? encoder.encode(self.mTranslatedJSON)
                                PrintUtility.printLog(tag: "", text: "mTranslatedJSON: \(String(data: data!, encoding: .utf8)!)")
                                PrintUtility.printLog(tag: "fromHistoryVC from itt", text: "\(fromHistoryVC)")
                                
                                if let entities = try? CameraHistoryDBModel().getAllCameraHistoryTables {
                                    if entities.contains(where: { $0.id == historyID }) {
                                        updateDataOnDatabase(id: historyID)
                                    } else {
                                        self.saveDataOnDatabase()
                                    }

                                }
                            }
                            
                        } else {
                            PrintUtility.printLog(tag: "completion ", text: " \(index) false")
                        }
                        self.semaphore.signal()
                    }
                } else {
                    GlobalMethod.showNoInternetAlert()
                }
                
                self.semaphore.wait()
            }
            
        }
    }
    
     */
    
    func translateText(arrayBlocks: [BlockDetection], type: String, isFromHistoryVC: Bool) {
        totalBlockCount = arrayBlocks.count
        tttCount = 0
        timeInterval = 60
        startCountdown()
        for (index,block) in arrayBlocks.enumerated() {
            let detectedText = block.text
            let sourceLan = block.detectedLanguage
            let targetLan = UserDefaults.standard.string(forKey: KCameraTargetLanguageCode)
            
                if Reachability.isConnectedToNetwork() {

                    self.translate(source: sourceLan!, target: targetLan!, text: detectedText!)
                    
                    if index == arrayBlocks.count-1 {
                        PrintUtility.printLog(tag: TAG, text: "blockTranslatedText size: \(blockTranslatedText.count), lineTranslatedText size: \(lineTranslatedText.count)")
                        
                    } else {
                        PrintUtility.printLog(tag: "completion ", text: " \(index) false")
                    }
                } else {
                    GlobalMethod.showNoInternetAlert()
                }
        }
    }
    
    func commandToGenerateTextView() {
        UserDefaults.standard.set(true, forKey: "isTransLateSuccessful")
        let type = UserDefaults.standard.string(forKey: modeSwitchType)
        let targetLan = UserDefaults.standard.string(forKey: KCameraTargetLanguageCode)
        
        //PrintUtility.printLog(tag: "commandToGenerateTextView", text: "\(type)")
        if type == "blockMode" {
            // blockTranslatedText = Array(Set(blockTranslatedText))
            mBlockData = BlockData(translatedText: blockTranslatedText, languageCodeTo: targetLan!)
            self.getTextViewWithCoordinator(detectedBlockOrLineList: blockListFromJson, arrTranslatedText: self.blockTranslatedText, completion: {[weak self] textView in
                self?.blockModeTextViewList = textView
            })
        } else {
            mLineData = BlockData(translatedText: lineTranslatedText, languageCodeTo: targetLan!)
            self.getTextViewWithCoordinator(detectedBlockOrLineList: lineListFromJson, arrTranslatedText: self.lineTranslatedText, completion: { textView in
                self.lineModetTextViewList = textView
                self.loaderdelegate?.hideLoader()
            })
        }
        
        if fromHistoryVC {
            PrintUtility.printLog(tag: "index", text: "\(historyID)")
            updateDataOnDatabase(id: historyID)
        } else {
            self.mTranslatedJSON = TranslatedTextJSONModel(block: self.mBlockData, line: self.mLineData)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try? encoder.encode(self.mTranslatedJSON)
           // PrintUtility.printLog(tag: "", text: "mTranslatedJSON: \(String(data: data!, encoding: .utf8)!)")
            //PrintUtility.printLog(tag: "fromHistoryVC from itt", text: "\(fromHistoryVC)")
            
            if let entities = try? CameraHistoryDBModel().getAllCameraHistoryTablesRow {
                if entities.contains(where: { $0.id == historyID }) {
                    updateDataOnDatabase(id: historyID)
                } else {
                    self.saveDataOnDatabase()
                }
                
            }
        }
    }

    
    func getTextViewWithCoordinator(detectedBlockOrLineList: [BlockDetection],  arrTranslatedText: [String], completion: @escaping(_ textView: [TextViewWithCoordinator])-> Void) {
        
        DispatchQueue.main.async {
            self.parseTextDetection.getListVerticalTextViewFromBlockList(detectedBlockList: detectedBlockOrLineList, arrTranslatedText: arrTranslatedText, completion: { (listTextView) in
                
                self.parseTextDetection.getListHorizontalTextViewFromBlockList(detectedBlockList: detectedBlockOrLineList, arrTranslatedText: arrTranslatedText, completion: { [self] (listTV) in
                    let textViewList = listTextView + listTV
                    PrintUtility.printLog(tag: TAG, text: "getTextViewWithCoordinator()>> Total textView: \(textViewList.count)")
                    PrintUtility.printLog(tag: TAG, text: "getTextViewWithCoordinator()>> Vertical TextView: \(listTextView.count)")
                    PrintUtility.printLog(tag: TAG, text: "getTextViewWithCoordinator()>> Horizontal TextView: \(listTV.count)")
                    completion(textViewList)
                })
            })
        }
    }
    func getBlockListFromJson(data: DetectedJSON) ->  [BlockDetection] {
        
        if let block = data.block {
            if let blocks = block.blocks {
                self.detectedBlockList = blocks.map({ result -> BlockDetection in
                    return BlockDetection(X1: result.boundingBox.vertices[0].x, Y1: result.boundingBox.vertices[0].y, X2: result.boundingBox.vertices[1].x, Y2: result.boundingBox.vertices[1].y, X3: result.boundingBox.vertices[2].x, Y3: result.boundingBox.vertices[2].y, X4: result.boundingBox.vertices[3].x, Y4: result.boundingBox.vertices[3].y, bottomTopBlock: result.bottomTopBlock, rightLeftBlock: result.rightLeftBlock, text: result.text, detectedLanguage: result.detectedLanguage)
                    
                })
            }
        }
        PrintUtility.printLog(tag: "detectedBlockList", text: "\(self.detectedBlockList)")
        return self.detectedBlockList
    }
    
    func saveDataOnDatabase() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(self.detectedJSON)
        //PrintUtility.printLog(tag: "DetectedJSON: ", text: "\(String(data: data!, encoding: .utf8)!)")
        
        let encoder1 = JSONEncoder()
        encoder1.outputFormatting = .prettyPrinted
        PrintUtility.printLog(tag: "translated language in save func: ", text: "\(String(describing: self.mTranslatedJSON.block?.languageCodeTo))")
        PrintUtility.printLog(tag: "translated line language in save func: ", text: "\(String(describing: self.mTranslatedJSON.line?.languageCodeTo))")
        let data1 = try? encoder1.encode(self.mTranslatedJSON)
        PrintUtility.printLog(tag: "", text: "mTranslatedJSON: \(String(data: data1!, encoding: .utf8)!)")
        
        if let image = capturedImage  {
            let imageData = UIImage.convertImageToBase64(image: image)
            _ = try? CameraHistoryDBModel().insert(item: CameraEntity(id: nil, detectedData: String(data: data!, encoding: .utf8)!, translatedData: String(data: data1!, encoding: .utf8)!, image: imageData))
        } else {
            PrintUtility.printLog(tag: "save to database: ", text: "False")
        }
    }
    
    func updateDataOnDatabase(id: Int64) {
        
        let translatedData = CameraHistoryDBModel().getTranslatedData(id: id)
        
        let modeSwitchTypes = UserDefaults.standard.string(forKey: modeSwitchType)
        if modeSwitchTypes == blockMode {
            self.mTranslatedJSON = TranslatedTextJSONModel(block: self.mBlockData, line: translatedData.line)
        } else {
            self.mTranslatedJSON = TranslatedTextJSONModel(block: translatedData.block, line: self.mLineData)
        }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try? encoder.encode(self.mTranslatedJSON)
        _ = try? CameraHistoryDBModel().updateTranslatedData(data: String(data: data!, encoding: .utf8)!, idToCompare: id)
        PrintUtility.printLog(tag: "", text: "Update mTranslatedJSON: \(String(data: data!, encoding: .utf8)!)")
    }
    
    func getLineListFromJson(data: DetectedJSON) ->  [BlockDetection] {
        
        if let line = data.line {
            if let lines = line.blocks {
                self.detectedLineList = lines.map({ result -> BlockDetection in
                    return BlockDetection(X1: result.boundingBox.vertices[0].x, Y1: result.boundingBox.vertices[0].y, X2: result.boundingBox.vertices[1].x, Y2: result.boundingBox.vertices[1].y, X3: result.boundingBox.vertices[2].x, Y3: result.boundingBox.vertices[2].y, X4: result.boundingBox.vertices[3].x, Y4: result.boundingBox.vertices[3].y, bottomTopBlock: result.bottomTopBlock, rightLeftBlock: result.rightLeftBlock, text: result.text, detectedLanguage: result.detectedLanguage)
                })
            }
        }
        return self.detectedLineList
    }
    
    func getScreenProperties(from image: UIImage) {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height

        PrintUtility.printLog(tag: "screenWidth: \(screenWidth)", text: "screenHeight: \(screenHeight)")
        
        let heightInPoints = image.size.height
        let heightInPixels = heightInPoints * image.scale
        
        let widthInPoints = image.size.width
        let widthInPixels = widthInPoints * image.scale
        PrintUtility.printLog(tag: "Image heightInPoints: \(heightInPoints)", text: ", heightInPixels: \(heightInPixels)")
        PrintUtility.printLog(tag: "Image widthInPoints: \(widthInPoints)", text: ", widthInPixels: \(widthInPixels)")
        
        // TODO change constant value to images height/width, following constents are images height and width. Here we have hardcoded those as we are using a test image
        if Int(widthInPixels) >= Int(screenWidth) {
            mXFactor = Float(screenWidth) / Float(widthInPixels)
        } else {
            mXFactor = 1
        }
        if Int(heightInPixels) >= Int(screenHeight) {
            mYFactor = Float(screenHeight) / Float(heightInPixels)
        } else {
            mYFactor = 1
        }
        PrintUtility.printLog(tag: "mXFactor:", text: "\(mXFactor)")
        PrintUtility.printLog(tag: "mYFactor:", text: "\(mYFactor)")
    }
}

// Get text view list for Camera Histoy Image

extension ITTServerViewModel {
    
    func getTextviewListForCameraHistory(detectedData: DetectedJSON, translatedData: TranslatedTextJSONModel) {
        self.blockListFromJson = self.getBlockListFromJson(data: detectedData)
        self.lineListFromJson = self.getLineListFromJson(data: detectedData)
        
        blockTranslatedText.removeAll()
        if let data = translatedData.block {
            for each in data.translatedText {
                blockTranslatedText.append(each)
            }
        }
        lineTranslatedText.removeAll()
        if let data = translatedData.line {
            for each in data.translatedText {
                lineTranslatedText.append(each)
            }
        }
        self.getTextViewWithCoordinator(detectedBlockOrLineList: blockListFromJson, arrTranslatedText: self.blockTranslatedText, completion: {[weak self] textView in
            self?.blockModeTextViewList = textView
        })
        
        self.getTextViewWithCoordinator(detectedBlockOrLineList: lineListFromJson, arrTranslatedText: self.lineTranslatedText, completion: { textView in
            self.lineModetTextViewList = textView
            self.loaderdelegate?.hideLoader()
        })
    }
    
    func getSelectedModeTextViewListFromHistory(detectedData: DetectedJSON, translatedData: TranslatedTextJSONModel, selectedMode: String) {
        
        if selectedMode == blockMode {
            self.blockListFromJson = self.getBlockListFromJson(data: detectedData)
            blockTranslatedText.removeAll()
            if let data = translatedData.block {
                for each in data.translatedText {
                    blockTranslatedText.append(each)
                }
            }
            self.getTextViewWithCoordinator(detectedBlockOrLineList: blockListFromJson, arrTranslatedText: self.blockTranslatedText, completion: {[weak self] textView in
                self?.blockModeTextViewList = textView
            })
            
        } else {
            
            self.lineListFromJson = self.getLineListFromJson(data: detectedData)
            
            lineTranslatedText.removeAll()
            if let data = translatedData.line {
                for each in data.translatedText {
                    lineTranslatedText.append(each)
                }
            }

            self.getTextViewWithCoordinator(detectedBlockOrLineList: lineListFromJson, arrTranslatedText: self.lineTranslatedText, completion: { textView in
                self.lineModetTextViewList = textView
                self.loaderdelegate?.hideLoader()
            })
        }
    }
    
}

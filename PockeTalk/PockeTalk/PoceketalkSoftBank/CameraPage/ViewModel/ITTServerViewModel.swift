//
//  ITTServerViewModel.swift
//  PockeTalk
//
//  Created by BJIT LTD on 13/9/21.
//

import Foundation
import UIKit

protocol ITTServerViewModelDelegates {
    func gettingServerDetectionDataSuccessful()
    func updateView()
}

class ITTServerViewModel: BaseModel {
    
    var capturedImage: UIImage?
    
    var mXFactor:Float = 1
    var mYFactor:Float = 1
    
    private(set) var loaderdelegate: LoaderDelegate?
    private(set) var parseTextDetection = ParseTextDetection()
    private(set) var delegate: ITTServerViewModelDelegates?
    
    let dispatchQueue = DispatchQueue(label: "myQueue", qos: .background)
    let semaphore = DispatchSemaphore(value: 0)
    let dispatchGroup = DispatchGroup()
    
    func viewDidLoad<T>(_ vc: T) {
        self.loaderdelegate = vc.self as? LoaderDelegate
        self.delegate = vc.self as? ITTServerViewModelDelegates
        
    }
    
    var detectedBlockList = [BlockDetection]()
    var detectedLineList = [BlockDetection]()
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
    
    var detectedJSON: DetectedJSON?
    var mTranslatedText = [String]()
    
    var blockListFromJson = [BlockDetection]()
    var lineListFromJson = [BlockDetection]()
    
    func createRequest()-> Resource{
        
        guard let url = URL(string: URL.ITTServerURL) else {
            fatalError("URl was incorrect")
        }
        var resource = Resource(url: url)
        
        resource.httpMethod = HttpMethod.get
        return resource
    }
    
    
    func getITTServerDetectionData(resource: Resource) {

        if Reachability.isConnectedToNetwork() {
            self.loaderdelegate?.showLoader()
            
            WebService.load(resource: resource) {[weak self] (result) in
                
                switch result {
                
                case .success(let data, let status):
                    switch status {
                    case HTTPStatusCodes.OK:
                        
                        
                        JSONDecoder.decodeData(model: GoogleCloudOCRResponse.self, data) { [weak self](result) in
                            switch result
                            {
                            case .success(let ocrResponse):
                                //PrintUtility.printLog(tag: "OCR Response", text: "\(ocrResponse)")
                                self?.getScreenProperties()
                                let response = ocrResponse.responses![0]
                                let lanCode = response.textAnnotations![0].locale
                                //PrintUtility.printLog(tag: "mDetectedLanguageCode: ", text: "\(lanCode!)")
                                let blockBlockClass = PointUtils.parseResponseForBlock(dataToParse: response.fullTextAnnotation, mDetectedLanguageCode: lanCode!, xFactor: self!.mXFactor, yFactor: self!.mYFactor)
                                var lineBlockClass = PointUtils.parseResponseForLine(dataToParse: response.fullTextAnnotation, mDetectedLanguageCode: lanCode!, xFactor:self!.mXFactor, yFactor:self!.mYFactor)
                                self?.detectedJSON = DetectedJSON(block: blockBlockClass, line: lineBlockClass)
                                
                                let encoder = JSONEncoder()
                                encoder.outputFormatting = .prettyPrinted
                                let data = try? encoder.encode(self?.detectedJSON)
                                //PrintUtility.printLog(tag: "DetectedJSON: ", text: "\(String(data: data!, encoding: .utf8)!)")
                                self?.delegate?.gettingServerDetectionDataSuccessful()
                                                                
                                //self?.saveDataOnDatabase()
                                
                                break
                                
                            case .failure(_):
                                self?.loaderdelegate?.hideLoader()
                                break
                            }
                        }
                        
                        break
                    case HTTPStatusCodes.BadRequest:
                        self?.loaderdelegate?.hideLoader()
                        break
                        
                    case HTTPStatusCodes.InternalServerError:
                        self?.loaderdelegate?.hideLoader()
                        break
                        
                    default:
                        self?.loaderdelegate?.hideLoader()
                        break
                        
                    }
                    break
                case .failure(_):
                    self?.loaderdelegate?.hideLoader()
                    break
                }
            }
        }
    }
    
    
    func getblockAndLineModeData(_ detectedJSON: DetectedJSON?) {
        
        if let detectionData = detectedJSON {
            
            self.blockListFromJson = self.getBlockListFromJson(data: detectionData)
            PrintUtility.printLog(tag: "blockListFromJson", text: "\(blockListFromJson.count)")
            self.translateText(arrayBlocks: blockListFromJson, type: "blockMode")
            self.lineListFromJson = self.getLineListFromJson(data: detectionData)
            self.translateText(arrayBlocks: lineListFromJson, type: "lineMode")

        } else {
            PrintUtility.printLog(tag: "Error : ", text: "Unable to get block or line mode data")
        }
    }
    
    
    func translateText(arrayBlocks: [BlockDetection], type: String) {
        //var mTranslatedText = [String]()
        
        dispatchQueue.async {
            
            for (index,block) in arrayBlocks.enumerated() {
                let detectedText = block.text
                let sourceLan = block.detectedLanguage
                let targetLan = UserDefaults.standard.string(forKey: KCameraTargetLanguageCode)
                
                TTTGoogle.translate(source: sourceLan!, target: targetLan!, text: detectedText!) { [self] text in
                    self.mTranslatedText.append(text!)
                    
                    if index == arrayBlocks.count-1 {
                        if type == "blockMode" {
                            self.getTextViewWithCoordinator(detectedBlockOrLineList: blockListFromJson, arrTranslatedText: self.mTranslatedText, completion: {[weak self] textView in
                                self?.blockModeTextViewList = textView
                            })
                        } else {
                            self.getTextViewWithCoordinator(detectedBlockOrLineList: lineListFromJson, arrTranslatedText: self.mTranslatedText, completion: { textView in
                                self.lineModetTextViewList = textView
                                self.loaderdelegate?.hideLoader()
                            })
                        }
                    } else {
                        PrintUtility.printLog(tag: "completion ", text: " \(index) false")
                    }
                    self.semaphore.signal()
                }
                self.semaphore.wait()
            }
        }
    }
    
    // TO DO : Need to delete after testing
//    func translateLineText(arrayBlocks: [BlockDetection], type: String) {
//        dispatchQueue.async {
//            for (index,block) in arrayBlocks.enumerated() {
//                let detectedText = block.text
//                let sourceLan = block.detectedLanguage
//                let targetLan = UserDefaults.standard.string(forKey: KCameraTargetLanguageCode)
//
//                TTTGoogle.translate(source: sourceLan!, target: targetLan!, text: detectedText!) { [self] text in
//                    self.mTranslatedText.append(text!)
//                    if index == arrayBlocks.count-1 {
//                        self.getTextViewWithCoordinator(detectedBlockOrLineList: lineListFromJson, arrTranslatedText: self.mTranslatedText, completion: { textView in
//                            self.lineModetTextViewList = textView
//                            self.loaderdelegate?.hideLoader()
//                            dispatchGroup.leave()
//                        })
//
//                    } else {
//                        PrintUtility.printLog(tag: "completion ", text: " \(index) false")
//                    }
//                    self.semaphore.signal()
//                }
//
//                self.semaphore.wait()
//            }
//        }
//    }
    
    func getTextViewWithCoordinator(detectedBlockOrLineList: [BlockDetection],  arrTranslatedText: [String], completion: @escaping(_ textView: [TextViewWithCoordinator])-> Void) {
        
        DispatchQueue.main.async {
            self.parseTextDetection.getListVerticalTextViewFromBlockList(detectedBlockList: detectedBlockOrLineList, arrTranslatedText: arrTranslatedText, completion: { (listTextView) in
                
                self.parseTextDetection.getListHorizontalTextViewFromBlockList(detectedBlockList: detectedBlockOrLineList, arrTranslatedText: arrTranslatedText, completion: { (listTV) in
                    let textViewList = listTextView + listTV
                    PrintUtility.printLog(tag: "textViewList", text: "\(textViewList.count)")
                    PrintUtility.printLog(tag: "listTextView", text: "\(listTextView.count)")
                    PrintUtility.printLog(tag: "listTV", text: "\(listTV.count)")
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
        
        if let image = capturedImage {
            let imageData = UIImage.convertImageToBase64(image: image)
            _ = try? CameraHistoryDBModel().insert(item: CameraEntity(id: nil, detectedData: "", translatedData: "", image: imageData))
        } else {
            PrintUtility.printLog(tag: "save to database: ", text: "False")
        }
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
}

extension ITTServerViewModel {
    
    func getScreenProperties() {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        let w:Int = Int(screenWidth)
        let h:Int = Int(screenHeight)
        PrintUtility.printLog(tag: "screenWidth: \(screenWidth)", text: "screenHeight: \(screenHeight)")
        
        // TODO change constant value to images height/width, following constents are images height and width. Here we have hardcoded those as we are using a test image
        if 334 >= IMAGE_WIDTH {
            mXFactor = Float(screenWidth) / Float(334)
        } else {
            mXFactor = 1
        }
        if 860 >= IMAGE_HEIGHT {
            mYFactor = Float(screenHeight) / Float(860)
        } else {
            mYFactor = 1
        }
        PrintUtility.printLog(tag: "mXFactor:", text: "\(mXFactor)")
        PrintUtility.printLog(tag: "mYFactor:", text: "\(mYFactor)")
    }

}

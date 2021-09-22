//
//  ITTServerViewModel.swift
//  PockeTalk
//
//  Created by BJIT LTD on 13/9/21.
//

import Foundation
import UIKit

protocol ITTServerViewModelDelegates {

    func updateView()
}

class ITTServerViewModel: BaseModel {
    
    var capturedImage: UIImage?
    
    var mXFactor:Float = 1
    var mYFactor:Float = 1
    
    private(set) var loaderdelegate: LoaderDelegate?
    private(set) var parseTextDetection = ParseTextDetection()
    private(set) var delegate: ITTServerViewModelDelegates?
    
    func viewDidLoad<T>(_ vc: T) {
        self.loaderdelegate = vc.self as? LoaderDelegate
        self.delegate = vc.self as? ITTServerViewModelDelegates
        
    }
    
    var detectedBlockList = [BlockDetection]() {
        didSet {
            //PrintUtility.printLog(tag: "detectedblockList", text: "\(detectedBlockList)")
        }
    }
    
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
    
    func createRequest()-> Resource{
        
        guard let url = URL(string: URL.ITTServerURL) else {
            fatalError("URl was incorrect")
        }
        var resource = Resource(url: url)
        
        resource.httpMethod = HttpMethod.get
        return resource
    }
    
    
    func getITTServerDetectionData(resource: Resource, completion: @escaping(_ blockData: DetectedJSON?, _ error: Error?)-> Void) {

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
                                let detectedJSON = DetectedJSON(block: blockBlockClass, line: lineBlockClass)
                                
                                let encoder = JSONEncoder()
                                encoder.outputFormatting = .prettyPrinted
                                let data = try? encoder.encode(detectedJSON)
                                PrintUtility.printLog(tag: "DetectedJSON: ", text: "\(String(data: data!, encoding: .utf8)!)")
                                
                                completion(detectedJSON, nil)
                                                                
                                //self?.saveDataOnDatabase()
                                
                                break
                                
                            case .failure(_):
                                completion(nil, NetworkError.decodingError)
                                self?.loaderdelegate?.hideLoader()
                                break
                            }
                        }
                        
                        break
                    case HTTPStatusCodes.BadRequest:
                        completion(nil, NetworkError.undefined)
                        self?.loaderdelegate?.hideLoader()
                        break
                        
                    case HTTPStatusCodes.InternalServerError:
                        completion(nil, NetworkError.offline)
                        self?.loaderdelegate?.hideLoader()
                        break
                        
                    default:
                        completion(nil, NetworkError.undefined)
                        self?.loaderdelegate?.hideLoader()
                        break
                        
                    }
                    break
                case .failure(_):
                    completion(nil, NetworkError.undefined)
                    self?.loaderdelegate?.hideLoader()
                    break
                }
            }
        }
    }
    
    
    func getblockAndLineModeData(_ detectedJSON: DetectedJSON?) {
                
        if let detectionData = detectedJSON {
                        
            self.getBlockListFromJson(data: detectionData) { [weak self] (result) in
                
                self?.getTextViewWithCoordinator(detectedBlockOrLineList: result, completion: {[weak self] textView in
                    self?.blockModeTextViewList = textView
                })
            }
            
            self.getLineListFromJson(data: detectionData) { [weak self] (result) in
                self?.getTextViewWithCoordinator(detectedBlockOrLineList: result, completion: { textView in
                    self?.lineModetTextViewList = textView
                    self?.loaderdelegate?.hideLoader()
                })
            }
        } else {
            PrintUtility.printLog(tag: "Error : ", text: "Unable to get block or line mode data")
        }
    }
    
    
    func getTextViewWithCoordinator(detectedBlockOrLineList: [BlockDetection], completion: @escaping(_ textView: [TextViewWithCoordinator])-> Void) {
        
        DispatchQueue.main.async {
            self.parseTextDetection.getListVerticalTextViewFromBlockList(detectedBlockList: detectedBlockOrLineList, completion: { (listTextView) in
                
                self.parseTextDetection.getListHorizontalTextViewFromBlockList(detectedBlockList: detectedBlockOrLineList, completion: { (listTV) in
                    let blockTextViewListtt = listTextView + listTV
                    
                    completion(blockTextViewListtt)
                })
            })
        }
    }

    func getBlockListFromJson(data: DetectedJSON, completion: @escaping(_ data: [BlockDetection])-> Void)  {
        
        if let block = data.block {
            if let blocks = block.blocks {
                self.detectedBlockList = blocks.map({ result -> BlockDetection in
                    return BlockDetection(X1: result.boundingBox.vertices[0].x, Y1: result.boundingBox.vertices[0].y, X2: result.boundingBox.vertices[1].x, Y2: result.boundingBox.vertices[1].y, X3: result.boundingBox.vertices[2].x, Y3: result.boundingBox.vertices[2].y, X4: result.boundingBox.vertices[3].x, Y4: result.boundingBox.vertices[3].y, bottomTopBlock: result.bottomTopBlock, rightLeftBlock: result.rightLeftBlock, text: result.text, detectedLanguage: result.text)
                    
                })
            }
        }
        completion(self.detectedBlockList)
    }
    
    func saveDataOnDatabase() {
        
        if let image = capturedImage {
            let imageData = UIImage.convertImageToBase64(image: image)
            _ = try? CameraHistoryDBModel().insert(item: CameraEntity(id: nil, detectedData: "", translatedData: "", image: imageData))
        } else {
            PrintUtility.printLog(tag: "save to database: ", text: "False")
        }
    }
    
    func getLineListFromJson(data: DetectedJSON, completion: @escaping(_ data: [BlockDetection])-> Void)  {
        
        if let line = data.line {
            if let lines = line.blocks {
                self.detectedBlockList = lines.map({ result -> BlockDetection in
                    return BlockDetection(X1: result.boundingBox.vertices[0].x, Y1: result.boundingBox.vertices[0].y, X2: result.boundingBox.vertices[1].x, Y2: result.boundingBox.vertices[1].y, X3: result.boundingBox.vertices[2].x, Y3: result.boundingBox.vertices[2].y, X4: result.boundingBox.vertices[3].x, Y4: result.boundingBox.vertices[3].y, bottomTopBlock: result.bottomTopBlock, rightLeftBlock: result.rightLeftBlock, text: result.text, detectedLanguage: result.text)
                    
                })
            }
        }
        completion(self.detectedBlockList)
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

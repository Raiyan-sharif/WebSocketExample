//
//  ITTServerViewModel.swift
//  PockeTalk
//
//  Created by BJIT LTD on 13/9/21.
//

import Foundation
import UIKit

protocol ITTServerViewModelDelegates {

    func updateViewWith(textViews: [TextViewWithCoordinator])
}

class ITTServerViewModel: BaseModel {
    
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
            PrintUtility.printLog(tag: "detectedblockList", text: "\(detectedBlockList)")
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
                                PrintUtility.printLog(tag: "OCR Response", text: "\(ocrResponse)")
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
                                //PrintUtility.printLog(tag: "DetectedJSON: ", text: "\(String(data: data!, encoding: .utf8)!)")
                                
                                self!.getBlockListFromJson(data: detectedJSON) { [weak self] (result) in
                                    
                                    DispatchQueue.main.async {
                                        self?.parseTextDetection.getListVerticalTextViewFromBlockList(detectedBlockList: result, completion: { (listTextView) in
                                            
                                            self?.parseTextDetection.getListHorizontalTextViewFromBlockList(detectedBlockList: result, completion: { (listTV) in
                                                let textViewList = listTextView + listTV
                                                self?.delegate?.updateViewWith(textViews: textViewList)
                                            })
                                        })
                                        self?.loaderdelegate?.hideLoader()
                                    }
                                                                        
                                }                                
                                
                                break
                                
                            case .failure(let error):
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
                case .failure(let error):
                    self?.loaderdelegate?.hideLoader()
                    break
                }
            }
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
    
    
    
}

extension ITTServerViewModel {
    
    func getScreenProperties() {
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        let w:Int = Int(screenWidth)
        let h:Int = Int(screenHeight)
        //PrintUtility.printLog(tag: "screenWidth:", text: "\(screenWidth)")
        if 640 >= IMAGE_WIDTH {
            mXFactor = Float(screenWidth) / Float(640)
        } else {
            mXFactor = 1
        }
        if 860 >= IMAGE_HEIGHT {
            mXFactor = Float(screenHeight) / Float(860)
        } else {
            mYFactor = 1
        }
        PrintUtility.printLog(tag: "mXFactor:", text: "\(mXFactor)")
        PrintUtility.printLog(tag: "mYFactor:", text: "\(mYFactor)")
    }

}

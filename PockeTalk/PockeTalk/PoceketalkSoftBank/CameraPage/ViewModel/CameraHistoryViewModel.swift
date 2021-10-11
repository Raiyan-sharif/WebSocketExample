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
            for each in cameraHistoryData.reversed() {
                if let imageData = each.image {
                    let image = UIImage.convertBase64ToImage(imageString: imageData)
                    cameraHistoryImages.append(CameraHistoryDataModel.init(image: image))
                }
            }
        }
    }
    
    func fetchImageCount() -> Int {
        var count = Int()
        if let cameraHistoryData = try? CameraHistoryDBModel().getAllCameraHistoryTables {
            count = cameraHistoryData.count
        }
        return count
    }
    
    func fetchDetectedAndTranslatedText(for index: Int) {
        if let cameraHistoryData = try? CameraHistoryDBModel().getAllCameraHistoryTables {
            
            if let detectedData = cameraHistoryData.reversed()[index].detectedData {
                do {
                    let data = try JSONDecoder().decode(DetectedJSON.self, from: Data(detectedData.utf8))
                    self.detectedData = data
                } catch let error {
                    PrintUtility.printLog(tag: "ERROR :", text: error.localizedDescription)
                }
            }
            
            if let translatedData = cameraHistoryData.reversed()[index].translatedData {
                do {
                    let data = try JSONDecoder().decode(TranslatedTextJSONModel.self, from: Data(translatedData.utf8))
                    self.translatedData = data
                } catch let error {
                    PrintUtility.printLog(tag: "ERROR :", text: error.localizedDescription)
                }
            }
        }
    }
    
}






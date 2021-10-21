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
    
    func fetchImageCount() -> Int {
        var count = Int()
        if let cameraHistoryData = try? CameraHistoryDBModel().getAllCameraHistoryTables {
            count = cameraHistoryData.count
        }
        return count
    }
    
}






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
    
    private(set) var delegate: CameraHistoryViewModelDelegates?
    
    func viewDidLoad<T>(_ vc: T) {
        self.delegate = vc.self as? CameraHistoryViewModelDelegates
    }
    
    
    func fetchCameraHistoryImages() {
        
        cameraHistoryImages.removeAll()
        
        if let cameraHistoryData = try? CameraHistoryDBModel().getAllCameraHistoryTables {
            for each in cameraHistoryData {
                if let imageData = each.image {
                    let image = UIImage.convertBase64ToImage(imageString: imageData)
                    cameraHistoryImages.append(CameraHistoryDataModel.init(image: image))
                }
                
                
            }
        }
        
    }
    
}






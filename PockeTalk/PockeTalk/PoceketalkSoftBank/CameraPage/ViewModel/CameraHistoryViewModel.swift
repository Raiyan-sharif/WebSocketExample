//
//  CameraHistoryViewModel.swift
//  PockeTalk
//
//  Created by BJIT LTD on 15/9/21.
//

import Foundation

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
        
        let imageArr: [UIImage] = [UIImage(named: "image1.jpeg")!, UIImage(named: "images2.png")!, UIImage(named: "images3.jpeg")!,UIImage(named: "images4.png")!]
        
        for each in imageArr {
            cameraHistoryImages.append(CameraHistoryDataModel.init(image: each))        }
        PrintUtility.printLog(tag: "image arr", text: "\(self.cameraHistoryImages)")
        
    }
    
}






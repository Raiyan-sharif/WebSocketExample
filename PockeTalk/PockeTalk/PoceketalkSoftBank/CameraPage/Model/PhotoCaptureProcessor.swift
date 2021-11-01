//
//  PhotoCaptureProcessor.swift
//  PockeTalk
//

import Foundation
import AVFoundation


class PhotoCaptureProcessor: NSObject {
    var photo: AVCapturePhoto?
    var completion: ((PhotoCaptureProcessor) -> Void)?
    var settings: AVCaptureResolvedPhotoSettings?
    var orientation: AVCaptureVideoOrientation = .portrait
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            return
        }
        
        self.photo = photo
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        guard error == nil else {
            return
        }
        self.settings = resolvedSettings
        completion?(self)
    }
}

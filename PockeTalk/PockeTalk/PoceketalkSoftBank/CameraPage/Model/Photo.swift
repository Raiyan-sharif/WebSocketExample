//
//  Photo.swift
//  PockeTalk
//
//  Created by BJIT LTD on 24/9/21.
//

import Foundation
import AVFoundation
import UIKit

class Photo {
    private let photo: AVCapturePhoto
    private let orientation: AVCaptureVideoOrientation
    
    init(photo: AVCapturePhoto, orientation: AVCaptureVideoOrientation) {
        self.photo = photo
        self.orientation = orientation
    }
    
    func image() -> UIImage? {
        guard let cgImage = photo.cgImageRepresentation()?.takeUnretainedValue() else { return nil }
        //guard let cgImage = photo.cgImageRepresentation() else { return nil }
        
        let imageOrientation: UIImage.Orientation
        switch orientation {
        case .portrait:
            imageOrientation = .right
        case .portraitUpsideDown:
            imageOrientation = .left
        case .landscapeRight:
            imageOrientation = .up
        case .landscapeLeft:
            imageOrientation = .down
        }
        return UIImage(cgImage: cgImage as! CGImage, scale: 1, orientation: imageOrientation)
    }
    
    func getResizedImage(image: UIImage, visibleLayerFrame: CGRect, completion: @escaping(_ textView: [TextViewWithCoordinator])-> Void) {
        
        
    }
}

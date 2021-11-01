//
//  Extension+UIImage.swift
//  PockeTalk
//

import Foundation
import UIKit

extension UIImage{
   static func convertBase64ToImage(imageString: String) -> UIImage {
        let imageData = Data(base64Encoded: imageString, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!
        return UIImage(data: imageData)!
    }
    
    
   static func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.pngData()!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
        
    func fixingOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let editedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        
        return editedImage
    }

    func crop(rect: CGRect) -> UIImage {
        
        var transform: CGAffineTransform
        switch imageOrientation {
        case .left:
            transform = CGAffineTransform(rotationAngle: PointUtils.radians(90)).translatedBy(x: 0, y: -size.height)
        case .right:
            transform = CGAffineTransform(rotationAngle: PointUtils.radians(-90)).translatedBy(x: -size.width, y: 0)
        case .down:
            transform = CGAffineTransform(rotationAngle: PointUtils.radians(-180)).translatedBy(x: -size.width, y: -size.height)
        default:
            transform = CGAffineTransform.identity
        }
        
        transform = transform.scaledBy(x: scale, y: scale)
        
        if let croppedImage = cgImage?.cropping(to: rect.applying(transform)) {
            return UIImage(cgImage: croppedImage, scale: scale, orientation: imageOrientation).fixingOrientation()
        }
        
        return self
    }


}


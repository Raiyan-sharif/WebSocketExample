//
//  CameraHistoryCollectionViewCell.swift
//  PockeTalk
//

import UIKit

class CameraHistoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var historyImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    var imageData: CameraHistoryDataModel? {
        didSet {
            self.historyImage.image = imageData?.image
        }
    }

    
}

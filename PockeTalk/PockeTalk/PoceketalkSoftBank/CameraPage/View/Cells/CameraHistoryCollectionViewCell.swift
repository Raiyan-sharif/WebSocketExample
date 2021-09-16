//
//  CameraHistoryCollectionViewCell.swift
//  PockeTalk
//
//  Created by BJIT LTD on 15/9/21.
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

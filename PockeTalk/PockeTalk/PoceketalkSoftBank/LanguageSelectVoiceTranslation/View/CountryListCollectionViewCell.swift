//
//  CountryListCollectionViewCell.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 8/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit

class CountryListCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var countryNameLabel: UILabel!
    static let identifier = "CountryListCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureFlagImage(with image: UIImage){
        flagImageView.image = image
    }
    
    static func nib() ->UINib{
        return UINib(nibName: "CountryListCollectionViewCell", bundle: nil)
    }
}

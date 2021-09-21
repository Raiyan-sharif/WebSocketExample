//
//  langListCollectionViewCell.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 9/9/21.
//

import UIKit

class langListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var languageNameLabel: UILabel!
    @IBOutlet weak var imageLanguageSelection: UIImageView!
    @IBOutlet weak var langListItemContainer: UIView!
    static let identifier = "langListCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    static func nib() -> UINib{
        return UINib(nibName: "langListCollectionViewCell", bundle: nil)
    }

    override func layoutSubviews() {
        changeFontSize()
    }
}

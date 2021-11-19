//
//  langListCollectionViewCell.swift
//  PockeTalk
//

import UIKit
import MarqueeLabel

class langListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var languageNameLabel: UILabel!
    @IBOutlet weak var languageNameLableSelected: MarqueeLabel!
    @IBOutlet weak var imageLanguageSelection: UIImageView!
    @IBOutlet weak var langListItemContainer: UIView!
    @IBOutlet weak var imageviewNoVoice: UIImageView!
    @IBOutlet weak var unselectedLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedLabelTrailingConstraint: NSLayoutConstraint!
    static let identifier = "langListCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        languageNameLabel.lineBreakMode = .byTruncatingTail
    }

    static func nib() -> UINib{
        return UINib(nibName: "langListCollectionViewCell", bundle: nil)
    }

    override func layoutSubviews() {
        changeFontSize()
    }
}

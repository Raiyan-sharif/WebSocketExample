//
//  LangListCell.swift
//  PockeTalk
//

import UIKit
import MarqueeLabel

class LangListCell: UITableViewCell {

    @IBOutlet weak var langListCellContainer: UIView!
    @IBOutlet weak var imageLangItemSelector: UIImageView!
    @IBOutlet weak var lableLangName: MarqueeLabel!
    @IBOutlet weak var langNameUnSelecteLabel: UILabel!
    @IBOutlet weak var imageNoVoice: UIImageView!
    @IBOutlet weak var unselectedLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var selectedLabelTrailingConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        changeFontSize()
    }

}

//
//  SettingsTableViewCell.swift
//  PockeTalk
//

import UIKit

class SettingsTableViewCell: UITableViewCell {

    @IBOutlet var labelTitle : UILabel!
    @IBOutlet var imageViewRightArrow: UIImageView!

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

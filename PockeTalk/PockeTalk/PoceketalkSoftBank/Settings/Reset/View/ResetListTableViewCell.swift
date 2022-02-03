//
//  ResetListTableViewCell.swift
//  PockeTalk
//

import UIKit
import MarqueeLabel

class ResetListTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: MarqueeLabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

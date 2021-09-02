//
//  SettingsTableViewCell.swift
//  PockeTalk
//
//  Created by Khairuzzaman Shipon on 9/2/21.
//  Copyright © 2021 Bjit ltd. on All rights reserved.
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
    
}

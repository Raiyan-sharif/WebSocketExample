//
//  LangListCell.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 4/9/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

import UIKit

class LangListCell: UITableViewCell {

    @IBOutlet weak var langListCellContainer: UIView!
    @IBOutlet weak var imageLangItemSelector: UIImageView!
    @IBOutlet weak var lableLangName: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

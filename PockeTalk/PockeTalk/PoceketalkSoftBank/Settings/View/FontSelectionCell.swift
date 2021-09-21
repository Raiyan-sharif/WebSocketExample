//
//  FontSelectionCell.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/14/21.
//

import UIKit

class FontSelectionCell: UITableViewCell,NibReusable {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        changeFontSize()
    }

}

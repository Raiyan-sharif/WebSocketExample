//
//  SystemLanguageCell.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/2/21.
//

import UIKit

class SystemLanguageCell: UITableViewCell,NibReusable {
    /// Set language name
    @IBOutlet weak var nameLabel: UILabel!
    ///Assign selected language
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
        changeFontSize()
    }

}

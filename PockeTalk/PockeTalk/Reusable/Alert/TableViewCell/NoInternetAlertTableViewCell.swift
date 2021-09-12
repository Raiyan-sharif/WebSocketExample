//
// NoInternetAlertTableViewCell.swift
// PockeTalk
//

import UIKit

class NoInternetAlertTableViewCell: UITableViewCell {
    ///Views
    @IBOutlet weak var titleLabel: UILabel!

    ///Properties
    let fontSize : CGFloat = 22.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //Initial UI set up
    func configureCell (title : String){
        self.titleLabel.text = title
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.titleLabel.textColor = UIColor._blackColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

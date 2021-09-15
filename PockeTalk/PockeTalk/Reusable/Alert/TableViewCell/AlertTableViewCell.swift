//
// AlertTableViewCell.swift
// PockeTalk
//

import UIKit

class AlertTableViewCell: UITableViewCell {
    ///Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!

    ///Views
    let fontSize : CGFloat = 19.0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    //Initial UI set up
    func configureCell (title : String, imageName : String){
        self.titleLabel.text = title
        self.titleLabel.textAlignment = .center
        self.titleLabel.numberOfLines = 0
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .regular)
        self.titleLabel.textColor = UIColor._alertTitleColor()

        self.imgView.image = UIImage(named: imageName)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

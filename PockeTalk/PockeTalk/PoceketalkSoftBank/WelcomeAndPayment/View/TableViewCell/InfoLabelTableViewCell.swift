//
//  InfoLabelTableViewCell.swift
//  PockeTalk
//

import UIKit

class InfoLabelTableViewCell: UITableViewCell {

    @IBOutlet weak private var textInfoLabel: UILabel!

    //MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: - Configure Cell
    func configCell(text: String){
        self.textInfoLabel.text = text
    }
}

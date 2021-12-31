//
//  SingleLabelCell.swift
//  PockeTalk
//

import UIKit

class SingleLabelCell: UITableViewCell {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var infoLabel: UILabel!
    
    //MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        changeFontSize()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Configure cell
    func configCell(ttsText: String, indexPath: IndexPath){
        infoLabel.text = ttsText
        if indexPath.row == 2{
            infoLabel.textColor = .gray
        } else {
            infoLabel.textColor = .black
        }
    }
}

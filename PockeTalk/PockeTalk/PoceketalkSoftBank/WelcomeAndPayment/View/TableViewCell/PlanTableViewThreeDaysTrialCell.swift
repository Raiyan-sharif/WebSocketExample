//
//  PlanTableViewThreeDaysTrialCell.swift
//  PockeTalk
//

import UIKit

class PlanTableViewThreeDaysTrialCell: UITableViewCell {
    @IBOutlet weak private var planTypeLabel: UILabel!
    @IBOutlet weak private var planDescriptionLabel: UILabel!
    @IBOutlet weak private var containerView: UIView!

    //MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: - Initial setup
    private func setupUI(){
        containerView.layer.cornerRadius = 10.0
        containerView.layer.borderWidth = 1.0
        containerView.layer.borderColor = UIColor.freeTrailColor.cgColor
        planDescriptionLabel.textColor = UIColor.black
        planTypeLabel.textColor = UIColor.freeTrailColor
    }

    //MARK: - ConfigCell
    func configCell(indexPath: IndexPath, cellType: PurchasePlanTVCellInfo){
        planTypeLabel.text = "kThreeDaysTrial".localiz()
        planDescriptionLabel.text = "kThreeDaysTrialDescription".localiz()
    }
}

//
//  PlanTableViewCell.swift
//  PockeTalk
//

import UIKit

class PlanTableViewCell: UITableViewCell {
    @IBOutlet weak private var planTypeLabel: UILabel!
    @IBOutlet weak private var planDetailsLabel: UILabel!
    @IBOutlet weak private var rightView: UIView!
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var freeFroThreeDaysLabel: UILabel!

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
        containerView.backgroundColor = UIColor._lightBlueColor()
        containerView.layer.borderColor = UIColor._royalBlueColor().cgColor
        planTypeLabel.textColor = UIColor._royalBlueColor()
        planDetailsLabel.textColor = UIColor.black
        rightView.layer.cornerRadius = rightView.frame.size.width / 2
    }

    //MARK: - ConfigCell
    func configCell(indexPath: IndexPath, cellType: PurchasePlanTVCellInfo, productData: ProductDetails?){
        planTypeLabel.text = cellType.planTitleText

        if productData?.planPerUnitText == nil {
            planDetailsLabel.text = "Loading..."
        } else {
            planDetailsLabel.text = productData?.planPerUnitText
        }

        if productData?.freeUsesDetailsText != nil {
            rightView.isHidden = false
            freeFroThreeDaysLabel.text = productData?.freeUsesDetailsText
        } else {
            rightView.isHidden = true
            freeFroThreeDaysLabel.text = ""
        }
    }
}

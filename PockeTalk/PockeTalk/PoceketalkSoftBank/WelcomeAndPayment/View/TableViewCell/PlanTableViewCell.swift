//
//  PlanTableViewCell.swift
//  PockeTalk
//

import UIKit

class PlanTableViewCell: UITableViewCell {
    @IBOutlet weak private var planTypeLabel: UILabel!
    @IBOutlet weak private var planDetailsLabel: UILabel!
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var planSuggestionLabel: UILabel!
    @IBOutlet weak private var planTypeLabelTopLayoutConstrain: NSLayoutConstraint!
    @IBOutlet weak private var planSuggestionLabelTopLayoutConstrain: NSLayoutConstraint!
    @IBOutlet weak private var ribbonImageView: UIImageView!
    @IBOutlet weak private var recommendationLabel: UILabel!

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
        ribbonImageView.layer.cornerRadius = 10.0
        ribbonImageView.layer.maskedCorners = [.layerMaxXMinYCorner]

        planTypeLabel.textColor = UIColor._royalBlueColor()
        planDetailsLabel.textColor = UIColor.black
        planSuggestionLabel.textColor = UIColor.black
    }

    //MARK: - ConfigCell
    func configCell(indexPath: IndexPath, cellType: PurchasePlanTVCellInfo, productData: ProductDetails?, isSuggestionTextAvailable: Bool){
        setUIConstrain(isSuggestionTextAvailable: isSuggestionTextAvailable)

        if productData != nil {
            planTypeLabel.text = cellType.planTitleText
            planDetailsLabel.text = productData!.planPerUnitText

            ///set suggestion text
            if let suggestionText = productData?.suggestionText {
                planSuggestionLabel.text = suggestionText
            } else {
                planSuggestionLabel.text = ""
            }

            ///set recommendation data
            if productData?.periodUnitType == .year {
                ribbonImageView.isHidden = false
                ribbonImageView.image = UIImage(named: "plan_label")

                recommendationLabel.isHidden = false
                setRecommendationLabel()
            } else {
                ribbonImageView.isHidden = true
                recommendationLabel.isHidden = true
            }
        }
    }

    private func setRecommendationLabel() {
        recommendationLabel.text = "kBestPrice".localiz()
        recommendationLabel.transform = CGAffineTransform(rotationAngle: CGFloat((Double.pi / 4.0)))
    }

    private func setUIConstrain(isSuggestionTextAvailable: Bool){
        if !isSuggestionTextAvailable {
            planTypeLabelTopLayoutConstrain.constant = InitialFlowHelper().planTypeLabelTopLayoutConstrain
        }
    }
}

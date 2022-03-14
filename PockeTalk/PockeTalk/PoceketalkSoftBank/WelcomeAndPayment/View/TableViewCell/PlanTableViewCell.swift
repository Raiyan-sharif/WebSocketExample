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
    @IBOutlet weak private var dummyImageContainerView: UIView!
    @IBOutlet weak private var dummyImageView: UIImageView!

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
        planSuggestionLabel.textColor = UIColor.black
    }

    //MARK: - ConfigCell
    func configCell(indexPath: IndexPath, cellType: PurchasePlanTVCellInfo, productData: ProductDetails?, isSuggestionTextAvailable: Bool, isShowDummyImage: Bool){

        if isShowDummyImage {
            dummyImageContainerView.isHidden = false
            containerView.isHidden = true

            if cellType == .weeklyPlan {
                dummyImageView.image = UIImage(named: InitialFlowHelper().weeklyProductImage)
            } else if cellType == .monthlyPlan {
                dummyImageView.image = UIImage(named: InitialFlowHelper().monthlyProductImage)
            } else if cellType == .annualPlan {
                dummyImageView.image = UIImage(named: InitialFlowHelper().annualProductImage)
            }

        } else {
            dummyImageContainerView.isHidden = true
            containerView.isHidden = false

            setUIConstrain(isSuggestionTextAvailable: isSuggestionTextAvailable)

            if productData != nil {
                planTypeLabel.text = cellType.planTitleText
                planDetailsLabel.text = productData!.planPerUnitText

                if let suggestionText = productData?.suggestionText {
                    planSuggestionLabel.text = suggestionText
                } else {
                    planSuggestionLabel.text = ""
                }
            }
        }
    }

    private func setUIConstrain(isSuggestionTextAvailable: Bool){
        if !isSuggestionTextAvailable {
            planTypeLabelTopLayoutConstrain.constant = InitialFlowHelper().planTypeLabelTopLayoutConstrain
        }
    }
}

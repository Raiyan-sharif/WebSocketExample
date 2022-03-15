//
//  FreePlanTableViewCell.swift
//  PockeTalk
//

import UIKit

class FreePlanTableViewCell: UITableViewCell {
    @IBOutlet weak private var freeDaysLabel: UILabel!
    @IBOutlet weak private var freeDaysInfoLabel: UILabel!
    @IBOutlet weak private var containerView: UIView!
    //@IBOutlet weak private var activityIndicatorContainerView: UIView!

    //MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    //MARK: - Initial setup
    private func setupView() {
        freeDaysLabel.textColor = UIColor._semiDarkYellowColor()
    }

    //MARK: - Config cell
    func configCell(indexPath: IndexPath, freeDaysDetailsInfoText: String, freeDaysUsesInfo: String?){
        if freeDaysUsesInfo != nil {
            freeDaysLabel.text = freeDaysUsesInfo!
            freeDaysInfoLabel.text = freeDaysDetailsInfoText
        }
    }
}

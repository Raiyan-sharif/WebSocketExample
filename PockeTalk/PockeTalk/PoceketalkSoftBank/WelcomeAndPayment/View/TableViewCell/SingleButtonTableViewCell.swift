//
//  SingleButtonTableViewCell.swift
//  PockeTalk
//

import UIKit

class SingleButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var singleBtn: UIButton!
    private var indexPath: IndexPath!
    private var callbackClosure: ((IndexPath) -> Void)?

    //MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: - Configure Cell
    func configure(indexPath: IndexPath, buttonTitle: String, callbackClosure: ((_ cellIndexPath: IndexPath) -> Void)?){
            self.callbackClosure = callbackClosure

        let myNormalAttributedTitle = NSAttributedString(string: buttonTitle,
                                                         attributes: [NSAttributedString.Key.foregroundColor : UIColor._royalBlueColor()])
        self.singleBtn.setAttributedTitle(myNormalAttributedTitle,for:.normal)
        self.singleBtn.titleLabel?.baselineAdjustment = .alignBaselines
        self.singleBtn.titleLabel?.textAlignment = .center

        self.indexPath = indexPath
        }

    //MARK: - IBActions
    @IBAction private func btnTap(_ sender: Any) {
        callbackClosure?(indexPath)
    }
}

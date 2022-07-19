//
//  PermissionTableViewCell.swift
//  PockeTalk
//

import UIKit

class PermissionTableViewCell: UITableViewCell {

    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var permissionImageView: UIImageView!
    @IBOutlet weak private var permissionLabel: UILabel!
    @IBOutlet weak private var checkImageView: UIImageView!

    //MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: - ConfigCell
    func configCell(indexPath: IndexPath, cellInfo: PermissionTVCellInfo){
        setupCellInfo(cellInfo)
    }

    private func setupCellInfo(_ cellInfo: PermissionTVCellInfo){
        let cellType = cellInfo.cellType
        let isPermissionGranted = cellInfo.isPermissionGranted

        switch cellType {
        case .allowAccess:
            return
        case .microphonePermission:
            isPermissionGranted ? (permissionImageView.image = UIImage(named: "icon_mic_select")) : (permissionImageView.image = UIImage(named: "icon_mic_unselect"))
            permissionLabel.text = "kInitialPermissionSettingsVCMicrophoneLabel".localiz()
            setupContainerView(isPermissionGranted: isPermissionGranted)
        case .cameraPermission:
            isPermissionGranted ? (permissionImageView.image = UIImage(named: "icon_camera_select")) : (permissionImageView.image = UIImage(named: "icon_camera_unselect"))
            permissionLabel.text = "kInitialPermissionSettingsVCCameraLabel".localiz()
            setupContainerView(isPermissionGranted: isPermissionGranted)

        case .notificationPermission:
            isPermissionGranted ? (permissionImageView.image = UIImage(named: "icon_notification_select")) : (permissionImageView.image = UIImage(named: "icon_notification_unselect"))
            permissionLabel.text = "kInitialPermissionSettingsVCNotificationLabel".localiz()
            setupContainerView(isPermissionGranted: isPermissionGranted)
        }

    }

    //MARK: - Utils
    private func setupContainerView(isPermissionGranted: Bool){
        containerView.layer.borderWidth = 2.0
        containerView.layer.cornerRadius = 30.0

        if isPermissionGranted {
            containerView.layer.borderColor = UIColor._royalBlueColor().cgColor
            checkImageView.isHidden = false
            permissionLabel.textColor = UIColor._royalBlueColor()
        }else {
            containerView.layer.borderColor = UIColor.gray.cgColor
            checkImageView.isHidden = true
            permissionLabel.textColor = UIColor.black
        }
    }
}

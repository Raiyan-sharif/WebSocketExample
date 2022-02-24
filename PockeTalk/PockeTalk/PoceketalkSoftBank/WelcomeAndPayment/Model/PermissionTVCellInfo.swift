//
//  PermissionTVCellInfo.swift
//  PockeTalk
//

import UIKit

enum PermissionTVCellType: Int {
    case allowAccess
    case microphonePermission
    case cameraPermission
    case notificationPermission

    var title: String {
        get {
            switch self {
            case .allowAccess: return "kInitialPermissionSettingsVCTitle".localiz()
            case .microphonePermission: return "kInitialPermissionSettingsVCMicrophoneLabel".localiz()
            case .cameraPermission: return "kInitialPermissionSettingsVCCameraLabel".localiz()
            case .notificationPermission: return "kInitialPermissionSettingsVCNotificationLabel".localiz()
            }
        }
    }

    var height: CGFloat {
        get {
            switch self {
            case .allowAccess: return 130
            case .microphonePermission, .cameraPermission, .notificationPermission: return 80
            }
        }
    }
}

struct PermissionTVCellInfo{
    var cellType: PermissionTVCellType
    var isPermissionGranted: Bool
}

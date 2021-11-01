//
//  CameraHistoryPopUPViewController.swift
//  PockeTalk
//

import UIKit

public struct CropUtils {

    var isEnabled: Bool
    var resizeable: Bool
    var dragable: Bool
    var minimumSize: CGSize

    public init(enabled: Bool = false,
                resizeable: Bool = true,
                dragable: Bool = true,
         minimumSize: CGSize = CGSize(width: 80, height: 80)) {

        self.isEnabled = enabled
        self.resizeable = resizeable
        self.dragable = dragable
        self.minimumSize = minimumSize
    }
}

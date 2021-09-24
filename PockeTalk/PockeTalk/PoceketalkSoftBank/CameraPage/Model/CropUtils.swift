//
//  CameraHistoryPopUPViewController.swift
//  PockeTalk
//
//  Created by BJIT LTD on 16/9/21.
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

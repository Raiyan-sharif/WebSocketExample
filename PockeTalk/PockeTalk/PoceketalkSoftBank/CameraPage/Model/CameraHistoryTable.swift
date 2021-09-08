//
//  CameraHistoryTable.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/7/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//

class CameraHistoryTable: BaseModel {
    let id: Int64?
    let detectedData: String?
    let translatedData: String?
    let image: String?

     init(id: Int64?, detectedData: String?, translatedData: String, image: String) {
        self.id = id
        self.detectedData = detectedData
        self.translatedData = translatedData
        self.image = image
        super.init()
    }
}

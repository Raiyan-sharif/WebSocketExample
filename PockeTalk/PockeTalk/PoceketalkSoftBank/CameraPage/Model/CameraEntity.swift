//
//  CameraHistoryTable.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/7/21.

class CameraEntity: BaseEntity {
    let detectedData: String?
    let translatedData: String?
    let image: String?

     init(id: Int64?, detectedData: String?, translatedData: String, image: String) {
        self.detectedData = detectedData
        self.translatedData = translatedData
        self.image = image
        super.init(baseId: id)
    }
}

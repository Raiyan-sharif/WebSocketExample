//
//  LanguageSelectionTable.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/7/21.
//  Copyright © 2021 Piklu Majumder-401. All rights reserved.
//


class LanguageSelectionTable: BaseModel {
    let id: Int64?
    let textLanguageCode: String?
    let cameraOrVoice: Int64?

    init(id: Int64?, textLanguageCode: String?, cameraOrVoice: Int64?) {
        self.id = id
        self.textLanguageCode = textLanguageCode
        self.cameraOrVoice = cameraOrVoice
        super.init()
    }
}

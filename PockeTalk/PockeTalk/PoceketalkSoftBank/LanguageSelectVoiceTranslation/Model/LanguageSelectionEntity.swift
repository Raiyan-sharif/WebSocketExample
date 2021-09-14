//
//  LanguageSelectionTable.swift
//  PockeTalk
//
//  Created by Piklu Majumder-401 on 9/7/21.


class LanguageSelectionEntity: BaseEntity {
    let textLanguageCode: String?
    let cameraOrVoice: Int64?

    init(id: Int64?, textLanguageCode: String?, cameraOrVoice: Int64?) {
        self.textLanguageCode = textLanguageCode
        self.cameraOrVoice = cameraOrVoice
        super.init(baseId: id)
    }
}

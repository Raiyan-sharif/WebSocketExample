//
//  ChatTableModel.swift
//  PockeTalk
//

import Foundation

class ChatEntity: BaseEntity {
    let textNative: String?
    let textTranslated: String?
    let textTranslatedLanguage: String?
    let textNativeLanguage: String?
    let textFileName: String?
    var chatIsLiked: Int64?
    let chatIsTop: Int64?
    let chatIsDelete: Int64?
    let chatIsFavorite: Int64?

    init(id: Int64?, textNative: String?, textTranslated: String?, textTranslatedLanguage: String?, textNativeLanguage: String, textFileName: String? = FileUtility.generateAudioFileName(), chatIsLiked: Int64?, chatIsTop: Int64?, chatIsDelete: Int64?, chatIsFavorite: Int64?) {
        self.textNative = textNative
        self.textTranslated = textTranslated
        self.textTranslatedLanguage = textTranslatedLanguage
        self.textNativeLanguage = textNativeLanguage
        self.textFileName = textFileName
        self.chatIsLiked = chatIsLiked
        self.chatIsTop = chatIsTop
        self.chatIsDelete = chatIsDelete
        self.chatIsFavorite = chatIsFavorite
        super.init(baseId: id)
    }
}

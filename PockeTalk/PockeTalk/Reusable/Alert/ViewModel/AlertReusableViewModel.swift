//
// AlertReusableViewModel.swift
// PockeTalk
//

import UIKit

class AlertReusableViewModel {
    
    func swapLikeValue(_ chatItem: ChatEntity){
        if(chatItem.id == nil){
            chatItem.id = UserDefaultsProperty<Int64>(kLastSavedChatID).value
        }
        let chatDataHelper = ChatDBModel()
        let value = chatItem.chatIsLiked == IsLiked.like.rawValue ? IsLiked.noLike : IsLiked.like
        do{
            try chatDataHelper.updateLikeValue(isliked: value, idToCompare: chatItem.id!)
        } catch {}
    }

}

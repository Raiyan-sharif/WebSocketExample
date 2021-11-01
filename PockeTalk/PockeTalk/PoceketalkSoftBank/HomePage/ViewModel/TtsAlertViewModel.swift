//
// TtsAlertViewModel.swift
// PockeTalk
//

import UIKit

class TtsAlertViewModel: BaseModel {
    var savedDataID : Int64?

        override init() {
            super.init()
        }
    /// this method takes the id of last saved chat and returns respective ChatEntity
    func findLastSavedChat (id : Int64) -> ChatEntity?{
        do {
            let baseEntity = try ChatDBModel.init().find(idToFind: id)
            return baseEntity as? ChatEntity
        } catch _ { return nil}
    }
    
    func saveChatItem(chatItem: ChatEntity)-> Int64{
        do {
            let row = try ChatDBModel.init().insert(item: chatItem)
            UserDefaultsProperty<Int64>(kLastSavedChatID).value = row
            return row
        } catch _ {}
        return -1
    }
    
    func deleteChatItemFromHistory(chatItem: ChatEntity){
        if(chatItem.id == nil){
            chatItem.id = UserDefaultsProperty<Int64>(kLastSavedChatID).value
        }
        do{
            try ChatDBModel().updateDeleteValue(isDelete: IsDeleted.delete, idToCompare: chatItem.id!)
        } catch {}
    }
}

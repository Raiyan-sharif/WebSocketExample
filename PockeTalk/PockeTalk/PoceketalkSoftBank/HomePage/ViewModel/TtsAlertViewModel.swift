//
// TtsAlertViewModel.swift
// PockeTalk
//

import UIKit

class TtsAlertViewModel: BaseModel {
    var savedDataID : Int64?

    /// this method takes the id of last saved chat and returns respective ChatEntity
    func findLastSavedChat (id : Int64) -> ChatEntity?{
        do {
            let baseEntity = try ChatDBModel.init().find(idToFind: id)
            return baseEntity as? ChatEntity
        } catch _ { return nil}
    }
    
    func saveChatItem(chatItem: ChatEntity){
        do {
            _ = try ChatDBModel.init().insert(item: chatItem)
        } catch _ {}
    }
    
}

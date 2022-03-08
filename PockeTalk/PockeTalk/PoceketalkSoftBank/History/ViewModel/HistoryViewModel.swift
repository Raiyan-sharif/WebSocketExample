//
//  HistoryViewModel.swift
//  PockeTalk
//

import Foundation

protocol HistoryViewModeling{
    var items:Bindable<[BaseEntity]>{ get }
    func deleteHistory(_ item:Int)
    func makeFavourite(_ item:Int)
    func addItem(_ chatItem: ChatEntity)
    func removeItem(_ idx: Int)
    func replaceItem(_ chatItem: ChatEntity, _ idx: Int)
    func getData()
}

class HistoryViewModel:BaseModel, HistoryViewModeling {
    var items: Bindable<[BaseEntity]> = Bindable([])
    var chatDataHelper = ChatDBModel()
    override init() {
        do{
            let values =  try chatDataHelper.pickListedItems(isFavorite: false)
            items.value = values ?? []
        } catch {}
    }
    
    func getData() {
        do{
            let values =  try chatDataHelper.pickListedItems(isFavorite: false)
            items.value = values ?? []
        } catch {}
    }

    func deleteHistory(_ item: Int) {
        let item = self.items.value[item]
        if(item.id == nil){
            item.id = UserDefaultsProperty<Int64>(kLastSavedChatID).value
        }
        do{
            try ChatDBModel().updateDeleteValue(isDelete: IsDeleted.delete, idToCompare: item.id!)
            if ChatDBModel().getLikeStatus(id: item.id!) == .noLike {
                if let entity = try ChatDBModel().find(idToFind: item.id!) as? ChatEntity {
                    FileUtility.deleteTtsAudioFile(chatEntity: entity)
                }
            }
        } catch {}
        self.items.value = self.items.value.filter{$0.id != item.id}
    }


    func makeFavourite(_ item:Int){
        if let chatEntity = self.items.value[item] as? ChatEntity{
            do {
                try chatDataHelper.updateLikeValue(isliked: chatEntity.chatIsLiked == IsLiked.noLike.rawValue ? .like : .noLike, idToCompare: chatEntity.id!)
                let isLiked  = chatEntity.chatIsLiked == IsLiked.noLike.rawValue ? IsLiked.like.rawValue : IsLiked.noLike.rawValue
                chatEntity.chatIsLiked = Int64(isLiked)
                PrintUtility.printLog(tag: "FV:", text: "\(String(describing: chatEntity.chatIsLiked))")
                self.items.value[item] = chatEntity

            }catch{
                
            }
        }
    }
    
    func addItem(_ chatItem: ChatEntity){
        self.items.value.append(chatItem)
    }
    func removeItem(_ idx: Int){
        let item = self.items.value[idx]
        if(item.id == nil){
            item.id = UserDefaultsProperty<Int64>(kLastSavedChatID).value
        }
        self.items.value = self.items.value.filter{$0.id != item.id}
    }
    func replaceItem(_ chatItem: ChatEntity, _ idx: Int){
        self.items.value[idx] = chatItem
    }
    
    func saveChatItem(chatItem: ChatEntity)-> Int64{
        do {
            let row = try ChatDBModel.init().insert(item: chatItem)
            UserDefaultsProperty<Int64>(kLastSavedChatID).value = row
            return row
        } catch _ {}
        return -1
    }
}

//
//  HistoryViewModel.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/10/21.
//

import Foundation

protocol HistoryViewModeling{
    var items:Bindable<[BaseEntity]>{ get }
    func deleteHistory(_ item:Int)
    func makeFavourite(_ item:Int)
    func addItem(_ chatItem: ChatEntity)
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

    func deleteHistory(_ item: Int) {
        let item = self.items.value[item]
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
}

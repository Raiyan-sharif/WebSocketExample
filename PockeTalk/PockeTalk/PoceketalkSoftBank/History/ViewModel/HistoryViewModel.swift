//
//  HistoryViewModel.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/10/21.
//

import Foundation

protocol HistoryViewModeling {
    var items:Bindable<[BaseEntity]>{ get }
    func deleteHistory(_ item:Int)
}

class HistoryViewModel:HistoryViewModeling {
    var items: Bindable<[BaseEntity]> = Bindable([])
    var chatDataHelper = ChatTableDBHelper()
    init() {
        do{
            let values =  try chatDataHelper.pickListedItems(isFavorite: false)
            print(values?.count)
            items.value = values ?? []
        } catch {}
    }
    func deleteHistory(_ item: Int) {
        //Todo: need to fix item deletion correctly
        do{
            try chatDataHelper.updateDeleteValue(isDelete: IsDeleted.delete, idToCompare: self.items.value[item].id!)
        } catch {}
        
        self.items.value.remove(at: item)
        
    }
}

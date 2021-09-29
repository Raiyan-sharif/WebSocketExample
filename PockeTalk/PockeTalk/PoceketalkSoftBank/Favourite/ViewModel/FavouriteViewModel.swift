import Foundation

protocol FavouriteViewModeling{
    var items:Bindable<[BaseEntity]>{ get }
    func deleteFavourite(_ item:Int)
}

class FavouriteViewModel:BaseModel, FavouriteViewModeling {
    var items: Bindable<[BaseEntity]> = Bindable([])
    var chatDataHelper = ChatDBModel()
    override init() {
        do{
            let values =  try chatDataHelper.pickListedItems(isFavorite: true)
            items.value = values ?? []
        } catch {}
    }

    func deleteFavourite(_ item: Int) {
        let item = self.items.value[item]
        if(item.id == nil){
            item.id = UserDefaultsProperty<Int64>(kLastSavedChatID).value
        }
        do{
            try chatDataHelper.updateLikeValue(isliked: IsLiked.noLike, idToCompare: item.id!)
            self.items.value = self.items.value.filter{$0.id != item.id}
        } catch {}
    }
}

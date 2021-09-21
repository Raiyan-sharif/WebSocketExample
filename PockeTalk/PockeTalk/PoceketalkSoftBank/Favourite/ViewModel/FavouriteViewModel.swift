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
        if let chatEntity = self.items.value[item] as? ChatEntity{
        do{
            try chatDataHelper.updateLikeValue(isliked: IsLiked.noLike, idToCompare: chatEntity.id!)
            let item = self.items.value[item]
            self.items.value = self.items.value.filter{$0.id != item.id}
        } catch {

        }
    }
}
}

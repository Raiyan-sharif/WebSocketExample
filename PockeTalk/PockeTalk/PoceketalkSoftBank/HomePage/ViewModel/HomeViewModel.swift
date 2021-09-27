//
// HomeViewModel.swift
// PockeTalk
//

import UIKit

protocol HomeViewModeling {
    func getHistoryItemCount()-> Int
    func getLanguageName() -> String?
    func getFavouriteItemCount() -> Int
}

class HomeViewModel: HomeViewModeling {

    var isUpdatedAPI:Bindable<Bool> = Bindable(false)
    //Get Language Name from language code
    func getLanguageName() -> String? {
        let deviceLan = NSLocale.preferredLanguages[0] as String
        let current = Locale.current
        return current.localizedString(forLanguageCode : deviceLan)
    }
    
    
    func getHistoryItemCount() -> Int{
        var historyItemCount = 0
        do{
            historyItemCount =  try ChatDBModel().getRowCount(isFavorite: false)
        } catch{}
        
        return historyItemCount
    }

    func getFavouriteItemCount() -> Int{
        var fvItemCount = 0
        do{
            fvItemCount =  try ChatDBModel().getRowCount(isFavorite: true)
        } catch{}
        PrintUtility.printLog(tag: "context menu", text: "\(fvItemCount)")
        return fvItemCount
    }
}

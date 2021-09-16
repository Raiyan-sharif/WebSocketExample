//
// HomeViewModel.swift
// PockeTalk
//

import UIKit

class HomeViewModel: BaseModel {

    //Get Language Name from language code
    func getLanguageName() -> String? {
        let deviceLan = NSLocale.preferredLanguages[0] as String
        let current = Locale.current
        return current.localizedString(forLanguageCode : deviceLan)
    }
    
    
    func getHistoryItemCount() -> Int{
        var historyItemCount = 0
        do{
            historyItemCount =  try ChatTableDBHelper().getRowCount(isFavorite: false)
        } catch{}
        
        return historyItemCount
    }
}

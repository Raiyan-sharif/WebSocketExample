//
//  HistoryViewModel.swift
//  PockeTalk
//
//  Created by Morshed Alam on 9/10/21.
//

import Foundation

protocol HistoryViewModeling {
    var items:Bindable<[HistoryModel]>{ get }
    func deleteHistory(_ item:Int)
}

class HistoryViewModel:HistoryViewModeling {
    var items: Bindable<[HistoryModel]> = Bindable([])
    
    init() {
        var loclItems = [HistoryModel]()
        // ToDo:
        for _ in 0..<10{
            loclItems.append(HistoryModel(FromLanguage: "আমার বাংলা নিয়ে প্রথম কাজ করবার সুযোগ তৈরি হয়েছিল অভ্র^ নামক এক যুগান্তকারী বাংলা সফ্‌টওয়্যার হাতে পাবার মধ্য দিয়ে।", Tolanguage: "In publishing and graphic design, Lorem ipsum is a placeholder text commonly used to demonstrate the visual form of a document or a typeface without relying on meaningful content."))
        }
        self.items.value = loclItems
    }
    
    func deleteHistory(_ item: Int) {
        self.items.value.remove(at: item)
    }
    
}

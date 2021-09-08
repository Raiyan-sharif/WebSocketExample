//
//  CountryWiseLanguageSelectionViewModel.swift
//  PockeTalk
//
//  Created by Sadikul Bari on 8/9/21.
//

import Foundation
public class CountryWiseLanguageSelectionViewModel{
    public static let shared: CountryWiseLanguageSelectionViewModel = CountryWiseLanguageSelectionViewModel()
    var countryList = [CountryListItemElement]()
    
    init() {
        print("\(CountryWiseLanguageSelectionViewModel.self) init called")
        //loadCountryDataFromJson()
    }
    
//    ///Get data from XML
//    public func loadCountryDataFromJson(){
//        print("\(CountryWiseLanguageSelectionViewModel.self) loadCountryDataFromJson called")
//        let sysLangCode = LanguageManager.shared.currentLanguage.rawValue
//        let mLanguageFile = "\(countryConversationFileNamePrefix)\(sysLangCode)"
//        print("\(LanguageSelectionManager.self) getdata for \(mLanguageFile)")
//        if let url = Bundle.main.url(forResource: mLanguageFile, withExtension: "json") {
//            do {
//                let data = try Data(contentsOf: url)
//                let decoder = JSONDecoder()
//                let jsonData = try decoder.decode(CountryList.self, from: data)
//                countryList = jsonData.countryList
//                print("\(CountryWiseLanguageSelectionViewModel.self) countrylist \(countryList.count) first-item \(countryList.first?.countryName)")
//            } catch {
//                print("error:\(error)")
//            }
//        }
//    }

    ///Get data from XML
    func loadCountryDataFromJsonbyCode(countryCode: String) -> CountryList?{
        print("\(CountryWiseLanguageSelectionViewModel.self) loadCountryDataFromJson called")
        //let sysLangCode = LanguageManager.shared.currentLanguage.rawValue
        let mLanguageFile = "\(countryConversationFileNamePrefix)\(countryCode)"
        print("\(LanguageSelectionManager.self) getdata for \(mLanguageFile)")
        if let url = Bundle.main.url(forResource: mLanguageFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(CountryList.self, from: data) as CountryList
                print("\(CountryWiseLanguageSelectionViewModel.self) countrylist \(jsonData.countryList.count) first-item \(String(describing: jsonData.countryList.first?.countryName))")
                return jsonData
            } catch {
                print("error:\(error)")
                return nil
            }
        }
        return nil
    }
}

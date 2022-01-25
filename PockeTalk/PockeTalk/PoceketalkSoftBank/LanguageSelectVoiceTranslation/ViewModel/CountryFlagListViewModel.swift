//
//  CountryWiseLanguageSelectionViewModel.swift
//  PockeTalk
//

import Foundation
class CountryFlagListViewModel: BaseModel{
    public static let shared: CountryFlagListViewModel = CountryFlagListViewModel()
    var countryList = [CountryListItemElement]()

    override init() {
        PrintUtility.printLog(tag: "\(CountryFlagListViewModel.self)", text: "init called")
    }

    func loadCountryDataFromJsonbyCode(countryCode: String) -> CountryList?{
        let convertedCountryCode = GlobalMethod.getAlternativeSystemLanguageCode(of: countryCode)
        let mLanguageFile = "\(countryConversationFileNamePrefix)\(convertedCountryCode)"
        
        if let url = Bundle.main.url(forResource: mLanguageFile, withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let jsonData = try decoder.decode(CountryList.self, from: data) as CountryList
                PrintUtility.printLog(tag: "\(CountryFlagListViewModel.self)", text: "\(CountryFlagListViewModel.self) countrylist \(jsonData.countryList.count) first-item \(String(describing: jsonData.countryList.first?.countryName))")
                return jsonData
            } catch {
                PrintUtility.printLog(tag: "\(CountryFlagListViewModel.self)", text: "error:\(error)")
                return nil
            }
        }
        return nil
    }
}

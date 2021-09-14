
import Foundation

enum ResetItemType: String, CaseIterable {
    case clearTranslationHistory = "Clear translation history"
    case deleteCameraHistory = "Delete the Camera translation history"
    case clearFavourite = "Clear all Favorite"
    case deleteAllData = "Delete all the data"
    static var resetItems: [String] {
        return ResetItemType.allCases.map { $0.rawValue }
      }
}

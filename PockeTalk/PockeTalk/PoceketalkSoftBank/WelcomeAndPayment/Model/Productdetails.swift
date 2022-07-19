//
//  ProductDetails.swift
//  PockeTalk
//

import Foundation
import StoreKit

struct ProductDetails{
    let product: SKProduct
    let currency: String
    let price: Double
    let periodUnitType: PeriodUnitType
    let planPerUnitText: String
    let freeUsesDetailsText: String?
    var suggestionText: String?
    let isAppStoreJapan: Bool
}

enum PeriodUnitType: String{
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
}

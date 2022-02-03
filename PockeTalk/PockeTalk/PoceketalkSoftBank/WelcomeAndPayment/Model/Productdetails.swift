//
//  Productdetails.swift
//  PockeTalk
//

import Foundation
import StoreKit

struct ProductDetails{
    let product: SKProduct
    let periodUnitType: PeriodUnitType
    let planPerUnitText: String
    let freeUsesDetailsText: String?
    let freeUsesDetailsTextInSingleLine: String?
}

enum PeriodUnitType: String{
    case day = "day"
    case week = "week"
    case month = "month"
    case year = "year"
}

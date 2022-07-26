//
//  PurchasePlanViewModel.swift
//  PockeTalk
//

import Foundation
import StoreKit
import SwiftKeychainWrapper

protocol PurchasePlanViewModeling {
    typealias CompletionCallBack = (_ success: Bool, _ error: String?) -> Void
    var numberOfRow: Int { get }
    var rowType: [PurchasePlanTVCellInfo] { get }
    var hasInAppPurchaseProduct: Bool { get }
    var productFetchError: String? { get }
    var isAPICallOngoing: Bool { get }
    var isProductFetchOngoing: Bool { get }
    func getProduct(onCompletion: @escaping CompletionCallBack)
    func restorePurchase(onCompletion: @escaping CompletionCallBack)
    func purchaseProduct(product: SKProduct, onCompletion: @escaping CompletionCallBack)
    func getProductDetailsData(using cellType: PurchasePlanTVCellInfo) -> ProductDetails?
    func getFreeDaysUsesInfo() -> String?
    func updateReceiptValidationAllow()
    func updateIsAPICallOngoing(_ status: Bool)
    func setProductFetchStatus(_ status: Bool)
    func setFreeTrialStatus(_ status: Bool)
}

class PurchasePlanViewModel: PurchasePlanViewModeling {
    private var products = [SKProduct]()
    private var productDetails = [ProductDetails]()
    private var row = [PurchasePlanTVCellInfo]()

    private let dummyRow: [PurchasePlanTVCellInfo] = [.selectPlan, .weeklyPlan, .monthlyPlan, .annualPlan, .restorePurchase]
    private var _isAPICallOngoing: Bool = false
    private var _hasInAppPurchaseProduct = false
    private var _productFetchError: String?
    private var _isProductFetchOngoing: Bool = false
    private var _isFreeTrialAvailable = false

    var numberOfRow: Int {
        return row.count
    }

    var rowType: [PurchasePlanTVCellInfo] {
        return self.row
    }

    var hasInAppPurchaseProduct: Bool {
        return _hasInAppPurchaseProduct
    }

    var isAPICallOngoing: Bool {
        return _isAPICallOngoing
    }

    var productFetchError: String? {
        return _productFetchError
    }

    var isProductFetchOngoing: Bool {
        return _isProductFetchOngoing
    }
    
    var isFreeTrialAvailable: Bool{
        return _isFreeTrialAvailable
    }

    //MARK: - API Calls
    func getProduct(onCompletion: @escaping CompletionCallBack) {
        _hasInAppPurchaseProduct = false
        IAPManager.shared.getProducts { [weak self] (result) in
            guard let self = `self` else {return}
            switch result {
            case .success(let products):
                if products.count > 0 {
                    self.resetData()
                    self.products = products
                    self.setProductDetails()
                    self.setupTVRowData()
                    self._hasInAppPurchaseProduct = true
                    onCompletion(true, nil)
                } else {
                    self._hasInAppPurchaseProduct = true
                    onCompletion(false, "Can't found products")
                }
            case .failure(let error):
                PrintUtility.printLog(tag: "IAP", text: "\(error.localizedDescription)")
                self._productFetchError = error.localizedDescription
                onCompletion(false, error.localizedDescription)
            }
        }
    }

    func restorePurchase(onCompletion: @escaping CompletionCallBack) {
        self._isAPICallOngoing = true
        IAPManager.shared.restorePurchases { [weak self] (result) in
            guard let self = `self` else {return}
            switch result {
            case .success(let success):
                self._isAPICallOngoing = false
                onCompletion(success, nil)
            case .failure(let error):
                PrintUtility.printLog(tag: "IAP", text: "\(error.localizedDescription)")
                self._isAPICallOngoing = false
                onCompletion(false, error.localizedDescription)
            }
        }
    }

    func purchaseProduct(product: SKProduct, onCompletion: @escaping CompletionCallBack) {
        self._isAPICallOngoing = true
        IAPManager.shared.purchaseProduct(product: product) { [weak self] result in
            guard let self = `self` else {return}
            switch result {
            case .success(let isPurchasedActive):
                self._isAPICallOngoing = false
                onCompletion(isPurchasedActive, nil)
            case .failure(let error):
                self._isAPICallOngoing = false
                onCompletion(false, error.localizedDescription)
            }
        }
    }

    //MARK: - Settable methods
    private func setProductDetails() {
        for product in self.products {
            let productDetail = IAPManager.shared.getProductDetails(from: product)
            self.productDetails.append(productDetail)
        }
        setSuggestionTextAndSortProduct()
    }

    private func setSuggestionTextAndSortProduct() {
        //Sort product details depend on price
        productDetails = productDetails.sorted { $0.price < $1.price}

        //Get weekly item price
        let weeklyPrice = (productDetails.filter { $0.periodUnitType == .week
        }).first?.price ?? 0.0

        //Set suggestion text
        for item in 0..<productDetails.count {
            if productDetails[item].periodUnitType == .month {
                let savingPrice = calculateSavings(
                    weeklyPrice: weeklyPrice,
                    productPrice: productDetails[item].price,
                    numberOfWeek: 4)

                productDetails[item].suggestionText = getProductDetailSuggestionText(
                    isAppStoreJapan: productDetails[item].isAppStoreJapan,
                    currency: productDetails[item].currency,
                    savingPrice: savingPrice)
            }

            if productDetails[item].periodUnitType == .year {
                let savingPrice = calculateSavings(
                    weeklyPrice: weeklyPrice,
                    productPrice: productDetails[item].price,
                    numberOfWeek: 52)

                productDetails[item].suggestionText = getProductDetailSuggestionText(
                    isAppStoreJapan: productDetails[item].isAppStoreJapan,
                    currency: productDetails[item].currency,
                    savingPrice: savingPrice)
            }
        }
    }

    private func getProductDetailSuggestionText(isAppStoreJapan: Bool, currency: String, savingPrice: Int) -> String {
        let savingPriceWithCurrency = isAppStoreJapan ? ("\(currency) \(Int(savingPrice))") : ("\(currency) \(savingPrice)")

        return "upToOff".localiz().replacingOccurrences(of: "xx", with: "\(savingPriceWithCurrency)")
    }

    private func calculateSavings(weeklyPrice: Double, productPrice: Double, numberOfWeek: Int) -> Int {
        //let doubleSavingPrice = ((weeklyPrice * Double(numberOfWeek)) - productPrice).roundToDecimal(2)
        let savingPrice = Int((weeklyPrice * Double(numberOfWeek)) - productPrice)
        let digitCount = String(savingPrice).count
        let mod = digitCount > 3 ? 100 : 10
        let nearestFloorSavingPrice = savingPrice - (savingPrice % mod)

        if !IAPManager.shared.iSAppStoreRegionJapan() {
            return savingPrice
        } else {
            return nearestFloorSavingPrice
        }
    }

    private func setupTVRowData() {
        row.append(.selectPlan)

        var isFreeOfferAvailable = false
        for item in productDetails {
            if item.freeUsesDetailsText != nil {
                isFreeOfferAvailable = true
            }
        }

        if isFreeOfferAvailable && IAPManager.shared.iSAppStoreRegionJapan() == true {
            row.append(.freeUses)
        }
        
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "Free Trail availibility: \(_isFreeTrialAvailable) , Region Japan? : \(IAPManager.shared.iSAppStoreRegionJapan())")

        if _isFreeTrialAvailable && IAPManager.shared.iSAppStoreRegionJapan() == false {
            row.append(.threeDaysTrial)
        }

        for item in productDetails {
            if item.periodUnitType == .day {
                row.append(.dailyPlan)
            } else if item.periodUnitType == .week {
                row.append(.weeklyPlan)
            } else if item.periodUnitType == .month {
                row.append(.monthlyPlan)
            } else if item.periodUnitType == .year {
                row.append(.annualPlan)
            }
        }

        row.append(.restorePurchase)
    }

    //MARK: - Getable methods
    func getProductDetailsData(using cellType: PurchasePlanTVCellInfo) -> ProductDetails? {
        for product in self.productDetails{
            if cellType.unitType == product.periodUnitType.rawValue{
                return product
            }
        }
        return nil
    }

    func getFreeDaysUsesInfo() -> String? {
        let cellType: PurchasePlanTVCellInfo = .monthlyPlan

        for product in self.productDetails {
            if cellType.unitType == product.periodUnitType.rawValue{
                return product.freeUsesDetailsText ?? ""
            }
        }
        return nil
    }

    //MARK: - Utils
    private func resetData() {
        row.removeAll()
        products.removeAll()
        productDetails.removeAll()
    }

    func updateReceiptValidationAllow() {
        KeychainWrapper.standard.set(true, forKey: receiptValidationAllow)
        KeychainWrapper.standard.set(true, forKey: receiptValidationAllowFromPurchase)
    }

    func updateIsAPICallOngoing(_ status: Bool) {
        self._isAPICallOngoing = status
    }

    func setProductFetchStatus(_ status: Bool) {
        self._isProductFetchOngoing = status
    }
    
    func setFreeTrialStatus(_ status: Bool) {
        self._isFreeTrialAvailable = status
    }
}

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
    func updateReceiptValidationAllow(iapReceiptValidationFrom: IAPReceiptValidationFrom)
    func updateIsAPICallOngoing(_ status: Bool)
    func setProductFetchStatus(_ status: Bool)
    func getSelectedPlanType() -> String?
    func setSelectedPlanType(planType: PurchasePlanTVCellInfo)
}

enum PurchasePlan: String {
    case week = "week"
    case month = "month"
    case year = "year"
    case none = "none"
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
    private var selectedPlanType: PurchasePlanTVCellInfo?

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
                    productPrice: (productDetails[item].price).roundToDecimal(2),
                    numberOfWeek: 4)

                productDetails[item].suggestionText = "kSaveAbout".localiz() + "kYen".localiz().replacingOccurrences(of: "XX", with: "\(savingPrice)")
            }

            if productDetails[item].periodUnitType == .year {
                let savingPrice = calculateSavings(
                    weeklyPrice: weeklyPrice,
                    productPrice: (productDetails[item].price).roundToDecimal(2),
                    numberOfWeek: 52)

                productDetails[item].suggestionText = "kSaveAbout".localiz() + "kYen".localiz().replacingOccurrences(of: "XX", with: "\(savingPrice)")
            }
        }
    }

    private func calculateSavings(weeklyPrice: Double, productPrice: Double, numberOfWeek: Int) -> Int {
        let savingPrice = Int((weeklyPrice * Double(numberOfWeek)) - productPrice)
        let digitCount = String(savingPrice).count
        let mod = digitCount > 3 ? 100 : 10
        let nearestFloorSavingPrice = savingPrice - (savingPrice % mod)
        return nearestFloorSavingPrice
    }

    private func setupTVRowData() {
        row.append(.selectPlan)

        var isFreeOfferAvailable = false
        for item in productDetails {
            if item.freeUsesDetailsText != nil {
                isFreeOfferAvailable = true
            }
        }

        if isFreeOfferAvailable {
            row.append(.freeUses)
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

    func setSelectedPlanType(planType: PurchasePlanTVCellInfo) {
        selectedPlanType = planType
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

    func getSelectedPlanType() -> String? {
        var planTypeText: String?

        if let planType = self.selectedPlanType {
            if planType == .weeklyPlan {
                planTypeText = PurchasePlan.week.rawValue
            } else if planType == .monthlyPlan {
                planTypeText = PurchasePlan.month.rawValue
            } else if planType == .annualPlan {
                planTypeText = PurchasePlan.year.rawValue
            }
        }
        return planTypeText
    }

    //MARK: - Utils
    private func resetData() {
        row.removeAll()
        products.removeAll()
        productDetails.removeAll()
    }

    func updateReceiptValidationAllow(iapReceiptValidationFrom: IAPReceiptValidationFrom) {
        KeychainWrapper.standard.set(true, forKey: receiptValidationAllow)
        KeychainWrapper.standard.set(true, forKey: receiptValidationAllowFromPurchase)
        IAPManager.shared.iapReceiptValidationForm = iapReceiptValidationFrom
    }

    func updateIsAPICallOngoing(_ status: Bool) {
        self._isAPICallOngoing = status
    }

    func setProductFetchStatus(_ status: Bool) {
        self._isProductFetchOngoing = status
    }
}

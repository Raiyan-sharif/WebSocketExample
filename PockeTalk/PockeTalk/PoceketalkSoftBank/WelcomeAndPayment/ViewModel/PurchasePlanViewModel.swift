//
//  PurchasePlanViewModel.swift
//  PockeTalk
//

import Foundation
import StoreKit
import SwiftKeychainWrapper

class PurchasePlanViewModel{
    private var products = [SKProduct]()
    private var productDetails = [ProductDetails]()
    private var row = [PurchasePlanTVCellInfo]()
    typealias CompletionCallBack = (_ success: Bool, _ error: String?) -> Void
    let dummyRow: [PurchasePlanTVCellInfo] = [.selectPlan, .weeklyPlan, .monthlyPlan, .annualPlan, .restorePurchase]
    var isDataLoading = true

    var numbeOfRow: Int {
        if isDataLoading {
            return dummyRow.count
        } else {
            return row.count
        }
    }

    var rowType: [PurchasePlanTVCellInfo]{
        if isDataLoading {
            return self.dummyRow
        } else {
            return self.row
        }
    }

    //MARK: - API Calls
    func getProduct(onCompletion: @escaping CompletionCallBack) {
        IAPManager.shared.getProducts { [weak self] (result) in
            guard let self = `self` else {return}
            self.isDataLoading = true
            switch result {
            case .success(let products):
                if products.count > 0 {
                    self.resetData()
                    self.products = products
                    self.setProductDetails()
                    self.setupTVRowData()
                    onCompletion(true, nil)
                } else {
                    onCompletion(false, "Can't found products")
                }
                self.isDataLoading = false
            case .failure(let error):
                PrintUtility.printLog(tag: "IAP", text: "\(error.localizedDescription)")
                onCompletion(false, error.localizedDescription)
                self.isDataLoading = false
            }
        }
    }

    func restorePurchase(onCompletion: @escaping CompletionCallBack){
        IAPManager.shared.restorePurchases { (result) in
            switch result {
            case .success(let success):
                onCompletion(success, nil)
            case .failure(let error):
                PrintUtility.printLog(tag: "IAP", text: "\(error.localizedDescription)")
                onCompletion(false, error.localizedDescription)
            }
        }
    }

    func purchaseProduct(product: SKProduct, onCompletion: @escaping CompletionCallBack){
        IAPManager.shared.purchaseProduct(product: product) { [weak self] result in
            guard let _ = `self` else {return}
            switch result {
            case .success(let isPurchasedActive):
                onCompletion(isPurchasedActive, nil)
            case .failure(let error):
                onCompletion(false, error.localizedDescription)
            }
        }
    }

    //MARK: - Setable methods
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
                productDetails[item].suggestionText = "Save about ".localiz() + productDetails[item].currency + "\(((weeklyPrice * 4) - productDetails[item].price).roundToDecimal(2)) " + "from weekly".localiz()
            }

            if productDetails[item].periodUnitType == .year {
                productDetails[item].suggestionText = "Save about ".localiz() + productDetails[item].currency + "\(((weeklyPrice * 52) - productDetails[item].price).roundToDecimal(2)) " + "from weekly".localiz()
            }
        }
    }

    private func setupTVRowData(){
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

    //MARK: - Getable methods
    func getProductDetailsData(using cellType: PurchasePlanTVCellInfo) -> ProductDetails? {
        for product in self.productDetails{
            if cellType.unitType == product.periodUnitType.rawValue{
                return product
            }
        }
        return nil
    }

    func getFreeDaysUsesInfo(using cellType: PurchasePlanTVCellInfo = .monthlyPlan) -> String? {
        for product in self.productDetails{
            if cellType.unitType == product.periodUnitType.rawValue{
                return product.freeUsesDetailsText ?? ""
            }
        }
        return nil
    }

    //MARK: - Utils
    private func resetData(){
        row.removeAll()
        products.removeAll()
        productDetails.removeAll()
    }

    func updateReceiptValidationAllow() {
        KeychainWrapper.standard.set(true, forKey: receiptValidationAllow)
    }
}

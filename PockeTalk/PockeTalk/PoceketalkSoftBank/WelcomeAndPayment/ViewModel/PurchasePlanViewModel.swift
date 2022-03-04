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
    private let dummyTVRow: [PurchasePlanTVCellInfo] = [.selectPlan, .dailyPlan, .weeklyPlan, .annualPlan, .cancle, .restorePurchase]
    private var isDataLoading = true

    var numbeOfRow: Int {
        if isDataLoading {
            return dummyTVRow.count
        } else {
            return row.count
        }
    }

    var rowType: [PurchasePlanTVCellInfo]{
        if isDataLoading {
            return dummyTVRow
        } else {
            return self.row
        }
    }

    func updateReceiptValidationAllow() {
        KeychainWrapper.standard.set(true, forKey: receiptValidationAllow)
    }

    private func resetData(){
        row.removeAll()
        products.removeAll()
        productDetails.removeAll()
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

    func getProduct(onCompletion: @escaping CompletionCallBack) {
        isDataLoading = true
        IAPManager.shared.getProducts { [weak self] (result) in
            guard let self = `self` else {return}
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

    func getProductDetailsData(using cellType: PurchasePlanTVCellInfo) -> ProductDetails? {
        for product in self.productDetails{
            if cellType.unitType == product.periodUnitType.rawValue{
                return product
            }
        }
        return nil
    }

    func getProductDetails(using cellType: PurchasePlanTVCellInfo) -> ProductDetails? {
        for product in self.productDetails{
            if cellType.unitType == product.periodUnitType.rawValue{
                return product
            }
        }
        return nil
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

    private func setProductDetails(){
        for product in self.products{
            let productDetail = IAPManager.shared.getProductDetails(from: product)
            self.productDetails.append(productDetail)
        }
    }

    private func setupTVRowData(){
        row.append(.selectPlan)

        for item in productDetails{
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

        row.append(.cancle)
        row.append(.restorePurchase)
    }
}

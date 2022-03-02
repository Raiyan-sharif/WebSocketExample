//
//  IAPManager.swift
//  PockeTalk
//
//  Created by BJIT on 3/2/22.
//

import Foundation
import StoreKit
import Kronos

enum IAPReceiptValidationFrom: String {
    case purchaseButton = "purchaseButton"
    case restoreButton = "restoreButton"
    case didFinishLaunchingWithOptions = "didFinishLaunchingWithOptions"
    case applicationWillEnterForeground = "applicationWillEnterForeground"
    case none = "none"
}

class IAPManager: NSObject {
    private let TAG: String = "IAPTAG"
    static let shared = IAPManager()
    private override init() { super.init() }

    struct LatestReceiptInfo {
        var productId: String?
        var expiresDate: Date? = nil
        var isInIntroOffer_period: Bool?
        var isTrialPeriod: Bool?
        var cancellationDate: Date? = nil
    }

    var receiptValidationAllow: Bool = false
    var onReceiveProductsHandler: ((Result<[SKProduct], IAPManagerError>) -> Void)?
    var onBuyProductHandler: ((Result<Bool, Error>) -> Void)?
    var totalRestoredPurchases = 0
    var isIntroductoryOfferActive: Bool?
    var IAPTimeoutInterval: Double = kIAPTimeoutInterval
    var activityIndicator = UIActivityIndicatorView(style: .whiteLarge)

    // MARK: - Custom Types
    enum IAPManagerError: Error {
        case noProductIDsFound
        case noProductsFound
        case paymentWasCancelled
        case productRequestFailed
    }
    
    // MARK: - General Methods
    fileprivate func getProductIDs() -> [String]? {
        guard let url = Bundle.main.url(forResource: IAP_ProductIDs, withExtension: "plist") else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let productIDs = try PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String] ?? []
            return productIDs
        } catch {
            PrintUtility.printLog(tag: String(describing: type(of: self)), text: error.localizedDescription)

            return nil
        }
    }
    
    // MARK: - Get IAP Products
    // (This will trigger `func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)`)
    func getProducts(withHandler productsReceiveHandler: @escaping (_ result: Result<[SKProduct], IAPManagerError>) -> Void) {
        // Keep the handler (closure) that will be called when requesting for
        // products on the App Store is finished.
        onReceiveProductsHandler = productsReceiveHandler

        // Get the product identifiers.
        guard let productIDs = getProductIDs() else {
            productsReceiveHandler(.failure(.noProductIDsFound))
            return
        }

        // Initialize a product request.
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        // Set self as the its delegate.
        request.delegate = self
        // Make the request.
        request.start()
    }
    
    func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }

    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }
    
    // MARK: - Purchase Products
    func purchaseProduct(product: SKProduct, withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        // Keep the completion handler.
        onBuyProductHandler = handler
    }
    
    // MARK: - Restore Products
    func restorePurchases(withHandler handler: @escaping ((_ result: Result<Bool, Error>) -> Void)) {
        onBuyProductHandler = handler
        totalRestoredPurchases = 0
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        // Get the available products contained in the response.
        let products = response.products

        // Check if there are any products available.
        if products.count > 0 {
            // Call the following handler passing the received products.
            onReceiveProductsHandler?(.success(products))
        } else {
            // No products were found.
            onReceiveProductsHandler?(.failure(.noProductsFound))
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        onReceiveProductsHandler?(.failure(.productRequestFailed))
    }
    
    func requestDidFinish(_ request: SKRequest) {
        // Implement this method OPTIONALLY and add any custom logic
        // you want to apply when a product request is finished.
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    //This delegate will trigger for every transactions, either for purchasing or restoring
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { (transaction) in
            switch transaction.transactionState {
            case .purchased:
                self.IAPResponseCheck(iapReceiptValidationFrom: .purchaseButton)
                self.receiptValidationAllow = false
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .restored:
                totalRestoredPurchases += 1
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .failed:
                if let error = transaction.error as? SKError {
                    if error.code != .paymentCancelled {
                        onBuyProductHandler?(.failure(error))
                    } else {
                        onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
                    }
                    PrintUtility.printLog(tag: String(describing: type(of: self)), text: "IAPError: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
                
            case .deferred, .purchasing: break
            @unknown default: break
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if totalRestoredPurchases != 0 {
            self.IAPResponseCheck(iapReceiptValidationFrom: .restoreButton)
            self.receiptValidationAllow = false
        } else {
            PrintUtility.printLog(tag: String(describing: type(of: self)), text: "IAP: No purchases to restore!")
            onBuyProductHandler?(.success(false))
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError {
            if error.code != .paymentCancelled {
                PrintUtility.printLog(tag: String(describing: type(of: self)), text: "IAP Restore Error: \(error.localizedDescription)")
                onBuyProductHandler?(.failure(error))
            } else {
                onBuyProductHandler?(.failure(IAPManagerError.paymentWasCancelled))
            }
        }
    }
}

// MARK: - IAPManagerError Localized Error Descriptions
extension IAPManager.IAPManagerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .noProductIDsFound: return "kIAPNoProductIDsFound".localiz()
        case .noProductsFound: return "kIAPNoProductsFound".localiz()
        case .productRequestFailed: return "kIAPProductRequestFailed".localiz()
        case .paymentWasCancelled: return "kIAPPaymentWasCancelled".localiz()
        }
    }
}

// MARK: - IAPManager Prepare alert cell
extension IAPManager {
    func getFormattedCurrency(product: SKProduct) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        let formattedString = numberFormatter.string(from: product.price)
        
        return formattedString!
    }
    
    func getSubscriptionDurationPeriod(product: SKProduct) -> String {
        let numberOfUnits = product.subscriptionPeriod?.numberOfUnits
        let unitValue = product.subscriptionPeriod?.unit
        var durationUnitType = ""
        
        if unitValue?.rawValue == SKProduct.PeriodUnit.day.rawValue {
            durationUnitType = numberOfUnits! == 1 ? "Day".localiz() : "Days".localiz()
        } else if unitValue?.rawValue == SKProduct.PeriodUnit.week.rawValue {
            durationUnitType = numberOfUnits! == 1 ? "Week".localiz() : "Weeks".localiz()
        } else if unitValue?.rawValue == SKProduct.PeriodUnit.month.rawValue {
            durationUnitType = numberOfUnits! == 1 ? "Month".localiz() : "Months".localiz()
        } else if unitValue?.rawValue == SKProduct.PeriodUnit.year.rawValue {
            durationUnitType = numberOfUnits! == 1 ? "Year".localiz() : "Years".localiz()
        }
        
        return "\(String(describing: numberOfUnits!)) \(durationUnitType)"
    }
    
    private func unitName(unitRawValue: UInt, numberOfUnits: Int) -> String {
        switch unitRawValue {
        case 0: return numberOfUnits == 1 ? "day".localiz() : "days".localiz()
        case 1: return numberOfUnits == 1 ? "week".localiz() : "weeks".localiz()
        case 2: return numberOfUnits == 1 ? "month".localiz() : "months".localiz()
        case 3: return numberOfUnits == 1 ? "year".localiz() : "years".localiz()
        default: return ""
        }
    }
    
    func alertCellSetUp(product: SKProduct) -> String {
        let currency = getFormattedCurrency(product: product)
        let duration = getSubscriptionDurationPeriod(product: product)
        let slashText = " / "
        let newLineText = "\n"
        var finalText: String = ""
        
        if let period = product.introductoryPrice?.subscriptionPeriod {
            let freeTrialDuration = "\(period.numberOfUnits) \(unitName(unitRawValue: period.unit.rawValue, numberOfUnits: period.numberOfUnits)) \("kfreeUse".localiz())"
            if let isIntroductoryOfferActive = isIntroductoryOfferActive {
                if isIntroductoryOfferActive == false {
                    finalText = "\(currency)\(slashText)\(duration)"
                } else {
                    finalText = "\(currency)\(slashText)\(duration)\(newLineText)\(freeTrialDuration)"
                }
            } else {
                finalText = "\(currency)\(slashText)\(duration)\(newLineText)\(freeTrialDuration)"
            }
        }
        return finalText
    }

    private func getPeriodUnitType(product: SKProduct) -> PeriodUnitType {
        let numberOfUnits = product.subscriptionPeriod?.numberOfUnits
        let unitValue = product.subscriptionPeriod?.unit

        if unitValue?.rawValue == SKProduct.PeriodUnit.day.rawValue {
            if numberOfUnits == 7 {
                return PeriodUnitType.week
            }
            return PeriodUnitType.day

        } else if unitValue?.rawValue == SKProduct.PeriodUnit.week.rawValue {
            return PeriodUnitType.week
        } else if unitValue?.rawValue == SKProduct.PeriodUnit.month.rawValue {
            return PeriodUnitType.month
        }

        return PeriodUnitType.year
    }

    private func getFreeUsesInfo(product: SKProduct) -> (isFreeTrialAvailable: Bool, freeTrialDuration: Int, freeTrialStringType: String){
        var isFreeTrialAvailable = false
        var freeTrialDuration = 0
        var freeTrialStringType = ""

        if let period = product.introductoryPrice?.subscriptionPeriod {
            freeTrialDuration = period.numberOfUnits
            freeTrialStringType = unitName(unitRawValue: period.unit.rawValue, numberOfUnits: period.numberOfUnits)

            if let isIntroductoryOfferActive = isIntroductoryOfferActive {
                isIntroductoryOfferActive ? (isFreeTrialAvailable = true) : (isFreeTrialAvailable = false)
            } else {
                isFreeTrialAvailable = true
            }
        }
        return (isFreeTrialAvailable, freeTrialDuration, freeTrialStringType)
    }

    func getProductDetails(from product: SKProduct) -> ProductDetails {
        let currency = getFormattedCurrency(product: product)
        let _ = product.subscriptionPeriod?.numberOfUnits ?? 0
        let unitType = getPeriodUnitType(product: product)
        let freeUsesInfo = getFreeUsesInfo(product: product)

        let planPerUnitText = "\(currency) / \(unitType.rawValue.localiz())."
        var freeUsesDetailsText: String?
        var freeUsesDetailsTextInSingleLine: String?

        if freeUsesInfo.isFreeTrialAvailable {
            freeUsesDetailsText = "\("Free for".localiz()) \n \(freeUsesInfo.freeTrialDuration) \("days".localiz())"
            freeUsesDetailsTextInSingleLine = "\("Free for".localiz()) \(freeUsesInfo.freeTrialDuration) \("days".localiz())"

        } else {
            freeUsesDetailsText = nil
            freeUsesDetailsTextInSingleLine = nil
        }

        return (
            ProductDetails(
                product: product,
                periodUnitType: unitType,
                planPerUnitText: planPerUnitText,
                freeUsesDetailsText: freeUsesDetailsText,
                freeUsesDetailsTextInSingleLine: freeUsesDetailsTextInSingleLine
            )
        )
    }
}

//MARK: - IAPManager Prepare alert cell
extension IAPManager {
    func IAPResponseCheck(iapReceiptValidationFrom: IAPReceiptValidationFrom) {
        if receiptValidationAllow == true {
            if iapReceiptValidationFrom == .purchaseButton || iapReceiptValidationFrom == .restoreButton {
                receiptValidation(iapReceiptValidationFrom: iapReceiptValidationFrom) { isPurchaseSchemeActive, error in
                    if let err = error {
                        self.onBuyProductHandler?(.failure(err))
                    } else {
                        self.onBuyProductHandler?(.success(isPurchaseSchemeActive))
                    }
                    self.hideActivityIndicator()
                }
            } else if iapReceiptValidationFrom == .didFinishLaunchingWithOptions {
                if Reachability.isConnectedToNetwork() {
                    receiptValidation(iapReceiptValidationFrom: iapReceiptValidationFrom) { isPurchaseSchemeActive, error in
                        if let err = error {
                            self.showAlertFromAppDelegates(error: err)
                        } else {
                            if isPurchaseSchemeActive == true {
                                if UserDefaultsUtility.getBoolValue(forKey: kIsClearedDataAll) == true {
                                    DispatchQueue.main.async {
                                        GlobalMethod.appdelegate().navigateToTermsAndConditionsViewController()
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        GlobalMethod.appdelegate().navigateToHomeViewController()
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    GlobalMethod.appdelegate().navigateToTermsAndConditionsViewController()
                                }
                            }
                        }
                        self.hideActivityIndicator()
                        self.receiptValidationAllow = false
                    }
                } else {
                    self.showNoInternetAlertOnVisibleViewController()
                }
            }  else if iapReceiptValidationFrom == .applicationWillEnterForeground {
                if Reachability.isConnectedToNetwork() {
                    receiptValidation(iapReceiptValidationFrom: iapReceiptValidationFrom) { isPurchaseSchemeActive, error in
                        if let err = error {
                            self.showAlertFromAppDelegates(error: err)
                        } else {
                            if isPurchaseSchemeActive == false {
                                if UserDefaultsUtility.getBoolValue(forKey: isTermAndConditionTap) == false {
                                    GlobalMethod.appdelegate().navigateToPaidPlanViewController()
                                    UserDefaultsUtility.setBoolValue(false, forKey: isTermAndConditionTap)
                                }
                            }
                        }
                        self.receiptValidationAllow = false
                    }
                } else {
                    self.showNoInternetAlertOnVisibleViewController()
                }
            }
        }
    }

    func receiptValidation(iapReceiptValidationFrom: IAPReceiptValidationFrom, completion: @escaping(_ isPurchaseSchemeActive: Bool, _ error: Error?) -> ()) {
        let receiptFileURL = Bundle.main.appStoreReceiptURL
        guard let receiptData = try? Data(contentsOf: receiptFileURL!) else {
            //This is the First launch app VC pointer call
            completion(false, nil)
            return
        }
        let recieptString = receiptData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        let jsonDict: [String: AnyObject] = [IAPreceiptData : recieptString as AnyObject, IAPPassword : appSpecificSharedSecret as AnyObject]
        
        do {
            let requestData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
            let storeURL = URL(string: verifyReceiptURL)!
            var storeRequest = URLRequest(url: storeURL)
            storeRequest.httpMethod = "POST"
            storeRequest.httpBody = requestData
            storeRequest.timeoutInterval = IAPTimeoutInterval
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: storeRequest, completionHandler: { [weak self] (data, response, error) in
                do {
                    if let error = error {
                        if (error as? URLError)?.code == .timedOut {
                            if iapReceiptValidationFrom == .applicationWillEnterForeground {
                                self?.IAPResponseCheck(iapReceiptValidationFrom: iapReceiptValidationFrom)
                            } else {
                                self?.showAlertForRetryIAP(iapReceiptValidationFrom: iapReceiptValidationFrom)
                            }
                        }
                    } else {
                        if let data = data, let jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
                            if let latestInfoReceiptObjects = self?.getLatestInfoReceiptObjects(jsonResponse: jsonResponse) {
                                Clock.sync(completion:  { date, offset in
                                    if let getResDate = date {
                                        let purchaseStatus = self?.isPurchaseActive(currentDateFromServer: getResDate, latestReceiptInfoArray: latestInfoReceiptObjects)
                                        completion(purchaseStatus!, nil)
                                    }
                                })
                            }
                        }
                    }
                } catch let parseError {
                    completion(false, parseError)
                }
            })
            task.resume()
        } catch let parseError {
            completion(false, parseError)
        }
    }

    func getLatestInfoReceiptObjects(jsonResponse: NSDictionary) -> [LatestReceiptInfo]? {
        if let receiptInfo: NSArray = jsonResponse[latest_receipt_info] as? NSArray {
            let formatter = DateFormatter()
            formatter.dateFormat = IAPDateFormat

            var latestReceiptInfoArray = [LatestReceiptInfo]()

            for receiptInf in receiptInfo {
                let recInf = receiptInf as! NSDictionary

                var productId: String?
                if let product_id = recInf[product_id] as? String {
                    productId = product_id
                } else {
                    productId = nil
                }

                var expiresDate: Date? = nil
                if let expires_date = recInf[expires_date] as? String {
                    expiresDate = formatter.date(from: expires_date)!
                } else {
                    expiresDate = nil
                }

                var isInIntroOfferPeriod: Bool? = nil
                if let is_in_intro_offer_period = recInf[is_in_intro_offer_period] as? String {
                    if is_in_intro_offer_period.contains("true") {
                        isInIntroOfferPeriod = true
                    } else {
                        isInIntroOfferPeriod = false
                    }
                } else {
                    isInIntroOfferPeriod = nil
                }

                var isTrialPeriod: Bool? = nil
                if let is_trial_period = recInf[is_trial_period] as? String {
                    if is_trial_period.contains("true") {
                        isTrialPeriod = true
                    } else {
                        isTrialPeriod = false
                    }
                } else {
                    isTrialPeriod = nil
                }

                var cancelDate: Date? = nil
                if let cancellation_date = recInf[cancellation_date] as? String {
                    cancelDate = formatter.date(from: cancellation_date)!
                } else {
                    cancelDate = nil
                }

                latestReceiptInfoArray.append(LatestReceiptInfo(productId: productId, expiresDate: expiresDate, isInIntroOffer_period: isInIntroOfferPeriod, isTrialPeriod: isTrialPeriod, cancellationDate: cancelDate))
            }
            return latestReceiptInfoArray
        } else {
            return nil
        }
    }

    func isPurchaseActive(currentDateFromServer: Date?, latestReceiptInfoArray: [LatestReceiptInfo]) -> Bool {
        var isSubsActive = true
        let latestReceiptInfoForHighestExpireDate = latestReceiptInfoArray
            .filter { $0.expiresDate != nil }
            .max { $0.expiresDate! < $1.expiresDate! }

        let formatter = DateFormatter()
        formatter.dateFormat = IAPDateFormat
        let currentServerTimeString = formatter.string(from: currentDateFromServer!)
        let currentDate = formatter.date(from: currentServerTimeString)

        isIntroductoryOfferActive = latestReceiptInfoForHighestExpireDate?.isInIntroOffer_period

        PrintUtility.printLog(tag: TAG, text: "latest_receipt_count \(latestReceiptInfoArray.count)")
        PrintUtility.printLog(tag: TAG, text: "expireDate \(String(describing: (latestReceiptInfoForHighestExpireDate?.expiresDate)!))")
        PrintUtility.printLog(tag: TAG, text: "currentDate \(String(describing: currentDate!))")

        if currentDate!.compare((latestReceiptInfoForHighestExpireDate?.expiresDate)!) == .orderedAscending {
            isSubsActive = true
        } else if currentDate!.compare((latestReceiptInfoForHighestExpireDate?.expiresDate)!) == .orderedDescending {
            isSubsActive = false
        } else if currentDate!.compare((latestReceiptInfoForHighestExpireDate?.expiresDate)!) == .orderedSame {
            isSubsActive = true
        }

        if isSubsActive == true {
            if latestReceiptInfoForHighestExpireDate?.cancellationDate == nil {
                isSubsActive = true
            } else {
                isSubsActive = false
            }
        }
        return isSubsActive
    }
}

// MARK: - IAPManager Additional pop up Alert and activity indicator
extension IAPManager {
    func getTopVisibleViewController(complition: @escaping(_ topViewController: UIViewController?) -> ()) {
        DispatchQueue.main.async {
            if let window = UIApplication.shared.delegate?.window {
                if var viewController = window?.rootViewController {
                    if(viewController is UINavigationController) {
                        viewController = (viewController as! UINavigationController).visibleViewController!
                        complition(viewController)
                    }
                }
            }
        }
    }

    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.getTopVisibleViewController { topViewController in
                if let viewController = topViewController {
                    self.activityIndicator.center = viewController.view.center
                    viewController.view.addSubview(self.activityIndicator)
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.hidesWhenStopped = true
                    viewController.view.isUserInteractionEnabled = false
                }
            }
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.getTopVisibleViewController { topViewController in
                if let viewController = topViewController {
                    self.activityIndicator.stopAnimating()
                    viewController.view.isUserInteractionEnabled = true
                    self.activityIndicator.removeFromSuperview()
                }
            }
        }
    }

    func showAlertFromAppDelegates(error: Error) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: "kIAPError".localiz() , message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alertVC.view.tintColor = UIColor.black
            let okAction = UIAlertAction(title: "OK".localiz(), style: UIAlertAction.Style.cancel) { (alert) in
                //exit(0)
            }
            alertVC.addAction(okAction)
            DispatchQueue.main.async {
                self.getTopVisibleViewController { topViewController in
                    if let viewController = topViewController {
                        var presentVC = viewController
                        while let next = presentVC.presentedViewController {
                            presentVC = next
                        }
                        presentVC.present(alertVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func showNoInternetAlertOnVisibleViewController() {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: "internet_connection_error".localiz() , message: "", preferredStyle: UIAlertController.Style.alert)
            alertVC.view.tintColor = UIColor.black
            let connectViaWifiAction = UIAlertAction(title: "connect_via_wifi".localiz(), style: UIAlertAction.Style.default) { (alert) in
                DispatchQueue.main.async {
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel".localiz(), style: UIAlertAction.Style.cancel) { (alert) in
                //exit(0)
            }
            alertVC.addAction(connectViaWifiAction)
            alertVC.addAction(cancelAction)

            DispatchQueue.main.async {
                self.getTopVisibleViewController { topViewController in
                    if let viewController = topViewController {
                        var presentVC = viewController
                        while let next = presentVC.presentedViewController {
                            presentVC = next
                        }
                        presentVC.present(alertVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }

    func showAlertForRetryIAP(iapReceiptValidationFrom: IAPReceiptValidationFrom) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: "kTimeOut".localiz() , message: "kAppleServerBusy".localiz(), preferredStyle: UIAlertController.Style.alert)
            alertVC.view.tintColor = UIColor.black
            let okAction = UIAlertAction(title: "kTryAgain".localiz(), style: UIAlertAction.Style.cancel) { (alert) in
                self.showActivityIndicator()
                self.IAPResponseCheck(iapReceiptValidationFrom: iapReceiptValidationFrom)
            }
            alertVC.addAction(okAction)

            DispatchQueue.main.async {
                self.getTopVisibleViewController { topViewController in
                    if let viewController = topViewController {
                        var presentVC = viewController
                        while let next = presentVC.presentedViewController {
                            presentVC = next
                        }
                        presentVC.present(alertVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}

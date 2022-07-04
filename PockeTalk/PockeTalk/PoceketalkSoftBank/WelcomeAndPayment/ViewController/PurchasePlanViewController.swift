//
//  PurchasePlanViewController.swift
//  PockeTalk
//

import UIKit
import SwiftRichString
import StoreKit
import SwiftKeychainWrapper

class PurchasePlanViewController: BaseViewController {
    @IBOutlet weak private var purchasePlanTV: UITableView!
    private let TAG = "\(PurchasePlanViewController.self)"
    private var purchasePlanVM: PurchasePlanViewModeling!

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        purchasePlanVM = PurchasePlanViewModel()
        setupUI()
        registerNotification()
        getProductList()
        ScreenTracker.sharedInstance.screenPurpose = .PurchasePlanScreen
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterNotification()
    }

    //MARK: - Initial setup
    private func setupUI() {
        setupView()
        setupTableView()
    }

    private func setupView() {
        self.view.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setupTableView() {
        purchasePlanTV.delegate = self
        purchasePlanTV.dataSource = self
        purchasePlanTV.separatorStyle = .none
        purchasePlanTV.backgroundColor = .white

        purchasePlanTV.register(UINib(nibName: KInfoLabelTableViewCell, bundle: nil), forCellReuseIdentifier: KInfoLabelTableViewCell)
        purchasePlanTV.register(UINib(nibName: KPlanTableViewCell, bundle: nil), forCellReuseIdentifier: KPlanTableViewCell)

        purchasePlanTV.register(UINib(nibName: KFreePlanTableViewCell, bundle: nil), forCellReuseIdentifier: KFreePlanTableViewCell)
        purchasePlanTV.register(UINib(nibName: KSingleButtonTableViewCell, bundle: nil), forCellReuseIdentifier: KSingleButtonTableViewCell)

        purchasePlanTV.reloadData()
    }

    //MARK: - Load data
    private func getProductList() {
        ActivityIndicator.sharedInstance.show()
        if Reachability.isConnectedToNetwork() {
            self.purchasePlanVM.setProductFetchStatus(true)
            self.purchasePlanVM.getProduct { [weak self] success, error in
                guard let self = `self` else {return}

                if self.purchasePlanVM.isProductFetchOngoing {
                    if let productFetchError = error {
                        DispatchQueue.main.async {
                            self.showProductFetchErrorAlert(message: productFetchError)
                            ActivityIndicator.sharedInstance.hide()
                            return
                        }
                        PrintUtility.printLog(tag: TagUtility.sharedInstance.iapTag, text: "Product can't fetch, error: \(productFetchError)")
                    }

                    DispatchQueue.main.async {
                        success ? (self.purchasePlanTV.reloadData()) : (PrintUtility.printLog(tag: TagUtility.sharedInstance.iapTag, text: "Can't successfully fetch the product, status: \(success)"))
                        ActivityIndicator.sharedInstance.hide()
                        self.purchasePlanVM.setProductFetchStatus(false)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                ActivityIndicator.sharedInstance.hide()
                InitialFlowHelper().showNoInternetAlert(on: self)
            }
        }
    }

    //MARK: - API Calls
    private func restorePurchases() {
        ActivityIndicator.sharedInstance.show()
        if Reachability.isConnectedToNetwork() {
            self.purchasePlanVM.updateReceiptValidationAllow(iapReceiptValidationFrom: .restoreButton)
            purchasePlanVM.restorePurchase { [weak self] success, error in
                if KeychainWrapper.standard.bool(forKey: receiptValidationAllowFromPurchase)! == true {
                    guard let self = `self` else {return}

                    if let error = error {
                        DispatchQueue.main.async {
                            self.showIAPRelatedError(error)
                            ActivityIndicator.sharedInstance.hide()
                        }
                    } else {
                        DispatchQueue.main.async {
                            success ? (self.goToPermissionVC()) : (self.didFinishRestoringPurchasesWithZeroProducts())
                            ActivityIndicator.sharedInstance.hide()
                            KeychainWrapper.standard.set(false, forKey: receiptValidationAllowFromPurchase)
                        }
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                ActivityIndicator.sharedInstance.hide()
                InitialFlowHelper().showNoInternetAlert(on: self)
                self.restorePurchaseLogEvent(planType: PurchasePlan.none.rawValue)
            }
        }
    }

    private func requestForPurchaseProduct(product: SKProduct) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            if Reachability.isConnectedToNetwork() {
                ActivityIndicator.sharedInstance.show()
                self.purchasePlanVM.updateReceiptValidationAllow(iapReceiptValidationFrom: .purchaseButton)
                self.purchasePlanVM.purchaseProduct(product: product){ [weak self] success, error in

                    if KeychainWrapper.standard.bool(forKey: receiptValidationAllowFromPurchase)! == true {
                        guard let self = `self` else {return}

                        if let productPurchaseError = error {
                            DispatchQueue.main.async {
                                self.purchaseFailureLogEvent()
                                self.showIAPRelatedError(productPurchaseError)
                                ActivityIndicator.sharedInstance.hide()
                            }
                        } else {
                            DispatchQueue.main.async {
                                if success {
                                    self.goToPermissionVC()
                                    self.purchaseSuccessfulLogEvent()
                                } else {
                                    self.purchaseFailureLogEvent()
                                    PrintUtility.printLog(tag: TagUtility.sharedInstance.iapTag, text: "Din't successfully buy the product")
                                }

                                ActivityIndicator.sharedInstance.hide()
                                KeychainWrapper.standard.set(false, forKey: receiptValidationAllowFromPurchase)
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    ActivityIndicator.sharedInstance.hide()
                    InitialFlowHelper().showNoInternetAlert(on: self)
                }
            }
        }
        return true
    }

    //MARK: - IBActions
    private func tapOnCell(indexPath: IndexPath) {
        Reachability.isConnectedToNetwork() ? (restorePurchases()) : (InitialFlowHelper().showNoInternetAlert(on: self))
    }

    //MARK: - View Transactions
    private func goToPermissionVC() {
        UserDefaults.standard.set(true, forKey: kUserPassedSubscription)
        if let viewController = UIStoryboard.init(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PermissionViewController.self)) as? PermissionViewController {
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(viewController, animated: false)
        }
    }

    //MARK: - Utils
    private func unregisterNotification() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:.inAppPurchaseRestoreInfoNotification, object: nil)
    }

    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restorePurchase(notification:)), name: .inAppPurchaseRestoreInfoNotification, object: nil)
    }

    @objc func applicationWillResignActive(notification: Notification) {
        ActivityIndicator.sharedInstance.hide()
    }

    @objc func applicationDidBecomeActive(notification: Notification) {
        if Reachability.isConnectedToNetwork() {
            purchasePlanVM.isAPICallOngoing ? (ActivityIndicator.sharedInstance.show()) : (ActivityIndicator.sharedInstance.hide())
        } else {
            InitialFlowHelper().showNoInternetAlert(on: self)
            purchasePlanVM.updateIsAPICallOngoing(false)
        }
    }

    private func getProductForPurchase(for type: PurchasePlanTVCellInfo){
        if let productDetails = purchasePlanVM.getProductDetailsData(using: type){
            if !self.requestForPurchaseProduct(product: productDetails.product){
                self.showSingleAlert(withMessage: "kIAPEnablePaymentFromSettings".localiz())
            }
        }
    }

    private func showProductFetchErrorAlert(message: String){
        self.popupAlert(title: "kPockeTalk".localiz(), message: message, actionTitles: ["OK".localiz(), "Cancel".localiz()], actionStyle: [.default, .cancel], action: [
            { ok in
                self.getProductList()
            },{ cancle in
                exit(0)
            }
        ])
    }

    private func showSingleAlert(withMessage message: String) {
        DispatchQueue.main.async {
            self.present( InitialFlowHelper().showSingleAlert(
                message: message),
                animated: true,
                completion: nil)
        }
    }

    private func didFinishRestoringPurchasesWithZeroProducts() {
        showSingleAlert(withMessage: "kIAPNoPurchasedItemToRestore".localiz())
    }

    private func showIAPRelatedError(_ error: String) {
        showSingleAlert(withMessage: error)
    }
}

//MARK: - UITableViewDataSource
extension PurchasePlanViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasePlanVM.numberOfRow
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = purchasePlanVM.rowType[indexPath.row]

        switch rowType{
        case .selectPlan:
            let cell = tableView.dequeueReusableCell(withIdentifier: KInfoLabelTableViewCell,for: indexPath) as! InfoLabelTableViewCell
            cell.configCell(text: rowType.title)
            cell.selectionStyle = .none
            return cell
        case .freeUses:
            let cell = tableView.dequeueReusableCell(withIdentifier: KFreePlanTableViewCell,for: indexPath) as! FreePlanTableViewCell
            cell.configCell (
                indexPath: indexPath,
                freeDaysDetailsInfoText: rowType.title,
                freeDaysUsesInfo: "kIAPFreeDaysDescription".localiz())
            cell.selectionStyle = .none
            return cell
        case .weeklyPlan, .monthlyPlan,.annualPlan, .dailyPlan:
            let cell = tableView.dequeueReusableCell(withIdentifier: KPlanTableViewCell,for: indexPath) as! PlanTableViewCell
            cell.selectionStyle = .none
            let productData = purchasePlanVM.getProductDetailsData(using: rowType)
            cell.configCell (
                indexPath: indexPath,
                cellType: rowType,
                productData: productData,
                isSuggestionTextAvailable: productData?.suggestionText == nil ? (false): (true))
            return cell
        case .restorePurchase:
            let cell = tableView.dequeueReusableCell(withIdentifier: KSingleButtonTableViewCell,for: indexPath) as! SingleButtonTableViewCell
            cell.configure (indexPath: indexPath, buttonTitle: rowType.title) { [weak self] cellIndexPath in
                self?.tapOnCell(indexPath: cellIndexPath)
            }
            cell.selectionStyle = .none
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension PurchasePlanViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = purchasePlanVM.rowType[indexPath.row]

        switch rowType{
        case .selectPlan, .freeUses, .weeklyPlan, .monthlyPlan, .annualPlan, .restorePurchase, .dailyPlan:
            return rowType.height
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if purchasePlanVM.hasInAppPurchaseProduct {
            let rowType = purchasePlanVM.rowType[indexPath.row]

            switch rowType{
            case .selectPlan, .freeUses, .restorePurchase:
                return
            case .dailyPlan, .weeklyPlan, .monthlyPlan, .annualPlan:
                purchasePlanVM.setSelectedPlanType(planType: rowType)
                getProductForPurchase(for: rowType)
                choosePlanLogEvent(rowType)
            }
        }
    }
}

//MARK: - Google analytics log events
extension PurchasePlanViewController {
    private func choosePlanLogEvent(_ rowType: PurchasePlanTVCellInfo) {
        switch rowType{
        case .selectPlan, .freeUses, .restorePurchase, .dailyPlan:
            return
        case .weeklyPlan:
            analytics.buttonTap(screenName: analytics.firstPlanSelect,
                                buttonName: analytics.buttonWeek)
        case .monthlyPlan:
            analytics.buttonTap(screenName: analytics.firstPlanSelect,
                                buttonName: analytics.buttonMonth)
        case .annualPlan:
            analytics.buttonTap(screenName: analytics.firstPlanSelect,
                                buttonName: analytics.buttonYear)
        }
    }

    private func purchaseSuccessfulLogEvent() {
        if let planTypeText = purchasePlanVM.getSelectedPlanType() {
        analytics.purchasePlan(screenName: analytics.firstPurchaseComplete,
                               buttonName: analytics.buttonOK,
                               selectedPlan: planTypeText)
        }
    }

    private func purchaseFailureLogEvent() {
        if let planTypeText = purchasePlanVM.getSelectedPlanType() {
        analytics.purchasePlan(screenName: analytics.firstPurchaseCancel,
                               buttonName: analytics.buttonOK,
                               selectedPlan: planTypeText)
        }
    }

    @objc private func restorePurchase(notification: Notification) {
        if let planType = notification.userInfo![planType] as? String {
            restorePurchaseLogEvent(planType: planType)
        }
    }

    private func restorePurchaseLogEvent(planType: String) {
        analytics.purchasePlan(screenName: analytics.firstPlanSelect,
                               buttonName: analytics.buttonRestore,
                               selectedPlan: planType)
    }
}

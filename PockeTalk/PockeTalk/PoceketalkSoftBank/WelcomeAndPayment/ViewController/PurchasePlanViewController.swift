//
//  PurchasePlanViewController.swift
//  PockeTalk
//

import UIKit
import SwiftRichString
import StoreKit
import SwiftKeychainWrapper

class PurchasePlanViewController: UIViewController {
    @IBOutlet weak private var purchasePlanTV: UITableView!
    private let TAG = "\(PurchasePlanViewController.self)"
    private var purchasePlanVM: PurchasePlanViewModeling!
    private var connectivity = Connectivity()
    private var shouldRefreshProductList = false
    private var alert: UIAlertController?
    private var shouldCallLicenseIssuanceApi = false
    private var shouldCallLicenseConfirmationApi = false
    private var shouldShowLoader = false
    private var freeTrialRetryCount = 0
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        purchasePlanVM = PurchasePlanViewModel()
        setupUI()
        registerNotification()
        ScreenTracker.sharedInstance.screenPurpose = .PurchasePlanScreen
        self.connectivity.startMonitoring { [weak self] connection, reachable in
            guard let self = self else { return }
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:" \(connection) Is reachable: \(reachable)")
            if UserDefaultsProperty<Bool>(isNetworkAvailable).value == nil && reachable == .yes {
                DispatchQueue.main.async {
                    self.hideNoInternetAlert()
                    if(self.shouldCallLicenseIssuanceApi){
                        self.checkFreeTrialEligibility()
                    }else if(self.shouldCallLicenseConfirmationApi){
                        self.callLicenseConfirmationApi()
                    }else if(self.shouldRefreshProductList){
                        self.getProductList()
                    }
                }
            }else {
                self.showNoInternetAlert()
            }
        }
        callLicenseConfirmationApi()
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
        purchasePlanTV.register(UINib(nibName: kPlanTableViewThreeDaysTrialCell, bundle: nil), forCellReuseIdentifier: kPlanTableViewThreeDaysTrialCell)
        purchasePlanTV.register(UINib(nibName: KFreePlanTableViewCell, bundle: nil), forCellReuseIdentifier: KFreePlanTableViewCell)
        purchasePlanTV.register(UINib(nibName: KSingleButtonTableViewCell, bundle: nil), forCellReuseIdentifier: KSingleButtonTableViewCell)

        purchasePlanTV.reloadData()
    }

    //MARK: - Load data
    private func getProductList() {
        if Reachability.isConnectedToNetwork() {
            showLoader()
            self.shouldRefreshProductList = false
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
                self.shouldRefreshProductList = true
            }
            self.showNoInternetAlert()
        }
    }

    //MARK: - API Calls
    private func restorePurchases() {
        ActivityIndicator.sharedInstance.show()
        if Reachability.isConnectedToNetwork() {
            self.purchasePlanVM.updateReceiptValidationAllow()
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
                self.showNoInternetAlert()
            }
        }
    }

    private func requestForPurchaseProduct(product: SKProduct) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            if Reachability.isConnectedToNetwork() {
                ActivityIndicator.sharedInstance.show()
                self.purchasePlanVM.updateReceiptValidationAllow()
                self.purchasePlanVM.purchaseProduct(product: product){ [weak self] success, error in

                    if KeychainWrapper.standard.bool(forKey: receiptValidationAllowFromPurchase)! == true {
                        guard let self = `self` else {return}

                        if let productPurchaseError = error {
                            DispatchQueue.main.async {
                                self.showIAPRelatedError(productPurchaseError)
                                ActivityIndicator.sharedInstance.hide()
                            }
                        } else {
                            DispatchQueue.main.async {
                                success ? (self.goToPermissionVC()) : (PrintUtility.printLog(tag: TagUtility.sharedInstance.iapTag, text: "Din't successfully buy the product"))
                                ActivityIndicator.sharedInstance.hide()
                                KeychainWrapper.standard.set(false, forKey: receiptValidationAllowFromPurchase)
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    ActivityIndicator.sharedInstance.hide()
                    self.showNoInternetAlert()
                }
            }
        }
        return true
    }

    //MARK: - IBActions
    private func tapOnCell(indexPath: IndexPath) {
        Reachability.isConnectedToNetwork() ? (restorePurchases()) : (self.showNoInternetAlert())
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
    }

    private func registerNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(notification:)), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: UIApplication.didBecomeActiveNotification, object: nil)
    }

    @objc func applicationWillResignActive(notification: Notification) {
        ActivityIndicator.sharedInstance.hide()
    }

    @objc func applicationDidBecomeActive(notification: Notification) {
        if Reachability.isConnectedToNetwork() {
            purchasePlanVM.isAPICallOngoing ? (ActivityIndicator.sharedInstance.show()) : (ActivityIndicator.sharedInstance.hide())
        } else {
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
    func showNoInternetAlert() {
        self.popupNoIntenetAlert(title: "internet_connection_error".localiz(), message: "", actionTitles: ["connect_via_wifi".localiz(), "Cancel".localiz()], actionStyle: [.default, .cancel], action: [
            { connectViaWifi in
                DispatchQueue.main.async {
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            },{ cancel in
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "Tap on no internet cancle")
                exit(0)
            }
        ])
    }
    
    func popupNoIntenetAlert(title: String, message: String, actionTitles:[String], actionStyle: [UIAlertAction.Style], action:[((UIAlertAction) -> Void)]) {
        DispatchQueue.main.async {
            self.alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            if let alert = self.alert{
                alert.view.tintColor = UIColor.black
                for (index, title) in actionTitles.enumerated() {
                    let action = UIAlertAction(title: title, style: actionStyle[index], handler: action[index])
                    alert.addAction(action)
                }
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func hideNoInternetAlert() {
        DispatchQueue.main.async {
            self.hideLoader()
            if let alert = self.alert{
                alert.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func checkFreeTrialEligibility(){
        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"checkFreeTrialEligibility =>")
        if Reachability.isConnectedToNetwork() == true{
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"checkFreeTrialEligibility => Has internet => Calling license token API")
            self.showLoader()
            self.shouldCallLicenseIssuanceApi = false
            NetworkManager.shareInstance.callTokenIssuanceApiForFreeTrial{ [weak self]
                data in
                guard let data = data else {
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"checkFreeTrialEligibility => Data => nill => API FAILED")
                    self?.hideLoader()
                    return
                }
                do {
                    self?.hideLoader()
                    let data = try JSONDecoder().decode(LiscenseTokenModel.self, from: data)
                    let alertService = CustomAlertViewModel()
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"checkFreeTrialEligibility => Data => result =>  \(data.result_code)")
                    if data.result_code == response_ok {
                        UserDefaults.standard.set(true, forKey: kFreeTrialStatus)
                        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"====== Trial is Activated =====")
                        self?.goToPermissionVC()
                    } else {
                        UserDefaults.standard.set(false, forKey: kFreeTrialStatus)
                        if self?.freeTrialRetryCount ?? 0 < 3 {
                            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"Token API error. Retrying.... Count > \(self?.freeTrialRetryCount)")
                            self?.freeTrialRetryCount += 1
                            self?.checkFreeTrialEligibility()
                        } else {
                            DispatchQueue.main.async {
                                let alert = alertService.alertDialogFreeTrialError(message: "kServerError".localiz()) {
                                }
                                self?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                } catch{
                    PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => Error")
                    UserDefaults.standard.set(false, forKey: kFreeTrialStatus)
                    self?.hideLoader()
                }
            }
        }else{
            PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"checkFreeTrialEligibility => No internet")
            self.hideLoader()
            self.showNoInternetAlert()
            self.shouldCallLicenseIssuanceApi = true
        }
    }
    
    func callLicenseConfirmationApi(){
        if IAPManager.shared.iSAppStoreRegionJapan() == false{
            if Reachability.isConnectedToNetwork() == true{
                showLoader()
                self.shouldCallLicenseConfirmationApi = false
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => Has internet => Calling license conformation API")
                NetworkManager.shareInstance.callLicenseConfirmationForFreeTrial { [weak self] data  in
                    guard let data = data, let self = self else {
                        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => Data => nill => API FAILED")
                        self?.hideLoader()
                        self?.purchasePlanVM.setFreeTrialStatus(false)
                        self?.getProductList()
                        return
                    }
                    do {
                        let result = try JSONDecoder().decode(LicenseConfirmationModel.self, from: data)
                        self.hideLoader()
                        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => result_code => \(result.result_code)")
                        if let result_code = result.result_code {
                            if result_code == response_ok {
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"====== Trial is active =====")
                                self.purchasePlanVM.setFreeTrialStatus(true)
                                self.getProductList()
                            }else if result_code == INFO_INVALID_LICENSE{
                                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"====== Trial can be activated =====")
                                self.purchasePlanVM.setFreeTrialStatus(true)
                                self.getProductList()
                            }else {
                                self.purchasePlanVM.setFreeTrialStatus(false)
                                self.getProductList()
                            }
                        }else{
                            self.purchasePlanVM.setFreeTrialStatus(false)
                            self.getProductList()
                        }
                    } catch let err {
                        PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => Error => \(err.localizedDescription)")
                        self.hideLoader()
                        self.purchasePlanVM.setFreeTrialStatus(false)
                        self.getProductList()
                    }
                }
            }else{
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text:"callLicenseConfirmationApi => No internet ")
                self.hideLoader()
                self.showNoInternetAlert()
                self.shouldCallLicenseConfirmationApi = true
            }
        } else {
            self.purchasePlanVM.setFreeTrialStatus(false)
            self.getProductList()
        }
    }
    
    func showLoader(){
        DispatchQueue.main.async {
            ActivityIndicator.sharedInstance.show()
            self.shouldShowLoader = true
        }
    }
    
    func hideLoader(){
        DispatchQueue.main.async {
            ActivityIndicator.sharedInstance.hide()
            self.shouldShowLoader = false
        }
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
        case .threeDaysTrial:
            let cell = tableView.dequeueReusableCell(withIdentifier: kPlanTableViewThreeDaysTrialCell,for: indexPath) as! PlanTableViewThreeDaysTrialCell
            cell.selectionStyle = .none
            cell.configCell(indexPath: indexPath, cellType: rowType)
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension PurchasePlanViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = purchasePlanVM.rowType[indexPath.row]

        switch rowType{
        case .selectPlan, .freeUses, .weeklyPlan, .monthlyPlan, .annualPlan, .restorePurchase, .dailyPlan, .threeDaysTrial:
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
                getProductForPurchase(for: rowType)
            case .threeDaysTrial:
                PrintUtility.printLog(tag: TagUtility.sharedInstance.trialTag, text: "Tap on no 3 days Trial")
                self.shouldCallLicenseIssuanceApi = false
                self.checkFreeTrialEligibility()
            }
        }
    }
}

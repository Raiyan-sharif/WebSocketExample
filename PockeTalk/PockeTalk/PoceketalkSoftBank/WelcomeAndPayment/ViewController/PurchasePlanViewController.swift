//
//  PurchasePlanViewController.swift
//  PockeTalk
//

import UIKit
import SwiftRichString
import StoreKit

class PurchasePlanViewController: UIViewController {
    @IBOutlet weak private var purchasePlanTV: UITableView!
    private let TAG = "\(PurchasePlanViewController.self)"
    private var purchasePlanVM: PurchasePlanViewModel!

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        purchasePlanVM = PurchasePlanViewModel()
        setupUI()
        registerForNotification()
        getProductList()
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
            self.purchasePlanVM.getProduct { [weak self] success, error in

                if let productFetchError = error{
                    DispatchQueue.main.async {
                        ActivityIndicator.sharedInstance.hide()
                        return
                    }
                    PrintUtility.printLog(tag: "IAP", text: "Product can't fetch, error: \(productFetchError)")
                }

                DispatchQueue.main.async {
                    if success {
                        PrintUtility.printLog(tag: "IAP", text: "Product fetch status \(success)")
                        self?.purchasePlanTV.reloadData()
                    }
                    ActivityIndicator.sharedInstance.hide()
                }
            }
        } else {
            ActivityIndicator.sharedInstance.hide()
            InitialFlowHelper().showNoInternetAlert(on: self)
        }
    }

    //MARK: - API Calls
    private func restorePurchases() {
        ActivityIndicator.sharedInstance.show()
        if Reachability.isConnectedToNetwork(){
            self.purchasePlanVM.updateReceiptValidationAllow()
            purchasePlanVM.restorePurchase { [weak self] success, error in
                guard let self = `self` else {return}

                if let error = error {
                    DispatchQueue.main.async {
                        self.showIAPRelatedError(error)
                        ActivityIndicator.sharedInstance.hide()
                        return
                    }
                }

                if success{
                    self.goToPermissionVC()
                } else {
                    self.didFinishRestoringPurchasesWithZeroProducts()
                }
                ActivityIndicator.sharedInstance.hide()
            }
        } else {
            ActivityIndicator.sharedInstance.hide()
            InitialFlowHelper().showNoInternetAlert(on: self)
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
                    guard let self = `self` else {return}

                    if let productPurchaseError = error{
                        DispatchQueue.main.async {
                            self.showIAPRelatedError(productPurchaseError)
                            ActivityIndicator.sharedInstance.hide()
                            return
                        }
                    }

                    success ? (self.goToPermissionVC()) : (PrintUtility.printLog(tag: "initialFlow", text: "Din't successfully buy the product"))
                    ActivityIndicator.sharedInstance.hide()
                }
            } else {
                ActivityIndicator.sharedInstance.hide()
                InitialFlowHelper().showNoInternetAlert(on: self)
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
        DispatchQueue.main.async {
            if let viewController = UIStoryboard.init(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PermissionViewController.self)) as? PermissionViewController {
                let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(viewController, animated: false)
            }
        }
    }

    private func goToTermAndConditionVC() {
        DispatchQueue.main.async { [self] in
            if UserDefaultsUtility.getBoolValue(forKey: isTermAndConditionTap) == false {
                let initialStoryBoard = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil)
                if let vc = initialStoryBoard.instantiateViewController(withIdentifier: String(describing: AppFirstLaunchViewController.self)) as? AppFirstLaunchViewController {
                    if var vcs: [UIViewController] = navigationController?.viewControllers {
                        vcs.insert(vc, at: 0)
                        navigationController?.viewControllers = vcs
                        navigationController?.popViewController(animated: true )
                    }
                }
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    //MARK: - Utils
    private func registerForNotification() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }

    @objc private func appWillEnterForeground() {
        purchasePlanVM.isAPICallOngoing ? (ActivityIndicator.sharedInstance.show()) : (ActivityIndicator.sharedInstance.hide())
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
                self.goToTermAndConditionVC()
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
            cell.configCell(indexPath: indexPath, freeDaysDetailsInfoText: rowType.title, freeDaysUsesInfo: "kIAPFreeDaysDescription".localiz())
            cell.selectionStyle = .none
            return cell
        case .weeklyPlan, .monthlyPlan,.annualPlan, .dailyPlan:
            let cell = tableView.dequeueReusableCell(withIdentifier: KPlanTableViewCell,for: indexPath) as! PlanTableViewCell
            cell.selectionStyle = .none
            let productData = purchasePlanVM.getProductDetailsData(using: rowType)
            cell.configCell(indexPath: indexPath, cellType: rowType, productData: productData, isSuggestionTextAvailable: productData?.suggestionText == nil ? (false): (true), isShowDummyImage: true)
            return cell
        case .restorePurchase:
            let cell = tableView.dequeueReusableCell(withIdentifier: KSingleButtonTableViewCell,for: indexPath) as! SingleButtonTableViewCell
            cell.configure(indexPath: indexPath, buttonTitle: rowType.title) { [weak self] cellIndexPath in
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
                getProductForPurchase(for: rowType)
            }
        } else {
            if let error = purchasePlanVM.productFetchError {
                showIAPRelatedError(error)
            }
        }
    }
}

//
//  PurchasePlanViewController.swift
//  PockeTalk
//

import UIKit
import SwiftRichString
import StoreKit

class PurchasePlanViewController: UIViewController {
    @IBOutlet weak private var purchasePlanTV: UITableView!
    @IBOutlet weak private var purchaseInfoLabel: UILabel!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!

    private let TAG = "\(PurchasePlanViewController.self)"
    private let purchasePlanVM = PurchasePlanViewModel()
    
    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        purchasePlanVM.resetData()
        getProductList()
    }

    //MARK: - Initial setup
    private func setupUI() {
        setupView()
        setupTableView()
        setupBottomLabel()
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
        purchasePlanTV.isScrollEnabled = false

        purchasePlanTV.register(UINib(nibName: KInfoLabelTableViewCell, bundle: nil), forCellReuseIdentifier: KInfoLabelTableViewCell)
        purchasePlanTV.register(UINib(nibName: KPlanTableViewCell, bundle: nil), forCellReuseIdentifier: KPlanTableViewCell)
        purchasePlanTV.register(UINib(nibName: KSingleButtonTableViewCell, bundle: nil), forCellReuseIdentifier: KSingleButtonTableViewCell)

        purchasePlanTV.reloadData()
    }

    private func setupBottomLabel() {
        purchaseInfoLabel.text = "kPaidPlanVCBulletPointOneLabel".localiz() + " " + "kPaidPlanVCBulletPointTwoLabel".localiz()
    }

    //MARK: - Load data
    private func getProductList() {
        setActivityIndicator(shouldStart: true)
        if Reachability.isConnectedToNetwork() {
            purchasePlanVM.getProduct { [weak self] success, error in
                if let productFetchError = error{
                    DispatchQueue.main.async {
                        self?.showProductFetchErrorAlert(message: productFetchError)
                        self?.setActivityIndicator(shouldStart: false)
                        return
                    }
                }

                DispatchQueue.main.async {
                    if success {
                        self?.purchasePlanTV.reloadData()
                    }
                    self?.setActivityIndicator(shouldStart: false)
                }
            }
        } else {
            setActivityIndicator(shouldStart: false)
            showNoInternetAlert()
        }

    }

    //MARK: - API Calls
    private func restorePurchases() {
        setActivityIndicator(shouldStart: true)
        if Reachability.isConnectedToNetwork(){
            self.purchasePlanVM.updateReceiptValidationAllow()
            purchasePlanVM.restorePurchase { [weak self] success, error in
                guard let self = `self` else {return}

                if let error = error {
                    DispatchQueue.main.async {
                        self.showIAPRelatedError(error)
                        self.setActivityIndicator(shouldStart: false)
                        return
                    }
                }

                if success{
                    self.goToPermissionVC()
                } else {
                    self.didFinishRestoringPurchasesWithZeroProducts()
                }
                self.setActivityIndicator(shouldStart: false)
            }
        } else {
            setActivityIndicator(shouldStart: false)
            showNoInternetAlert()
        }
    }

    private func requestForPurchaseProduct(product: SKProduct) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            if Reachability.isConnectedToNetwork() {
                setActivityIndicator(shouldStart: true)
                self.purchasePlanVM.updateReceiptValidationAllow()
                self.purchasePlanVM.purchaseProduct(product: product){ [weak self] success, error in
                    guard let self = `self` else {return}

                    if let productPurchaseError = error{
                        DispatchQueue.main.async {
                            self.showIAPRelatedError(productPurchaseError)
                            self.setActivityIndicator(shouldStart: false)
                            return
                        }
                    }

                    success ? (self.goToPermissionVC()) : (PrintUtility.printLog(tag: "initialFlow", text: "Din't successfully buy the product"))
                }
            } else {
                setActivityIndicator(shouldStart: false)
                showNoInternetAlert()
            }
        }
        return true
    }

    //MARK: - IBActions
    private func tapOnCell(indexPath: IndexPath) {
        if purchasePlanVM.rowType[indexPath.row] == .cancle {
            goToTermAndConditionVC()
        }

        if purchasePlanVM.rowType[indexPath.row] == .restorePurchase {
            Reachability.isConnectedToNetwork() ? (restorePurchases()) : (showNoInternetAlert())
        }
    }

    //MARK: - View Transactions
    private func goToPermissionVC() {
        DispatchQueue.main.async {
            GlobalMethod.appdelegate().goTopermissionVC()
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
    private func setActivityIndicator(shouldStart: Bool) {
        DispatchQueue.main.async {
            if shouldStart == true {
                self.activityIndicator.startAnimating()
                self.view.isUserInteractionEnabled = false
            } else {
                self.activityIndicator.stopAnimating()
                self.view.isUserInteractionEnabled = true
            }
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

    private func showNoInternetAlert() {
        self.popupAlert(title: "internet_connection_error".localiz(), message: "", actionTitles: ["connect_via_wifi".localiz(), "Cancel".localiz()], actionStyle: [.default, .cancel], action: [
            { connectViaWifi in
                DispatchQueue.main.async {
                    if let url = URL(string:UIApplication.openSettingsURLString) {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }
            },{ cancel in
                PrintUtility.printLog(tag: "initialFlow", text: "Tap on no internet cancle")
            }
        ])
    }
}

//MARK: - UITableViewDataSource
extension PurchasePlanViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchasePlanVM.numbeOfRow
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = purchasePlanVM.rowType[indexPath.row]

        switch rowType{
        case .selectPlan:
            let cell = tableView.dequeueReusableCell(withIdentifier: KInfoLabelTableViewCell,for: indexPath) as! InfoLabelTableViewCell
            cell.configCell(text: rowType.title)
            cell.selectionStyle = .none
            return cell
        case .weeklyPlan, .monthlyPlan,.annualPlan, .dailyPlan:
            let cell = tableView.dequeueReusableCell(withIdentifier: KPlanTableViewCell,for: indexPath) as! PlanTableViewCell
            cell.selectionStyle = .none
            let productData = purchasePlanVM.getProductDetailsData(using: rowType)
            cell.configCell(indexPath: indexPath, cellType: rowType, productData: productData)
            return cell
        case .cancle, .restorePurchase:
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
        case .selectPlan, .weeklyPlan, .monthlyPlan, .annualPlan, .cancle, .restorePurchase, .dailyPlan:
            return rowType.height
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowType = purchasePlanVM.rowType[indexPath.row]

        switch rowType{
        case .selectPlan, .cancle, .restorePurchase:
            return
        case .dailyPlan, .weeklyPlan, .monthlyPlan, .annualPlan:
            getProductForPurchase(for: rowType)
        }
    }
}

//
//  PaidPlanViewController.swift
//  PockeTalk
//
//  Created by BJIT on 4/1/22.
//

import UIKit
import StoreKit

class PaidPlanViewController: UIViewController {
    let TAG = "\(PaidPlanViewController.self)"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bulletPointOneLabel: UILabel!
    @IBOutlet weak var bulletPointTwoLabel: UILabel!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var restorePurchaseHistoryButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var products = [SKProduct]()
    
    func setActivityIndicator(shouldStart: Bool) {
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
    
    func restorePurchaseHistoryButtonUI() {
        restorePurchaseHistoryButton.layer.cornerRadius = 10
        restorePurchaseHistoryButton.layer.borderColor = UIColor.black.cgColor
        restorePurchaseHistoryButton.layer.borderWidth = 1.0
    }

    func initialUISetUp() {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        restorePurchaseHistoryButtonUI()
        titleLabel.text = "kPaidPlanVCTitleLabel".localiz()
        bulletPointOneLabel.text = "kPaidPlanVCBulletPointOneLabel".localiz()
        bulletPointTwoLabel.text = "kPaidPlanVCBulletPointTwoLabel".localiz()
        purchaseButton.setTitle("kPaidPlanVCPurchaseButtonTitle".localiz(), for: .normal)
        restorePurchaseHistoryButton.setTitle("kPaidPlanVCRestorePurchaseHistoryButton".localiz(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUISetUp()
    }
}

// MARK: - IAPManager related
extension PaidPlanViewController {
    func getProductList() {
        setActivityIndicator(shouldStart: true)
        IAPManager.shared.getProducts { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let products): self.showProducts(products: products)
                case .failure(let error): self.showIAPRelatedError(error)
                }
                self.setActivityIndicator(shouldStart: false)
            }
        }
    }
    
    func purchaseProduct(product: SKProduct) -> Bool {
        if !IAPManager.shared.canMakePayments() {
            return false
        } else {
            if Reachability.isConnectedToNetwork() {
                setActivityIndicator(shouldStart: true)
                IAPManager.shared.purchaseProduct(product: product) { (result) in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let isPurchasedActive):
                            if isPurchasedActive == true {
                                self.navigateToWelcomeViewController()
                            } else {
                                GlobalMethod.appdelegate().navigateToPaidPlanViewController()
                            }
                        case .failure(let error):
                            self.showIAPRelatedError(error)
                        }
                        self.setActivityIndicator(shouldStart: false)
                    }
                }
            } else {
                showNoInternetAlert()
            }
        }
        return true
    }
    
    func restorePurchases() {
        setActivityIndicator(shouldStart: true)
        IAPManager.shared.restorePurchases { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let isPurchasedActive):
                    if isPurchasedActive == true {
                        //self.restoredProductSuccessfully()
                        //self.didFinishRestoringPurchasedProducts()
                        self.navigateToWelcomeViewController()
                    } else {
                        self.didFinishRestoringPurchasesWithZeroProducts()
                        self.setActivityIndicator(shouldStart: false)
                    }
                case .failure(let error):
                    self.showIAPRelatedError(error)
                    self.setActivityIndicator(shouldStart: false)
                }
            }
        }
    }
}

// MARK: - Button Actions
extension PaidPlanViewController {
    @IBAction func purchaseButtonAction(_ sender: Any) {
//        if Reachability.isConnectedToNetwork() {
//            getProductList()
//        } else {
//            showNoInternetAlert()
//        }
        navigateToWelcomeViewController()
    }
    
    @IBAction func restorePurchaseHistoryButtonAction(_ sender: Any) {
//        if Reachability.isConnectedToNetwork() {
//            restorePurchases()
//        } else {
//            showNoInternetAlert()
//        }
        navigateToWelcomeViewController()
    }
}

// MARK: - Alert related
extension PaidPlanViewController {
    func showNoInternetAlert() {
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

            }
        ])
    }

    func showSingleAlert(withMessage message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "kPockeTalk".localiz(), message: message, preferredStyle: .alert)
            alertController.view.tintColor = UIColor.black
            alertController.addAction(UIAlertAction(title: "OK".localiz(), style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func didFinishRestoringPurchasesWithZeroProducts() {
        showSingleAlert(withMessage: "kIAPNoPurchasedItemToRestore".localiz())
    }
    
    func didFinishRestoringPurchasedProducts() {
        showSingleAlert(withMessage: "kIAPALLPreviousIAPRestored".localiz())
    }
    
    func showIAPRelatedError(_ error: Error) {
        let message = error.localizedDescription
        showSingleAlert(withMessage: message)
    }
    
    func showProducts(products: [SKProduct]) {
        DispatchQueue.main.async {
            self.chooseProduct(alertTitle: "kPaidPlanVCRestorePurchaseButtonAlertTitle".localiz(), alertMessage: "", products: products) { product, isCancelButton  in
                if isCancelButton == false {
                    self.purchaseSingleProductAlert(product: product)
                } else {
                    PrintUtility.printLog(tag: self.TAG, text: "Cancel button is tapped!")
                }
            }
        }
    }
    
    func purchaseSingleProductAlert(product: SKProduct) {
        self.popupAlert(title: "", message: IAPManager.shared.alertCellSetUp(product: product), actionTitles: ["OK".localiz(), "Cancel".localiz()], actionStyle: [.default, .cancel], action: [
            { ok in
                DispatchQueue.main.async {
                    if !self.purchaseProduct(product: product) {
                        self.showSingleAlert(withMessage: "kIAPEnablePaymentFromSettings".localiz())
                    }
                }
            },{ cancel in
                PrintUtility.printLog(tag: self.TAG, text: "Cancel button is tapped!")
                //TODO: Should I popup first Alert or not?
            }
        ])
    }
    
    func chooseProduct(alertTitle: String, alertMessage: String,  products: [SKProduct], completion: @escaping (_ products: SKProduct, _ isCancelButton: Bool) -> ()) {
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).numberOfLines = 2
        UILabel.appearance(whenContainedInInstancesOf:[UIAlertController.self]).lineBreakMode = .byWordWrapping
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
            alert.view.tintColor = UIColor.black
            for prod in products {
                let action = UIAlertAction(title: IAPManager.shared.alertCellSetUp(product: prod), style: UIAlertAction.Style.default) { _ in
                    completion(prod, false)
                }
                alert.addAction(action)
            }
            
            alert.addAction(UIAlertAction(title: "cancel".localiz(), style: UIAlertAction.Style.cancel) { _ in completion(SKProduct(), true) } )
            self.present(alert, animated: true) {}
        }
    }
    
    func navigateToWelcomeViewController() {
        DispatchQueue.main.async {
            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
            if let welcomeViewController = mainStoryBoard.instantiateViewController(withIdentifier: String(describing: WelcomeViewController.self)) as? WelcomeViewController {
                let transition = CATransition()
                transition.duration = kSettingsScreenTransitionDuration
                transition.type = CATransitionType.moveIn
                transition.subtype = CATransitionSubtype.fromRight
                transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(welcomeViewController, animated: false)
            }
        }
    }
}

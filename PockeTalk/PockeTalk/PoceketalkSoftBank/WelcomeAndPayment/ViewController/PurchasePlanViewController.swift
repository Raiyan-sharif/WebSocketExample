//
//  PurchasePlanViewController.swift
//  PockeTalk
//

import UIKit
import SwiftRichString

class PurchasePlanViewController: UIViewController {
    @IBOutlet weak private var purchasePlanTV: UITableView!
    @IBOutlet weak private var purchaseInfoLabel: UILabel!
    private var row: [PurchasePlanTVCellInfo] = [.selectPlan, .weeklyPlan, .monthlyPlan, .annualPlan, .cancle, .restorePurchase]

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    //MARK: - Initial setup
    private func setupUI(){
        setupView()
        setupTableView()
        setupBottomLabel()
    }

    private func setupView(){
        self.view.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setupTableView(){
        purchasePlanTV.delegate = self
        purchasePlanTV.dataSource = self
        purchasePlanTV.separatorStyle = .none
        purchasePlanTV.backgroundColor = .white

        purchasePlanTV.register(UINib(nibName: KInfoLabelTableViewCell, bundle: nil), forCellReuseIdentifier: KInfoLabelTableViewCell)
        purchasePlanTV.register(UINib(nibName: KPlanTableViewCell, bundle: nil), forCellReuseIdentifier: KPlanTableViewCell)
        purchasePlanTV.register(UINib(nibName: KSingleButtonTableViewCell, bundle: nil), forCellReuseIdentifier: KSingleButtonTableViewCell)
    }

    private func setupBottomLabel(){
        purchaseInfoLabel.text = "kPaidPlanVCBulletPointOneLabel".localiz() + " " + "kPaidPlanVCBulletPointTwoLabel".localiz()
    }

    //MARK: - IBActions
    private func tapOnCell(indexPath: IndexPath){
        if row[indexPath.row] == .cancle{
            self.navigationController?.popViewController(animated: true)
        }

        if row[indexPath.row] == .restorePurchase{
            goToPermissionVC()
        }
    }

    //MARK: - View Transactions
    private func goToPermissionVC(){
        if let viewController = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PermissionViewController.self)) as? PermissionViewController{
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(viewController, animated: false)
        }
    }

    //MARK: - Utils
    private func showMonthlyPlanAlert() {
        self.popupAlert(title: "kPaidPlanVCRestorePurchaseButtonAlertButtonOneTitle".localiz(), message: "", actionTitles: ["OK".localiz(), "cancel".localiz()], actionStyle: [.default, .cancel], action: [
            { ok in
                AppRater.shared.saveAppLaunchTimeOnce()
                //self.goToWelcomeViewController(isUserPurchased: true)
                self.goToPermissionVC()
            },{ cancel in
                PrintUtility.printLog(tag: "initalFlow", text: "Cancel button tapped.")
            }
        ])
    }

    private func showAnnualPlanAlert() {
        self.popupAlert(title: "kPaidPlanVCRestorePurchaseButtonAlertButtonTwoTitle".localiz(), message: "", actionTitles: ["OK".localiz(), "cancel".localiz()], actionStyle: [.default, .cancel], action: [
            { ok in
                AppRater.shared.saveAppLaunchTimeOnce()
                //self.goToWelcomeViewController(isUserPurchased: true)
                self.goToPermissionVC()
            },{ cancel in
                PrintUtility.printLog(tag: "initalFlow", text: "Cancel button tapped.")
            }
        ])
    }
}

//MARK: - UITableViewDataSource
extension PurchasePlanViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return row.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = row[indexPath.row]

        switch rowType{
        case .selectPlan:
            let cell = tableView.dequeueReusableCell(withIdentifier: KInfoLabelTableViewCell,for: indexPath) as! InfoLabelTableViewCell
            cell.configCell(text: rowType.title)
            cell.selectionStyle = .none
            return cell
        case .weeklyPlan, .monthlyPlan,.annualPlan:
            let cell = tableView.dequeueReusableCell(withIdentifier: KPlanTableViewCell,for: indexPath) as! PlanTableViewCell
            cell.selectionStyle = .none
            cell.configCell(indexPath: indexPath, title: rowType.title, subTitle: rowType.subTitle)
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
        let rowType = row[indexPath.row]

        switch rowType{
        case .selectPlan, .weeklyPlan, .monthlyPlan, .annualPlan, .cancle, .restorePurchase:
            return rowType.height
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let rowType = row[indexPath.row]

        switch rowType{
        case .selectPlan, .weeklyPlan, .cancle, .restorePurchase:
            return
        case .monthlyPlan:
            showMonthlyPlanAlert()
        case .annualPlan:
            showAnnualPlanAlert()
        }
    }
}

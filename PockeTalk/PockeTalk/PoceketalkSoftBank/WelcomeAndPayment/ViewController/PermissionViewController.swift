//
//  PermissionViewController.swift
//  PockeTalk
//

import UIKit

class PermissionViewController: UIViewController {
    @IBOutlet weak private var permissionTV: UITableView!
    @IBOutlet weak private var nextBtn: UIButton!
    private var row = [PermissionTVCellInfo]()
    private var isAllPermissionShown = false

    //MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initializeData()
        checkPermissions()
        UserDefaultsUtility.setBoolValue(false, forKey: kIsClearedDataAll)
    }

    //MARK: - Initial setup
    private func setupUI() {
        setupView()
        setupTableView()
        setupButtonProperty(isButtonActive: false)
        hideTalkButtonIfExist()
    }

    private func setupView() {
        view.backgroundColor = .white
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    private func setupTableView() {
        permissionTV.delegate = self
        permissionTV.dataSource = self
        permissionTV.separatorStyle = .none
        permissionTV.backgroundColor = .white

        permissionTV.register(UINib(nibName: KInfoLabelTableViewCell, bundle: nil), forCellReuseIdentifier: KInfoLabelTableViewCell)
        permissionTV.register(UINib(nibName: KPermissionTableViewCell, bundle: nil), forCellReuseIdentifier: KPermissionTableViewCell)
    }

    private func setupButtonProperty(isButtonActive: Bool) {
        nextBtn.setButtonAttributes (
            cornerRadius: InitialFlowHelper().nextButtonCornerRadius,
            title: "kNextButtonTitle".localiz(),
            backgroundColor: isButtonActive ? UIColor._royalBlueColor() : UIColor._semiDarkGrayColor())
        nextBtn.setTitleColor( isButtonActive ? .white : .black, for: .normal)
    }

    private func initializeData() {
           row.append(PermissionTVCellInfo(cellType: .allowAccess, isPermissionGranted: false))
           row.append(PermissionTVCellInfo(cellType: .microphonePermission, isPermissionGranted: false))
           row.append(PermissionTVCellInfo(cellType: .cameraPermission, isPermissionGranted: false))
       }

    private func checkPermissions() {
        let semaphore = DispatchSemaphore(value: 0)
        let dispatchQueue = DispatchQueue.global(qos: .background)

        dispatchQueue.async {
            AppsPermissionCheckingManager.shared.checkPermissionFor(permissionTypes: .microphone) { isPermissionOn in
                DispatchQueue.main.async {
                    self.setGrantPermissionStatusAndReloadTV(for: .microphonePermission, status: isPermissionOn)
                }
                semaphore.signal()
            }
            semaphore.wait()

            AppsPermissionCheckingManager.shared.checkPermissionFor(permissionTypes: .camera) { isPermissionOn in
                DispatchQueue.main.async {
                    self.setGrantPermissionStatusAndReloadTV(for: .cameraPermission, status: isPermissionOn)
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    //MARK: - Utils
    private func setGrantPermissionStatusAndReloadTV(for cellType: PermissionTVCellType, status permissionStatus: Bool ) {
        for item in 0..<row.count {
            if row[item].cellType == cellType {
                row[item].isPermissionGranted = permissionStatus

                if cellType == .cameraPermission {
                    isAllPermissionShown = true
                    resetButtonProperty()
                }
            }
        }
        permissionTV.reloadData()
    }

    private func resetButtonProperty(){
        DispatchQueue.main.async {
            self.setupButtonProperty(isButtonActive: true)
        }
    }

    private func hideTalkButtonIfExist() {
        let window = UIApplication.shared.keyWindow ?? UIWindow()
        let talkButtonImageView = window.viewWithTag(109) as? UIImageView

        if talkButtonImageView != nil {
            talkButtonImageView?.removeFromSuperview()
        }
    }

    //MARK: - IBActions
    @IBAction private func nextButtonTap(_ sender: UIButton) {
        if isAllPermissionShown {
            if let viewController = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: WelcomesViewController.self)) as? WelcomesViewController {
                let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(viewController, animated: false)
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension PermissionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return row.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rowType = row[indexPath.row].cellType

        switch rowType {
        case .allowAccess:
            let cell = tableView.dequeueReusableCell(withIdentifier: KInfoLabelTableViewCell,for: indexPath) as! InfoLabelTableViewCell
            cell.configCell(text: rowType.title)
            cell.selectionStyle = .none
            return cell
        case .microphonePermission, .cameraPermission, .notificationPermission:
            let cell = tableView.dequeueReusableCell(withIdentifier: KPermissionTableViewCell,for: indexPath) as! PermissionTableViewCell
            cell.configCell(indexPath: indexPath, cellInfo: row[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }
    }
}

//MARK: - UITableViewDelegate
extension PermissionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let rowType = row[indexPath.row].cellType

        switch rowType {
        case .allowAccess, .microphonePermission, .cameraPermission, .notificationPermission:
            return rowType.height
        }
    }
}

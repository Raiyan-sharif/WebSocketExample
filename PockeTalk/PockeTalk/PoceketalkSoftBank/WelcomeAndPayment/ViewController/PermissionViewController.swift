//
//  PermissionViewController.swift
//  PockeTalk
//

import UIKit

class PermissionViewController: BaseViewController {
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
        initialCallCall()
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
            AppsPermissionCheckingManager.shared.checkPermissionFor(permissionTypes: .microphone) { (isPermissionOn, permissionGiven) in

                //Log permission status depending on previous alert shown status
                if !permissionGiven {
                    self.permissionLogEvent(permissionType: .microphone,
                                            permissionStatus: isPermissionOn)
                }

                DispatchQueue.main.async {
                    self.setGrantPermissionStatusAndReloadTV(for: .microphonePermission, status: isPermissionOn)
                }
                semaphore.signal()
            }
            semaphore.wait()

            AppsPermissionCheckingManager.shared.checkPermissionFor(permissionTypes: .camera) { (isPermissionOn, permissionGiven) in

                //Log permission status depending on previous alert shown status
                if !permissionGiven {
                    self.permissionLogEvent(permissionType: .camera,
                                            permissionStatus: isPermissionOn)
                }

                DispatchQueue.main.async {
                    self.setGrantPermissionStatusAndReloadTV(for: .cameraPermission, status: isPermissionOn)
                }
                semaphore.signal()
            }
            semaphore.wait()
        }
    }

    //MARK: - Utils
    func initialCallCall() {
        NetworkManager.shareInstance.handleLicenseToken { result in
            if result {
                AppDelegate.generateAccessKey{ result in
                    if result == true {
                       // SocketManager.sharedInstance.connect()
                    }
                }
            }
        }
    }

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
            nextButtonLogEvent()
            goToWelcomeVC()
        }
    }

    //MARK: - View Transactions
    private func goToWelcomeVC() {
        if let viewController = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: WelcomesViewController.self)) as? WelcomesViewController {
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(viewController, animated: false)
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

//MARK: - Google analytics log events
extension PermissionViewController {
    private func permissionLogEvent(permissionType: PermissionTypes, permissionStatus: Bool) {
        switch permissionType {
        case .microphone:
            analytics.permission(screenName: self.analytics.firstMicPermission,
                                 permissionStatus: permissionStatus)
        case .camera:
            analytics.permission(screenName: self.analytics.firstCamPermission,
                                 permissionStatus: permissionStatus)
        case .notification:
            return
        }
    }

    private func nextButtonLogEvent() {
        analytics.permissionConfirm(screenName: analytics.firstPermissionConfirm,
                                    buttonName: analytics.buttonNext,
                                    micPermissionStatus: row[1].isPermissionGranted,
                                    camPermissionStatus: row[2].isPermissionGranted)
    }
}

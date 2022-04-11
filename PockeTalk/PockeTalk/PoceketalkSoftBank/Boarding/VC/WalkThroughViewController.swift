//
//  WalkThroughViewController.swift
//  PockeTalk
//
//

import UIKit

class WalkThroughViewController: BaseViewController {

    @IBOutlet weak private var bottomLangNativeNameLabel: UILabel!
    @IBOutlet weak private var bottomLangSysLangNameButton: UIButton!
    @IBOutlet weak private var topLangNativeNameLabel: UILabel!
    @IBOutlet weak private var topLangSysLangNameButton: UIButton!
    @IBOutlet weak private var languageChangedDirectionButton: UIButton!
    @IBOutlet weak private var menuButton: UIButton!
    @IBOutlet weak private var topClickView: UIView!
    @IBOutlet weak private var bottomClickView: UIView!
    @IBOutlet weak  var bottomView: UIView!

    @IBOutlet weak private var animatedView: UIView!
    @IBOutlet weak private var directionButtonContainerView: UIView!
    @IBOutlet weak private var ButtonBackgroundView: UIView!

    @IBOutlet weak var backGround_blackView: UIView!

    @IBOutlet weak var buttonsStackView: UIStackView!
    @IBOutlet weak var firstNextBtn: UIButton!
    @IBOutlet weak var secondNextBtn: UIButton!
    @IBOutlet weak var firstBackBtn: UIButton!
    @IBOutlet weak var secondBackBtn: UIButton!
    @IBOutlet weak var close: UIButton!

    @IBOutlet weak var lastStackView: UIStackView!
    @IBOutlet weak var middleStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!



    @IBOutlet weak var lanNameLabel: UILabel!
    @IBOutlet weak var languageView: UIView!

    @IBOutlet weak var arrowBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLanguageNames()
        initialCase()
        ScreenTracker.sharedInstance.screenPurpose = .WalkThroughViewController
    }

    func initialCase(){

        firstNextBtn.setTitle("kNextButtonTitle".localiz(), for: .normal)
        firstBackBtn.setTitle("Back".localiz(), for: .normal)
        secondNextBtn.setTitle("kNextButtonTitle".localiz(), for: .normal)
        secondBackBtn.setTitle("Back".localiz(), for: .normal)
        close.setTitle("Close".localiz(), for: .normal)

        firstNextBtn.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())
        firstBackBtn.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())
        secondNextBtn.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())
        secondBackBtn.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())
        close.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())

        titleLabel.font = UIFont.systemFont(ofSize: FontUtility.getBiggestFontSize())


        middleStackView.isHidden = true
        lastStackView.isHidden = true

        backGround_blackView.layer.zPosition = 1
        bottomView.layer.zPosition = 2
        arrowBackgroundView.layer.zPosition = 2
        languageView.layer.zPosition = 2
        buttonsStackView.layer.zPosition = 2
        titleLabel.layer.zPosition = 2

        languageView.isHidden = true
        arrowBackgroundView.isHidden = true

        self.view.bringSubviewToFront(buttonsStackView)
        titleLabel.text = "KBoardingTalkButtonTitle".localiz()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.changeFontSize()
//        self.bottomLangSysLangNameButton.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())
        self.topLangSysLangNameButton.titleLabel?.font = UIFont.systemFont(ofSize: FontUtility.getSmallFontSize())
        self.bottomLangNativeNameLabel.font = UIFont.systemFont(ofSize: FontUtility.getBiggestFontSize(), weight: .bold)
        self.lanNameLabel.font = UIFont.systemFont(ofSize: FontUtility.getBiggestFontSize(), weight: .bold)
        self.topLangNativeNameLabel.font = UIFont.systemFont(ofSize: FontUtility.getBiggestFontSize(), weight: .bold)
    }


    @IBAction func actionBackorNext(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            firstNextBtn.isHidden = true
            middleStackView.isHidden = false
            languageView.isHidden = false
            bottomView.isHidden = true
            titleLabel.text = "KBoardingTransLationLan".localiz()

        case 1:
            bottomView.isHidden = false
            languageView.isHidden = true
            firstNextBtn.isHidden = false
            middleStackView.isHidden = true
            titleLabel.text = "KBoardingTalkButtonTitle".localiz()
        case 2:
            middleStackView.isHidden = true
            languageView.isHidden = true
            lastStackView.isHidden = false
            arrowBackgroundView.isHidden = false
            titleLabel.text = "KBoardingLanChange".localiz()
        case 3:
            middleStackView.isHidden = false
            languageView.isHidden = false
            lastStackView.isHidden = true
            arrowBackgroundView.isHidden = true
            titleLabel.text = "KBoardingTalkButtonTitle".localiz()
        case 4:
            UserDefaults.standard.set(true, forKey: kInitialFlowCompletedForCoupon)
            var savedCoupon = ""
            if let coupon =  UserDefaults.standard.string(forKey: kCouponCode) {
                savedCoupon = coupon
                PrintUtility.printLog(tag: "In WalkThrough", text: "Coupon found: \(coupon)")
            }
            if Reachability.isConnectedToNetwork() {
                if savedCoupon.isEmpty {
                    goToPurchasePlan()
                }else{
                    goToPermissionVC()
                }
            }else{
                DispatchQueue.main.async {
                    InitialFlowHelper().showNoInternetAlert(on: self)
                }
            }

        default:
            break
        }
    }
    private func goToPermissionVC() {
        DispatchQueue.main.async {
            if let viewController = UIStoryboard.init(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PermissionViewController.self)) as? PermissionViewController {
                let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
                self.navigationController?.view.layer.add(transition, forKey: nil)
                self.navigationController?.pushViewController(viewController, animated: false)
            }
        }
    }

    private func goToPurchasePlan() {
        if let viewController = UIStoryboard(name: KStoryboardInitialFlow, bundle: nil).instantiateViewController(withIdentifier: String(describing: PurchasePlanViewController.self)) as? PurchasePlanViewController {
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
            self.navigationController?.view.layer.add(transition, forKey: nil)
            self.navigationController?.pushViewController(viewController, animated: false)
        }
    }

    private func updateLanguageNames() {
        let languageManager = LanguageSelectionManager.shared
        let nativeLangCode = languageManager.bottomLanguage
        let targetLangCode = languageManager.topLanguage
        let nativeLanguage = languageManager.getLanguageInfoByCode(langCode: nativeLangCode)
        let targetLanguage = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        //bottomLangSysLangNameButton.setTitle(nativeLanguage?.sysLangName, for: .normal)
        topLangSysLangNameButton.setTitle(targetLanguage?.sysLangName, for: .normal)
        bottomLangNativeNameLabel.text = nativeLanguage?.name
        lanNameLabel.text = nativeLanguage?.name
        topLangNativeNameLabel.text = targetLanguage?.name
    }

}


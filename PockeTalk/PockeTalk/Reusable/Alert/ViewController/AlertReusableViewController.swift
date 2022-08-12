//
// AlertReusable.swift
// PockeTalk
//

import UIKit
protocol AlertReusableDelegate: AnyObject {
    func updateFavourite(chatItemModel: HistoryChatItemModel)
    func transitionFromReverse(chatItemModel: HistoryChatItemModel?)
    func transitionFromRetranslation (chatItemModel: HistoryChatItemModel?)
    func pronunciationPracticeTap (chatItemModel: HistoryChatItemModel?)
    func onDeleteItem(chatItemModel: HistoryChatItemModel?)
    func onSharePressed(chatItemModel: HistoryChatItemModel?)
}

class AlertReusableViewController: BaseViewController {
    static var nib: UINib =  UINib.init(nibName: KAlertReusable, bundle: nil)
    /// Views
    @IBOutlet weak var alertTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    let window = UIApplication.shared.keyWindow!
    var talkButtonImageView: UIImageView!
    var flagTalkButton = false

    /// Properties
    var items : [AlertItems] = []
    let cellHeight : CGFloat = 58.0
    let cornerRadius : CGFloat = 15.0
    let viewAlpha : CGFloat = 0.8
    var chatItemModel: HistoryChatItemModel?
    var alertViewModel: AlertReusableViewModel!
    weak var delegate : AlertReusableDelegate?
    let toastDisplayTime : Double = 2.0
    private var connectivity = Connectivity()
    var fromScreenPurpose: SpeechProcessingScreenOpeningPurpose?
    var analyticsScreenName: String?
    var isFromHistoryTTS = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        AppDelegate.executeLicenseTokenRefreshFunctionality(){ result in }
//         connectivity.startMonitoring { connection, reachable in
//             PrintUtility.printLog(tag:"Current Connection :", text:" \(connection) Is reachable: \(reachable)")
//             if  UserDefaultsProperty<Bool>(isNetworkAvailable).value == nil && reachable == .yes{
//                 AppDelegate.executeLicenseTokenRefreshFunctionality(){ result in }
//             }
//
//         }
        // Do any additional setup after loading the view.
        alertViewModel = AlertReusableViewModel()
        self.setUpUI()
        self.registerForNotification()
        setAnalyticsScreenName()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        FloatingMikeButton.sharedInstance.isHidden(true)
        talkButtonImageView = window.viewWithTag(109) as! UIImageView
        flagTalkButton = talkButtonImageView.isHidden
        if(!flagTalkButton){
            talkButtonImageView.isHidden = true
            HomeViewController.dummyTalkBtnImgView.isHidden = false
        }
        self.navigationController?.navigationBar.isHidden = true
        self.tableViewHeightConstraint.constant = cellHeight * CGFloat(items.count)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if #available(iOS 13.0, *) {
            if(!flagTalkButton){
                talkButtonImageView.isHidden = false
                HomeViewController.dummyTalkBtnImgView.isHidden = true
            }
        } else {
            PrintUtility.printLog(tag: "AlertReusableViewController", text: "Fall into previous version than iOS 13")
        }
        FloatingMikeButton.sharedInstance.hideFloatingMicrophoneBtnInCustomViews()
    }

    func setUpUI () {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(viewAlpha)
        self.alertTableView.layer.cornerRadius = cornerRadius
        self.alertTableView.layer.masksToBounds = true
        self.alertTableView.rowHeight = UITableView.automaticDimension
        self.alertTableView.estimatedRowHeight = cellHeight
        alertTableView.register(UINib(nibName: KAlertTableViewCell, bundle: nil), forCellReuseIdentifier: KAlertTableViewCell)
    }

    /// Add to favorites
    func addFavorite (index : IndexPath) {
        let cell = self.alertTableView.cellForRow(at: index) as! AlertTableViewCell
        
        if(chatItemModel?.chatItem != nil){
            if chatItemModel!.chatItem?.chatIsLiked == IsLiked.like.rawValue{
                // Favorite limit flag update
                favoriteLogEvent(isLiked: true)
                UserDefaultsProperty<Bool>("FAVORITE_LIMIT_FLAG_KEY").value = false
                alertViewModel.swapLikeValue(chatItemModel!.chatItem!)
                cell.imgView.image = UIImage(named:"icon_favorite_popup.png")
                chatItemModel!.chatItem?.chatIsLiked = IsLiked.noLike.rawValue
            }else{
                favoriteLogEvent(isLiked: false)
                // Favorite limit check
                var favoriteItemCount:Int = 0
                do{
                    favoriteItemCount =  try ChatDBModel().getRowCount(isFavorite: true)
                } catch{}
                if favoriteItemCount >= FAVORITE_MAX_LIMIT {
                    // Favorite limit flag update
                    UserDefaultsProperty<Bool>("FAVORITE_LIMIT_FLAG_KEY").value = true
                } else {
                    // Favorite limit flag update
                    UserDefaultsProperty<Bool>("FAVORITE_LIMIT_FLAG_KEY").value = false
                    alertViewModel.swapLikeValue(chatItemModel!.chatItem!)
                    cell.imgView.image = UIImage(named:"icon_favorite_select_popup.png")
                    chatItemModel!.chatItem?.chatIsLiked = IsLiked.like.rawValue
                }
            }
            self.delegate?.updateFavourite(chatItemModel: chatItemModel!)
        }else{
            if UserDefaultsUtility.getBoolValue(forKey: kIsAlreadyFavorite) == true {
                UserDefaultsUtility.setBoolValue(false, forKey: kIsAlreadyFavorite)
                cell.imgView.image = UIImage(named: items[index.row].imageName)
            } else {
                UserDefaultsUtility.setBoolValue(true, forKey: kIsAlreadyFavorite)
                cell.imgView.image = UIImage(named:"icon_favorite_select_popup.png")
            }
        }
    }

    func retranslation () {
        self.delegate?.transitionFromRetranslation(chatItemModel: self.chatItemModel)
    }
    
    func deleteItemPressed () {
        self.delegate?.onDeleteItem(chatItemModel: self.chatItemModel)
    }

    func showPracticeView () {
        self.delegate?.pronunciationPracticeTap(chatItemModel: self.chatItemModel)
    }

    func shareTranslation () {
        PrintUtility.printLog(tag: "TAG", text: "shareJson shareTranslation delegate calling")
        self.delegate?.onSharePressed(chatItemModel: self.chatItemModel)
    }

    func reverseTranslation () {
        //DispatchQueue.main.async {
            //self.navigationController?.dismiss(animated: true, completion: nil)
            self.delegate?.transitionFromReverse(chatItemModel: self.chatItemModel)
       // }
    }

    /// Dynamically update table view height
    func updateTableViewHeight () {
        UIView.animate(withDuration: 0, animations: {
            self.alertTableView.layoutIfNeeded()
        }) { (complete) in
            var heightOfTableView: CGFloat = 0.0
            // Get visible cells and sum up their heights
            let cells = self.alertTableView.visibleCells
            for cell in cells {
                heightOfTableView += cell.frame.height
            }
            // Edit heightOfTableViewConstraint's constant to update height of table view
            self.tableViewHeightConstraint.constant = heightOfTableView
        }
    }

    private func setAnalyticsScreenName() {
        if let fromScreen = fromScreenPurpose {
            switch fromScreen {
            case .HomeSpeechProcessing:
                analyticsScreenName = analytics.mainResultMenu
            case .HistoryScrren:
                if isFromHistoryTTS {
                    analyticsScreenName = analytics.historyCardMenu
                } else {
                    analyticsScreenName = analytics.historyLongTapMenu
                }
            default:
                break
            }
        }
    }

    private func registerForNotification() {
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIScene.willEnterForegroundNotification, object: nil)

        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }

    deinit {
        connectivity.cancel()
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self, name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }

    @objc private func appWillEnterForeground() {
        PrintUtility.printLog(tag: "AlertReusableViewController", text: "Will Enter foreground")
//        AppDelegate.executeLicenseTokenRefreshFunctionality() { _ in
//        }
    }

}

extension AlertReusableViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Obtain table view cells.
        let defaultCell = tableView.dequeueReusableCell(withIdentifier: KAlertTableViewCell) as! AlertTableViewCell
        var imageName = ""
        var title = ""
        if items[indexPath.row].menuType == .favorite {
            if(chatItemModel?.chatItem != nil){
                if chatItemModel!.chatItem?.chatIsLiked == IsLiked.like.rawValue{
                    imageName = "icon_favorite_select_popup.png"
                    title = "history_remove_fav".localiz()
                } else {
                    imageName = items[indexPath.row].imageName
                    title = items[indexPath.row].title
                }
            }else{
                if UserDefaultsUtility.getBoolValue(forKey: kIsAlreadyFavorite) == true {
                    imageName = "icon_favorite_select_popup.png"
                    title = "history_remove_fav".localiz()
                } else {
                    imageName = items[indexPath.row].imageName
                    title = items[indexPath.row].title
                }
            }

        } else {
            imageName = items[indexPath.row].imageName
            title = items[indexPath.row].title
        }
        defaultCell.configureCell(title: title, imageName: imageName)

        ///Update tableview height for visible cells
        if indexPath.row == items.count-1{
            self.updateTableViewHeight()
        }
        return defaultCell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = items[indexPath.row].menuType
        switch type {
        case .favorite:
            self.dismiss(animated: true, completion: nil)
            self.addFavorite(index: indexPath)
            break
        case .retranslation :
            //self.showToast(message: kTranslateIntoOtherLanguageUnderDevelopment, seconds: toastDisplayTime)
            /// ToDo in next version
            retranslateLogEvent()
            self.dismiss(animated: true, completion: nil)
            self.retranslation()
            break
        case .reverse:
            //self.showToast(message: kReverseTranslationUnderDevelopment, seconds: toastDisplayTime)
            /// ToDo in next version
            reverseTranslateLogEvent()
             self.dismiss(animated: false, completion: nil)
            self.reverseTranslation()
            break
        case .practice :
            practicePronunciationLogEvent()
            self.dismiss(animated: true, completion: nil)
            showPracticeView()
            break
        case .sendMail :
            shareLogEvent()
            PrintUtility.printLog(tag: "TAG", text: "shareJson sendmail button pressed")
            self.dismiss(animated: true, completion: nil)
            shareTranslation()
            break
        case .cancel :
            cancelLogEvent()
            self.dismiss(animated: true, completion: nil)
        case .delete :
            deleteLogEvent()
            self.dismiss(animated: true, completion: nil)
            deleteItemPressed()
            break
        }
    }
}

//MARK: - Google analytics log events
extension AlertReusableViewController {
    private func favoriteLogEvent(isLiked: Bool) {
        if let screenName = analyticsScreenName {
            analytics.addToFavorite(screenName: screenName,
                                    buttonName: analytics.buttonFav,
                                    isLiked: !isLiked)
        }
    }

    private func retranslateLogEvent() {
        if let screenName = analyticsScreenName {
            analytics.buttonTap(screenName: screenName,
                                buttonName: analytics.buttonDestinationLang)
        }
    }

    private func reverseTranslateLogEvent() {
        if let screenName = analyticsScreenName {
            analytics.buttonTap(screenName: screenName,
                                buttonName: analytics.buttonReverseTranslate)
        }
    }

    private func practicePronunciationLogEvent() {
        if let screenName = analyticsScreenName {
            let desLanguageName = self.chatItemModel?.chatItem?.textTranslatedLanguage ?? ""
            analytics.updateDestinationLanguage(screenName: screenName,
                                                buttonName: analytics.buttonPractice,
                                                desLanguageName: desLanguageName)
        }
    }

    private func shareLogEvent() {
        if let screenName = analyticsScreenName {
            analytics.buttonTap(screenName: screenName,
                                buttonName: analytics.buttonShare)
        }
    }

    private func cancelLogEvent() {
        if let screenName = analyticsScreenName {
            analytics.buttonTap(screenName: screenName,
                                buttonName: analytics.buttonCancel)
        }
    }

    private func deleteLogEvent() {
        if let screenName = analyticsScreenName {
            if screenName == analytics.historyCardMenu {
                let srcLangName = self.chatItemModel?.chatItem?.textNativeLanguage ?? ""
                let desLangName = self.chatItemModel?.chatItem?.textTranslatedLanguage ?? ""

                analytics.historyCardMenuDelete(screenName: screenName,
                                                srcLanguageName: srcLangName,
                                                desLanguageName: desLangName)
            } else {
                analytics.buttonTap(screenName: screenName,
                                    buttonName: analytics.buttonDelete)
            }
        }
    }
}

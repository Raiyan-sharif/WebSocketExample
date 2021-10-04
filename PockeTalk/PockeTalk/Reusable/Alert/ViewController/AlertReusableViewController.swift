//
// AlertReusable.swift
// PockeTalk
//

import UIKit
protocol AlertReusableDelegate {
    func updateFavourite(chatItemModel: HistoryChatItemModel)
    func transitionFromReverse(chatItemModel: HistoryChatItemModel?)
    func transitionFromRetranslation (chatItemModel: HistoryChatItemModel?)
    func pronunciationPracticeTap (chatItemModel: HistoryChatItemModel?)
    func onDeleteItem(chatItemModel: HistoryChatItemModel?)
}

class AlertReusableViewController: BaseViewController {
    static var nib: UINib =  UINib.init(nibName: KAlertReusable, bundle: nil)
    /// Views
    @IBOutlet weak var alertTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!

    /// Properties
    var items : [AlertItems] = []
    let cellHeight : CGFloat = 58.0
    let cornerRadius : CGFloat = 15.0
    let viewAlpha : CGFloat = 0.8
    var chatItemModel: HistoryChatItemModel?
    var alertViewModel: AlertReusableViewModel!
    var delegate : AlertReusableDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        alertViewModel = AlertReusableViewModel()
        self.setUpUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.tableViewHeightConstraint.constant = cellHeight * CGFloat(items.count)
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
            alertViewModel.swapLikeValue(chatItemModel!.chatItem!)
            if chatItemModel!.chatItem?.chatIsLiked == IsLiked.like.rawValue{
                cell.imgView.image = UIImage(named:"icon_favorite_popup.png")
                chatItemModel!.chatItem?.chatIsLiked = IsLiked.noLike.rawValue
            }else{
                cell.imgView.image = UIImage(named:"icon_favorite_select_popup.png")
                chatItemModel!.chatItem?.chatIsLiked = IsLiked.like.rawValue
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

    func reverseTranslation () {
        if(chatItemModel?.chatItem != nil){
            let isTop = chatItemModel?.chatItem?.chatIsTop == IsTop.top.rawValue ? IsTop.noTop.rawValue : IsTop.top.rawValue
            let nativeText = chatItemModel!.chatItem!.textTranslated
            let targetText = chatItemModel!.chatItem!.textNative
            let nativeLangName = chatItemModel!.chatItem!.textTranslatedLanguage!
            let targetLangName = chatItemModel!.chatItem!.textNativeLanguage
            
            let chatEntity =  ChatEntity.init(id: nil, textNative: nativeText, textTranslated: targetText, textTranslatedLanguage: targetLangName, textNativeLanguage: nativeLangName, chatIsLiked: IsLiked.noLike.rawValue, chatIsTop: isTop, chatIsDelete: IsDeleted.noDelete.rawValue, chatIsFavorite: IsFavourite.noFavourite.rawValue)
            
            let row = alertViewModel.saveChatItem(chatItem: chatEntity)
            chatEntity.id = row
            self.chatItemModel?.chatItem = chatEntity
        }
        DispatchQueue.main.async {
            self.navigationController?.dismiss(animated: true, completion: nil)
            self.delegate?.transitionFromReverse(chatItemModel: self.chatItemModel)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
            self.dismiss(animated: true, completion: nil)
            self.retranslation()
            break
        case .reverse:
            self.dismiss(animated: true, completion: nil)
            self.reverseTranslation()
            break
        case .practice :
            self.dismiss(animated: true, completion: nil)
            showPracticeView()
            break
        case .sendMail :
            break
        case .cancel :
            self.dismiss(animated: true, completion: nil)
        case .delete :
            self.dismiss(animated: true, completion: nil)
            deleteItemPressed()
            break
        }
     
    }
}

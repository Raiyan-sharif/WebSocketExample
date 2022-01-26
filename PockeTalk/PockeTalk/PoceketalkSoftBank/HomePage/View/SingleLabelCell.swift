//
//  SingleLabelCell.swift
//  PockeTalk
//

import UIKit

class SingleLabelCell: UITableViewCell {
    @IBOutlet weak private var containerView: UIView!
    @IBOutlet weak private var infoLabel: UILabel!
    
    //MARK: - Lifecycle methods
    override func awakeFromNib() {
        super.awakeFromNib()
        changeFontSize()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: - Configure cell
    func configCell(ttsText: String, indexPath: IndexPath, chatItem: ChatEntity?) {
        infoLabel.text = ttsText
        if indexPath.row == 2 {
            infoLabel.textColor = .gray
            if let nativeLanguage = chatItem?.textNativeLanguage,
               let nativeLanguageCode = LanguageSelectionManager.shared.getLanguageCodeByName(langName: nativeLanguage) {

                if (nativeLanguageCode.code == BURMESE_MY_LANGUAGE_CODE) {
                    infoLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE)
                }
                else {
                    infoLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_OTHERS_LANGUAGE)
                }
            }
        } else {
            infoLabel.textColor = .black
            if let translatedLanguage = chatItem?.textTranslatedLanguage,
               let translatedLanguageCode = LanguageSelectionManager.shared.getLanguageCodeByName(langName: translatedLanguage) {

                if (translatedLanguageCode.code == BURMESE_MY_LANGUAGE_CODE) {
                    infoLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_BURMESE_LANGUAGE)
                }
                else {
                    infoLabel.setLineHeight(lineHeight: LABEL_LINE_HEIGHT_FOR_OTHERS_LANGUAGE)
                }
            }
        }
        infoLabel.textAlignment = .center
    }
}

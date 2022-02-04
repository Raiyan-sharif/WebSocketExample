//
//  FloatingMikeButton.swift
//  PockeTalk
//

import UIKit

protocol FloatingMikeButtonDelegate: AnyObject{
    func didTapOnMicrophoneButton()
}

class FloatingMikeButton: NSObject{
    private let TAG = "\(FloatingMikeButton.self)"
    public static let sharedInstance = FloatingMikeButton()
    private let widthMicrophone : CGFloat = 50
    var window = UIWindow()
    private var floatingMicrophoneButton: UIButton!
    private var dummyFloatingMicrophoneButton: UIButton!
    weak var delegate: FloatingMikeButtonDelegate?
    
    private override init() {
        super.init()
    }
    
    ///Add mike button on window
    func add(){
        let bottomMergin = (window.frame.maxY / 4) / 2 + widthMicrophone / 2
        
        floatingMicrophoneButton = UIButton(frame: CGRect(
            x: window.frame.maxX - 60,
            y: window.frame.maxY - bottomMergin,
            width: widthMicrophone,
            height: widthMicrophone)
        )
        
        floatingMicrophoneButton.setImage(UIImage(named: "mic"), for: .normal)
        floatingMicrophoneButton.backgroundColor = UIColor._buttonBackgroundColor()
        floatingMicrophoneButton.layer.cornerRadius = widthMicrophone/2
        floatingMicrophoneButton.clipsToBounds = true
        floatingMicrophoneButton.tag = floatingMikeButtonTag
        window.addSubview(floatingMicrophoneButton)
        
        floatingMicrophoneButton.addTarget(self, action: #selector(microphoneTapAction(sender:)), for: .touchUpInside)
    }
    
    ///Mike button tap functionality
    @objc private func microphoneTapAction (sender:UIButton) {
        delegate?.didTapOnMicrophoneButton()
    }
    
    ///Show and hide mike button
    func isHidden(_ isHidden: Bool){
        floatingMicrophoneButton.isHidden = isHidden
    }
    
    ///Remove mike button from current window
    func remove(){
        floatingMicrophoneButton.removeFromSuperview()
    }
    
    ///Check mike button exist on current window
    func isMikeButtonExistOnWindow() -> Bool{
        guard let mikeBtn = window.viewWithTag(floatingMikeButtonTag) else {return false}
        
        if window.subviews.contains(mikeBtn) {
            return true
        } else {
            return false
        }
    }
    
    ///Check mike button hidden status
    func hiddenStatus() -> Bool{
        guard let floatingBtnStatus = window.viewWithTag(floatingMikeButtonTag)?.isHidden else {return false}
        return floatingBtnStatus == true ? (true) : (false)
    }
    
    ///Hide mike button on "NoInternet" & "CustomAlert" UI
    func hideFloatingMicrophoneBtnInCustomViews(){
        if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice ||
            ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionVoice ||
            ScreenTracker.sharedInstance.screenPurpose == .CountrySelectionByVoice ||
            ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionCamera ||
            ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionCamera {
            isHidden(false)
        } else {
            isHidden(true)
        }
    }
}

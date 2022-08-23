//
//  HomeViewController+Extension.swift
//  PockeTalk
//

import UIKit

protocol HomeVCDelegate: AnyObject{
    func startRecord()
    func stopRecord()
}

extension HomeViewController{
    
    func setUPLongPressGesture(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(gesture:)))
        longPress.minimumPressDuration = 0.5
        talkBtnImgView.addGestureRecognizer(longPress)
        bottmViewGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(gesture:)))
        bottmViewGesture.minimumPressDuration = 0.5
        bottomView.addGestureRecognizer(bottmViewGesture)
    }
    func hideORShowlTalkButton(isEnable:Bool){
        if let imgView = self.bottomView.viewWithTag(109) as? UIImageView{
            imgView.isHidden = isEnable
        }
    }
    func enableORDisableMicrophoneButton(isEnable:Bool){
        if let imgView = self.bottomView.viewWithTag(109) as? UIImageView{
            imgView.isUserInteractionEnabled = isEnable
            bottomView.isUserInteractionEnabled = isEnable
        }
    }
    
    func homeGestureEnableOrDiable(){
        homeContainerView.isHidden = self.homeContainerView.subviews.count == 0
    }
    
    private func isSwipUpGestureEnable() -> Bool {
        if historyCardVC.view.subviews.count > 0 {
            for view in historyCardVC.view.subviews {
                if view.tag == ttsAlertViewTag {
                    return true
                }
            }
        }
        
        if isFromlanguageSelection(){
            return true
        }
        
        if ScreenTracker.sharedInstance.screenPurpose == .HistroyPronunctiation {
            return true
        }
        
        return false
    }
    
    func hideSpeechView(){
        self.speechContainerView.isHidden = true
        TalkButtonAnimation.stopAnimation(bottomView: bottomView, pulseGrayWave: pulseGrayWave, pulseLayer: pulseLayer, midCircleViewOfPulse: midCircleViewOfPulse, bottomImageView: bottomImageView)
        bottomImageView.isHidden = true
        homeGestureEnableOrDiable()
        HomeViewController.showOrHideTalkButtonImage(!self.isFromPronuntiationPractice())
        PrintUtility.printLog(tag: "ScreenTracker.sharedInstance.screenPurpose", text: "\(ScreenTracker.sharedInstance.screenPurpose)")
    }
    
    @objc func animationDidEnterBackground(notification: Notification) {
        if TalkButtonAnimation.isTalkBtnAnimationExist {
            talkBtnImgView.image = #imageLiteral(resourceName: "talk_button").withRenderingMode(.alwaysOriginal)
            if !self.speechVC.isMinimumLimitExceed {
                self.enableORDisableMicrophoneButton(isEnable: false)
            }else{
                self.speechVC.isMinimumLimitExceed = false
            }
            self.homeVCDelegate?.stopRecord()
            
            TalkButtonAnimation.isTalkBtnAnimationExist = false
            TalkButtonAnimation.stopAnimation(bottomView: self.bottomView, pulseGrayWave: self.pulseGrayWave, pulseLayer: self.pulseLayer, midCircleViewOfPulse: self.midCircleViewOfPulse, bottomImageView: self.bottomImageView)
        }
    }
    
    private func openSpeechView(){
        if self.isFromPronuntiationPractice() != true{
            bottomImageViewHeight.constant = view.frame.height * 0.8
            UIView.animate(withDuration: fadeAnimationDuration, delay: fadeAnimationDelay, options: .curveEaseOut) {
                if self.isFromlanguageSelection() == false {
                    self.historyCardVC.view.alpha = self.fadeOutAlpha
                }
            } completion: { _ in
                if self.isFromlanguageSelection() == false {
                    self.dissmissHistory(shouldUpdateViewAlpha: false, isFromHistoryScene: false)
                }
                let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: speechViewTransitionTime, animationStyle: CATransitionSubtype.fromTop)
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.speechContainerView.isHidden = false
            }
        } else {
            bottomImageViewHeight.constant = view.frame.height * 0.5
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: speechViewTransitionTime, animationStyle: CATransitionSubtype.fromTop)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.speechContainerView.isHidden = false
        }
        
        //Hide microphone button when talk button tap and navigate to speech view
        FloatingMikeButton.sharedInstance.isHidden(true)
    }
    
    func getLastVCFromContainer()->UIViewController?{
        return homeContainerView.subviews.last?.parentViewController
    }
    
    func removeAllChildControllers(_ isNative: Int){
        if isFromCameraPreview {
            let transition = GlobalMethod.addMoveOutTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            
        }
        for view in homeContainerView.subviews{
            if let controller = view.parentViewController{
                if(controller is LangSelectVoiceVC){
                    var tr = GlobalMethod.addMoveOutTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: .fromLeft)
                    if isNative == IsTop.top.rawValue{
                        tr = GlobalMethod.addMoveOutTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: .fromRight)
                    }
                    remove(asChildViewController: controller, animation: tr)
                }else{
                    remove(asChildViewController: controller)
                    
                }
            }
        }
        
        for view in historyCardVC.view.subviews {
            if view.tag == ttsAlertViewTag {
                view.removeFromSuperview()
            }
        }
        
        homeGestureEnableOrDiable()
        isFromCameraPreview = false
        enableorDisableGesture(notification: nil)
    }

    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
            if isGranted {
                let imageView = self.window.viewWithTag(109) as! UIImageView
                let languageManager = LanguageSelectionManager.shared
                let isArrowUp = languageManager.isArrowUp
                var nativeLangCode = LanguageSelectionManager.shared.bottomLanguage
                let targetLangCode = LanguageSelectionManager.shared.topLanguage
                if (!isArrowUp){
                    nativeLangCode = targetLangCode
                }
                let hasSttSupport = languageManager.hasSttSupport(languageCode: nativeLangCode)

                if gesture.state == .began {
                    if Reachability.isConnectedToNetwork() {
                        HomeViewController.showOrHideTalkButtonImage(true)

                        //Talk button log event functionalities
                        self.talkButtonLogEventHelper()

                        if ScreenTracker.sharedInstance.screenPurpose == .HistoryScrren || ScreenTracker.sharedInstance.screenPurpose == .FavouriteScreen {
                            ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
                        }
                        if (ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing && !hasSttSupport) {
                            if self.nextState == .collapsed {
                                self.animateTransitionIfNeeded(state: self.nextState, shouldUpdateCardViewAlpha: true)
                            }
                            self.updateContainer(notification: Notification(name: .containerViewSelection))
                            let alertService = CustomAlertViewModel()
                            let alert = alertService.alertDialogWithoutTitleWithOkButton(message: "no_stt_msg".localiz())
                            self.present(alert, animated: true, completion: nil)
//                            GlobalMethod.showAlert("no_stt_msg".localiz(), in: self, completion: nil)
                        }else{
                            //self.setBlackGradientImageToBottomView(usingState: .black)
                            DispatchQueue.main.async {
                                guard let url = Bundle.main.url(forResource: "start_record", withExtension: "wav") else { return }
                                AudioPlayer.sharedInstance.playSTTSound(url: url)
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
//                            SocketManager.sharedInstance.connect()
                            SocketManager.sharedInstance.socketManagerDelegate = self.speechVC
                            self.speechVC.updateLanguageType()

                            if TokenApiStateObserver.shared.apiState != .running {
                                self.isWaitingForTokenApi = false
                                self.callLicenseTokenApi(gesture: gesture)
                            }else{
                                self.gesture = gesture
                                self.isWaitingForTokenApi = true
                            }
                            
                            self.speechVC.hideOrOpenExampleText(isHidden: true)
                            imageView.image = #imageLiteral(resourceName: "talk_button").withRenderingMode(.alwaysTemplate)
                            
                            self.openSpeechView()
                            if ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing{
                                self.removeAllChildControllers(Int(IsTop.top.rawValue))
                            }
                            
                            self.homeVCDelegate?.startRecord()
                            
                            TalkButtonAnimation.isTalkBtnAnimationExist = true
                            TalkButtonAnimation.startTalkButtonAnimation(pulseGrayWave: self.pulseGrayWave, pulseLayer: self.pulseLayer, midCircleViewOfPulse: self.midCircleViewOfPulse, bottomImageView: self.bottomImageView)
                        }
                    }else {
                        GlobalMethod.showNoInternetAlert()
                    }
                }
                
                if gesture.state == .ended {
                    if Reachability.isConnectedToNetwork() {
                        if (ScreenTracker.sharedInstance.screenPurpose != .HomeSpeechProcessing || hasSttSupport){
                            imageView.image = #imageLiteral(resourceName: "talk_button").withRenderingMode(.alwaysOriginal)
                            self.homeVCDelegate?.stopRecord()
                            if !self.speechVC.isMinimumLimitExceed {
                                self.enableORDisableMicrophoneButton(isEnable: false)
                            }else{
                                self.speechVC.isMinimumLimitExceed = false
                            }
                            TalkButtonAnimation.isTalkBtnAnimationExist = false
                            TalkButtonAnimation.stopAnimation(bottomView: self.bottomView, pulseGrayWave: self.pulseGrayWave, pulseLayer: self.pulseLayer, midCircleViewOfPulse: self.midCircleViewOfPulse, bottomImageView: self.bottomImageView)
                        }
                    }
                }
            } else {
                GlobalMethod.showPermissionAlert(viewController: self, title : kMicrophoneUsageTitle, message : kMicrophoneUsageMessage)
            }
        }
    }

    func callLicenseTokenApi(gesture: UILongPressGestureRecognizer) {
        AppDelegate.executeLicenseTokenRefreshFunctionality(){ [weak self] result in
            guard let `self` = self else {return}
            if result { 
                if self.speechVC.languageHasUpdated{
                    self.speechVC.updateLanguageInRemote(completion: { isOk in
                        if isOk{
                            SocketManager.sharedInstance.connect()
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) {
                                gesture.state = .ended
                            }
                        }
                    })
                }else{
                    SocketManager.sharedInstance.connect()
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) {
                    gesture.state = .ended
                }
            }
        }
    }

    private func talkButtonLogEventHelper() {
        //Update the speech processing fromScreenPurpose property
        self.speechVC.fromScreenPurpose = ScreenTracker.sharedInstance.screenPurpose

        //Get the source and destination lang name
        let src = LanguageSelectionManager.shared.isArrowUp == true ? LanguageSelectionManager.shared.bottomLanguage : LanguageSelectionManager.shared.topLanguage
        let des = LanguageSelectionManager.shared.isArrowUp == true ? LanguageSelectionManager.shared.topLanguage : LanguageSelectionManager.shared.bottomLanguage

        let srcLangName =  LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: src)?.name ?? ""
        let desLangName = LanguageSelectionManager.shared.getLanguageInfoByCode(langCode: des)?.name ?? ""

        //Trigger logEvent depending on the screen purpose
        if !(UserDefaultsProperty<Bool>(kHistoryTTS).value ?? false) {
            if ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing {
                self.homeTalkButtonLogEvent(sourceLanguage: srcLangName, destinationLanguage: desLangName)
            } else if ScreenTracker.sharedInstance.screenPurpose == .HistoryScrren {
                self.historyTalkButtonLogEvent(sourceLanguage: srcLangName, destinationLanguage: desLangName)
            }
        }
    }
    
    func isFromPronuntiationPractice()-> Bool{
        return ScreenTracker.sharedInstance.screenPurpose == .PronunciationPractice ||
        ScreenTracker.sharedInstance.screenPurpose == .HistroyPronunctiation
    }
    
    func isFromlanguageSelection()-> Bool{
        return ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice ||
        ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionVoice ||
        ScreenTracker.sharedInstance.screenPurpose == .LanguageSettingsSelectionVoice ||
        
        ScreenTracker.sharedInstance.screenPurpose == .CountrySelectionByVoice ||
        ScreenTracker.sharedInstance.screenPurpose == .CountrySettingsSelectionByVoice ||
        
        ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionCamera ||
        ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionCamera ||
        ScreenTracker.sharedInstance.screenPurpose == .LanguageSettingsSelectionCamera
    }
}


//MARK: - Bottom View functionality
extension HomeViewController {
    func setupGestureForBottomView() {
        self.bottomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBottomGesture(recognizer:))))
    }
    
    @objc private func handleBottomGesture(recognizer: UITapGestureRecognizer) {
        if(recognizer.state == .ended){
            let point = recognizer.location(in: view)
            var pointDictionary = [String: CGPoint]()
            pointDictionary["point"] = point
            
            if(ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice || ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionVoice){
                NotificationCenter.default.post(name: .talkButtonContainerSelectionPoint, object: nil, userInfo: pointDictionary)
            }
        }
    }
}

extension HomeViewController{
    class func showOrHideTalkButtonImage(_ isHidden: Bool){
        if let img = UIApplication.shared.keyWindow?.viewWithTag(110) as? UIImageView{
            img.isHidden = isHidden
        }
    }
}

enum BottomImageViewState{
    case gradient
    case black
    case hidden
}

//MARK: - Google analytics log events
extension HomeViewController {
    func sourceLanguageButtonLogEvent(){
        analytics.buttonTap(screenName: analytics.home,
                            buttonName: analytics.buttonSourceLang)
    }

    func destinationLanguageButtonLogEvent(){
        analytics.buttonTap(screenName: analytics.home,
                            buttonName: analytics.buttonDestinationLang)
    }

    func historyTrayTapLogEvent(){
        analytics.buttonTap(screenName: analytics.home,
                            buttonName: analytics.buttonHistory)
    }

    func cameraButtonLogEvent(){
        analytics.buttonTap(screenName: analytics.home,
                            buttonName: analytics.buttonCamera)
    }

    func menuButtonLogEvent(){
        analytics.buttonTap(screenName: analytics.home,
                            buttonName: analytics.buttonSettings)
    }

    func changeLanguageButtonLogEvent(sourceLanguage: String, destinationLanguage: String){
        analytics.changeLanguage(screenName: analytics.home,
                                 buttonName: analytics.buttonExchangeLang,
                                 srcLanguageName: sourceLanguage,
                                 desLanguageName: destinationLanguage)
    }

    private func homeTalkButtonLogEvent(sourceLanguage: String, destinationLanguage: String) {
        analytics.mainTalkButton(screenName: analytics.home,
                                 srcLanguageName: sourceLanguage,
                                 desLanguageName: destinationLanguage)
    }

    func historyTalkButtonLogEvent(sourceLanguage: String, destinationLanguage: String) {
        analytics.historyTalkButton(screenName: analytics.history,
                                 srcLanguageName: sourceLanguage,
                                 desLanguageName: destinationLanguage)
    }
}





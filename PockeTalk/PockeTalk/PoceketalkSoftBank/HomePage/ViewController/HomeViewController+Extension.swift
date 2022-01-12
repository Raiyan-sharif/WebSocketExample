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
        showMicrophoneBtnInLanguageScene()
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
                    self.dissmissHistory(shouldUpdateViewAlpha: false)
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
        self.hideMicrophoneBtnInLanguageScene()
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
                if gesture.state == .began {
                    if Reachability.isConnectedToNetwork() {
//                        self.setBlackGradientImageToBottomView(usingState: .black)
                        SocketManager.sharedInstance.connect()
                        SocketManager.sharedInstance.socketManagerDelegate = self.speechVC
                        
                        if ScreenTracker.sharedInstance.screenPurpose == .HistoryScrren || ScreenTracker.sharedInstance.screenPurpose == .FavouriteScreen{
                            ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
                        }
                        self.speechVC.updateLanguageType()
                        
                        if self.speechVC.languageHasUpdated{
                            self.speechVC.updateLanguageInRemote()
                        }
                        
                        self.speechVC.hideOrOpenExampleText(isHidden: true)
                        imageView.image = #imageLiteral(resourceName: "talk_button").withRenderingMode(.alwaysTemplate)
                        
                        self.openSpeechView()
                        if ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing{
                            self.removeAllChildControllers(Int(IsTop.top.rawValue))
                        }
                        
                        SpeechProcessingViewModel.isLoading = false;
                        self.homeVCDelegate?.startRecord()
                        
                        TalkButtonAnimation.isTalkBtnAnimationExist = true
                        TalkButtonAnimation.startTalkButtonAnimation(pulseGrayWave: self.pulseGrayWave, pulseLayer: self.pulseLayer, midCircleViewOfPulse: self.midCircleViewOfPulse, bottomImageView: self.bottomImageView)
                        
                        
                    }else {
                        GlobalMethod.showNoInternetAlert()
                    }
                }
                
                if gesture.state == .ended {
                    imageView.image = #imageLiteral(resourceName: "talk_button").withRenderingMode(.alwaysOriginal)
                    
                    SpeechProcessingViewModel.isLoading = true;
                    if !self.speechVC.isMinimumLimitExceed {
                        self.enableORDisableMicrophoneButton(isEnable: false)
                    }else{
                        self.speechVC.isMinimumLimitExceed = false
                    }
                    self.homeVCDelegate?.stopRecord()
                    
                    TalkButtonAnimation.isTalkBtnAnimationExist = false
                    TalkButtonAnimation.stopAnimation(bottomView: self.bottomView, pulseGrayWave: self.pulseGrayWave, pulseLayer: self.pulseLayer, midCircleViewOfPulse: self.midCircleViewOfPulse, bottomImageView: self.bottomImageView)
                }
                
            } else {
                GlobalMethod.showPermissionAlert(viewController: self, title : kMicrophoneUsageTitle, message : kMicrophoneUsageMessage)
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
    
    private func hideMicrophoneBtnInLanguageScene(){
        if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice {
            NotificationCenter.default.post(name: .hideMicrophoneLanguageSelectionVoice, object: nil)
        }
        
        else if ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionVoice {
            NotificationCenter.default.post(name: .hideMicrophoneLanguageSelectionVoice, object: nil)
        }
        
        else if ScreenTracker.sharedInstance.screenPurpose == .CountrySelectionByVoice {
            NotificationCenter.default.post(name: .hideMicrophoneCountrySelectionVoice, object: nil)
        }
        
        else if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionCamera {
            NotificationCenter.default.post(name: .hideMicrophoneLanguageSelectionVoiceCamera, object: nil)
        }
        
        else if ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionCamera {
            NotificationCenter.default.post(name: .hideMicrophoneLanguageSelectionVoiceCamera, object: nil)
        }
    }
    
    private func showMicrophoneBtnInLanguageScene(){
        if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice {
            NotificationCenter.default.post(name: .showMicrophoneLanguageSelectionVoice, object: nil)
        }
        
        else if ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionVoice {
            NotificationCenter.default.post(name: .showMicrophoneLanguageSelectionVoice, object: nil)
        }
        
        else if ScreenTracker.sharedInstance.screenPurpose == .CountrySelectionByVoice {
            NotificationCenter.default.post(name: .showMicrophoneCountrySelectionVoice, object: nil)
        }
        
        else if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionCamera {
            NotificationCenter.default.post(name: .showMicrophoneLanguageSelectionVoiceCamera, object: nil)
        }
        
        else if ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionCamera {
            NotificationCenter.default.post(name: .showMicrophoneLanguageSelectionVoiceCamera, object: nil)
        }
    }
}


//MARK: - HistoryCardVC Functionalities
extension HomeViewController {
    //MARK: - Talk Button Selection Point Post Notification
    func setupGestureForBottomView() {
    
        self.bottomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleBottomGesture(recognizer:))))
    }
    @objc private func handleBottomGesture(recognizer: UITapGestureRecognizer) {
        if(recognizer.state == .ended){
            let point = recognizer.location(in: view)
            print(type(of: point))
            var pointDictionary = [String: CGPoint]()
            pointDictionary["point"] = point
            
            if(ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice || ScreenTracker.sharedInstance.screenPurpose == .LanguageHistorySelectionVoice){
                NotificationCenter.default.post(name: .talkButtonContainerSelectionPoint, object: nil, userInfo: pointDictionary)
            }
        }
    }
    
    //MARK: - HistoryCardview setup
    func setupCardView() {
        historyCardVC = HistoryCardViewController(nibName: "HistoryCardViewController", bundle: nil)
        self.addChild(historyCardVC)
        self.view.addSubview(historyCardVC.view)
        historyCardVC.delegate = self
        
        historyCardVC.view.frame = CGRect(
            x: 0,
            y: -cardHeight + UIApplication.shared.statusBarFrame.height,
            width: self.view.bounds.width,
            height: cardHeight)
        historyCardVC.view.clipsToBounds = true
    }
    
    func setupGestureForCardView() {
        historyImageView.isUserInteractionEnabled = true
        
        imageViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCardPanForImageGesture(recognizer:)))
        self.historyImageView.addGestureRecognizer(imageViewPanGesture)
        
        viewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCardPanForViewGesture(recognizer:)))
        self.view.addGestureRecognizer(viewPanGesture)
        
    }
    
    @objc private func handleCardPanForImageGesture (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            self.historyImageView.isHidden = true
            startInteractiveTransition(state: nextState, duration: historyCardAnimationDuration)
            self.historyCardVC.updateData(shouldCVScrollToBottom: true)
        case .changed:
            let translation = recognizer.translation(in: self.view)
            var fractionComplete = translation.y / cardHeight
            fractionComplete = cardVisible ? -fractionComplete : fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            continueInteractiveTransition()
            ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
            self.enableorDisableGesture(notification:nil)
        default:
            break
        }
    }
    
    @objc private func handleCardPanForViewGesture (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .ended:
            let translationY = recognizer.translation(in: self.view).y
            if nextState == .collapsed && translationY < 0 {
                if !isSwipUpGestureEnable() {
                    animateTransitionIfNeeded(state: nextState, shouldUpdateCardViewAlpha: false)
                    self.historyCardVC.updateData(shouldCVScrollToBottom: true)

                    //Remove all the child container while swipe up to dismiss
                    removeAllChildControllers(Int(IsTop.top.rawValue))
                    ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
                    self.enableorDisableGesture(notification:nil)
                }
            }
            
            if nextState == .expanded && translationY > 0 {
                if ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing {
                    animateTransitionIfNeeded(state: nextState, shouldUpdateCardViewAlpha: false)
                    self.historyCardVC.updateData(shouldCVScrollToBottom: true)
                    ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
                    self.enableorDisableGesture(notification:nil)
                }
            }
            self.historyImageView.isHidden = false
        default:
            break
        }
    }
    
    //MARK: - CardView animation functionalities
    private func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, shouldUpdateCardViewAlpha: false)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    private func updateInteractiveTransition(fractionCompleted:CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    private func continueInteractiveTransition (){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    private func animateTransitionIfNeeded (state:CardState, shouldUpdateCardViewAlpha: Bool) {
        if runningAnimations.isEmpty {
            
            if !shouldUpdateCardViewAlpha {
                self.historyCardVC.view.alpha = 1
            }
            
            let frameAnimator = UIViewPropertyAnimator(duration: historyCardAnimationDuration, dampingRatio: 1) { [weak self] in
                guard let `self` = self else { return }
                switch state {
                case .expanded:
                    self.historyCardVC.view.frame.origin.y = 0
                case .collapsed:
                    self.historyCardVC.view.frame.origin.y = -self.cardHeight + UIApplication.shared.statusBarFrame.height
                    self.historyDissmissed()
                }
            }
            
            frameAnimator.addCompletion { _ in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
        }
    }
}

//MARK: - HistoryCardViewControllerDelegate
extension HomeViewController: HistoryCardViewControllerDelegate {
    func dissmissHistory(shouldUpdateViewAlpha: Bool) {
        historyDissmissed()
        animateTransitionIfNeeded(state: .collapsed, shouldUpdateCardViewAlpha: shouldUpdateViewAlpha)
    }
}

enum BottomImageViewState{
    case gradient
    case black
    case hidden
}




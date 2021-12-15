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
        talkBtnImgView.tag = 109
        talkBtnImgView.image = UIImage(named: "talk_button")
        talkBtnImgView.isUserInteractionEnabled = true
        talkBtnImgView.translatesAutoresizingMaskIntoConstraints = false
        bottomImageView.translatesAutoresizingMaskIntoConstraints = false
        talkBtnImgView.tintColor = UIColor._skyBlueColor()
        talkBtnImgView.layer.cornerRadius = width/2
        talkBtnImgView.clipsToBounds = true
        bottomView.addSubview(bottomImageView)
        self.bottomView.addSubview(talkBtnImgView)
        talkBtnImgView.widthAnchor.constraint(equalToConstant: width).isActive = true
        talkBtnImgView.heightAnchor.constraint(equalToConstant: width).isActive = true
        talkBtnImgView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        talkBtnImgView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        
        bottomImageView.widthAnchor.constraint(equalToConstant: bottomView.frame.width).isActive = true
        bottomImageView.heightAnchor.constraint(equalToConstant: bottomView.frame.width / 1.2).isActive = true
        bottomImageView.centerXAnchor.constraint(equalTo: self.bottomView.centerXAnchor).isActive = true
        bottomImageView.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor).isActive = true
        self.bottomImageView.isHidden = true
        self.pulseGrayWave.isHidden = true
        self.pulseLayer.isHidden = true
        self.midCircleViewOfPulse.isHidden = true
        self.bottomImageView.isHidden = true
        self.bottomImageView.image = #imageLiteral(resourceName: "bg_speak").withRenderingMode(.alwaysOriginal)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(gesture:)))
        longPress.minimumPressDuration = 0.1
        talkBtnImgView.addGestureRecognizer(longPress)
    }
    
    func enableORDisableMicrophoneButton(isEnable:Bool){
        if let imgView = self.bottomView.viewWithTag(109) as? UIImageView{
            imgView.isUserInteractionEnabled = isEnable
        }
    }
    
    func homeGestureEnableOrDiable(){
        homeContainerView.isHidden = self.homeContainerView.subviews.count == 0
    }
    
    private func isSwipUpGestureEnable() -> Bool {
        var isAlertViewPresent = false
        
        if historyCardVC.view.subviews.count > 0 {
            for view in historyCardVC.view.subviews {
                if view.tag == ttsAlertViewTag {
                    isAlertViewPresent = true
                }
            }
        }
        
        return isAlertViewPresent
    }
    
    func hideSpeechView(){
        self.speechContainerView.isHidden = true
        homeGestureEnableOrDiable()
        HomeViewController.bottomImageViewOfAnimationRef.image = UIImage(named: "bottomBackgroudImage")
    }
    @objc func animationDidEnterBackground(notification: Notification) {
        talkBtnImgView.image = #imageLiteral(resourceName: "talk_button").withRenderingMode(.alwaysOriginal)
        if !self.speechVC.isMinimumLimitExceed {
            self.enableORDisableMicrophoneButton(isEnable: false)
        }else{
            self.speechVC.isMinimumLimitExceed = false
        }
        self.homeVCDelegate?.stopRecord()
        TalkButtonAnimation.stopAnimation(bottomView: self.bottomView, pulseGrayWave: self.pulseGrayWave, pulseLayer: self.pulseLayer, midCircleViewOfPulse: self.midCircleViewOfPulse, bottomImageView: self.bottomImageView)
    }
    private func openSpeechView(){
        
        if self.isFromPronuntiationPractice() != true{
            UIView.animate(withDuration: fadeAnimationDuration, delay: fadeAnimationDelay, options: .curveEaseOut) {
                if self.isFromlanguageSelection() == false {
                    self.historyCardVC.view.alpha = self.fadeOutAlpha
                }
            } completion: { _ in
                if self.isFromlanguageSelection() == false {
                    self.dissmissHistory()
                }
                let transition = GlobalMethod.getTransitionAnimatation(duration: speechViewTransitionTime, animationStyle: CATransitionSubtype.fromTop)
                self.view.window!.layer.add(transition, forKey: kCATransition)
                self.speechContainerView.isHidden = false
            }
            
        } else {
            
            let transition = GlobalMethod.getTransitionAnimatation(duration: speechViewTransitionTime, animationStyle: CATransitionSubtype.fromTop)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.speechContainerView.isHidden = false
        }
    }
    func getLastVCFromContainer()->UIViewController?{
        return homeContainerView.subviews.last?.parentViewController
    }
    
    func removeAllChildControllers(_ isNative: Int){
        if isFromCameraPreview {
            let transition = GlobalMethod.getBackTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            
        }
        for view in homeContainerView.subviews{
            if let controller = view.parentViewController{
                if(controller is LangSelectVoiceVC){
                    var tr = GlobalMethod.getBackTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: .fromLeft)
                    if isNative == IsTop.top.rawValue{
                        tr = GlobalMethod.getBackTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: .fromRight)
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
    }
    
    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        RuntimePermissionUtil().requestAuthorizationPermission(for: .audio) { (isGranted) in
            if isGranted {
                let imageView = gesture.view! as! UIImageView
                if gesture.state == .began {
                    
                    SocketManager.sharedInstance.connect()
                    SocketManager.sharedInstance.socketManagerDelegate = self.speechVC
                    
                    if ScreenTracker.sharedInstance.screenPurpose == .HistoryScrren{
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
                    
                    
                    // TODO: Remove micrphone functionality as per current requirement. Will modify after final confirmation.
                    /*
                     if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice {
                     NotificationCenter.default.post(name: .tapOnMicrophoneLanguageSelectionVoice, object: nil)
                     }
                     
                     if ScreenTracker.sharedInstance.screenPurpose == .CountrySelectionByVoice {
                     NotificationCenter.default.post(name: .tapOnMicrophoneCountrySelectionVoice, object: nil)
                     }
                     
                     if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionCamera {
                     NotificationCenter.default.post(name: .tapOnMicrophoneCountrySelectionVoiceCamera, object: nil)
                     }
                     */
                    SpeechProcessingViewModel.isLoading = false;
                    self.homeVCDelegate?.startRecord()
                    self.bottomImageViewOfAnimation.image = UIImage(named: "blackView")
                    TalkButtonAnimation.startTalkButtonAnimation(imageView: imageView, pulseGrayWave: self.pulseGrayWave, pulseLayer: self.pulseLayer, midCircleViewOfPulse: self.midCircleViewOfPulse, bottomImageView: self.bottomImageView)
                }
                
                if gesture.state == .ended {
                    imageView.image = #imageLiteral(resourceName: "talk_button").withRenderingMode(.alwaysOriginal)
                    
                    // TODO: Remove micrphone functionality as per current requirement. Will modify after final confirmation.
                    /*
                     if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice && speechVC.isSTTDataAvailable(){
                     NotificationCenter.default.post(name: .tapOffMicrophoneLanguageSelectionVoice, object: nil)
                     }
                     
                     if ScreenTracker.sharedInstance.screenPurpose == .CountrySelectionByVoice  && speechVC.isSTTDataAvailable(){
                     NotificationCenter.default.post(name: .tapOffMicrophoneCountrySelectionVoice, object: nil)
                     }
                     
                     if ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionCamera  && speechVC.isSTTDataAvailable(){
                     NotificationCenter.default.post(name: .tapOffMicrophoneCountrySelectionVoiceCamera, object: nil)
                     }
                     */
                    SpeechProcessingViewModel.isLoading = true;
                    if !self.speechVC.isMinimumLimitExceed {
                        self.enableORDisableMicrophoneButton(isEnable: false)
                    }else{
                        self.speechVC.isMinimumLimitExceed = false
                    }
                    self.homeVCDelegate?.stopRecord()
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
        return ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionVoice ||        ScreenTracker.sharedInstance.screenPurpose == .CountrySelectionByVoice ||
        ScreenTracker.sharedInstance.screenPurpose == .LanguageSelectionCamera
    }
}


//MARK: - HistoryCardVC Functionalities
extension HomeViewController {
    //MARK: - HistoryCardview setup
    func setupCardView() {
        historyCardVC = HistoryCardViewController(nibName: "HistoryCardViewController", bundle: nil)
        self.addChild(historyCardVC)
        self.view.addSubview(historyCardVC.view)
        historyCardVC.delegate = self
        
        historyCardVC.view.frame = CGRect(
            x: self.view.bounds.width / 3,
            y: -cardHeight + UIApplication.shared.statusBarFrame.height,
            width: self.view.bounds.width / 3,
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
                    animateTransitionIfNeeded(state: nextState, duration: historyCardAnimationDuration)
                    self.historyCardVC.updateData(shouldCVScrollToBottom: true)
                    
                    //Remove all the child container while swipe up to dismiss
                    removeAllChildControllers(Int(IsTop.top.rawValue))
                }
            }
            
            if nextState == .expanded && translationY > 0 {
                animateTransitionIfNeeded(state: nextState, duration: historyCardAnimationDuration)
                self.historyCardVC.updateData(shouldCVScrollToBottom: true)
            }
            self.historyImageView.isHidden = false
        default:
            break
        }
    }
    
    
    //MARK: - CardView animation functionalities
    private func startInteractiveTransition(state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
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
    
    private func animateTransitionIfNeeded (state:CardState, duration:TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                guard let `self` = self else { return }
                switch state {
                case .expanded:
                    self.historyCardVC.view.frame.origin.y = 0
                    self.historyCardVC.view.frame.origin.x = 0
                    self.historyCardVC.view.frame.size.width = self.view.bounds.width
                    self.historyCardVC.view.alpha = 1
                case .collapsed:
                    self.historyCardVC.view.frame.origin.y = -self.cardHeight + UIApplication.shared.statusBarFrame.height
                    self.historyCardVC.view.frame.origin.x = self.view.bounds.width / 3
                    self.historyCardVC.view.frame.size.width = self.view.bounds.width / 3
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
    func dissmissHistory() {
        historyDissmissed()
        animateTransitionIfNeeded(state: .collapsed, duration: historyCardAnimationDuration)
    }
}




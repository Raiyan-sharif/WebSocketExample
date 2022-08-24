//
//  HomeViewController+HistoryCardVCExtension.swift
//  PockeTalk
//

import UIKit

extension HomeViewController{
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
        
        imageViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapForImageGesture(tapGestureRecognizer:)))
        self.historyImageView.addGestureRecognizer(imageViewTapGesture)

        
        imageViewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCardPanForImageGesture(recognizer:)))
        self.historyImageView.addGestureRecognizer(imageViewPanGesture)
        
        viewPanGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCardPanForViewGesture(recognizer:)))
        self.view.addGestureRecognizer(viewPanGesture)
        
    }
    
    ///HistoryImageView tap gesture functionality
    @objc private func handleTapForImageGesture(tapGestureRecognizer: UITapGestureRecognizer){
        PrintUtility.printLog(tag: historyCardTAG, text: "Tap on Hisotry ImageView,  Visibility: \(self.cardVisible) State:\(self.nextState)")
        historyTrayTapLogEvent()
        animateTransitionIfNeeded(state: nextState, shouldUpdateCardViewAlpha: false)
        self.historyCardVC.updateData(shouldCVScrollToBottom: true)
        ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
        self.enableorDisableGesture(notification:nil)
    }
    
    ///HistoryImageView bottom pan gesture functionality
    @objc private func handleCardPanForImageGesture (recognizer:UIPanGestureRecognizer) {
        PrintUtility.printLog(tag: historyCardTAG, text: "Card pan for Hisotry ImageView,  Visibility: \(self.cardVisible) State:\(self.nextState)")
        switch recognizer.state {
        case .began:
            self.historyImageView.isHidden = true
            startInteractiveTransition(state: nextState, duration: historyCardAnimationDuration)
            self.historyCardVC.updateData(shouldCVScrollToBottom: true)
            resetHistoryViewProperty(isBackgroundClear: true)
        case .changed:
            let translation = recognizer.translation(in: self.view)
            var fractionComplete = translation.y / cardHeight
            PrintUtility.printLog(tag: historyCardTAG, text: "Card pan for Hisotry ImageView, fractionComplete \(fractionComplete)")
            fractionComplete = cardVisible ? -fractionComplete : fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended, .failed, .cancelled, .possible:
            continueInteractiveTransition()
            ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
            self.enableorDisableGesture(notification:nil)
            resetHistoryViewProperty(isBackgroundClear: false)
        default:
            break
        }
    }
    
    ///Home view pan to bottom
    @objc private func handleCardPanForViewGesture (recognizer:UIPanGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            let translationY = recognizer.translation(in: self.view).y
            
            //TODO: Disable code block because swipe up to dismiss history is currently disabled from home
            /*
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
            */
            PrintUtility.printLog(tag: historyCardTAG, text: "Card pan for View,  translationY \(translationY), Visibility: \(self.cardVisible) State:\(self.nextState)")
            
            if nextState == .expanded && translationY > 20 {
                if ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing {
                    animateTransitionIfNeeded(state: nextState, shouldUpdateCardViewAlpha: false)
                    self.historyCardVC.updateData(shouldCVScrollToBottom: true)
                    ScreenTracker.sharedInstance.screenPurpose = .HistoryScrren
                    self.enableorDisableGesture(notification:nil)
                    self.historyImageView.isHidden = false
                }
            }
            
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
    
    func animateTransitionIfNeeded (state:CardState, shouldUpdateCardViewAlpha: Bool) {
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
                }
            }
            
            frameAnimator.addCompletion { [self] _ in
                PrintUtility.printLog(tag: historyCardTAG, text: "Before change visibility,  Visibility: \(self.cardVisible) State:\(self.nextState)")
                self.cardVisible = !self.cardVisible
                PrintUtility.printLog(tag: historyCardTAG, text: "After change visibility,  Visibility: \(self.cardVisible) State:\(self.nextState)")
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
        }
    }
    
    //MARK: - Utils
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
    
    private func resetHistoryViewProperty(isBackgroundClear: Bool){
        if isBackgroundClear {
            historyCardVC.view.backgroundColor = .clear
            historyCardVC.imageView.image = UIImage(named: "")
        } else {
            historyCardVC.view.backgroundColor = .black
            historyCardVC.imageView.image = UIImage(named: "bottomBackgroudImage")
        }
    }
}

//MARK: - HistoryCardViewControllerDelegate
extension HomeViewController: HistoryCardViewControllerDelegate {
    func dissmissHistory(shouldUpdateViewAlpha: Bool, isFromHistoryScene: Bool) {
        self.historyDissmissed()
        if isFromHistoryScene{
            animateTransitionIfNeeded(state: nextState, shouldUpdateCardViewAlpha: shouldUpdateViewAlpha)
            PrintUtility.printLog(tag: historyCardTAG, text: "Dismiss history from history,  Visibility: \(self.cardVisible) State:\(self.nextState)")
        } else {
            PrintUtility.printLog(tag: historyCardTAG, text: "Dismiss history from home,  Visibility: \(self.cardVisible) State:\(self.nextState)")
        }
    }
}

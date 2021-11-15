//
//  HomeViewController+Extension.swift
//  PockeTalk
//
//  Created by Morshed Alam on 10/21/21.
//


import UIKit

protocol HomeVCDelegate:class {
    func startRecord()
    func stopRecord()
}

extension HomeViewController{

     func setUPLongPressGesture(){
        let talkBtnImgView = UIImageView()
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
         bottomImageView.heightAnchor.constraint(equalToConstant: bottomView.frame.width).isActive = true
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
        self.swipeDown.isEnabled = self.homeContainerView.subviews.count == 0
        homeContainerView.isHidden = self.homeContainerView.subviews.count == 0
    }

    func hideSpeechView(){
        self.speechContainerView.isHidden = true
        homeGestureEnableOrDiable()
    }
    private func openSpeechView(){
        self.speechContainerView.isHidden = false
        //self.homeContainerView.isHidden = true
    }
    func getLastVCFromContainer()->UIViewController?{
        return homeContainerView.subviews.last?.parentViewController
    }
    
    func removeAllChildControllers(){
        for view in homeContainerView.subviews{
            if let controller = view.parentViewController{
                remove(asChildViewController: controller)
            }
        }
        homeGestureEnableOrDiable()
    }

    @objc func longPress(gesture: UILongPressGestureRecognizer) {
        let imageView = gesture.view! as! UIImageView
        if gesture.state == .began {

            SocketManager.sharedInstance.connect()
            SocketManager.sharedInstance.socketManagerDelegate = speechVC

            if ScreenTracker.sharedInstance.screenPurpose == .HistoryScrren{
                ScreenTracker.sharedInstance.screenPurpose = .HomeSpeechProcessing
            }
            speechVC.updateLanguageType()

            if speechVC.languageHasUpdated{
                speechVC.updateLanguageInRemote()
            }

            self.speechVC.hideOrOpenExampleText(isHidden: true)
            imageView.image = #imageLiteral(resourceName: "talk_button").withRenderingMode(.alwaysTemplate)

            openSpeechView()
            if ScreenTracker.sharedInstance.screenPurpose == .HomeSpeechProcessing{
                removeAllChildControllers()
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
            
            homeVCDelegate?.startRecord()
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
            
            if !speechVC.isMinimumLimitExceed {
                enableORDisableMicrophoneButton(isEnable: false)
            }else{
                speechVC.isMinimumLimitExceed = false
            }
            homeVCDelegate?.stopRecord()
            TalkButtonAnimation.stopAnimation(bottomView: self.bottomView, pulseGrayWave: self.pulseGrayWave, pulseLayer: self.pulseLayer, midCircleViewOfPulse: self.midCircleViewOfPulse, bottomImageView: self.bottomImageView)
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

extension UIViewController{

    func add(asChildViewController viewController: UIViewController, containerView: UIView, animation: CATransition?) {
        addChild(viewController)
        
        if(animation != nil){
            viewController.navigationController?.view.layer.add(animation!, forKey: nil)
        }
        
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }

     func remove(asChildViewController viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
}


extension UIView {
    var parentViewController: UIViewController? {
        // Starts from next (As we know self is not a UIViewController).
        var parentResponder: UIResponder? = self.next
        while parentResponder != nil {
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
            parentResponder = parentResponder?.next
        }
        return nil
    }
}

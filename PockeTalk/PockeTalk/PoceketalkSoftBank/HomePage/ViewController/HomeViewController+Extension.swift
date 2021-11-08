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
        talkBtnImgView.image = UIImage(named: "talk_button")
        talkBtnImgView.isUserInteractionEnabled = true
        talkBtnImgView.translatesAutoresizingMaskIntoConstraints = false
        talkBtnImgView.tintColor = UIColor._skyBlueColor()
        talkBtnImgView.layer.cornerRadius = width/2
        talkBtnImgView.clipsToBounds = true
        self.bottomView.addSubview(talkBtnImgView)
        talkBtnImgView.widthAnchor.constraint(equalToConstant: width).isActive = true
        talkBtnImgView.heightAnchor.constraint(equalToConstant: width).isActive = true
        talkBtnImgView.centerXAnchor.constraint(equalTo: bottomView.centerXAnchor).isActive = true
        talkBtnImgView.centerYAnchor.constraint(equalTo: bottomView.centerYAnchor).isActive = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPress(gesture:)))
        longPress.minimumPressDuration = 0.1
        talkBtnImgView.addGestureRecognizer(longPress)
    }

    func enableORDisableMicrophoneButton(isEnable:Bool){
        if let imgView = self.bottomView.subviews.first as? UIImageView{
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
            homeVCDelegate?.startRecord()
        }

        if gesture.state == .ended {
            imageView.image = #imageLiteral(resourceName: "talk_button").withRenderingMode(.alwaysOriginal)

            enableORDisableMicrophoneButton(isEnable: false)
            homeVCDelegate?.stopRecord()
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

    func add(asChildViewController viewController: UIViewController, containerView: UIView) {
        addChild(viewController)
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

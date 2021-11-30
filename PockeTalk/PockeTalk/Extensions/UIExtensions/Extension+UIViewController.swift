//
// Extension+UIViewController.swift
// PockeTalk
//

import UIKit

extension UIViewController{
    // Define toast message and duration
    func showToast(message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black
        alert.view.alpha = 0.5
        alert.view.layer.cornerRadius = 15
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    func embed(_ viewController:UIViewController, inView view:UIView){
        addChild(viewController)
        self.view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
    func add(asChildViewController viewController: UIViewController, containerView: UIView) {
        addChild(viewController)
        containerView.addSubview(viewController.view)
        viewController.view.frame = containerView.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewController.didMove(toParent: self)
    }
    
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
    
    func remove(asChildViewController viewController: UIViewController, animation: CATransition?) {
        
        if(animation != nil){
            viewController.navigationController?.view.layer.add(animation!, forKey: nil)
        }
        
       viewController.willMove(toParent: nil)
       viewController.view.removeFromSuperview()
       viewController.removeFromParent()
   }
}

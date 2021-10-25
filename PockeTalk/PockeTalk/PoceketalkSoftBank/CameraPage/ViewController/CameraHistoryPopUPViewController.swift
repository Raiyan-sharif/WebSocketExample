//
//  CameraHistoryPopUPViewController.swift
//  PockeTalk
//
//  Created by BJIT LTD on 16/9/21.
//

import UIKit

class CameraHistoryPopUPViewController: BaseViewController {
    
    
    @IBOutlet weak var openBtnContainerView: UIView!
    @IBOutlet weak var shareBtnContainerView: UIView!
    @IBOutlet weak var deleteBtnContainerView: UIView!
    @IBOutlet weak var cancelBtnContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    let viewAlpha : CGFloat = 0.6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    func setUpViews() {
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(viewAlpha)
        
        containerView.layer.cornerRadius = 15.0
        self.containerView.layer.masksToBounds = true

        let tapForOpen = UITapGestureRecognizer(target: self, action: #selector(self.openButtonEventHandler(sender:)))
        openBtnContainerView.isUserInteractionEnabled = true
        openBtnContainerView.addGestureRecognizer(tapForOpen)
        
        let tapForShare = UITapGestureRecognizer(target: self, action: #selector(self.shareButtonEventHandler(sender:)))
        shareBtnContainerView.isUserInteractionEnabled = true
        shareBtnContainerView.addGestureRecognizer(tapForShare)
        
        let tapForDelete = UITapGestureRecognizer(target: self, action: #selector(self.deleteButtonEventHandler(sender:)))
        deleteBtnContainerView.isUserInteractionEnabled = true
        deleteBtnContainerView.addGestureRecognizer(tapForDelete)
        
        let tapForCancel = UITapGestureRecognizer(target: self, action: #selector(self.cancelButtonEventHandler(sender:)))
        cancelBtnContainerView.isUserInteractionEnabled = true
        cancelBtnContainerView.addGestureRecognizer(tapForCancel)
    }
    
    @objc func openButtonEventHandler(sender:UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }

    @objc func shareButtonEventHandler(sender:UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }

    @objc func deleteButtonEventHandler(sender:UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
    @objc func cancelButtonEventHandler(sender:UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }

    
}

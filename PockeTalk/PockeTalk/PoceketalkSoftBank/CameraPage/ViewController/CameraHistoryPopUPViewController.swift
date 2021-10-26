//
//  CameraHistoryPopUPViewController.swift
//  PockeTalk
//
//  Created by BJIT LTD on 16/9/21.
//

import UIKit

protocol CameraHistoryPopUPDelegates {
    func openImageFromHistoryPopUp(index: Int)
    func shareImageFromHistoryPopUp(id: Int64)
    func deleteImageFromFistoryPopUp(index: Int, id: Int64)
}

class CameraHistoryPopUPViewController: BaseViewController {
    
    @IBOutlet weak var openBtnContainerView: UIView!
    @IBOutlet weak var shareBtnContainerView: UIView!
    @IBOutlet weak var deleteBtnContainerView: UIView!
    @IBOutlet weak var cancelBtnContainerView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    let viewAlpha : CGFloat = 0.6
    
    let cameraHistoryDBModel = CameraHistoryDBModel()
    var delegate: CameraHistoryPopUPDelegates?
    
    var id = Int64()
    var index = Int()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpViews()
    }
    
    func setUpViews() {
        
        PrintUtility.printLog(tag: "CameraHistoryPopUPViewController", text: "id: \(id)")
        
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
        self.delegate?.openImageFromHistoryPopUp(index: index)
    }

    @objc func shareButtonEventHandler(sender:UITapGestureRecognizer) {
        self.dismiss(animated: true)
        self.delegate?.shareImageFromHistoryPopUp(id: id)
    }

    @objc func deleteButtonEventHandler(sender:UITapGestureRecognizer) {

        try? cameraHistoryDBModel.delete(item: CameraEntity(id: id, detectedData: nil, translatedData: nil, image: nil))
        self.dismiss(animated: true)
        self.delegate?.deleteImageFromFistoryPopUp(index: index, id: id)
        
    }
    
    @objc func cancelButtonEventHandler(sender:UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }

}

//
//  CaptureImageProcessVC.swift
//  PockeTalk
//
//


import UIKit

class CaptureImageProcessVC: BaseViewController {
    
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var modeSwitchButton: UIButton!
    
    private let viewModel = ITTServerViewModel()
    private let activity = ActivityIndicator()
    
    var image = UIImage()
    var blockmMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.viewDidLoad(self)
        self.cameraImageView.image = image
        self.cameraImageView.backgroundColor = UIColor.white
        //self.viewModel.getDetectionData()
        self.viewModel.getITTServerDetectionData(resource: self.viewModel.createRequest())
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func backButtonEventListener(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func modeSwitchButtonEventListener(_ sender: Any) {
        if blockmMode {
            modeSwitchButton.setImage(UIImage(named: "block_mode"), for: .normal)
        } else {
            modeSwitchButton.setImage(UIImage(named: "line_mode"), for: .normal)
        }
    }
    
    
}

extension CaptureImageProcessVC: ITTServerViewModelDelegates {
    func updateViewWith(textViews: [TextViewWithCoordinator]) {
        DispatchQueue.main.async {[self] in
            
            if textViews.count > 0 {
                
                for i in 0..<textViews.count {
                    textViews[i].view.frame.origin.x = CGFloat(Float(textViews[i].X1))
                    textViews[i].view.frame.origin.y = CGFloat(Float(textViews[i].Y1))
                    self.view.addSubview(textViews[i].view)
                }
            }
        }
    }
}

extension CaptureImageProcessVC: LoaderDelegate{
    
    func showLoader() {
        DispatchQueue.main.async { [self] in
            activity.showLoading(view: self.view)
        }
    }
    
    func hideLoader() {
        activity.hideLoading()
    }
}

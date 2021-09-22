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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.viewDidLoad(self)
        self.viewModel.capturedImage = image
        self.cameraImageView.image = image
                
        self.viewModel.getITTServerDetectionData(resource: self.viewModel.createRequest()) { [weak self] (data, error) in
            
            if error != nil {
                PrintUtility.printLog(tag: "ERROR :", text: "\(String(describing: error))")
            } else {
                if let detectedData = data {
                    self?.viewModel.getblockAndLineModeData(detectedData)
                }
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func backButtonEventListener(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func modeSwitchButtonEventListener(_ sender: Any) {
        let modeSwitchTypes = UserDefaults.standard.string(forKey: modeSwitchType)
        if modeSwitchTypes == blockMode {
            UserDefaults.standard.set(lineMode, forKey: modeSwitchType)
            updateView()
        } else {
            UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
            updateView()
        }
        
    }
    
}

extension CaptureImageProcessVC: ITTServerViewModelDelegates {
    func updateView() {
        DispatchQueue.main.async {[self] in
            let blockModeTextViews = self.viewModel.blockModeTextViewList
            let lineModeTextViews = self.viewModel.lineModetTextViewList
            if (blockModeTextViews.count != 0 && lineModeTextViews.count != 0) {
                hideLoader()
                
                if let modeSwitchType = UserDefaults.standard.string(forKey: modeSwitchType) {
                    if modeSwitchType == blockMode {
                        plotLineOrBlock(using: blockModeTextViews)
                        
                    } else {
                        plotLineOrBlock(using: lineModeTextViews)
                    }
                } else {
                    UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
                    plotLineOrBlock(using: blockModeTextViews)
                }
            }
        }
    }
    
    
    
    func plotLineOrBlock(using textViews: [TextViewWithCoordinator]) {
        
        
        let screenRect = UIScreen.main.bounds
        let screenWidth = screenRect.size.width
        let screenHeight = screenRect.size.height
        
        // TO Do: will remove static image
        let image = UIImage(named: "vv")
        let imageView = UIImageView(image: image!)
        
        imageView.frame = CGRect(x: 0, y: 0, width: 334, height: 736) // To do : This will be actual cropped & processed image height width
        
        self.view.addSubview(imageView)
        
        if textViews.count > 0 {
            for i in 0..<textViews.count {
                textViews[i].view.frame.origin.x = CGFloat(Float(textViews[i].X1))
                textViews[i].view.frame.origin.y = CGFloat(Float(textViews[i].Y1))
                self.view.addSubview(textViews[i].view)
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



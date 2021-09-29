//
//  CaptureImageProcessVC.swift
//  PockeTalk
//
//


import UIKit

class CaptureImageProcessVC: BaseViewController {
    
    @IBOutlet weak var cameraImageView: UIImageView!
    @IBOutlet weak var modeSwitchButton: UIButton!
    let serialQueue = DispatchQueue(label: "com.queue.serial")
    var btn = UIButton(type: .custom)
    private let viewModel = ITTServerViewModel()
    private let activity = ActivityIndicator()
    
    private lazy var cameraTTSDiaolog: CameraTTSDialog = {
        let cameraTTSDialog = CameraTTSDialog(frame: CGRect(x: 0, y: 0, width: SIZE_WIDTH, height: SIZE_HEIGHT))
        cameraTTSDialog.delegate = self
        return cameraTTSDialog
    }()
    
    private lazy var cameraTTSContextMenu: CameraTTSContextMenu = {
        let cameraTTSContextMenu = CameraTTSContextMenu(frame: CGRect(x: 0, y: 0, width: SIZE_WIDTH, height: SIZE_HEIGHT))
        cameraTTSContextMenu.delegate = self
        return cameraTTSContextMenu
    }()
    
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel.viewDidLoad(self)
        self.viewModel.capturedImage = image
        self.cameraImageView.image = image
        
        self.viewModel.getITTServerDetectionData(resource: self.viewModel.createRequest())
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        btn.removeFromSuperview()
    }
    
    @IBAction func backButtonEventListener(_ sender: Any) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    @IBAction func modeSwitchButtonEventListener(_ sender: Any) {
        let modeSwitchTypes = UserDefaults.standard.string(forKey: modeSwitchType)
        if modeSwitchTypes == blockMode {
            UserDefaults.standard.set(lineMode, forKey: modeSwitchType)
            for each in self.viewModel.blockModeTextViewList {
                each.view.removeFromSuperview()
            }
            updateView()
        } else {
            UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
            for each in self.viewModel.lineModetTextViewList {
                each.view.removeFromSuperview()
            }
            updateView()
        }
        
    }
    
}

extension CaptureImageProcessVC: ITTServerViewModelDelegates {
    func gettingServerDetectionDataSuccessful() {
        //PrintUtility.printLog(tag: "Detected JSON", text: "\(self.viewModel.detectedJSON)")
        self.viewModel.getblockAndLineModeData(self.viewModel.detectedJSON)
    }
    
    func updateView() {
        
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
                
                DispatchQueue.main.async {
                    let height = textViews[i].view.frame.size.height
                    let width = textViews[i].view.frame.size.width
                    PrintUtility.printLog(tag: "X, y: ", text: "\(CGFloat(Float(textViews[i].X1))), \(CGFloat(Float(textViews[i].Y1)))")
                    textViews[i].view.frame.origin.x = CGFloat(Float(textViews[i].X1))
                    textViews[i].view.frame.origin.y = CGFloat(Float(textViews[i].Y1))
                    textViews[i].view.frame.size.height = height
                    textViews[i].view.frame.size.width = width
                    
                    self.view.addSubview(textViews[i].view)
                }
                
            }
        }
        /// Just showing the TTS dialog for testing.
        //self.view.addSubview(cameraTTSDiaolog)
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

//MARK: - CameraTTSDialogProtocol

extension CaptureImageProcessVC: CameraTTSDialogProtocol {
    func cameraTTSDialogToPlaybutton() {
        // Action ToLanguage play
    }
    
    func cameraTTSDialogFromPlaybutton() {
        // Action FromLanguage play
    }
    
    
    func cameraTTSDialogShowContextMenu() {
        self.view.addSubview(cameraTTSContextMenu)
    }
}

//MARK: - CameraTTSContextMenuProtocol

extension CaptureImageProcessVC: CameraTTSContextMenuProtocol {
    func cameraTTSContextMenuSendMail() {
        // Send an email implementaiton goes here
    }
    
    
}



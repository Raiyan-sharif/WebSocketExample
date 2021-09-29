//
//  CaptureImageProcessVC.swift
//  PockeTalk
//
//

import UIKit

class CaptureImageProcessVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cameraImageView: UIImageView!
    let serialQueue = DispatchQueue(label: "com.queue.serial")
    private let viewModel = ITTServerViewModel()
    private let activity = ActivityIndicator()
    
    lazy var modeSwitchButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "line_mode"), for: .normal)
        button.addTarget(self, action: #selector(fabTapped(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(named: "btn_back"), for: .normal)
        button.addTarget(self, action: #selector(backButtonEventListener(_:)), for: .touchUpInside)
        return button
    }()


    
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
        
        cameraImageView.image = UIImage(named: "vv")
        scrollView.delegate = self
        scrollView.maximumZoomScale = 5.0
        scrollView.delaysContentTouches = true
        self.viewModel.getITTServerDetectionData(resource: self.viewModel.createRequest())
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let view = UIApplication.shared.keyWindow {
                view.addSubview(backButton)
                setupBackButton()
            }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let view = UIApplication.shared.keyWindow, modeSwitchButton.isDescendant(of: view) {
            modeSwitchButton.removeFromSuperview()
        }
        if let backButtonView = UIApplication.shared.keyWindow, backButton.isDescendant(of: backButtonView) {
            backButton.removeFromSuperview()
        }
    }
    
    @objc func fabTapped(_ button: UIButton) {
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
    
    @objc func backButtonEventListener(_ button: UIButton) {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }


    func setupModeSwitchButton() {
        NSLayoutConstraint.activate([
            modeSwitchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            modeSwitchButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            modeSwitchButton.heightAnchor.constraint(equalToConstant: 60),
            modeSwitchButton.widthAnchor.constraint(equalToConstant: 60)
            ])
        modeSwitchButton.layer.cornerRadius = 30
        modeSwitchButton.layer.masksToBounds = true
    }
    
    func setupBackButton() {
        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 60),
            backButton.widthAnchor.constraint(equalToConstant: 60)
            ])
        backButton.layer.cornerRadius = 30
        backButton.layer.masksToBounds = true
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
        //        let image = UIImage(named: "vv")
        //        let imageView = UIImageView(image: image!)
        //
        //        imageView.frame = CGRect(x: 0, y: 0, width: 334, height: 736) // To do : This will be actual cropped & processed image height width
        //
        //        self.view.addSubview(imageView)
        
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
                    textViews[i].view.backgroundColor = .gray.withAlphaComponent(0.4)
                    
                    
                    self.cameraImageView.addSubview(textViews[i].view)
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.textViewDidTap(sender:)))
                    tap.delegate = self
                    textViews[i].view.isUserInteractionEnabled = true
                    textViews[i].view.tag = i
                    textViews[i].view.addGestureRecognizer(tap)
                }
                
            }
            if let view = UIApplication.shared.keyWindow {
                    view.addSubview(modeSwitchButton)
                    setupModeSwitchButton()
                }
        }
        /// Just showing the TTS dialog for testing.
        //self.view.addSubview(cameraTTSDiaolog)
    }
    
    @objc func textViewDidTap(sender : UITapGestureRecognizer)
    {
        let textView = sender.view!
        let tag = textView.tag
        PrintUtility.printLog(tag: "view tag :", text: " \(tag)")
    }
    
}

extension CaptureImageProcessVC: UIScrollViewDelegate , UIGestureRecognizerDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return cameraImageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.contentScaleFactor = scale
        for subView in scrollView.subviews {
            subView.contentScaleFactor = scale
            subView.isUserInteractionEnabled = true
        }
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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



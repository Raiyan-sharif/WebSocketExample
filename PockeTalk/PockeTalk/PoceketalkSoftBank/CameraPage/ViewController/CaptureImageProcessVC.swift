//
//  CaptureImageProcessVC.swift
//  PockeTalk
//
//


import UIKit

class CaptureImageProcessVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    private let iTTServerViewModel = ITTServerViewModel()
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
    //var image = UIImage(named: "vv")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.iTTServerViewModel.viewDidLoad(self)
        self.iTTServerViewModel.capturedImage = image
        
        let heightInPoints = image.size.height
        let widthInPoints = image.size.width
        PrintUtility.printLog(tag: "Captured Image heightInPoints: \(heightInPoints)", text: ", widthInPoints: \(widthInPoints)")
        
        image = UIImage(data: image.jpeg(.lowest)!)!
        
        let heightInPoints1 = image.size.height
        let widthInPoints1 = image.size.width
        PrintUtility.printLog(tag: "Compressed Image heightInPoints: \(heightInPoints1)", text: ", widthInPoints: \(widthInPoints1)")
        
        //image = resizeImage(image: image)
        image = resizeImage(image: image, targetSize: CGSize.init(width: 390, height: 844))
        let heightInPoints2 = image.size.height
        let widthInPoints2 = image.size.width
        PrintUtility.printLog(tag: "Resized Image heightInPoints: \(heightInPoints2)", text: ", widthInPoints: \(widthInPoints2)")
        self.cameraImageView.image = image
        
        //        GoogleCloudOCR().detect(from: image) { ocrResult in
        //            guard let ocrResult = ocrResult else {
        //                fatalError("Did not recognize any text in this image")
        //            }
        //            print("OcrResult: \(ocrResult)")
        //        }
        
        self.iTTServerViewModel.getITTData(from: image) { [weak self] (data, error) in
            
            if error != nil {
                PrintUtility.printLog(tag: "ERROR :", text: "\(String(describing: error))")
            } else {
                if let detectedData = data {
                    self?.iTTServerViewModel.getblockAndLineModeData(detectedData)
                }
            }
        }
        
        //        self.viewModel.getITTServerDetectionData(resource: self.viewModel.createRequest()) { [weak self] (data, error) in
        //
        //            if error != nil {
        //                PrintUtility.printLog(tag: "ERROR :", text: "\(String(describing: error))")
        //            } else {
        //                if let detectedData = data {
        //                    self?.viewModel.getblockAndLineModeData(detectedData)
        //                }
        //            }
        //        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //    @IBAction func backButtonEventListener(_ sender: Any) {
    //        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
    //            self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    //    }
    
    //    @IBAction func modeSwitchButtonEventListener(_ sender: Any) {
    //        let modeSwitchTypes = UserDefaults.standard.string(forKey: modeSwitchType)
    //        if modeSwitchTypes == blockMode {
    //            UserDefaults.standard.set(lineMode, forKey: modeSwitchType)
    //            updateView()
    //        } else {
    //            UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
    //            updateView()
    //        }
    //
    //    }
    
}

extension CaptureImageProcessVC: ITTServerViewModelDelegates {
    func updateView() {
        DispatchQueue.main.async {[self] in
            let blockModeTextViews = self.iTTServerViewModel.blockModeTextViewList
            let lineModeTextViews = self.iTTServerViewModel.lineModetTextViewList
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
        //let image1 = UIImage(named: "vv")
        let imageView = UIImageView(image: image)
        
        let heightInPoints = image.size.height
        let heightInPixels = heightInPoints * image.scale
        
        let widthInPoints = image.size.width
        let widthInPixels = widthInPoints * image.scale
        
        imageView.frame = CGRect(x: 0, y: 0, width: widthInPixels, height: heightInPixels) // To do : This will be actual cropped & processed image height width
        
        self.view.addSubview(imageView)
        
        if textViews.count > 0 {
            for i in 0..<textViews.count {
                textViews[i].view.frame.origin.x = CGFloat(Float(textViews[i].X1))
                textViews[i].view.frame.origin.y = CGFloat(Float(textViews[i].Y1))
                self.view.addSubview(textViews[i].view)
            }
        }
        
        if let view = UIApplication.shared.keyWindow {
            view.addSubview(modeSwitchButton)
            setupModeSwitchButton()
        }
        
        /// Just showing the TTS dialog for testing.
        //self.view.addSubview(cameraTTSDiaolog)
        
        
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    //image compression
    func resizeImage(image: UIImage) -> UIImage {
        var actualHeight: Float = Float(image.size.height)
        var actualWidth: Float = Float(image.size.width)
        let maxHeight: Float = 844.0
        let maxWidth: Float = 390.0
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let compressionQuality: Float = 0.5
        //50 percent compression
        
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img!.jpegData(compressionQuality: CGFloat(compressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!)!
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
            for each in self.iTTServerViewModel.blockModeTextViewList {
                each.view.removeFromSuperview()
            }
            updateView()
        } else {
            UserDefaults.standard.set(blockMode, forKey: modeSwitchType)
            for each in self.iTTServerViewModel.lineModetTextViewList {
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

extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}



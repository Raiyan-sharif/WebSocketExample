//
//  CameraViewController.swift
//  PockeTalk
//
//

import AVFoundation
import Photos
import UIKit
import MarqueeLabel

enum Camera {
    case front, back
}

class CameraViewController: BaseViewController, AVCapturePhotoCaptureDelegate {
    
    let TAG = CameraViewController.self
    var minimumSize: CGSize = CGSize(width: 60, height: 60)
    @IBOutlet weak var zoomLevel: UILabel!
    @IBOutlet weak var cameraPreviewView: UIView!
    var camera = Camera.back
    lazy var session = AVCaptureSession()
    lazy var photoOutput = AVCapturePhotoOutput()
    private var initialScale: CGFloat = 0
    var capturedImage = UIImage()
    var allowsLibraryAccess = true
    var isCaptureButtonClickable = Bool()
    let window = UIApplication.shared.keyWindow!
    var talkButtonImageView: UIImageView!
    var isLanguageViewPresent = false
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var toLangLabel: MarqueeLabel!
    @IBOutlet weak var fromLangLabel: MarqueeLabel!
    var activeCamera: AVCaptureDevice?
    lazy var backCamera: AVCaptureDevice? = {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
    }()
    @IBOutlet weak var btnFromLanguage: RoundButtonWithBorder!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var btnTargetLanguage: RoundButtonWithBorder!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cameraHistoryImageView: UIImageView!
    private lazy var previewView = UIView()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: session)
    private let currentDevice = UIDevice.current
    
    var cropImageRect = CGRect()
    open var onCompletion: CameraViewCompletion?
    var zoomScaleRange: ClosedRange<CGFloat> = 1...5
    let sessionQueue = DispatchQueue(label: "Session Queue")
    var sessionSetupSucceeds = false
    private var captureProcessors: [Int64: PhotoCaptureProcessor] = [:]
    private var videoOrientation: AVCaptureVideoOrientation = .portrait
    
    /// Circle drawing properties
    let startAngle : CGFloat = 0
    let endAngle : CGFloat = CGFloat(Double.pi * 2)
    let radius : CGFloat = 25
    let lineWidth : CGFloat = 2
    let removeTime : Double = 0.3
    let zoomLabelBorderWidth : CGFloat = 2.0
    var circleColor: UIColor = .white
    
    /// Camera History
    private let cameraHistoryViewModel = CameraHistoryViewModel()
    var updateHomeContainer:((_ isTalkButtonVisible:Bool)->())?
    
    @IBAction func onFromLangBtnPressed(_ sender: Any) {
        self.updateHomeContainer?(false)
        HomeViewController.cameraTapFlag = 1
        UserDefaultsProperty<Bool>(KCameraLanguageFrom).value = true
        openCameraLanguageListScreen()
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionCamera
    }
    
    @IBAction func onTargetLangBtnPressed(_ sender: Any) {
        self.updateHomeContainer?(false)
        HomeViewController.cameraTapFlag = 2
        UserDefaultsProperty<Bool>(KCameraLanguageFrom).value = false
        openCameraLanguageListScreen()
        ScreenTracker.sharedInstance.screenPurpose = .LanguageSelectionCamera
    }
    
    func openCameraLanguageListScreen(){
        isViewInteractionEnable(false)
        let storyboard = UIStoryboard(name: KStoryBoardCamera, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KiDLangSelectCamera)as! LanguageSelectCameraVC
        let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromRight)
        
        add(asChildViewController: controller, containerView: view, animation: transition)
        guard let activeCamera = activeCamera else {
            return
        }
        controller.activeCamera = activeCamera
        isLanguageViewPresent = true
        turnOffCamera()
        DispatchQueue.main.asyncAfter(deadline: .now() + kScreenTransitionTime) {
            [weak self] in
            self?.talkButtonImageView.isHidden = false
        }
    }
    
    fileprivate func updateLanguageNames() {
        let languageManager = LanguageSelectionManager.shared
        let fromLangCode = CameraLanguageSelectionViewModel.shared.fromLanguage
        let targetLangCode = CameraLanguageSelectionViewModel.shared.targetLanguage
        
        let fromLang = CameraLanguageSelectionViewModel.shared.getLanguageInfoByCode(langCode: fromLangCode, languageList: CameraLanguageSelectionViewModel.shared.getFromLanguageLanguageList())
        let targetLang = languageManager.getLanguageInfoByCode(langCode: targetLangCode)

        if(fromLang?.code == CameraLanguageSelectionViewModel.shared.getFromLanguageLanguageList()[0].code){
            fromLangLabel.text = "\(fromLang?.sysLangName ?? "")"
        }else{
            fromLangLabel.text = "\(fromLang?.sysLangName ?? "") (\(fromLang?.name ?? ""))"
        }
        toLangLabel.text = "\(targetLang?.sysLangName ?? "") (\(targetLang?.name ?? ""))"
    }
    
    @objc func onCameraLanguageChanged(notification: Notification) {
        updateLanguageNames()
        isViewInteractionEnable(true)
        let flashStatus = UserDefaults.standard.value(forKey: isCameraFlashOn) as? Bool
        PrintUtility.printLog(tag: "flash status", text: "\(flashStatus)")
        if let flashStatus = flashStatus, flashStatus {
            turnOnCameraFlash()
        }
        isLanguageViewPresent = false
        circleColor = .white
    }
    
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.onCameraLanguageChanged(notification:)), name: .languageSelectionCameraNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name: .languageSelectionCameraNotification, object: nil)
    }
    
    deinit {
        unregisterNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUPViews()
        previewLayer.videoGravity = .resize
        previewView = cameraPreviewView
        previewView.frame = cameraPreviewView.frame
        cropImageRect = cameraPreviewView.frame
        previewView.layer.addSublayer(previewLayer)
        talkButtonImageView = window.viewWithTag(109) as! UIImageView
        view.insertSubview(previewView, at: 0)
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            sessionQueue.async { [unowned self] in
                self.configureSession()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
                if granted {
                    self.sessionQueue.async {
                        self.configureSession()
                    }
                }
            }
        default:
            break
        }
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        previewView.addGestureRecognizer(pinch)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        previewView.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: session)
    }
    
    @objc
    func didInterrupted() {
        PrintUtility.printLog(tag: "Session", text: "\(session.isInterrupted)")
    }
    
    @objc func applicationDidBecomeActive() {
        guard let isCameraFlashOn: Bool = UserDefaults.standard.value(forKey: isCameraFlashOn) as? Bool else {return}
        if isCameraFlashOn == true && isLanguageViewPresent == false {
            turnOnCameraFlash()
        }
    }
    
    func turnOnCameraFlash() {
        if let activeCamera = activeCamera {
            if activeCamera.hasTorch {
                // lock your device for configuration
                do {
                    _ = try activeCamera.lockForConfiguration()
                } catch {
                    PrintUtility.printLog(tag: "error", text: "")
                }
                do {
                    _ = try activeCamera.setTorchModeOn(level: 1.0)
                    flashButton.setImage(UIImage(named: "btn_flash_push"), for: .normal)
                } catch {
                    PrintUtility.printLog(tag: "error", text: "")
                }
                activeCamera.unlockForConfiguration()
            }
        }
    }
    
    
    //    override var prefersStatusBarHidden: Bool {
    //        return true
    //    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUPViews() {
        changeStatusBarColor()
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageHistoryEvent(sender: )))
        self.cameraHistoryImageView.addGestureRecognizer(tap)
        
        /// Make zoom label round shaped
        self.zoomLevel.layer.masksToBounds = true
        self.zoomLevel.layer.cornerRadius = self.zoomLevel.frame.size.width/2
        self.zoomLevel.layer.borderWidth = zoomLabelBorderWidth
        self.zoomLevel.layer.borderColor = UIColor.white.cgColor
    }
    
    func changeStatusBarColor() {
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: statusBarHeight))
            statusbarView.backgroundColor = UIColor.black
            view.addSubview(statusbarView)
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = UIColor.red
        }
        
    }
    
    
    @objc func imageHistoryEvent (sender: UITapGestureRecognizer) {
        isViewInteractionEnable(false)
        let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
        if let vc = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CameraHistoryViewController.self)) as? CameraHistoryViewController {
            let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
            self.view.window!.layer.add(transition, forKey: kCATransition)
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        HomeViewController.setBlackGradientImageToBottomView(usingState: .hidden)
        talkButtonImageView.isHidden = true
        isCaptureButtonClickable = true
        isViewInteractionEnable(true)
        self.updateHomeContainer?(true)
        self.cameraHistoryViewModel.cameraHistoryImages.removeAll()
        self.cameraHistoryViewModel.fetchCameraHistoryImages(size: 0)
        if cameraHistoryViewModel.cameraHistoryImages.count == 0 {
            cameraHistoryImageView.isHidden = true
        } else {
            cameraHistoryImageView.isHidden = false
            cameraHistoryImageView.image = self.cameraHistoryViewModel.cameraHistoryImages[0].image
        }
        
        sessionQueue.async { [unowned self] in
            if self.sessionSetupSucceeds {
                do {
                    try activeCamera?.lockForConfiguration()
                    activeCamera?.videoZoomFactor = 1.0
                    activeCamera?.unlockForConfiguration()
                }catch {
                    return
                }
                self.session.startRunning()
                if let flashOn: Bool = UserDefaults.standard.value(forKey: isCameraFlashOn) as? Bool {
                    if flashOn == true {
                        DispatchQueue.main.async {
                            self.turnOnCameraFlash()
                        }
                        
                    }
                }else {
                    UserDefaults.standard.set(false, forKey: isCameraFlashOn)
                }
                
            }
        }
        registerNotification()
        updateLanguageNames()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageHistoryEvent(sender: )))
        self.cameraHistoryImageView.addGestureRecognizer(tap)
        captureButton.isExclusiveTouch = true
        PrintUtility.printLog(tag: TagUtility.sharedInstance.cameraScreenPurpose, text: "\(ScreenTracker.sharedInstance.screenPurpose)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        HomeViewController.cameraTapFlag = 0
        sessionQueue.async { [weak self] in
            
            if let _ = self?.sessionSetupSucceeds {
                if let _session = self?.session {
                    _session.stopRunning()
                }
            }
        }
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        previewLayer.frame = previewView.layer.bounds
    }
    
    func takePhoto(_ completion: ((Photo) -> Void)? = nil) {
        guard sessionSetupSucceeds else { return }
        
        let settings: AVCapturePhotoSettings
        if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        } else {
            settings = AVCapturePhotoSettings()
        }
        
        let orientation = videoOrientation
        
        photoOutput.connection(with: .video)?.videoOrientation = orientation
        
        let processor = PhotoCaptureProcessor()
        processor.orientation = orientation
        processor.completion = { [unowned self] processor in
            if let photo = processor.photo {
                // To DO: keep this code for check image quality and size.  will delete when task is finished
                //                RuntimePermissionUtil().requestAuthorizationPermissionForUsingPhotoLibrary { (isAuthorized) in
                //                    if isAuthorized {
                //                        PHPhotoLibrary.shared().performChanges({
                //                            // Add the captured photo's file data as the main resource for the Photos asset.
                //                            //let creationRequest = PHAssetCreationRequest.forAsset()
                //                            //creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
                //                        }, completionHandler: nil)
                //
                //                        completion?(Photo(photo: photo, orientation: processor.orientation))
                //
                //                    } else {
                //                        GlobalMethod.showAlert(title: kPhotosUsageTitle, message: kPhotosUsageMessage, in: self) {
                //                            GlobalMethod.openSettingsApplication()
                //                        }
                //
                //                    }
                //                }
                
                completion?(Photo(photo: photo, orientation: processor.orientation))
            }
            
            if let settings = processor.settings {
                let id = settings.uniqueID
                self.captureProcessors.removeValue(forKey: id)
            }
        }
        captureProcessors[settings.uniqueID] = processor
        sessionQueue.async { [unowned self] in
            self.photoOutput.capturePhoto(with: settings, delegate: processor)
        }
    }
    
    @objc
    private func handlePinch(_ pinch: UIPinchGestureRecognizer) {
        guard sessionSetupSucceeds,  let device = activeCamera else { return }
        self.zoomLevel.isHidden = true
        switch pinch.state {
        case .began:
            initialScale = device.videoZoomFactor
        case .changed:
            let minAvailableZoomScale = device.minAvailableVideoZoomFactor
            let maxAvailableZoomScale = device.maxAvailableVideoZoomFactor
            let availableZoomScaleRange = minAvailableZoomScale...maxAvailableZoomScale
            let resolvedZoomScaleRange = zoomScaleRange.clamped(to: availableZoomScaleRange)
            
            let resolvedScale = max(resolvedZoomScaleRange.lowerBound, min(pinch.scale * initialScale, resolvedZoomScaleRange.upperBound))
            
            configCamera(device) { device in
                device.videoZoomFactor = resolvedScale
                DispatchQueue.main.async {
                    self.zoomLevel.isHidden = false
                    self.zoomLevel.text = String(format:"%.01f", resolvedScale) + "x"
                }
            }
        default:
            return
        }
    }
    
    @objc
    private func handleTap(_ tap: UITapGestureRecognizer) {
        guard sessionSetupSucceeds else { return }
        
        let point = tap.location(in: previewView)
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
        
        configCamera(activeCamera) { device in
            let focusMode = AVCaptureDevice.FocusMode.autoFocus
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                device.focusPointOfInterest = devicePoint
                device.focusMode = focusMode
            }
            
            let exposureMode = AVCaptureDevice.ExposureMode.autoExpose
            if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                device.exposurePointOfInterest = devicePoint
                device.exposureMode = exposureMode
            }
        }
    }
    
}

extension CameraViewController {
    
    @IBAction func backButtonEventListener(_ sender: Any) {
        isViewInteractionEnable(false)
        self.updateHomeContainer?(false)
        HomeViewController.isCameraButtonClickable = true
        talkButtonImageView.isHidden = false
        NotificationCenter.default.post(name: .containerViewSelection, object: nil)
    }
    
    var croppingParameters: CropUtils {
        return CropUtils(enabled: true, resizeable: true, dragable: true, minimumSize: minimumSize)
    }
    
    @IBAction func captureButtonEventListener(_ sender: Any) {
        
        if isCaptureButtonClickable == true {
            isViewInteractionEnable(false)
            isCaptureButtonClickable = false
            takePhoto { [self] photo in
                
                let image = photo.image()
                let originalSize: CGSize
                let visibleLayerFrame = cropImageRect
                
                let metaRect = (previewLayer.metadataOutputRectConverted(fromLayerRect: visibleLayerFrame ))
                
                if (image!.imageOrientation == UIImage.Orientation.left || image!.imageOrientation == UIImage.Orientation.right) {
                    originalSize = CGSize(width: (image?.size.height)!, height: image!.size.width)
                } else {
                    originalSize = image!.size
                }
                let cropRect: CGRect = CGRect(x: metaRect.origin.x * originalSize.width, y: metaRect.origin.y * originalSize.height, width: metaRect.size.width * originalSize.width, height: metaRect.size.height * originalSize.height).integral
                
                if let finalCgImage = image!.cgImage?.cropping(to: cropRect) {
                    let image = UIImage(cgImage: finalCgImage, scale: 1.0, orientation: image!.imageOrientation)
                    
                    self.capturedImage = image
                }
                //            let image11 = cropToBounds(image: image!, width: Double(cropImageRect.width), height: Double(cropImageRect.height))
                layoutCameraResult(uiImage: image!)
            }
        }
    }

    private func isViewInteractionEnable(_ status: Bool) {
        btnFromLanguage.isUserInteractionEnabled = status
        btnTargetLanguage.isUserInteractionEnabled = status
        backButton.isUserInteractionEnabled = status
        cameraHistoryImageView.isUserInteractionEnabled = status
        captureButton.isUserInteractionEnabled = status
    }
    
    internal func layoutCameraResult(uiImage: UIImage) {
        startConfirmController(uiImage: uiImage)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ///Get the preview screen size to determine the focuspoint
        let screenSize = previewView.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: previewView).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: previewView).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            let location = touchPoint.location(in: previewView)
            let focusCircleLocation = CGPoint(x: location.x, y: location.y)
            let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            
            if let device = backCamera {
                do {
                    try device.lockForConfiguration()
                    device.focusPointOfInterest = focusPoint
                    
                    /// Pass the touch point of camera preview view as center point
                    pointInCamera(centerPoint: focusCircleLocation, circleColor: circleColor)
                    device.focusMode = .autoFocus
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                }
                catch {
                    /// ignore for now
                }
            }
        }
    }
    
    func pointInCamera(centerPoint:CGPoint, circleColor: UIColor){
        ///Get the path based on the center point
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle:endAngle, clockwise: true)
        
        ///Draw the layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = circleColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        cameraPreviewView.layer.addSublayer(shapeLayer)
        self.zoomLevel.isHidden = false
        
        ///Remove the circle
        DispatchQueue.main.asyncAfter(deadline: .now() + removeTime) {
            self.zoomLevel.isHidden = true
            shapeLayer.removeFromSuperlayer()
        }
        
    }
    
    private func startConfirmController(uiImage: UIImage) {
        let vc = ImageCroppingViewController(image: uiImage, croppingParameters: croppingParameters)
        vc.onCompletion = { [weak self] image, asset in
            defer {
                self?.dismiss(animated: true, completion: nil)
            }
            
            guard let image = image else {
                return
            }
            self?.onCompletion?(image, asset)
            self?.onCompletion = nil
        }
        let transition = GlobalMethod.addMoveInTransitionAnimatation(duration: kScreenTransitionTime, animationStyle: CATransitionSubtype.fromLeft)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func didTouchFlashButton(sender: UIButton) {
        let batteryPercentage = UIDevice.current.batteryLevel * batteryMaxPercent
        if batteryPercentage <= flashDisabledBatteryPercentage {
            showLowBatteryErrorAlert(message: "camera_flash_unavailable".localiz())
        } else {
            if let activeCamera = activeCamera {
                if activeCamera.hasTorch {
                    // lock your device for configuration
                    do {
                        _ = try activeCamera.lockForConfiguration()
                    } catch {
                        PrintUtility.printLog(tag: "error", text: "")
                    }
                    // if flash is on turn it off, if turn off turn it on
                    if activeCamera.isTorchActive {
                        activeCamera.torchMode = AVCaptureDevice.TorchMode.off
                        flashButton.setImage(UIImage(named: "flash"), for: .normal)
                        
                        UserDefaults.standard.set(false, forKey: isCameraFlashOn)
                    } else {
                        // sets the torch intensity to 100%
                        do {
                            _ = try activeCamera.setTorchModeOn(level: 1.0)
                            flashButton.setImage(UIImage(named: "btn_flash_push"), for: .normal)
                            UserDefaults.standard.set(true, forKey: isCameraFlashOn)
                        } catch {
                            PrintUtility.printLog(tag: "error", text: "")
                        }
                    }
                    activeCamera.unlockForConfiguration()
                }
            }
        }
    }
    
    func turnOffCamera() {
        do {
            if let activeCamera = activeCamera {
                _ = try activeCamera.lockForConfiguration()
                activeCamera.torchMode = AVCaptureDevice.TorchMode.off
                flashButton.setImage(UIImage(named: "flash"), for: .normal)
                circleColor = .clear
            }
        } catch {
            PrintUtility.printLog(tag: "error", text: "")
        }

    }
    
    func showLowBatteryErrorAlert(message: String){
        let alertService = CustomAlertViewModel()
        let alert = alertService.alertDialogWithoutTitleWithOkButtonAction(message: message) {}
        self.present(alert, animated: true, completion: nil)
    }
    
}

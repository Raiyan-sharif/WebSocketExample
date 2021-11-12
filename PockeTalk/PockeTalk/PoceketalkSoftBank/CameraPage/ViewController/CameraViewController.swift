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
    
    /// Camera History
    private let cameraHistoryViewModel = CameraHistoryViewModel()
    var updateHomeContainer:((_ isfullScreen:Bool)->())?
    
    @IBAction func onFromLangBtnPressed(_ sender: Any) {
        UserDefaultsProperty<Bool>(KCameraLanguageFrom).value = true
        openCameraLanguageListScreen()
    }
    
    @IBAction func onTargetLangBtnPressed(_ sender: Any) {
        UserDefaultsProperty<Bool>(KCameraLanguageFrom).value = false
        openCameraLanguageListScreen()
    }
    
    func openCameraLanguageListScreen(){
        let storyboard = UIStoryboard(name: KStoryBoardCamera, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: KiDLangSelectCamera)as! LanguageSelectCameraVC
        controller.updateHomeContainer = { [weak self] in
            self?.updateHomeContainer?(true)
        }
       // self.navigationController?.pushViewController(controller, animated: true);
        self.updateHomeContainer?(false)
        add(asChildViewController: controller, containerView: view)
    }
    
    fileprivate func updateLanguageNames() {
        let languageManager = LanguageSelectionManager.shared
        let fromLangCode = CameraLanguageSelectionViewModel.shared.fromLanguage
        let targetLangCode = CameraLanguageSelectionViewModel.shared.targetLanguage
        
        let fromLang = CameraLanguageSelectionViewModel.shared.getLanguageInfoByCode(langCode: fromLangCode, languageList: CameraLanguageSelectionViewModel.shared.getFromLanguageLanguageList())
        let targetLang = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        if(fromLang?.code == CameraLanguageSelectionViewModel.shared.getFromLanguageLanguageList()[0].code){
            fromLangLabel.text = "\(fromLang!.sysLangName)"
        }else{
            fromLangLabel.text = "\(fromLang!.sysLangName) (\(fromLang!.name))"
        }
        toLangLabel.text = "\(targetLang!.sysLangName) (\(targetLang!.name))"
    }
    
    @objc func onCameraLanguageChanged(notification: Notification) {
        updateLanguageNames()
    }
        
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.onCameraLanguageChanged(notification:)), name: .languageSelectionCameraNotification, object: nil)
    }
    
    func unregisterNotification(){
        NotificationCenter.default.removeObserver(self, name: .languageSelectionCameraNotification, object: nil)
    }
    
    deinit {
        //unregisterNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUPViews()
        previewLayer.videoGravity = .resize
        previewView = cameraPreviewView
        previewView.frame = cameraPreviewView.frame
        cropImageRect = cameraPreviewView.frame
        previewView.layer.addSublayer(previewLayer)
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
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setUPViews() {
        captureButton.isExclusiveTouch = true
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
        let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
        if let vc = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CameraHistoryViewController.self)) as? CameraHistoryViewController {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateHomeContainer?(true)
        self.cameraHistoryViewModel.fetchCameraHistoryImages()
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
            }
        }
        registerNotification()
        updateLanguageNames()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sessionQueue.async { [weak self] in
            
            if let _ = self?.sessionSetupSucceeds {
                if let _session = self?.session {
                    _session.stopRunning()
                }
            }
        }
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
        self.updateHomeContainer?(false)
        NotificationCenter.default.post(name: .containerViewSelection, object: nil)
//        if(self.navigationController == nil){
//            self.dismiss(animated: true, completion: nil)
//        }else{
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    var croppingParameters: CropUtils {
        return CropUtils(enabled: true, resizeable: true, dragable: true, minimumSize: minimumSize)
    }
    
    @IBAction func captureButtonEventListener(_ sender: Any) {
        
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
            let focusCircleLocation = CGPoint(x: location.x, y: location.y+radius)
            let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            
            if let device = backCamera {
                do {
                    try device.lockForConfiguration()
                    device.focusPointOfInterest = focusPoint
                    
                    /// Pass the touch point of camera preview view as center point
                    pointInCamera(centerPoint: focusCircleLocation)
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
    
    func pointInCamera(centerPoint:CGPoint){
        ///Get the path based on the center point
        let circlePath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: startAngle, endAngle:endAngle, clockwise: true)
        
        ///Draw the layer
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = lineWidth
        
        view.layer.addSublayer(shapeLayer)
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
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func didTouchFlashButton(sender: UIButton) {
        if activeCamera!.hasTorch {
            // lock your device for configuration
            do {
                _ = try activeCamera!.lockForConfiguration()
            } catch {
                PrintUtility.printLog(tag: "error", text: "")
            }
            // if flash is on turn it off, if turn off turn it on
            if activeCamera!.isTorchActive {
                activeCamera!.torchMode = AVCaptureDevice.TorchMode.off
                flashButton.setImage(UIImage(named: "flash"), for: .normal)
                
            } else {
                // sets the torch intensity to 100%
                do {
                    _ = try activeCamera!.setTorchModeOn(level: 1.0)
                    flashButton.setImage(UIImage(named: "btn_flash_push"), for: .normal)
                } catch {
                    PrintUtility.printLog(tag: "error", text: "")
                }
            }
            activeCamera!.unlockForConfiguration()
        }
    }
}

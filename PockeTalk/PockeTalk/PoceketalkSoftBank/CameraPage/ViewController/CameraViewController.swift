//
//  CameraViewController.swift
//  PockeTalk
//
//

import AVFoundation
import Photos
import UIKit

enum Camera {
    case front, back
}

class CameraViewController: BaseViewController, AVCapturePhotoCaptureDelegate {
    
    let TAG = CameraViewController.self
    var minimumSize: CGSize = CGSize(width: 60, height: 60)
    @IBOutlet weak var zoomLevel: UILabel!
    var camera = Camera.back
    lazy var session = AVCaptureSession()
    lazy var photoOutput = AVCapturePhotoOutput()
    private var initialScale: CGFloat = 0
    var capturedImage = UIImage()
    var allowsLibraryAccess = true
    
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
        self.navigationController?.pushViewController(controller, animated: true);
    }
    
    fileprivate func updateLanguageNames() {
        let languageManager = LanguageSelectionManager.shared
        let fromLangCode = CameraLanguageSelectionViewModel.shared.fromLanguage
        let targetLangCode = CameraLanguageSelectionViewModel.shared.targetLanguage
        
        let fromLang = CameraLanguageSelectionViewModel.shared.getLanguageInfoByCode(langCode: fromLangCode, languageList: CameraLanguageSelectionViewModel.shared.getFromLanguageLanguageList())
        let targetLang = languageManager.getLanguageInfoByCode(langCode: targetLangCode)
        if(fromLang?.code == CameraLanguageSelectionViewModel.shared.getFromLanguageLanguageList()[0].code){
            btnFromLanguage.setTitle("\(fromLang!.sysLangName)", for: .normal)
        }else{
            btnFromLanguage.setTitle("\(fromLang!.sysLangName) (\(fromLang!.name))", for: .normal)
        }
        btnTargetLanguage.setTitle("\(targetLang!.sysLangName) (\(targetLang!.name))", for: .normal)
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
        unregisterNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUPViews()
        previewLayer.videoGravity = .resizeAspectFill
        previewView.frame = view.bounds
        cropImageRect = previewView.frame
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func setUPViews() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageHistoryEvent(sender: )))
        self.cameraHistoryImageView.addGestureRecognizer(tap)
    }
    
    @objc func imageHistoryEvent (sender: UITapGestureRecognizer) {
        let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
        if let vc = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CameraHistoryViewController.self)) as? CameraHistoryViewController {
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async { [unowned self] in
            if self.sessionSetupSucceeds {
                self.session.startRunning()
            }
        }
        registerNotification()
        updateLanguageNames()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sessionQueue.async { [unowned self] in
            if self.sessionSetupSucceeds {
                self.session.stopRunning()
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
                PHPhotoLibrary.shared().performChanges({
                    // Add the captured photo's file data as the main resource for the Photos asset.
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
                }, completionHandler: nil)
                
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
        self.navigationController?.popViewController(animated: true)
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
            layoutCameraResult(uiImage: image!)
        }
    }
    
    internal func layoutCameraResult(uiImage: UIImage) {
        startConfirmController(uiImage: uiImage)

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

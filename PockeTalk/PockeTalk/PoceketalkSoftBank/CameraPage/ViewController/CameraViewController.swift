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
    
    @IBOutlet weak var zoomLevel: UILabel!
    private(set) var camera = Camera.back

    private lazy var session = AVCaptureSession()
    private lazy var photoOutput = AVCapturePhotoOutput()
    private var initialScale: CGFloat = 0
    var capturedImage = UIImage()

    private var activeCamera: AVCaptureDevice?
    private lazy var backCamera: AVCaptureDevice? = {
        return AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInWideAngleCamera], mediaType: .video, position: .back).devices.first
    }()
    @IBOutlet weak var btnFromLanguage: RoundButtonWithBorder!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var btnTargetLanguage: RoundButtonWithBorder!
    @IBOutlet weak var cameraHistoryImageView: UIImageView!
    private lazy var previewView = UIView()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: session)

    // Used to determine the image orientation.
    private let currentDevice = UIDevice.current


    var zoomScaleRange: ClosedRange<CGFloat> = 1...5

    private let sessionQueue = DispatchQueue(label: "Session Queue")

    private var sessionSetupSucceeds = false

    private var captureProcessors: [Int64: PhotoCaptureProcessor] = [:]

    private var videoOrientation: AVCaptureVideoOrientation = .portrait

    @IBAction func onFromLangBtnPressed(_ sender: Any) {
            //self.showToast(message: "Show country selection screen", seconds: toastVisibleTime)
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
        // Bloking point start , to open camera screen without camera
        
        setUPViews()
        
        previewLayer.videoGravity = .resizeAspectFill
        previewView.frame = view.bounds
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
        // Bloking point end , to open camera screen without camera
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
        registerNotification()
        updateLanguageNames()
        sessionQueue.async { [unowned self] in
            if self.sessionSetupSucceeds {
                self.session.startRunning()
            }
        }
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

    func setCamera(_ camera: Camera) {
        guard sessionSetupSucceeds else { return }

        if camera == self.camera { return }

        sessionQueue.async { [unowned self] in
            self.session.beginConfiguration()
            self._setCamera(camera)
            self.session.commitConfiguration()
        }
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

        // Update the photo output's connection to match current device's orientation
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

    // Call this on the `sessionQueue`.
    
    private func configureSession() {
        self.session.beginConfiguration()

        self.session.sessionPreset = .photo

        if backCamera != nil {
            _setCamera(.back)
        } else {
            return
        }

        self.photoOutput.isHighResolutionCaptureEnabled = true
        guard self.session.canAddOutput(self.photoOutput) else {
            return
        }
        self.session.addOutput(self.photoOutput)

        self.session.commitConfiguration()

        sessionSetupSucceeds = true
    }

    private func _setCamera(_ camera: Camera) {
        let newDevice: AVCaptureDevice?
        newDevice = backCamera

        if let _currentInput = session.inputs.first {
            session.removeInput(_currentInput)
        }

        guard
            let device = newDevice,
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input) else { return }

        session.addInput(input)

        self.camera = camera
        activeCamera = device
    }

    private func configCamera(_ camera: AVCaptureDevice?, _ config: @escaping (AVCaptureDevice) -> ()) {
        guard let device = camera else { return }

        sessionQueue.async { [device] in
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }

            config(device)

            device.unlockForConfiguration()
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

        //focus
    }
    
}

// MARK: - Internal Photo class to get image
extension CameraViewController {

    class Photo {
        private let photo: AVCapturePhoto
        private let orientation: AVCaptureVideoOrientation

        fileprivate init(photo: AVCapturePhoto, orientation: AVCaptureVideoOrientation) {
            self.photo = photo
            self.orientation = orientation
        }

        func image() -> UIImage? {
            guard let cgImage = photo.cgImageRepresentation()?.takeUnretainedValue() else { return nil }

            let imageOrientation: UIImage.Orientation
            switch orientation {
            case .portrait:
                imageOrientation = .right
            case .portraitUpsideDown:
                imageOrientation = .left
            case .landscapeRight:
                imageOrientation = .up
            case .landscapeLeft:
                imageOrientation = .down
            }

            return UIImage(cgImage: cgImage, scale: 1, orientation: imageOrientation)
        }
    }
}


// MARK: - Photo Capture Processor
private class PhotoCaptureProcessor: NSObject {
    var photo: AVCapturePhoto?
    var completion: ((PhotoCaptureProcessor) -> Void)?
    var settings: AVCaptureResolvedPhotoSettings?
    var orientation: AVCaptureVideoOrientation = .portrait
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            return
        }

        self.photo = photo
        
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        guard error == nil else {
            return
        }

        self.settings = resolvedSettings
        
        completion?(self)
    }
}


extension CameraViewController {

    @IBAction func backButtonEventListener(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
    }


    @IBAction func captureButtonEventListener(_ sender: Any) {
        //        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        //        photoOutput.capturePhoto(with: settings, delegate: self)

        takePhoto { photo in
            let image = photo.image()
            if let captureImg = image {
                self.capturedImage = captureImg
            }
            let cropViewController = CropViewController(image: image ?? UIImage())
            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)

        }
        
    }


    @IBAction func didTouchFlashButton(sender: UIButton) {
        // check if the device has torch
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
            // unlock your device
            activeCamera!.unlockForConfiguration()
        }
    }


}


extension CameraViewController: CropViewControllerDelegate {

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        //self.captureImageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)

        let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
        if let vc = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CaptureImageProcessVC.self)) as? CaptureImageProcessVC {
            vc.image = image
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true) {
            let cameraStoryBoard = UIStoryboard(name: "Camera", bundle: nil)
            if let vc = cameraStoryBoard.instantiateViewController(withIdentifier: String(describing: CaptureImageProcessVC.self)) as? CaptureImageProcessVC {
                vc.image = self.capturedImage
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}

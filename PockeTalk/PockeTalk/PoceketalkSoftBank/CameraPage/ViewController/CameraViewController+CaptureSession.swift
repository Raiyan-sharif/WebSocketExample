//
//  CameraViewController+CaptureSession.swift
//  PockeTalk
//

import Foundation
import AVFoundation

extension CameraViewController {
    
    func setCamera(_ camera: Camera) {
        guard sessionSetupSucceeds else { return }
        
        if camera == self.camera { return }
        
        sessionQueue.async { [unowned self] in
            self.session.beginConfiguration()
            self._setCamera(camera)
            self.session.commitConfiguration()
        }
    }
    
    func _setCamera(_ camera: Camera) {
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
    
    func configCamera(_ camera: AVCaptureDevice?, _ config: @escaping (AVCaptureDevice) -> ()) {
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

    func configureSession() {
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
        
        sessionQueue.async { [unowned self] in
            if self.sessionSetupSucceeds {
                self.session.startRunning()
            }
        }
    }
}

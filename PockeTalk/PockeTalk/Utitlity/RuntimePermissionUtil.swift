//
//  RuntimePermissionUtil.swift
//  PockeTalk
//

import AVFoundation
import Photos
class RuntimePermissionUtil {

      func requestAuthorizationPermission(for mediaType: AVMediaType, completionHandler: @escaping (_ isGranted: Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: mediaType) {
        // The user has previously granted access to the camera.
        case .authorized:
            completionHandler(true)

        // The user has not yet been asked for camera access.
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: mediaType) { granted in
                if granted {
                    DispatchQueue.main.async {
                        completionHandler(true)
                    }
                }
            }


        // The user has previously denied access.
        case .denied:
            completionHandler(false)
            return

        // The user can't grant access due to restrictions.
        case .restricted:
            return
        default:
            break

        }
    }

    func requestAuthorizationPermissionForUsingPhotoLibrary(_ completionHandler: @escaping (Bool) -> Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        // The user has previously granted access to the Photos.
        case .authorized:
            completionHandler(true)
            return

        // The user has not yet been asked for Photos access.
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    return
                }
                DispatchQueue.main.async {
                    completionHandler(true)
                }

            }
            return

        // The user has previously denied access.
        case .denied:
            completionHandler(false)
            return

        default:
            break
        }
    }
}

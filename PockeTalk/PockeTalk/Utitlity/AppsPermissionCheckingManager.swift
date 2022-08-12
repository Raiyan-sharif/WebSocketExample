//
//  AppsPermissionCheckingManager.swift
//  PockeTalk
//
//  Created by BJIT on 4/1/22.
//

import Foundation
import UIKit
import AVFoundation
import UserNotifications

enum PermissionTypes {
    case microphone
    case camera
    case notification
}

class AppsPermissionCheckingManager {
    static let shared = AppsPermissionCheckingManager()
    private init() { }

    func checkPermissionFor(permissionTypes: PermissionTypes, completion: @escaping (_ status: Bool, _ permissionGiven: Bool) -> ()) {
        if permissionTypes == .microphone {
            switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                //If user allow the permission
                completion(true, true)
                break
            case .denied:
                //If user denied the permission
                completion(false, true)
                break
            case .undetermined:
                //First time
                AVAudioSession.sharedInstance().requestRecordPermission({ success in
                    if success {
                        completion(true, false)
                    } else {
                        completion(false, false)
                    }
                })
                break
            @unknown default:
                fatalError()
            }
        } else if permissionTypes == .camera {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                //First time
                AVCaptureDevice.requestAccess(for: .video) { success in
                    if success {
                        completion(true, false)
                    } else {
                        completion(false, false)
                    }
                }
                break
            case .restricted:
                //If user turns it off from app settings
                completion(false, true)
                break
            case .denied:
                //If user denied the permission
                completion(false, true)
                break
            case .authorized:
                //If user allow the permission
                completion(true, true)
                break
            @unknown default:
                fatalError()
            }
        } else if permissionTypes == .notification {
            let current = UNUserNotificationCenter.current()
            current.getNotificationSettings(completionHandler: { permission in
                switch permission.authorizationStatus  {
                case .authorized:
                    //If user allow the permission
                    completion(true, true)
                case .denied:
                    //If user denied the permission
                    completion(false, true)
                case .notDetermined:
                    //First time
                    current.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if granted {
                            completion(true, false)
                        } else {
                            completion(false, false)
                        }
                    }
                case .provisional:
                    // @available(iOS 12.0, *)
                    // The application is authorized to post non-interruptive user notifications.
                    completion(true, true)
                case .ephemeral:
                    // @available(iOS 14.0, *)
                    // The application is temporarily authorized to post notifications. Only available to app clips.
                    completion(true, true)
                @unknown default:
                    PrintUtility.printLog(tag: "unknowDefault", text: "Unknow Status")
                }
            })
        }
    }
}

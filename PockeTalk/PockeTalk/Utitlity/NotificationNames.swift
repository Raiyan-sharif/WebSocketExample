//
//  NotificationNames.swift
//  PockeTalk
//

import Foundation
extension Notification.Name {
    static let languageSelectionVoiceNotification = Notification.Name("languageSelectionVoiceNotification")
    static let languageSelectionCameraNotification = Notification.Name("languageSelectionCameraNotification")
    static let languageSelectionArrowNotification = Notification.Name("languageSelectionArrowNotification")
    static let containerViewSelection = Notification.Name("ContainerViewSelection")
    static let animationDidEnterBackground = Notification.Name("animationDidEnterBackground")
    static let ttsNotofication = Notification.Name("TTSVCNotification")
    static let pronuntiationNotification = Notification.Name("PronuntiationNotification")
    static let pronuntiationResultNotification = Notification.Name("pronuntiationResultNotification")
    static let historyNotofication = Notification.Name("HistoryNotofication")
    static let languageListNotofication = Notification.Name("languageListNotofication")
    static let languageHistoryListNotification = Notification.Name("languageHistoryListNotification")
    
    static let countySlectionByVoiceNotofication = Notification.Name("countySlectionByVoiceNotofication")
    static let cameraSelectionLanguage = Notification.Name("CameraSelectionLanguage")
    static let cameraHistorySelectionLanguage = Notification.Name("cameraHistorySelectionLanguage")
    
    static let pronumTiationTextUpdate = Notification.Name("PronumTiationTextUpdate")
    static let tapOnMicrophoneLanguageSelectionVoice = Notification.Name("tapOnMicrophoneLanguageSelectionVoice")
    static let tapOffMicrophoneLanguageSelectionVoice = Notification.Name("tapOffMicrophoneLanguageSelectionVoice")
    
    static let tapOnMicrophoneCountrySelectionVoice = Notification.Name("tapOnCountrySelectionVoice")
    static let tapOffMicrophoneCountrySelectionVoice = Notification.Name("tapOffCountrySelectionVoice")
    static let popFromCountrySelectionVoice = Notification.Name("popFromCountrySelectionVoice")
    static let pronuntiationTTSStopNotification = Notification.Name("pronuntiationTTSStopNotification")
    static let popFromCameralanguageSelectionVoice = Notification.Name("popFromCameralanguageSelectionVoice")
    
    static let tapOnMicrophoneCountrySelectionVoiceCamera = Notification.Name("tapOnMicrophoneCountrySelectionVoiceCamera")
    static let tapOffMicrophoneCountrySelectionVoiceCamera = Notification.Name("tapOffMicrophoneCountrySelectionVoiceCamera")
    static let updateTranlationNotification = Notification.Name("UpdateTranlationNotification")
}

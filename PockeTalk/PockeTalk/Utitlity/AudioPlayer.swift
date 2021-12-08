//
//  AudioPlayer.swift
//  PockeTalk
//
//  Created by Morshed Alam on 12/3/21.
//

import Foundation
import AVFoundation
protocol AudioPlayerDelegate:class{
    func didStopAudioPlayer(flag: Bool)
    func didStartAudioPlayer()
}

class AudioPlayer: NSObject {
    static let sharedInstance = AudioPlayer()
    private var player: AVAudioPlayer?
    weak var delegate:AudioPlayerDelegate!
    var isPlaying = false
    func play(data:Data) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.wav.rawValue)
            guard let player = player else { return }
            player.prepareToPlay()
            player.delegate = self
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    func stop() {
        isPlaying = false
        player?.stop()
        player = nil
    }

    func getTTSDataAndPlay(translateText:String,targetLanguageItem:String, tempo:String){
         let item = LanguageEngineParser.shared.getTTTSSupportEngine(langCode: targetLanguageItem)!
        PrintUtility.printLog(tag: "Engine Name", text: item)

        let params:[String:String]  = [
            imei : "862793051345020",
            licenseToken:"" ,
            language : targetLanguageItem,
            text : translateText,
            tempo: item == engineName ? normal : tempo
        ]
        if Reachability.isConnectedToNetwork() {
        NetworkManager.shareInstance.ttsApi(params: params) { [weak self] data  in
            guard let data = data, let self = self else { return }
            do {
                let result = try JSONDecoder().decode(TTSModel.self, from: data)
                if result.resultCode == response_ok, let ttsValue = result.tts, let ttsData = Data(base64Encoded: ttsValue){
                    self.delegate.didStartAudioPlayer()
                    self.isPlaying = true
                    self.play(data: ttsData)
                }
            }catch{
            }
        }
     }
    }
}

extension AudioPlayer:AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isPlaying = false
        self.delegate.didStopAudioPlayer(flag: flag)
        self.player = nil
    }
}

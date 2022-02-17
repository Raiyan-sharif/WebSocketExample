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
    weak var delegate:AudioPlayerDelegate?
    var isPlaying = false
    func play(data:Data) {
        do {
            if(AVCaptureDevice.authorizationStatus(for: .audio) != .authorized){
                try AVAudioSession.sharedInstance().setCategory(.playback)
                try AVAudioSession.sharedInstance().setActive(true)
            }

            player = try AVAudioPlayer(data: data, fileTypeHint: AVFileType.wav.rawValue)
            guard let player = player else { return }
            player.prepareToPlay()
            player.delegate = self
            player.play()

        } catch let error {
            PrintUtility.printLog(tag: "PLAYER_ERROR", text: error.localizedDescription)
        }
    }

    func stop() {
        isPlaying = false
        player?.stop()
        player = nil
    }

    func getTTSDataAndPlay(translateText:String,targetLanguageItem:String, tempo:String){

        guard let item = LanguageEngineParser.shared.getTTTSSupportEngine(langCode: targetLanguageItem) else {
            return
        }
        PrintUtility.printLog(tag: "Engine Name", text: item)
        var licenseToken = ""
        if let token =  UserDefaults.standard.string(forKey: licenseTokenUserDefaultKey) {
            licenseToken = token
        }
        let params:[String:String]  = [
            license_token: licenseToken,
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
                        if let delegate = self.delegate {
                            delegate.didStartAudioPlayer()
                            self.isPlaying = true
                            if self.isHeaderExist(data: ttsData){
                                self.play(data: ttsData)
                            }else{
                                let sampleRate = self.codecValue(value: result.codec!)
                                let headerData = self.createWaveHeader(sampleRate: (sampleRate as NSString).integerValue, data: ttsData)
                                let playData = headerData + ttsData
                                self.play(data: playData)
                            }
                        }
                        

                    }
                }catch{
                }
            }
        }
    }
    
    

    private func createWaveHeader(sampleRate: Int , data: Data) -> Data {
        let sampleRate:Int32 = Int32(sampleRate)
        let chunkSize:Int32 = 16 + Int32(data.count)
        let subChunkSize:Int32 = 16
        let format:Int16 = 1
        let channels:Int16 = 1
        let bitsPerSample:Int16 = 16
        let byteRate:Int32 = sampleRate * Int32(channels * bitsPerSample / 8)
        let blockAlign: Int16 = channels * bitsPerSample / 8
        let dataSize:Int32 = Int32(data.count)

        let header = NSMutableData()

        header.append([UInt8]("RIFF".utf8), length: 4)
        header.append(intToByteArray(chunkSize), length: 4)

        //WAVE
        header.append([UInt8]("WAVE".utf8), length: 4)

        //FMT
        header.append([UInt8]("fmt ".utf8), length: 4)

        header.append(intToByteArray(subChunkSize), length: 4)
        header.append(shortToByteArray(format), length: 2)
        header.append(shortToByteArray(channels), length: 2)
        header.append(intToByteArray(sampleRate), length: 4)
        header.append(intToByteArray(byteRate), length: 4)
        header.append(shortToByteArray(blockAlign), length: 2)
        header.append(shortToByteArray(bitsPerSample), length: 2)

        header.append([UInt8]("data".utf8), length: 4)
        header.append(intToByteArray(dataSize), length: 4)

        return header as Data
    }

    private func intToByteArray(_ i: Int32) -> [UInt8] {
        return [
            //little endian
            UInt8(truncatingIfNeeded: (i      ) & 0xff),
            UInt8(truncatingIfNeeded: (i >>  8) & 0xff),
            UInt8(truncatingIfNeeded: (i >> 16) & 0xff),
            UInt8(truncatingIfNeeded: (i >> 24) & 0xff)
        ]
    }

    private func shortToByteArray(_ i: Int16) -> [UInt8] {
        return [
            //little endian
            UInt8(truncatingIfNeeded: (i      ) & 0xff),
            UInt8(truncatingIfNeeded: (i >>  8) & 0xff)
        ]
    }

    private func isHeaderExist(data:Data) -> Bool {
        let position = data.subdata(in: 8..<12)
        let wave = String(bytes: position, encoding: .utf8) ?? "NoName"
        guard wave == "WAVE" else {
            return false
        }
        return true
    }

    private func codecValue(value : String)->String{
        if value != nil{
            if value.contains(KEngineSeparator){
                return value.components(separatedBy: KEngineSeparator)[1]
            }else{
                return value
            }
        }
        return ""
    }
    
}

extension AudioPlayer:AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.isPlaying = false
        self.delegate?.didStopAudioPlayer(flag: flag)
        self.player = nil
    }
}

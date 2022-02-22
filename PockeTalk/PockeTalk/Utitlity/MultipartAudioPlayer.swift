//
//  MultipartAudioPlayer.swift
//  PockeTalk
//
//  Created by BJIT LTD on 8/2/22.
//

import Foundation
import AVFoundation
import AVKit

protocol MultipartAudioPlayerProtocol: AnyObject{
    func onSpeakStart()
    func onSpeakFinish()
    func onError()
}

class MultipartAudioPlayer: UIView, AVAudioPlayerDelegate {
    var player: AVPlayer?
    var urlToPlay:[String] = []
    var avplayerController: AVPlayerViewController = AVPlayerViewController()
    var delegate: MultipartAudioPlayerProtocol?
    var playerItemContext = 0

    init(controller: UIViewController, delegate: MultipartAudioPlayerProtocol?){
        super.init(frame: .zero)
            //try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            avplayerController.player = player
            avplayerController.showsPlaybackControls = false
            controller.addChild(avplayerController)
            let screenSize = UIScreen.main.bounds.size
            let videoFrame = CGRect(x: 0, y: 130, width: screenSize.width, height: (screenSize.height - 130) / 2)
            avplayerController.view.frame = videoFrame
            avplayerController.view.isHidden = true
            avplayerController.view.tag = multipartPlayerViewTag
            controller.view.addSubview(avplayerController.view)
            self.delegate = delegate

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func playMultipartAudio(urls: [String]){
        urlToPlay = urls
        self.play(position: 0)
        self.delegate?.onSpeakStart()
    }
    
    
    func play(position: Int) {
        if(urlToPlay.isEmpty){
            self.delegate?.onSpeakFinish()
            return
        }
        
        let item = AVPlayerItem(url: URL.init(string: self.urlToPlay[position])!)
        item.addObserver(self,
                         forKeyPath: #keyPath(AVPlayerItem.status),
                         options: [.old, .new],
                         context: &playerItemContext)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(sender:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
        
        player = AVPlayer(playerItem: item)
        avplayerController.player = player
        player?.play()
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
           guard context == &playerItemContext else {
               super.observeValue(forKeyPath: keyPath,
                                  of: object,
                                  change: change,
                                  context: context)
               return
           }

           if keyPath == #keyPath(AVPlayerItem.status) {
               let status: AVPlayerItem.Status
               if let statusNumber = change?[.newKey] as? NSNumber {
                   status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
               } else {
                   status = .unknown
               }

               // Switch over status value
               switch status {
               case .readyToPlay:
                   PrintUtility.printLog(tag: "multipartUrlListener", text: "readyToPlay")
                   let dateFormatter = DateFormatter()
                   dateFormatter.timeStyle = .medium
                   PrintUtility.printLog(tag: "multipartUrlListener", text: "readyToPlay The time is: \(dateFormatter.string(from: Date() as Date))")
                   break
                   // Player item is ready to play.
               case .failed:
                   PrintUtility.printLog(tag: "multipartUrlListener", text: "failed")
                   self.urlToPlay = []
                   self.delegate?.onSpeakFinish()
                   break
                   // Player item failed. See error.
               case .unknown:
                   PrintUtility.printLog(tag: "multipartUrlListener", text: "unknown")
                   break
                   // Player item is not yet ready.
               }
               
           }
    }
    
    @objc func playerDidFinishPlaying(sender: Notification) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        PrintUtility.printLog(tag: "multipartUrlListener", text: "GotThe time is: \(dateFormatter.string(from: Date() as Date))")
        
        if(urlToPlay.count > 0) {
            self.urlToPlay.remove(at: 0)
        }
        if(urlToPlay.count > 0) {
            self.play(position: 0)
        }else{
            self.delegate?.onSpeakFinish()
        }
    }
    
    func stop() {
        if let play = player {
            play.pause()
            player = nil
        }
        urlToPlay = []
        self.delegate?.onSpeakFinish()
    }
}

//
//  TutorialContainerViewController.swift
//  PockeTalk
//

import UIKit
import AVKit
import AVFoundation

class TutorialContainerViewController: BaseViewController{
    var playVideoCallback: (()-> Void)?
    var player: AVPlayer?
    var playerLayer: CALayer?

    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
        self.view.backgroundColor = UIColor.white
        setupVideoPlayer()
        player?.play()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        playerLayer?.frame = self.view.bounds
    }

    //MARK: - Initial Setup
    private func setupVideoPlayer() {
        self.view.backgroundColor = .clear
        ///get the video path and set on player
        guard let path = Bundle.main.path(forResource: "tutorial", ofType: "mp4") else { return }
        let videoURL = NSURL(fileURLWithPath: path)
        player = AVPlayer(url: videoURL as URL)

        //create and embade AVPlayerViewController
        let avPlayerVC = UIViewController()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.shouldRasterize = true
        playerLayer?.rasterizationScale = UIScreen.main.scale
        playerLayer?.frame = self.view.bounds
        if let playerLyr = playerLayer {
            avPlayerVC.view.layer.addSublayer(playerLyr)
        }
        avPlayerVC.view.backgroundColor = UIColor.clear
        embed(avPlayerVC, inView: self.view)
        ///register tap gesture
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        avPlayerVC.view.addGestureRecognizer(tapGestureRecognizer)
        avPlayerVC.view.isExclusiveTouch = true
    }
    
    //MARK: - IBActions
    @objc func handleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        //playVideo()
        player?.seek(to: .zero)
        player?.play()
        playVideoCallback?()
    }

    @objc func playerDidFinishPlaying(note: NSNotification) {
        player?.seek(to: CMTimeMakeWithSeconds(100, preferredTimescale: 1))
    }
    
}

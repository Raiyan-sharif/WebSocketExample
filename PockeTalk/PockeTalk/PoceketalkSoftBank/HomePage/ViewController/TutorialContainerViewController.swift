//
//  TutorialContainerViewController.swift
//  PockeTalk
//

import UIKit
import AVKit

class TutorialContainerViewController: BaseViewController{
    var playVideoCallback: (()-> Void)?
    var player: AVPlayer?
    
    //MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        setupVideoPlayer()
        player?.play()
    }
    
    //MARK: - Initial Setup
    private func setupVideoPlayer() {
        ///get the video path and set on player
        guard let path = Bundle.main.path(forResource: "tutorial", ofType: "mp4") else { return }
        let videoURL = NSURL(fileURLWithPath: path)
        player = AVPlayer(url: videoURL as URL)
        
        ///create and embade AVPlayerViewController
        let avPlayerVC = AVPlayerViewController()
        avPlayerVC.player = player
        avPlayerVC.showsPlaybackControls = false
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
}

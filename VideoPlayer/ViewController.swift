//
//  ViewController.swift
//  VideoPlayer
//
//  Created by Ethan on 2020/11/4.
//  Copyright © 2020 ethanlab. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    var videoView = UIView()
    let playButton = UIButton(type: .system)
    var playSlider = UISlider()
    var player: AVPlayer?
    var isPlaying = false {
        willSet {
            playButton.setTitle(newValue ? "暫停" : "播放", for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(videoView)
        videoView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        playSlider.translatesAutoresizingMaskIntoConstraints = false
        playSlider.isContinuous = false
        view.addSubview(playSlider)
        playSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        playSlider.topAnchor.constraint(equalTo: videoView.bottomAnchor).isActive = true
        playSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        playSlider.addTarget(self, action: #selector(dragSlider), for: .valueChanged)
 
        playButton.setTitle("播放", for: .normal)
        playButton.addTarget(self, action: #selector(tapPlayButton), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playButton)
        playButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        playButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let url = Bundle.main.url(forResource: "test", withExtension: "mp4") {
            player = AVPlayer(url: url)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = videoView.bounds
            videoView.layer.addSublayer(playerLayer)
            addPlayTimerObserver()
        }
    }
    
    @objc func tapPlayButton() {
        if playSlider.value == 1 {
            let duration: Int64 = 0
            let beginTime = CMTime(value: duration, timescale: CMTimeScale(NSEC_PER_SEC))
            player?.seek(to: beginTime)
            player?.play()
            playSlider.value = 0
        } else {
            if isPlaying {
                player?.pause()
            } else {
                player?.play()
            }
        }
        isPlaying.toggle()
    }
    
    @objc func dragSlider(_ playbackSlider:UISlider, event: UIEvent) {
        let sliderValue = Float64(playSlider.value)
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let currentSeconds = Int64(sliderValue * totalSeconds)
        let targetTime = CMTime(value: currentSeconds, timescale: 1)
        player?.seek(to: targetTime)
        
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .began:
                if isPlaying {
                    player?.pause()
                }
            case .ended:
                if isPlaying {
                    player?.play()
                }
            default: break
            }
        }
    }
    
    func addPlayTimerObserver() {
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        let mainQueue = DispatchQueue.main
        player?.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
            let currentSeconds = CMTimeGetSeconds(time)
            guard let weakSelf = self, let duration = weakSelf.player?.currentItem?.duration else { return }
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = Float(currentSeconds / totalSeconds)
            weakSelf.playSlider.value = value
            if weakSelf.playSlider.value == 1 {
                weakSelf.isPlaying.toggle()
            }
        }
    }


}


//
//  VideoPlayerView.swift
//  VideoPlayer
//
//  Created by Ethan on 2020/11/5.
//  Copyright © 2020 ethanlab. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class VideoPlayerView: UIView {
    
    var displayView = UIView()
    let playButton = UIButton(type: .system)
    var playSlider = UISlider()
    var player: AVPlayer?
    var isPlaying = false {
        willSet {
            playButton.setTitle(newValue ? "暫停" : "播放", for: .normal)
        }
    }
    
    init(withUrl url: URL) {
        super.init(frame: CGRect.zero)
        setupBasicUI()
        setupPlayer(withUrl: url)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if displayView.bounds != CGRect.zero {
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = displayView.bounds
            displayView.layer.addSublayer(playerLayer)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBasicUI() {
        displayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(displayView)
        displayView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        displayView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        displayView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        playSlider.translatesAutoresizingMaskIntoConstraints = false
        playSlider.isContinuous = false
        addSubview(playSlider)
        playSlider.heightAnchor.constraint(equalToConstant: 15).isActive = true
        playSlider.topAnchor.constraint(equalTo: displayView.bottomAnchor).isActive = true
        playSlider.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        playSlider.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        playSlider.addTarget(self, action: #selector(dragSlider), for: .valueChanged)
 
        playButton.setTitle("播放", for: .normal)
        playButton.addTarget(self, action: #selector(tapPlayButton), for: .touchUpInside)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(playButton)
        playButton.widthAnchor.constraint(equalToConstant: 15).isActive = true
        playButton.topAnchor.constraint(equalTo: displayView.bottomAnchor).isActive = true
        playButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        playButton.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        playButton.trailingAnchor.constraint(equalTo: playSlider.leadingAnchor).isActive = true
    }
    
    private func setupPlayer(withUrl url: URL) {
        player = AVPlayer(url: url)
        addPlayTimerObserver()
    }
    
    private func addPlayTimerObserver() {
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
    
}

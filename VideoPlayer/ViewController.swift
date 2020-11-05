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
    
    var videoView: VideoPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let url = Bundle.main.url(forResource: "test", withExtension: "mp4") {
            let videoView = VideoPlayerView(withUrl: url)
            view.addSubview(videoView)
            videoView.translatesAutoresizingMaskIntoConstraints = false
            videoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            videoView.heightAnchor.constraint(equalToConstant: 315).isActive = true
        }
    }


}


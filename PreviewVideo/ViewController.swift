//
//  ViewController.swift
//  PreviewVideo
//
//  Created by VietLV on 10/12/20.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    var videoURL: URL!

    @IBOutlet weak var cslider: CSlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var remainTimeLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var videoView: UIView!

    private var playerItem: AVPlayerItem?
    private var videoPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        config()
        makeData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAsset()
    }

    override func viewDidLayoutSubviews() {
        playerLayer?.frame = videoView.bounds
    }

    private func makeData() {
        videoURL = Bundle.main.url(forResource: "sample", withExtension: "mp4")
    }

    private func loadAsset() {
        let asset = AVAsset.init(url: videoURL)
        playerItem = AVPlayerItem.init(asset: asset)
        videoPlayer = AVPlayer.init(playerItem: playerItem)
        playerLayer = AVPlayerLayer.init(player: videoPlayer)
        playerLayer?.videoGravity = .resizeAspect
        videoView.layer.addSublayer(playerLayer!)
        playerLayer?.frame = videoView.bounds

        playVideo()
        addVideoTimeChecking()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }

    // MARK: - Config
    private func config() {
        cslider.thumbColor = .orange
        cslider.leftColor = .orange
        cslider.rightColor = .lightGray
        cslider.delegate = self
    }

    // MARK: - Notification
    private func addVideoTimeChecking() {
        videoPlayer?.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 30), queue: .main, using: { [self] (_) in
            let timeValue = self.playerItem!.currentTime().seconds / self.playerItem!.duration.seconds
            if timeValue.isNaN {
                return
            }
            self.cslider.value = CGFloat(timeValue)
            self.updateVideoTime()
        })
    }

    @objc func playerDidFinishPlaying(_ notification: Notification) {
        videoPlayer?.seek(to: .zero)
        playVideo()
    }

    // MARK: - IBAction
    @IBAction func backButtonDidTap(_ sender: Any) {
        print(#function)
    }

    @IBAction func playPauseButtonDidTap(_ sender: Any) {
        if isPlaying {
            pauseVideo()
        } else {
            playVideo()
        }
    }

    // MARK: - Helper
    private func updateVideoTime() {
        let currentTime = Int(playerItem!.currentTime().seconds)
        let remainTime = Int(CMTimeSubtract(playerItem!.duration, playerItem!.currentTime()).seconds)

        currentTimeLabel.text = String(format: "%02d:%02d", currentTime / 60, currentTime % 60)
        remainTimeLabel.text = String(format: "-%02d:%02d", remainTime / 60, remainTime % 60)
    }

    private func playVideo() {
        isPlaying = true
        playPauseButton.setImage(UIImage.init(named: "ic_pause"), for: .normal)
        videoPlayer?.play()
    }

    private func pauseVideo() {
        isPlaying = false
        playPauseButton.setImage(UIImage.init(named: "ic_play"), for: .normal)
        videoPlayer?.pause()
    }
}

// MARK: - CSliderDelegate
extension ViewController: CSliderDelegate {
    func csliderDidChangedValue(_ slider: CSlider) {
        let seekTime = CMTimeMultiplyByFloat64(self.playerItem!.duration, multiplier: Float64(slider.value))
        videoPlayer?.seek(to: seekTime)
    }

    func csliderDidEndChangeValue(_ slider: CSlider) {
        playVideo()
    }

    func csliderWillBeginChangeValue(_ slider: CSlider) {
        pauseVideo()
    }
}


//
//  AudioPlayerViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 19..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit
import MediaPlayer

class AudioPlayerViewController: UIViewController {
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var waveformContainer: UIScrollView!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var audioPlotWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var volumeView: AudioVolumeView!
    
    public var item: AudioItem?
    fileprivate var audioFile: EZAudioFile?
    fileprivate var timer: Timer?
    fileprivate var playingWhenScrollStart = false
    fileprivate var scrollViewDecelerate = false

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item = self.item else { return }
        if (AudioManager.sharedInstance().isPlayingItemSame(asItem: self.item)) {
        } else {
            AudioManager.sharedInstance().play(playingItem: item)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AudioManager.sharedInstance().register(delegate: self)
        self.setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioManager.sharedInstance().delete(delegate: self)
    }
    
    // MARK - Private
    func setup() {
        guard let item = self.item else { return }
        self.titleLabel.text = item.title
        self.artistNameLabel.text = item.artist
        self.albumCoverImageView.image = item.artwork
        self.loadWaveform(url: item.fileURL, duration: AudioManager.sharedInstance().duration())
        self.waveformContainer.delegate = self
        if (AudioManager.sharedInstance().isPlaying()) {
            self.setupPlaying()
        } else {
            self.setupPause()
        }
    }
    
    func loadWaveform(url: URL, duration: TimeInterval?) {
        weak var weakSelf = self
        let screenWidth = UIScreen.main.bounds.width
        self.waveformContainer.contentInset = UIEdgeInsets(top: 0, left: screenWidth / 2, bottom: 0, right: screenWidth / 2)
        var width = screenWidth
        if let duration = duration {
            width = CGFloat(duration.value()) * 10
        }
        self.audioPlotWidthConstraint.constant = width
        self.audioFile = EZAudioFile(url: url)
        self.audioPlot.plotType = .buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.color = UIColor.blue
        self.audioFile?.getWaveformData(completionBlock: { (waveformData: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>?, length: Int32) in
            weakSelf?.audioPlot.updateBuffer(waveformData?[0], withBufferSize: UInt32(length))
        })
    }
    
    func setupPlaying() {
        self.playButton.setTitle("Pause", for: .normal)
    }
    
    func setupPause() {
        self.playButton.setTitle("Play", for: .normal)
    }
    
    // MARK - IBBinding
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        if (AudioManager.sharedInstance().isPlaying()) {
            AudioManager.sharedInstance().pause()
        } else {
            AudioManager.sharedInstance().resume()
        }
    }
    
    @IBAction func moveBeforeButtonTapped(_ sender: Any) {
        AudioManager.sharedInstance().moveBackwardCurrentAudio()
    }
    
    @IBAction func moveAfterButtonTapped(_ sender: Any) {
        AudioManager.sharedInstance().moveForwardCurrentAudio()
    }
    
    @IBAction func playNextButtonTapped(_ sender: Any) {
        AudioManager.sharedInstance().playNextAudio()
    }
    
    @IBAction func playPreviousButtonTapped(_ sender: Any) {
        if let currentTime = AudioManager.sharedInstance().playingTime() {
            if currentTime > 5 {
                AudioManager.sharedInstance().move(at: 0)
                return
            }
            AudioManager.sharedInstance().playPrevAudio()
        }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        
    }
}

extension AudioPlayerViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (self.scrollViewDecelerate) {
            return
        }
        self.playingWhenScrollStart = AudioManager.sharedInstance().isPlaying()
        AudioManager.sharedInstance().pause()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollViewDecelerate = decelerate
        if (!decelerate) {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDecelerate = false
        let progress = (scrollView.contentInset.left + scrollView.contentOffset.x) / scrollView.contentSize.width
        if (progress <= 0) {
            AudioManager.sharedInstance().move(at: 0)
        } else if (progress >= 1.0) {
            if let duration = AudioManager.sharedInstance().duration() {
                AudioManager.sharedInstance().move(at: duration)
            } else {
                AudioManager.sharedInstance().move(at: 0)
            }
        } else {
            AudioManager.sharedInstance().move(progress: Double(progress))
        }
        
        if (self.playingWhenScrollStart) {
            AudioManager.sharedInstance().resume()
        }
    }
}

extension AudioPlayerViewController: AudioManagerDelegate {
    func didStartPlaying(item: AudioItem) {
        self.item = item
        self.setup()
    }
    
    func didPausePlaying(item: AudioItem) {
        self.setupPause()
    }
    
    func didResumePlaying(item: AudioItem) {
        self.setupPlaying()
    }
    
    func didResetPlaying() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didUpdateTime(progress: Double) {
        self.waveformContainer.delegate = nil
        self.waveformContainer.contentOffset = CGPoint(x: (CGFloat(progress) * self.waveformContainer.contentSize.width) - self.waveformContainer.contentInset.left, y: 0)
        self.waveformContainer.delegate = self
    }
}

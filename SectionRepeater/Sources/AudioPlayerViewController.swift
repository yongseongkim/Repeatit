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

/*
 필요한 audio 정보
 - file information(name, album cover, lyrics)
 - current play time, total play time
 필요한 기능
 - play(play current, play next, play prev), pause, stop
 - move play time
 - part iteration
 - play repeat, play once
 - change play rate
 */

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
    @IBOutlet weak var volumeSlider: UISlider!
    
    public var item: AudioItem?
    fileprivate var audioFile: EZAudioFile?
    fileprivate var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let item = self.item else { return }
        AudioManager.sharedInstance().play(playingItem: item)
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
        self.loadWaveform(url: item.fileURL, duration: 100)
        self.waveformContainer.delegate = self
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
        AudioManager.sharedInstance().playPrevAudio()
    }
    
    @IBAction func slidenrChanged(_ sender: Any) {
        AudioManager.sharedInstance().setVolume(volume: self.volumeSlider.value)
    }
}

extension AudioPlayerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let screenWidth = UIScreen.main.bounds.width
        if (scrollView.contentOffset.x < -screenWidth) {
            AudioManager.sharedInstance().moveTo(at: 0)
            return
        }
        if scrollView.contentOffset.x > scrollView.contentSize.width - (screenWidth / 2) {
            AudioManager.sharedInstance().moveTo(progress: 1)
            return
        }
        let progress = scrollView.contentOffset.x / scrollView.contentSize.width
        AudioManager.sharedInstance().moveTo(progress: Double(progress))
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        AudioManager.sharedInstance().pause()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let progress = (scrollView.contentOffset.x + scrollView.contentInset.left) / scrollView.contentSize.width
        if (progress >= 1.0) {
            AudioManager.sharedInstance().playNextAudio()
            return
        }
        AudioManager.sharedInstance().moveTo(progress: Double(progress))
        AudioManager.sharedInstance().resume()
    }
}

extension AudioPlayerViewController: AudioManagerDelegate {
    func didStartPlaying(item: AudioItem) {
        if self.item?.fileURL.absoluteString == item.fileURL.absoluteString {
            return
        }
        self.playButton.setTitle("Play", for: .normal)
        self.item = item
        self.setup()
    }
    
    func didPausePlaying(item: AudioItem) {
        self.playButton.setTitle("Pause", for: .normal)
    }
    
    func didResumePlaying(item: AudioItem) {
        self.playButton.setTitle("Play", for: .normal)
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

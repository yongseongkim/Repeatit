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
    
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var lyricsView: UIView!
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var waveformContainer: UIScrollView!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var audioPlotWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var repeatItemButton: UIButton!
    @IBOutlet weak var repeatSwitchButton: UIButton!
    @IBOutlet weak var volumeView: AudioVolumeView!
    @IBOutlet weak var rateButton: UIButton!
    
    public var item: AudioItem?
    fileprivate var manager: AudioManager
    fileprivate var audioFile: EZAudioFile?
    fileprivate var timer: Timer?
    fileprivate var playingWhenScrollStart = false
    fileprivate var scrollViewDecelerate = false
    fileprivate var bookmarkViews: [UIView]?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.manager = Dependencies.sharedInstance().resolve(serviceType: AudioManager.self)!
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.manager.notificationCenter.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.manager.notificationCenter.addObserver(self, selector: #selector(handleAudioItemChanged(object:)), name: .onAudioManagerItemChanged, object: nil)
        self.manager.notificationCenter.addObserver(self, selector: #selector(handleAudioPlay), name: .onAudioManagerPlay, object: nil)
        self.manager.notificationCenter.addObserver(self, selector: #selector(handleAudioPause), name: .onAudioManagerPause, object: nil)
        self.manager.notificationCenter.addObserver(self, selector: #selector(handleAudioReset), name: .onAudioManagerReset, object: nil)
        self.manager.notificationCenter.addObserver(self, selector: #selector(handleAudioTimeChanged), name: .onAudioManagerTimeChanged, object: nil)
        self.manager.notificationCenter.addObserver(self, selector: #selector(handleAudioBookmarkUpdated), name: .onAudioManagerBookmarkUpdated, object: nil)
        self.manager.notificationCenter.addObserver(self, selector: #selector(handleAudioRateChanged), name: .onAudioManagerRateChanged, object: nil)
        guard let item = self.item else { return }
        self.manager.play(targetURL: item.fileURL)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setup()
    }
    
    // MARK - Private
    func setup() {
        guard let item = self.item else { return }
        self.titleLabel.text = item.title
        self.artistNameLabel.text = item.artist
        self.albumCoverImageView.image = item.artwork
        self.loadWaveform(url: item.fileURL, duration: self.manager.currentPlayingItemDuration())
        self.lyricsTextView.text = item.lyrics
        self.waveformContainer.delegate = self
        self.loadBookmarks()
        self.setupButtons()
    }
    
    func loadWaveform(url: URL, duration: TimeInterval?) {
        weak var weakSelf = self
        let inset = self.waveformContainer.bounds.width / 2
        self.waveformContainer.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        var width = UIScreen.main.bounds.width
        if let duration = duration {
            width = CGFloat(duration.value()) * 10
            self.waveformContainer.contentSize = CGSize(width:width, height:self.waveformContainer.bounds.height)
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
    
    func loadBookmarks() {
        guard let duration = self.manager.currentPlayingItemDuration() else { return }
        self.bookmarkViews?.forEach({ (view) in
            return view.removeFromSuperview()
        })
        self.bookmarkViews = [UIView]()
        for time in self.manager.getBookmarkTimes() {
            let ratio = time / duration
            let waveformContainerSize = self.waveformContainer.contentSize
            let view = UIView(frame: CGRect(x: waveformContainerSize.width * CGFloat(ratio), y: 0, width: 1, height: waveformContainerSize.height))
            view.backgroundColor = UIColor.red
            self.waveformContainer.addSubview(view)
            self.bookmarkViews?.append(view)
        }
    }
    
    func setupButtons() {
        if self.manager.isPlaying() {
            self.playButton.setTitle("Pause", for: .normal)
        } else {
            self.playButton.setTitle("Play", for: .normal)
        }
        
        switch self.manager.mode {
        case .All:
            self.repeatItemButton.setTitle("ALL", for: .normal)
            break
        case .OnlyOne:
            self.repeatItemButton.setTitle("OnlyOne", for: .normal)
            break
        case .None:
            self.repeatItemButton.setTitle("None", for: .normal)
            break
        }
        
        if (self.manager.switchRepeat) {
            self.repeatSwitchButton.setTitle("Now On", for: .normal)
        } else {
            self.repeatSwitchButton.setTitle("Now Off", for: .normal)
        }
    }
    
    // MARK - IBBinding
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showBookmarksButtonTapped(_ sender: Any) {
        let bookmarksViewController = AudioBookmarksViewController(nibName: AudioBookmarksViewController.className(), bundle: nil)
        bookmarksViewController.targetPath = self.item?.fileURL.path
        bookmarksViewController.modalPresentationStyle = .custom
        self.present(bookmarksViewController, animated: true, completion: nil)
    }
    
    @IBAction func movePreviousBookmark(_ sender: Any) {
        self.manager.movePreviousBookmark()
    }
    
    @IBAction func moveStartCurrentBookmark(_ sender: Any) {
        self.manager.moveCurrentBookmark()
    }
    
    @IBAction func moveNextBookmark(_ sender: Any) {
        self.manager.moveNextBookmark()
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        if (self.manager.isPlaying()) {
            self.manager.pause()
        } else {
            self.manager.resume()
        }
    }
    
    @IBAction func moveBeforeButtonTapped(_ sender: Any) {
        self.manager.moveBackwardCurrentAudio()
    }
    
    @IBAction func moveAfterButtonTapped(_ sender: Any) {
        self.manager.moveForwardCurrentAudio()
    }
    
    @IBAction func playNextButtonTapped(_ sender: Any) {
        self.manager.playNextAudio()
    }
    
    @IBAction func playPreviousButtonTapped(_ sender: Any) {
        guard let currentSeconds = self.manager.currentPlayingSeconds() else  { return }
        if (currentSeconds > 5) {
            self.manager.move(at: 0)
        } else {
            self.manager.playPrevAudio()
        }
    }
    
    @IBAction func repeatItemButtonTapped(_ sender: Any) {
        let repeatOrders = [AudioRepeatMode.All, AudioRepeatMode.OnlyOne, AudioRepeatMode.None]
        if let index = repeatOrders.index(where: { (mode) -> Bool in return mode == self.manager.mode }) {
            let nextMode = repeatOrders[((index + 1) % repeatOrders.count)]
            self.manager.mode = nextMode
            self.setupButtons()
        }
    }
    
    @IBAction func repeatSwitchTapped(_ sender: Any) {
        self.manager.switchRepeat = !self.manager.switchRepeat
        self.setupButtons()
    }
    
    @IBAction func addBookmarkButtonTapped(_ sender: Any) {
        self.manager.addBookmarkTimeObject()
    }
    
    @IBAction func rateButtonTapped(_ sender: Any) {
        self.manager.nextRate()
    }
    
    @IBAction func lyricsButtonTapped(_ sender: Any) {
        self.lyricsView.isHidden = false
    }
    
    @IBAction func lyricsViewTapped(_ sender: Any) {
        self.lyricsView.isHidden = true
    }
    // MARK - Notification Handling
    func handleAudioItemChanged(object: NSNotification) {
        guard let item = object.object as? AVPlayerItem else { return }
        if let url = item.url {
            self.item = AudioItem(url: url)
        }
        self.setup()
    }
    
    func handleAudioPlay(object: NSNotification) {
        self.setupButtons()
    }
    
    func handleAudioPause() {
        self.setupButtons()
    }
    
    func handleAudioReset() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleAudioTimeChanged() {
        guard let currentSeconds = self.manager.currentPlayingSeconds(), let durationSeconds = self.manager.currentPlayingItemDuration() else { return }
        if (durationSeconds.isEqual(to: 0.0)) {
            return
        }
        let progress = currentSeconds / durationSeconds
        self.waveformContainer.delegate = nil
        self.waveformContainer.contentOffset = CGPoint(x: (CGFloat(progress) * self.waveformContainer.contentSize.width) - self.waveformContainer.contentInset.left, y: 0)
        self.waveformContainer.delegate = self
    }
    
    func handleAudioBookmarkUpdated() {
        self.loadBookmarks()
    }
    
    func handleAudioRateChanged() {
        self.rateButton.setTitle(String(format: "x%.1f", self.manager.rate), for: .normal)
    }
}

extension AudioPlayerViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if (self.scrollViewDecelerate) {
            return
        }
        self.playingWhenScrollStart = self.manager.isPlaying()
        self.manager.pause()
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
        self.manager.move(ratio: Double(progress))
        if (self.playingWhenScrollStart) {
            self.manager.resume()
        }
    }
}

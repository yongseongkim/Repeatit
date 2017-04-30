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

class PlayItemContext {
    var audioItem: AudioItem?
    var mediaItem: MPMediaItem?
    var mediaItems: [MPMediaItem]?
}

class AudioPlayerViewController: UIViewController {
    
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var playerSlider: UISlider!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var lyricsView: UIView!
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var waveformContainer: UIScrollView!
    @IBOutlet weak var audioPlot: EZAudioPlot!
    @IBOutlet weak var audioPlotWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var repeatItemButton: UIButton!
    @IBOutlet weak var repeatSwitchButton: UIButton!
    @IBOutlet weak var volumeView: AudioVolumeView!
    @IBOutlet weak var rateButton: UIButton!
    
    public var context: PlayItemContext?
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
        AppDelegate.currentAppDelegate()?.notificationCenter.removeObserver(self)
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
        
        guard let contenxt = self.context else { return }
        if let item = contenxt.audioItem {
            self.item = item
            self.manager.play(targetURL: item.fileURL)
        }
        if let mpitem = contenxt.mediaItem, let mpitems = contenxt.mediaItems {
            self.manager.play(item: mpitem, items: mpitems)
        }
        if contenxt.audioItem == nil && contenxt.mediaItem == nil {
            return
        }
        AppDelegate.currentAppDelegate()?.notificationCenter.addObserver(self, selector: #selector(enterForeground), name: .onEnterForeground, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setup()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if self.contentViewTopConstraint.constant != self.topLayoutGuide.length {
            self.contentViewTopConstraint.constant = self.topLayoutGuide.length
        }
    }

    // MARK - Private
    func enterForeground() {
        self.setup()
    }
    
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
        var width = UIScreen.mainScreenWidth()
        if let duration = duration {
            width = CGFloat(duration.value()) * 10
            self.waveformContainer.contentSize = CGSize(width:width, height:self.waveformContainer.bounds.height)
            
            for time in stride(from: 0, to: duration, by: 5) {
                let tickView = UIView(frame: CGRect(x: time * 10, y: 0, width: 1, height: 8))
                tickView.backgroundColor = UIColor.black
                self.waveformContainer.addSubview(tickView)
                let tickLabel = UILabel(frame: CGRect(x: time * 10 + 1, y: 2, width: 27, height: 12))
                let minutes = Int(time / 60)
                let seconds = Int(time.truncatingRemainder(dividingBy: 60))
                tickLabel.text = String(format: "%02d:%02d", minutes, seconds)
                tickLabel.font = UIFont(name: tickLabel.font.fontName, size: 9.0)
                self.waveformContainer.addSubview(tickLabel)
            }
        }
        self.audioPlotWidthConstraint.constant = width
        self.audioFile = EZAudioFile(url: url)
        self.audioPlot.plotType = .buffer
        self.audioPlot.shouldFill = true
        self.audioPlot.shouldMirror = true
        self.audioPlot.color = UIColor.greenery()
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
            let waveContainerSize = self.waveformContainer.contentSize
            let view = UIView(frame: CGRect(x: Double(waveContainerSize.width).multiplied(by: ratio).subtracting(0.5), y: 0, width: 1, height: Double(waveContainerSize.height)))
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
        let minutes = Int(currentSeconds/60)
        let seconds = Int(currentSeconds.truncatingRemainder(dividingBy: 60))
        let millis = Int((currentSeconds.truncatingRemainder(dividingBy: 60) - floor(currentSeconds.truncatingRemainder(dividingBy: 60))) * 10)
        self.timeLabel.text = String(format: "%02d:%02d.%d", minutes, seconds, millis)
    }
    
    func handleAudioBookmarkUpdated() {
        self.loadBookmarks()
    }
    
    func handleAudioRateChanged() {
        self.rateButton.setTitle(String(format: "x%.1f", self.manager.rate), for: .normal)
    }
}

extension AudioPlayerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
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

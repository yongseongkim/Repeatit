//
//  PlayerViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 19..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import AVFoundation
import AudioKit
import MediaPlayer

class PlayerViewController: UIViewController {
    //MARK: Constants
    static let waveformPlotRatio = 20
    
    //MARK: IB Properties
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var lyricsView: UIView!
    @IBOutlet weak var lyricsTextView: UITextView!
    @IBOutlet weak var waveformContainer: UIScrollView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var repeatModeButton: UIButton!
    @IBOutlet weak var repeatBookmarkButton: UIButton!
    @IBOutlet weak var volumeView: AudioVolumeView!
    @IBOutlet weak var rateButton: UIButton!
    var audioPlot: EZAudioPlot?

    // Properties
    fileprivate var player: Player
    fileprivate var audioFile: EZAudioFile?
    fileprivate var timer: Timer?
    fileprivate var scrollViewDragging = false
    fileprivate var playingWhenScrollStart = false
    fileprivate var scrollViewDecelerate = false
    fileprivate var bookmarkViews: [UIView]?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.player = Dependencies.sharedInstance().resolve(serviceType: Player.self)!
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        AppDelegate.currentAppDelegate()?.notificationCenter.removeObserver(self)
        self.player.notificationCenter.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.player.notificationCenter.addObserver(self, selector: #selector(handlePlayerItemDidSet(object:)), name: Notification.Name.playerItemDidSet, object: nil)
        self.player.notificationCenter.addObserver(self, selector: #selector(handlePlayerStateUpdatedNotification), name: Notification.Name.playerStateUpdated, object: nil)
        self.player.notificationCenter.addObserver(self, selector: #selector(handlePlayingTimeUpdatedNotification), name: Notification.Name.playerTimeUpdated, object: nil)
        self.player.notificationCenter.addObserver(self, selector: #selector(handleBookmarkUpdatedNotification), name: Notification.Name.playerBookmakrUpdated, object: nil)
        self.waveformContainer.delegate = self
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
    
    fileprivate func setup() {
        guard let information = self.player.audioInformation else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.titleLabel.text = information.title
        self.artistNameLabel.text = information.artist
        self.albumCoverImageView.image = information.artwork
        self.lyricsTextView.text = information.lyrics
        self.loadWavefromIfNecessary(information: information)
        self.loadBookmarks(duration: self.player.duration)
        self.setupButtons()
    }
    
    fileprivate func loadWavefromIfNecessary(information: AudioInformation) {
        weak var weakSelf = self
        guard let url = information.url else { return }
        if let currentLoadedURL = self.audioFile?.url {
            if currentLoadedURL.path == url.path {
                return
            }
        }
        let containerWidth = self.waveformContainer.bounds.width
        let inset = containerWidth / 2
        self.waveformContainer.contentInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        for subview in self.waveformContainer.subviews {
            subview.removeFromSuperview()
        }
        let duration = self.player.duration
        let plotWidth = duration * PlayerViewController.waveformPlotRatio
        let audioPlot = EZAudioPlot().then { (plot) in
            plot.plotType = .buffer
            plot.shouldFill = true
            plot.shouldMirror = true
            plot.backgroundColor = UIColor.clear
            plot.color = UIColor.greenery
        }
        self.waveformContainer.addSubview(audioPlot)
        self.waveformContainer.contentSize = CGSize(width:CGFloat(plotWidth), height:self.waveformContainer.bounds.height)
        
        audioPlot.snp.makeConstraints({ (make) in
            make.top.equalTo(self.waveformContainer)
            make.left.equalTo(self.waveformContainer)
            make.bottom.equalTo(self.waveformContainer)
            make.right.equalTo(self.waveformContainer)
            make.height.equalTo(self.waveformContainer.snp.height)
            make.width.equalTo(plotWidth)
        })
        
        //TODO: 시간표 refactoring
        for time in stride(from: 0, to: duration, by: 5) {
            let tickView = UIView(frame: CGRect(x: time * PlayerViewController.waveformPlotRatio, y: 0, width: 1, height: 8))
            tickView.backgroundColor = UIColor.black
            self.waveformContainer.addSubview(tickView)
            let tickLabel = UILabel(frame: CGRect(x: time * PlayerViewController.waveformPlotRatio + 1, y: 2, width: 27, height: 12))
            let minutes = Int(time / 60)
            let seconds = Int(time.truncatingRemainder(dividingBy: 60))
            tickLabel.text = String(format: "%02d:%02d", minutes, seconds)
            tickLabel.font = UIFont(name: tickLabel.font.fontName, size: 9.0)
            self.waveformContainer.addSubview(tickLabel)
        }
        let tickView = UIView(frame: CGRect(x: self.player.duration * PlayerViewController.waveformPlotRatio, y: 0, width: 1, height: 8))
        tickView.backgroundColor = UIColor.black
        self.waveformContainer.addSubview(tickView)
        let tickLabel = UILabel(frame: CGRect(x: duration * PlayerViewController.waveformPlotRatio + 1, y: 2, width: 27, height: 12))
        let minutes = Int(duration / 60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        tickLabel.text = String(format: "%02d:%02d", minutes, seconds)
        tickLabel.font = UIFont(name: tickLabel.font.fontName, size: 9.0)
        self.waveformContainer.addSubview(tickLabel)

        self.audioPlot = audioPlot
        if !url.absoluteString.contains("ipod-library") {
            // EZAudio가 ipod 노래 waveform을 읽지 못한다.
            self.audioFile = EZAudioFile(url: url)
            self.audioFile?.getWaveformData(completionBlock: { [weak self] (waveformData: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>?, length: Int32) in
                if let currentURL = self?.player.audioInformation?.url {
                    if url.absoluteString == currentURL.absoluteString {
                        weakSelf?.audioPlot?.updateBuffer(waveformData?[0], withBufferSize: UInt32(length))
                    }
                }
            })
        }
    }
    
    fileprivate func loadBookmarks(duration: Double) {
        self.bookmarkViews?.forEach({ (view) in
            return view.removeFromSuperview()
        })
        self.bookmarkViews = [UIView]()
        for time in self.player.bookmarks {
            let ratio = time / duration
            let waveContainerSize = self.waveformContainer.contentSize
            let view = UIView(frame: CGRect(x: Double(waveContainerSize.width).multiplied(by: ratio).subtracting(0.5), y: 0, width: 1, height: Double(waveContainerSize.height)))
            view.backgroundColor = UIColor.directoireBlue
            self.waveformContainer.addSubview(view)
            self.bookmarkViews?.append(view)
        }
    }
    
    fileprivate func setupButtons() {
        let state = self.player.state
        if state.isPlaying {
            self.playButton.setTitle("Pause", for: .normal)
        } else {
            self.playButton.setTitle("Play", for: .normal)
        }
        self.rateButton.setTitle(String(format: "x%.1f", state.rate), for: .normal)
        switch state.repeatMode {
        case .All:
            self.repeatModeButton.setTitle("Repeat All", for: .normal)
            break
        case .One:
            self.repeatModeButton.setTitle("Repeat One", for: .normal)
            break
        case .None:
            self.repeatModeButton.setTitle("None", for: .normal)
            break
        }
    }
    
    // MARK - Notification Handling
    func handlePlayerItemDidSet(object: Notification) {
        self.setup()
    }
    
    func handlePlayerStateUpdatedNotification() {
        self.setupButtons()
    }
    
    func handlePlayingTimeUpdatedNotification() {
        if (self.scrollViewDragging) {
            return
        }
        var progress: Double = 0
        if self.player.duration != 0 {
            progress = self.player.currentSeconds / self.player.duration
        }
        self.waveformContainer.contentOffset = CGPoint(x: (CGFloat(progress) * self.waveformContainer.contentSize.width) - self.waveformContainer.contentInset.left, y: 0)
    }
    
    func handleBookmarkUpdatedNotification() {
        self.loadBookmarks(duration: self.player.duration)
    }
    
    
    // MARK - IB Actions
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showBookmarksButtonTapped(_ sender: Any) {
        let bookmarksViewController = AudioBookmarksViewController(nibName: AudioBookmarksViewController.className(), bundle: nil)
        bookmarksViewController.modalPresentationStyle = .custom
        self.present(bookmarksViewController, animated: true, completion: nil)
    }
    
    @IBAction func movePreviousBookmark(_ sender: Any) {
        self.player.movePreviousBookmark()
    }
    
    @IBAction func moveStartCurrentBookmark(_ sender: Any) {
        self.player.moveLastestBookmark()
    }
    
    @IBAction func moveNextBookmark(_ sender: Any) {
        self.player.moveNextBookmark()
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        if self.player.state.isPlaying {
            self.player.pause()
        } else {
            self.player.resume()
        }
    }
    
    @IBAction func moveBefore7SecondsButtonTapped(_ sender: Any) {
        self.player.moveBackward(seconds: 7)
    }
    
    @IBAction func moveBefore5SecondsButtonTapped(_ sender: Any) {
        self.player.moveBackward(seconds: 5)
    }
    
    @IBAction func moveBefore3SecondsButtonTapped(_ sender: Any) {
        self.player.moveBackward(seconds: 3)
    }
    
    @IBAction func moveBefore1SecondsButtonTapped(_ sender: Any) {
        self.player.moveBackward(seconds: 1)
    }
    
    @IBAction func moveAfter5SecondsButtonTapped(_ sender: Any) {
        self.player.moveForward(seconds: 5)
    }
    
    @IBAction func moveAfter10SecondsButtonTapped(_ sender: Any) {
        self.player.moveForward(seconds: 10)
    }
    
    @IBAction func playNextButtonTapped(_ sender: Any) {
        self.player.playNext()
    }
    
    @IBAction func playPreviousButtonTapped(_ sender: Any) {
        self.player.playPrev()
    }
    
    @IBAction func repeatModeButtonTapped(_ sender: Any) {
        self.player.nextRepeatMode()
    }
    
    @IBAction func repeatBookmarkButtonTapped(_ sender: Any) {
    }
    
    @IBAction func addBookmarkButtonTapped(_ sender: Any) {
        do {
            try self.player.addBookmark()
        } catch PlayerError.alreadExistBookmarkNearby {
            print("already exist nearby")
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func rateButtonTapped(_ sender: Any) {
        self.player.nextRate()
    }
    
    @IBAction func lyricsButtonTapped(_ sender: Any) {
        self.lyricsView.isHidden = false
    }
    
    @IBAction func lyricsViewTapped(_ sender: Any) {
        self.lyricsView.isHidden = true
    }
}

extension PlayerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var progress: Double = 0
        if (self.waveformContainer.contentSize.width > 0) {
            progress = Double((scrollView.contentOffset.x + self.waveformContainer.contentInset.left) / self.waveformContainer.contentSize.width)
        }
        let current = progress * self.player.duration
        let minutes = Int(current/60)
        let seconds = Int(current.truncatingRemainder(dividingBy: 60))
        let millis = Int((current.truncatingRemainder(dividingBy: 60) - floor(current.truncatingRemainder(dividingBy: 60))) * 10)
        self.timeLabel.text = String(format: "%02d:%02d.%d", minutes, seconds, millis)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.scrollViewDragging = true
        if (self.scrollViewDecelerate) {
            return
        }
        self.playingWhenScrollStart = self.player.state.isPlaying
        self.player.pause()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollViewDragging = false
        self.scrollViewDecelerate = decelerate
        if (!decelerate) {
            self.scrollViewDidEndDecelerating(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.scrollViewDecelerate = false
        let progress = Double((scrollView.contentInset.left + scrollView.contentOffset.x) / scrollView.contentSize.width)
        self.player.move(at: progress * self.player.duration)
        if (self.playingWhenScrollStart) {
            self.player.resume()
        }
    }
}

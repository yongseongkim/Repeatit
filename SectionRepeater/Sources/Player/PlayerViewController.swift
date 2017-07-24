//
//  PlayerViewController.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 19..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class PlayerViewController: UIViewController {
    
    //MARK: IB Properties
    @IBOutlet weak var contentViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var albumCoverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var lyricsView: UIView!
    @IBOutlet weak var lyricsTextView: UITextView!
    
    @IBOutlet weak var timeSliderTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    @IBOutlet weak var timeSliderDurationLabel: UILabel!
    
    @IBOutlet weak var waveformView: WaveformView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSeparateViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var repeatModeButton: UIButton!
    @IBOutlet weak var repeatBookmarkButton: UIButton!
    @IBOutlet weak var volumeView: AudioVolumeView!
    @IBOutlet weak var rateButton: UIButton!

    // Properties
    fileprivate var timer: Timer?
    fileprivate var scrollViewDragging = false
    fileprivate var playingWhenScrollStart = false
    fileprivate var scrollViewDecelerate = false
    fileprivate var bookmarkViews: [UIView]?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Player.shared.notificationCenter.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.waveformView.delegate = self
        self.alertView.isHidden = true
        self.timeSeparateViewWidthConstraint.constant = UIScreen.scaleWidth
        self.timeSlider.setThumbImage(UIImage.size(width: 3, height: 16).color(UIColor.black).image, for: .normal)
        self.timeSlider.setMinimumTrackImage(UIImage.size(width: self.timeSlider.bounds.width, height: 3).color(UIColor.black).image, for: .normal)
        self.timeSlider.setMaximumTrackImage(UIImage.size(width: self.timeSlider.bounds.width, height: 3).color(UIColor.gray220).image, for: .normal)
        Player.shared.notificationCenter.addObserver(self, selector: #selector(handlePlayerItemDidSet(object:)), name: Notification.Name.playerItemDidSet, object: nil)
        Player.shared.notificationCenter.addObserver(self, selector: #selector(handlePlayerStateUpdatedNotification), name: Notification.Name.playerStateUpdated, object: nil)
        Player.shared.notificationCenter.addObserver(self, selector: #selector(handlePlayingTimeUpdatedNotification), name: Notification.Name.playerTimeUpdated, object: nil)
        Player.shared.notificationCenter.addObserver(self, selector: #selector(handleBookmarkUpdatedNotification), name: Notification.Name.playerBookmakrUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(enterForeground), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
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
        guard let item = Player.shared.currentItem else {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.titleLabel.text = item.title ?? item.url?.lastPathComponent
        self.artistNameLabel.text = item.artist ?? "Unknown Artist"
        if let artwork = item.artwork {
            self.albumCoverImageView.image = artwork
        } else {
            self.albumCoverImageView.image = UIImage(named: "empty_music_note_120pt")
        }
        self.lyricsTextView.text = item.lyrics
        if (item.lyrics ?? "").isEmpty {
            if let url = item.mediaItem?.value(forProperty: MPMediaItemPropertyAssetURL) as? URL {
                let songAsset = AVURLAsset(url: url, options: nil)
                let lyrics = songAsset.lyrics
                self.lyricsTextView.text = lyrics
            }
        }
        self.loadWaveformIfNecessary(item: item)
        let duration = Player.shared.duration
        let minutes = Int(duration/60)
        let seconds = Int(duration.truncatingRemainder(dividingBy: 60))
        self.timeSliderDurationLabel.text = String(format: "%02d:%02d", minutes, seconds)
        self.durationLabel.text = String(format: "%02d:%02d", minutes, seconds)
        self.setupButtons()
    }
    
    fileprivate func loadWaveformIfNecessary(item: PlayerItem) {
        guard let url = item.url else { return }
        if url.absoluteString == self.waveformView.url?.absoluteString {
            return
        }
        self.waveformView.loadWaveform(url: url)
    }
    
    fileprivate func setupButtons() {
        let state = Player.shared.state
        if state.isPlaying {
            self.playButton.setImage(UIImage(named: "btn_pause_52pt"), for: .normal)
        } else {
            self.playButton.setImage(UIImage(named: "btn_play_52pt"), for: .normal)
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
        self.repeatBookmarkButton.setTitle(state.repeatBookmark ? "On" : "Off", for: .normal)
    }
    
    // MARK - Notification Handling
    func handlePlayerItemDidSet(object: Notification) {
        self.setup()
    }
    
    func handlePlayerStateUpdatedNotification() {
        if let _ = Player.shared.currentItem {
            self.setupButtons()
            return
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func handlePlayingTimeUpdatedNotification() {
        if (self.scrollViewDragging) {
            return
        }
        var progress: Double = 0
        if Player.shared.duration != 0 {
            progress = Player.shared.currentTime / Player.shared.duration
        }
        self.waveformView.move(progress: progress)
        self.timeSlider.value = Float(progress)
        self.timeSlider.sendActions(for: .valueChanged)
    }
    
    func handleBookmarkUpdatedNotification() {
        self.waveformView.loadBookmarks()
    }
    
    func showAlertView() {
        if (!self.alertView.isHidden) {
            return
        }
        self.alertView.isHidden = false
        self.alertView.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: {
            self.alertView.alpha = 1.0
        })
    }
    
    func hideAlertView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alertView.alpha = 0
        }) { (finished) in
            self.alertView.isHidden = true
        }
    }
    
    // MARK - IB Actions
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func timeSliderValueChanged(_ sender: Any) {
        let current = Double(self.timeSlider.value) * Player.shared.duration
        let minutes = Int(abs(current/60))
        let seconds = Int(abs(current.truncatingRemainder(dividingBy: 60)))
        self.timeSliderTimeLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    @IBAction func timeSliderTouchDown(_ sender: Any) {
        self.playingWhenScrollStart = Player.shared.state.isPlaying
        Player.shared.pause()
    }
    
    @IBAction func timeSliderTouchUpInside(_ sender: Any) {
        Player.shared.move(to: Double(self.timeSlider.value) * Player.shared.duration)
        if (self.playingWhenScrollStart) {
            Player.shared.resume()
        }
    }
    
    @IBAction func timeSliderTouchUpOutside(_ sender: Any) {
        Player.shared.move(to: Double(self.timeSlider.value) * Player.shared.duration)
        if (self.playingWhenScrollStart) {
            Player.shared.resume()
        }
    }
    
    @IBAction func showBookmarksButtonTapped(_ sender: Any) {
        let bookmarksViewController = BookmarksViewController(nibName: BookmarksViewController.className(), bundle: nil)
        bookmarksViewController.modalPresentationStyle = .custom
        self.present(bookmarksViewController, animated: false, completion: nil)
    }
    
    @IBAction func movePreviousBookmark(_ sender: Any) {
        Player.shared.movePreviousBookmark()
    }
    
    @IBAction func moveStartCurrentBookmark(_ sender: Any) {
        Player.shared.moveLatestBookmark()
    }
    
    @IBAction func moveNextBookmark(_ sender: Any) {
        Player.shared.moveNextBookmark()
    }
    
    @IBAction func playButtonTapped(_ sender: Any) {
        if Player.shared.state.isPlaying {
            Player.shared.pause()
        } else {
            Player.shared.resume()
        }
    }
    
    @IBAction func moveBefore5SecondsButtonTapped(_ sender: Any) {
        Player.shared.moveBackward(seconds: 5)
    }
    
    @IBAction func moveBefore2SecondsButtonTapped(_ sender: Any) {
        Player.shared.moveBackward(seconds: 3)
    }
    
    @IBAction func moveBefore1SecondsButtonTapped(_ sender: Any) {
        Player.shared.moveBackward(seconds: 1)
    }
    
    @IBAction func moveAtStartButtonTapped(_ sender: Any) {
        Player.shared.move(to: 0)
    }
    
    @IBAction func moveAfter5SecondsButtonTapped(_ sender: Any) {
        Player.shared.moveForward(seconds: 5)
    }
    
    @IBAction func moveAfter10SecondsButtonTapped(_ sender: Any) {
        Player.shared.moveForward(seconds: 10)
    }
    
    @IBAction func playNextButtonTapped(_ sender: Any) {
        Player.shared.playNext()
    }
    
    @IBAction func playPreviousButtonTapped(_ sender: Any) {
        Player.shared.playPrev()
    }
    
    @IBAction func repeatModeButtonTapped(_ sender: Any) {
        Player.shared.nextRepeatMode()
    }
    
    @IBAction func repeatBookmarkButtonTapped(_ sender: Any) {
        Player.shared.switchRepeatBookmark()
    }
    
    @IBAction func addBookmarkButtonTapped(_ sender: Any) {
        do {
            try Player.shared.addBookmark()
        } catch PlayerError.alreadExistBookmarkNearby {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.alertLabel.text = "It's too close to another bookmark."
            self.showAlertView()
            self.perform(#selector(hideAlertView), with: self, afterDelay: 1.5)
        } catch PlayerError.bookmarkTooCloseFinish {
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            self.alertLabel.text = "It's too close to the finish time."
            self.showAlertView()
            self.perform(#selector(hideAlertView), with: self, afterDelay: 1.5)
        } catch let error {
            print(error)
        }
    }
    
    @IBAction func rateButtonTapped(_ sender: Any) {
        Player.shared.nextRate()
    }
    
    @IBAction func lyricsButtonTapped(_ sender: Any) {
        self.lyricsView.isHidden = false
    }
    
    @IBAction func lyricsViewTapped(_ sender: Any) {
        self.lyricsView.isHidden = true
    }
}

extension PlayerViewController: WaveformViewDelegate {
    func waveformViewDidScroll(scrollView: UIScrollView) {
        var progress: Double = 0
        if (scrollView.contentSize.width > 0) {
            progress = Double((scrollView.contentOffset.x + scrollView.contentInset.left) / scrollView.contentSize.width)
        }
        let current = progress * Player.shared.duration
        let minutes = Int(abs(current/60))
        let seconds = Int(abs(current.truncatingRemainder(dividingBy: 60)))
        let millis = Int(abs((current * 10).truncatingRemainder(dividingBy: 10)))
        var format = "%02d:%02d.%d"
        if current < 0 {
            format = "-%02d:%02d.%d"
        }
        self.timeLabel.text = String(format: format, minutes, seconds, millis)
    }
    
    func waveformViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrollViewDragging = true
        if (self.scrollViewDecelerate) {
            return
        }
        self.playingWhenScrollStart = Player.shared.state.isPlaying
        Player.shared.pause()
    }
    
    func waveformViewDidEndDragging(_ scrollView: UIScrollView, decelerate: Bool) {
        self.scrollViewDragging = false
        self.scrollViewDecelerate = decelerate
        if (!decelerate) {
            self.waveformViewDidEndDecelerating(scrollView: scrollView)
        }
    }
    
    func waveformViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollViewDecelerate = false
        let progress = Double((scrollView.contentInset.left + scrollView.contentOffset.x) / scrollView.contentSize.width)
        Player.shared.move(to: progress * Player.shared.duration)
        if (self.playingWhenScrollStart) {
            Player.shared.resume()
        }
    }
}

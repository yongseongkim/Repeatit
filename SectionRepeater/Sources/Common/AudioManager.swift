//
//  AudioManager.swift
//  SectionRepeater
//
//  Created by KimYongSeong on 2017. 2. 19..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer

enum AudioRepeatMode {
    case None               // doesn't repeat
    case All                // repeat all item
    case OnlyOne            // repeat only one item
}

extension Notification.Name {
    static let onAudioManagerStart = Notification.Name("audiomanager.start")
    static let onAudioManagerPause = Notification.Name("audiomanager.pause")
    static let onAudioManagerResume = Notification.Name("audiomanager.resume")
    static let onAudioManagerReset = Notification.Name("audiomanager.reset")
    static let onAudioManagerTimeChanged = Notification.Name("audiomanager.timechanged")
}

class AudioManager: NSObject {
    fileprivate var player: AVPlayer?
    fileprivate var playerItem: AVPlayerItem? {
        didSet {
            guard let item = playerItem else {
                self.player = nil
                self.timer = nil
                return
            }
            self.player = AVPlayer(playerItem: item)
            self.player?.volume = self.volume
        }
    }
    fileprivate var playlist: [AVPlayerItem]
    fileprivate var timer: Timer?
    public var notificationCenter: NotificationCenter
    public var volume = Float(integerLiteral: 5) {
        didSet {
            if let player = self.player {
                player.volume = volume
            }
        }
    }
    public var mode = AudioRepeatMode.None

    override init() {
        self.playlist = [AVPlayerItem]()
        self.notificationCenter = NotificationCenter()
        super.init()
        
        do {
//            UIApplication.shared.beginReceivingRemoteControlEvents()
//            let commandCenter = MPRemoteCommandCenter.shared()
//            commandCenter.nextTrackCommand.isEnabled = true
//            commandCenter.nextTrackCommand.addTarget(handler: { (event) -> MPRemoteCommandHandlerStatus in
//                self.playNextAudio()
//                return .success
//            })
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: self.playerItem)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK - Public
    
    public func play(targetURL: URL) {
        // doesn't play if it is not supported file type.
        if (!self.isSupportedAudioFile(fileURL: targetURL)) { return }
        // doesn't play if it is same.
        if let currentItem = self.playerItem, AVPlayerItem(url: targetURL) == currentItem { return }
        // set playlist in current directory
        do {
            let currentDirectoryPath = targetURL.deletingLastPathComponent().path
            let fileManager = FileManager.default
            let fileNames = try fileManager.contentsOfDirectory(atPath: currentDirectoryPath)
            var targetItem:AVPlayerItem?
            for fileName in fileNames {
                let filePath = currentDirectoryPath.appendingFormat("/%@", fileName)
                var isDir:ObjCBool = true
                if (fileManager.fileExists(atPath: filePath, isDirectory: &isDir)) {
                    if (!isDir.boolValue) {
                        let url = URL(fileURLWithPath: filePath)
                        if (self.isSupportedAudioFile(fileURL: url)) {
                            self.playlist.append(AVPlayerItem(url: url))
                            if (url.absoluteString == targetURL.absoluteString) {
                                targetItem = AVPlayerItem(url: url)
                            }
                        }
                        
                    }
                }
            }
            
            if let targetItem = targetItem {
                self.playerItem = targetItem
                self.internalPlay()
            }
        } catch let error as NSError {
            print(error)
        }

    }
    
    public func pause() {
        self.internalPause()
    }
    
    public func resume() {
        self.internalResume()
    }
    
    public func reset() {
        self.internalReset()
    }
    
    public func moveForwardCurrentAudio() {
        guard let player = self.player else { return }
        let afterSeconds = player.currentSeconds.adding(5)
        var time = player.durationSeconds
        if (afterSeconds < player.durationSeconds) {
            time = afterSeconds
        }
        player.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }

    public func moveBackwardCurrentAudio() {
        guard let player = self.player else { return }
        let beforeSeconds = player.currentSeconds.subtracting(5)
        var time = 0.0
        if (beforeSeconds > 0) {
            time = beforeSeconds
        }
        player.seek(to: time)
    }
    
    public func move(at: Double) {
        guard let player = self.player else { return }
        var time = at
        if (time < 0) {
            time = 0
        }
        if (time > player.durationSeconds) {
            time = player.durationSeconds
        }
        player.seek(to: time)
    }
    
    public func move(progress: Double) {
        guard let player = self.player else { return }
        self.move(at: progress * player.durationSeconds)
    }
    
    public func playNextAudio() {
        guard let currentPlayerItem = self.playerItem else { return }
        if let index = self.playlist.index(where: { (item) -> Bool in return item == currentPlayerItem }) {
            var item:AVPlayerItem? = nil
            switch self.mode {
            case .OnlyOne:
                item = currentPlayerItem
                break
            case .All:
                if (index == self.playlist.count - 1) {
                    item = self.playlist.first
                } else {
                    item = self.playlist[index + 1]
                }
                break
            case .None:
                if (index == self.playlist.count - 1) {
                    self.reset()
                    return
                } else {
                    item = self.playlist[index + 1]
                }
                break
            }
            self.playerItem = item
            self.internalPlay()
        }
    }
    
    public func playPrevAudio() {
        guard let currentPlayerItem = self.playerItem else { return }
        if let index = self.playlist.index(where: { (item) -> Bool in return item == currentPlayerItem }) {
            var item:AVPlayerItem? = nil
            switch self.mode {
            case .OnlyOne:
                item = currentPlayerItem
                break
            case .All:
                if (index == 0) {
                    item = self.playlist.last
                } else {
                    item = self.playlist[index - 1]
                }
                break
            case .None:
                if (index == 0) {
                    self.reset()
                    return
                } else {
                    item = self.playlist[index - 1]
                }
                break
            }
            self.playerItem = item
            self.internalPlay()
        }
    }
    
    // MARK: Getter, Setter
    public func currentPlayingItemDuration() -> Double? {
        guard let player = self.player else { return nil }
        return player.durationSeconds
    }
    
    public func currentPlayingSeconds() -> Double? {
        guard let player = self.player else { return nil }
        return player.currentSeconds
    }

    public func isSupportedAudioFile(fileURL: URL) -> Bool {
        let supportedFormats = ["aac","adts","ac3","aif","aiff","aifc","caf","mp3","mp4","m4a","snd","au","sd2","wav"]
        return supportedFormats.contains(fileURL.pathExtension)
    }
    
    public func isPlaying() -> Bool {
        guard let player = self.player else { return false }
        return player.isPlaying
    }
    
    // MARK: Notification Handler
    
    func finishedPlaying(notification: Notification) {
        self.playNextAudio()
    }
    
    func updateTime() {
        self.notificationCenter.post(name: .onAudioManagerTimeChanged, object: nil)
    }
    
    // MARK: Private
    fileprivate func internalPlay() {
        guard let item = self.playerItem else { return }
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        self.player?.play()
        self.notificationCenter.post(name: .onAudioManagerStart, object: item)
    }
    
    fileprivate func internalPause() {
        guard let item = self.playerItem else { return }
        self.player?.pause()
        self.notificationCenter.post(name: .onAudioManagerPause, object: item)
    }
    
    fileprivate func internalResume() {
        guard let item = self.playerItem else { return }
        self.player?.play()
        self.notificationCenter.post(name: .onAudioManagerResume, object: item)
    }
    
    fileprivate func internalReset() {
        self.playerItem = nil
        self.playlist = [AVPlayerItem]()
        self.notificationCenter.post(name: .onAudioManagerReset, object: nil)
    }
}
 

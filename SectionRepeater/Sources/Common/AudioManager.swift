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

protocol AudioManagerDelegate: class {
    func didStartPlaying(item: AudioItem)
    func didPausePlaying(item: AudioItem)
    func didResumePlaying(item: AudioItem)
    func didResetPlaying()
    func didUpdateTime(progress: Double)
}

enum AudioRepeatMode {
    case None               // 반복 X
    case All                // 전체 반복
    case OnlyOne            // 한곡 반복
}

class AudioManager: NSObject {
    fileprivate var player: AVPlayer?
    fileprivate var playerItem: AVPlayerItem?
    fileprivate var currentDirectoryURL: URL? {
        get {
            guard let playing = playing else { return nil }
            return playing.fileURL.deletingLastPathComponent()
        }
    }
    fileprivate var playing: AudioItem?
    fileprivate var playlist: [AudioItem]
    fileprivate var timer: Timer?
    fileprivate var targets: [AudioManagerDelegate]
    public var volume = Float(integerLiteral: 5) {
        didSet {
            if let player = self.player {
                player.volume = volume
            }
        }
    }
    public var mode = AudioRepeatMode.None

    override init() {
        self.playlist = [AudioItem]()
        self.targets = [AudioManagerDelegate]()
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
    }
    
    //MARK - Public
    
    public func register(delegate: AudioManagerDelegate) {
        if let _ = self.targets.index(where: { (target) -> Bool in return target === delegate }) {
            return
        }
        self.targets.append(delegate)
    }
    
    public func delete(delegate: AudioManagerDelegate) {
        if let index = self.targets.index(where: { (target) -> Bool in return target === delegate }) {
            self.targets.remove(at: index)
        }
    }
    
    public func play(playingItem: AudioItem) {
        if (playingItem.isEqual(self.playing)) {
            return
        }
        self.playlist = [AudioItem]()
        self.playing = playingItem
        do {
            guard let currentDirectoryPath = self.currentDirectoryURL?.path else { return }
            let fileManager = FileManager.default
            let fileNames = try fileManager.contentsOfDirectory(atPath: currentDirectoryPath)
            for fileName in fileNames {
                let filePath = currentDirectoryPath.appendingFormat("/%@", fileName)
                var isDir:ObjCBool = true
                if (fileManager.fileExists(atPath: filePath, isDirectory: &isDir)) {
                    if (!isDir.boolValue) {
                        let fileURL = URL(fileURLWithPath: filePath)
                        if (AudioItem.isAudioFile(url: fileURL)) {
                            let item = AudioItem(url: fileURL)
                            self.playlist.append(item)
                        }
                    }
                }
            }
            self.internalPlay(item: playingItem)
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
        guard let duration = self.duration() else { return }
        guard let currentTime = self.playingTime() else { return }
        let afterSeconds = currentTime.adding(5)
        var time = duration
        if (afterSeconds < duration) {
            time = afterSeconds
        }
        player.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }

    public func moveBackwardCurrentAudio() {
        guard let player = self.player else { return }
        guard let currentTime = self.playingTime() else { return }
        let beforeSeconds = currentTime.subtracting(5)
        var time = 0.0
        if (beforeSeconds > 0) {
            time = beforeSeconds
        }
        player.seek(to: CMTime(seconds: time, preferredTimescale: 1))
    }
    
    public func move(at: Double) {
        if let duration = self.duration() {
            var time = at
            if (time < 0) {
                time = 0
            }
            if (time > duration) {
                time = duration
            }
            self.player?.seek(to: CMTime(seconds: time, preferredTimescale: 1))
        }
    }
    
    public func move(progress: Double) {
        guard let duration = self.duration() else { return }
        self.move(at: progress * duration)
    }
    
    public func playNextAudio() {
        guard let playing = self.playing else { return }
        if let index = self.playlist.index(where: { (item) -> Bool in return item == playing }) {
            var item = self.playing
            switch self.mode {
            case .OnlyOne:
                self.internalPlay(item: item!)
                return
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
            guard let playingItem = item else { return }
            self.internalPlay(item: playingItem)
        } else {
            // error
            return
        }
    }
    
    public func playPrevAudio() {
        guard let playing = self.playing else { return }
        if let index = self.playlist.index(where: { (item) -> Bool in return item == playing }) {
            var item = self.playing
            switch self.mode {
            case .OnlyOne:
                self.internalPlay(item: item!)
                return
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
            guard let playingItem = item else { return }
            self.internalPlay(item: playingItem)
        } else {
            // error
            return
        }
    }
    
    func updateTime() {
        if let duration = self.duration(), let currentTime = self.playingTime() {
            let progress = currentTime / duration
            for target in self.targets {
                target.didUpdateTime(progress: progress)
            }
        }
    }
    
    func finishedPlaying(notification: Notification) {
        print("finishedPlaying")
    }
    
    //MARK - Getter, Setter
    
    public func isPlayingItemSame(asItem: AudioItem?) -> Bool {
        if let playing = self.playing {
            return playing == asItem
        }
        return false
    }
    
    public func isPlaying() -> Bool {
        if let player = self.player {
            return player.isPlaying
        }
        return false
    }
    
    public func playingTime() -> Double? {
        guard let currentTime = self.player?.currentTime().seconds else { return nil }
        return currentTime
    }
    
    public func duration() -> Double? {
        guard let playing = self.playing else { return nil }
        return AVPlayerItem(url: playing.fileURL).asset.duration.seconds
    }
    
    // MARK: Private
    fileprivate func internalPlay(item: AudioItem) {
        self.playerItem = AVPlayerItem(url: item.fileURL)
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.addObserver(self, selector: Selector(("finishedPlaying:")), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        self.player = AVPlayer(url: item.fileURL)
        self.player?.volume = self.volume
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true);
        self.player?.play()
        self.playing = item
        for target in self.targets {
            target.didStartPlaying(item: item)
        }
    }
    
    fileprivate func internalPause() {
        self.player?.pause()
        if let playing = self.playing {
            for target in self.targets {
                target.didPausePlaying(item: playing)
            }
        }
    }
    
    fileprivate func internalResume() {
        if let player = self.player, let playing = self.playing {
            for target in self.targets {
                target.didResumePlaying(item: playing)
            }
            player.play()
        } else {
            self.reset()
        }
    }
    
    fileprivate func internalReset() {
        self.player = nil
        self.playing = nil
        self.playlist = [AudioItem]()
        for target in self.targets {
            target.didResetPlaying()
        }
    }
}

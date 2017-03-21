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
    fileprivate var player: AVAudioPlayer?
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
            UIApplication.shared.beginReceivingRemoteControlEvents()
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.nextTrackCommand.isEnabled = true
            commandCenter.nextTrackCommand.addTarget(handler: { (event) -> MPRemoteCommandHandlerStatus in
                self.playNextAudio()
                return .success
            })
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
        var time = TimeInterval(player.duration)
        if (player.currentTime + 5 < player.duration) {
            time = player.currentTime.adding(5)
        }
        player.currentTime = time
    }

    public func moveBackwardCurrentAudio() {
        guard let player = self.player else { return }
        var time = TimeInterval(0)
        if (player.currentTime - 5 > 0) {
            time = player.currentTime.subtracting(5)
        }
        player.currentTime = time
    }
    
    public func move(at: TimeInterval) {
        if let duration = self.player?.duration {
            var time = at
            if (at < 0) {
                time = 0
            }
            if (at >= duration) {
                time = duration - 0.1
            }
            self.player?.currentTime = time
        }
    }
    
    public func move(progress: Double) {
        guard let player = self.player else { return }
        self.move(at: progress * player.duration)
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
        if let duration = self.player?.duration, let currentTime = self.player?.currentTime {
            let progress = currentTime.value().divided(by: duration)
            for target in self.targets {
                target.didUpdateTime(progress: progress)
            }
        }
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
        if let player = self.player {
            return player.currentTime
        }
        return nil
    }
    
    public func duration() -> Double? {
        if let player = self.player {
            return player.duration
        }
        return nil
    }
    
    // MARK: Private
    fileprivate func internalPlay(item: AudioItem) {
        do {
            self.player = try AVAudioPlayer(contentsOf: item.fileURL)
            self.player?.delegate = self
            self.player?.prepareToPlay()
            self.player?.volume = self.volume
            for target in self.targets {
                target.didStartPlaying(item: item)
            }
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true);
            self.player?.play()
            self.playing = item
        } catch let error as NSError {
            print(error)
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
            player.prepareToPlay()
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

extension AudioManager: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.playNextAudio()
    }
}

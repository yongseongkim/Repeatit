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

class AudioManager: NSObject {
    static fileprivate var instance: AudioManager?
    class func sharedInstance() -> AudioManager {
        if let instance = instance {
            return instance
        } else {
            instance = AudioManager()
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print(error)
            }
            return instance!
        }
    }

    fileprivate var player: AVAudioPlayer?
    fileprivate var currentDirectoryURL: URL?
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

    override init() {
        self.playlist = [AudioItem]()
        self.targets = [AudioManagerDelegate]()
        super.init()
    }
    
    //MARK - Getter, Setter
    
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
    
    public func play(playingItem: AudioItem) {
        if (playingItem.isEqual(self.playing)) {
            return
        }
        self.playing = nil
        self.playlist = [AudioItem]()
        do {
            let currentDirectoryURL = playingItem.fileURL.deletingLastPathComponent()
            let currentDirectoryPath = currentDirectoryURL.path
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
                            if (playingItem.fileURL.absoluteString == fileURL.absoluteString) {
                                self.playing = item
                            }
                        }
                    }
                }
            }
            guard let playing = self.playing else { return }
            self.internalPlay(item: playing)
        } catch let error as NSError {
            print(error)
        }
    }
    
    //MARK - Public

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
        if let index = self.playlist.index(where: { (item) -> Bool in return item.fileURL.absoluteString == playing.fileURL.absoluteString }) {
            if (index == self.playlist.count - 1) {
                // last
                self.reset()
                return
            }
            let item = self.playlist[index + 1]
            self.playing = item
            self.internalPlay(item: item)
        } else {
            // error
            return
        }
    }
    
    public func playPrevAudio() {
        guard let playing = self.playing else { return }
        
        if let index = self.playlist.index(where: { (item) -> Bool in return item.fileURL.absoluteString == playing.fileURL.absoluteString }) {
            if (index == 0) {
                // first
                self.reset()
                return
            }
            let item = self.playlist[index - 1]
            self.playing = item
            self.internalPlay(item: item)
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
            player.play()
        } else {
            self.reset()
        }
    }
    
    fileprivate func internalReset() {
        self.player = nil
        self.currentDirectoryURL = nil
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
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
    }
    
    /* audioPlayerBeginInterruption: is called when the audio session has been interrupted while the player was playing. The player will have been paused. */
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        
    }
    
    /* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
    func audioPlayerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        
    }
}

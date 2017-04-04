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
import RealmSwift

enum AudioRepeatMode {
    case None               // doesn't repeat
    case All                // repeat all item
    case OnlyOne            // repeat only one item
}

extension Notification.Name {
    static let onAudioManagerItemChanged = Notification.Name("audiomanager.itemchanged")
    static let onAudioManagerPlay = Notification.Name("audiomanager.play")
    static let onAudioManagerPause = Notification.Name("audiomanager.pause")
    static let onAudioManagerReset = Notification.Name("audiomanager.reset")
    static let onAudioManagerTimeChanged = Notification.Name("audiomanager.timechanged")
    static let onAudioManagerBookmarkUpdated = Notification.Name("audiomanager.bookmarkupdated")
    static let onAudioManagerRateChanged = Notification.Name("audiomanager.ratechanged")
}

class AudioManager: NSObject {
    fileprivate var queuePlayer: AVQueuePlayer?
    fileprivate var player: AVPlayer?
    fileprivate var playerItem: AVPlayerItem? {
        didSet {
            guard let item = playerItem else {
                self.player = nil
                return
            }
            if let periodicObserver = self.periodicObserver {
                self.player?.removeTimeObserver(periodicObserver)
                self.periodicObserver = nil
            }
            if let boundaryObserver = self.boundaryObserver {
                self.player?.removeTimeObserver(boundaryObserver)
                self.boundaryObserver = nil
            }
            self.player = AVPlayer(playerItem: AVPlayerItem(asset: item.asset))
            self.periodicObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.05, Int32(NSEC_PER_SEC)), queue: nil, using: { (time) in
                self.updateTime()
            })
            self.player?.volume = self.volume
            self.player?.rate = self.rate
            self.switchRepeat = false
            self.notificationCenter.post(name: .onAudioManagerItemChanged, object: item)
            
            self.bookmarkTimes = [Double]()
            if let targetPath = self.playerItem?.url?.path {
                let realm = try! Realm()
                if let bookmarkObj = realm.objects(BookmarkObject.self).filter("path = '\(targetPath)'").first {
                    self.bookmarkTimes = bookmarkObj.times.map({ (dObj) -> Double in return dObj.value }).sorted()
                    self.addBoundaryTimeHandler()
                }
            }
        }
    }
    fileprivate var playlist: [AVPlayerItem]
    fileprivate var bookmarkTimes: [Double]
    fileprivate var periodicObserver: Any?
    fileprivate var boundaryObserver: Any?
    fileprivate let rates: [Float]
    public var notificationCenter: NotificationCenter
    public var volume = Float(integerLiteral: 5) {
        didSet {
            if let player = self.player {
                player.volume = volume
            }
        }
    }
    public var rate: Float {
        get {
            guard let player = self.player else { return 1.0 }
            return player.rate
        }
    }
    public var mode = AudioRepeatMode.None
    public var switchRepeat = false

    override init() {
        self.playlist = [AVPlayerItem]()
        self.notificationCenter = NotificationCenter()
        self.bookmarkTimes = [Double]()
        self.rates = [0.50, 0.80, 1.0, 1.25, 1.50, 2.0]
        super.init()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(finishedPlaying(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK - Public
    
    public func addBookmarkTimeObject() {
        guard let currentSeconds = self.player?.currentSeconds else { return }
        guard let targetPath = self.playerItem?.url?.path else { return }
        self.bookmarkTimes.append(currentSeconds)
        self.bookmarkTimes.sort()
    
        let realm = try! Realm()
        try! realm.write {
            let bookmarkObj = BookmarkObject(path: targetPath)
            self.bookmarkTimes.forEach({ (time) in
                bookmarkObj.times.append(DoubleObject(doubleValue: time))
            })
            realm.add(bookmarkObj, update: true)
        }
        self.addBoundaryTimeHandler()
        self.bookmarkUpdated()
    }
    
    public func removeBookmarkTimeObject(removedTime: Double) {
        guard let targetPath = self.playerItem?.url?.path else { return }
        if let index = self.bookmarkTimes.index(of: removedTime) {
            self.bookmarkTimes.remove(at: index)
        }
        let realm = try! Realm()
        try! realm.write {
            let bookmarkObj = BookmarkObject(path: targetPath)
            self.bookmarkTimes.forEach({ (time) in
                bookmarkObj.times.append(DoubleObject(doubleValue: time))
            })
            realm.add(bookmarkObj, update: true)
        }
        self.addBoundaryTimeHandler()
        self.bookmarkUpdated()
    }
    
    public func getBookmarkTimes() -> [Double] {
        return self.bookmarkTimes
    }
    
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
    
    public func movePreviousBookmark() {
        guard let currentSeconds = self.currentPlayingSeconds() else { return }
        var previousBookmarkTimes = self.bookmarkTimes.filter { (bookmark) -> Bool in return bookmark < currentSeconds }
        if previousBookmarkTimes.count > 0 {
            previousBookmarkTimes.removeLast()
            if let previousBookmark = previousBookmarkTimes.last {
                self.move(at: previousBookmark)
                return
            }
        }
        self.move(at: 0)
    }
    
    public func moveCurrentBookmark() {
        guard let currentSeconds = self.currentPlayingSeconds() else { return }
        let previousBookmarkTimes = self.bookmarkTimes.filter { (bookmark) -> Bool in return bookmark < currentSeconds }
        if let currentBookmark = previousBookmarkTimes.last {
            self.move(at: currentBookmark)
            return
        }
        self.move(at: 0)
    }
    
    public func moveNextBookmark() {
        guard let currentSeconds = self.currentPlayingSeconds() else { return }
        let nextBookmarkTimes = self.bookmarkTimes.filter { (bookmark) -> Bool in return bookmark > currentSeconds }
        if let nextBookmark = nextBookmarkTimes.first {
            self.move(at: nextBookmark)
            return
        }
        self.moveCurrentBookmark()
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
    
    public func move(ratio: Double) {
        guard let player = self.player else { return }
        self.move(at: ratio * player.durationSeconds)
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
    
    public func nextRate() {
        guard let player = self.player else { return }
        guard let item = self.playerItem else { return }
        if let index = self.rates.index(of: player.rate) {
            let nextRateIndex = (index + 1) % self.rates.count
            player.rate = self.rates[nextRateIndex]
            self.notificationCenter.post(name: .onAudioManagerRateChanged, object: item)
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
    
    func handleReachBoundaryTime() {
        if (!self.switchRepeat) { return }
        guard let currentSeconds = self.currentPlayingSeconds() else { return }
        let previousBookmarks = self.bookmarkTimes.filter { (bookmark) -> Bool in return bookmark < (currentSeconds - 0.1) }
        if let previousBookmark = previousBookmarks.last {
            self.move(at: previousBookmark + 0.1)
        }
    }
    
    // MARK: Private
    fileprivate func internalPlay() {
        guard let item = self.playerItem else { return }
        self.player?.play()
        self.notificationCenter.post(name: .onAudioManagerPlay, object: item)
    }
    
    fileprivate func internalPause() {
        guard let item = self.playerItem else { return }
        self.player?.pause()
        self.notificationCenter.post(name: .onAudioManagerPause, object: item)
    }
    
    fileprivate func internalResume() {
        guard let item = self.playerItem else { return }
        self.player?.play()
        self.notificationCenter.post(name: .onAudioManagerPlay, object: item)
    }
    
    fileprivate func internalReset() {
        self.playerItem = nil
        self.playlist = [AVPlayerItem]()
        self.notificationCenter.post(name: .onAudioManagerReset, object: nil)
    }
    
    fileprivate func bookmarkUpdated() {
        self.notificationCenter.post(name: .onAudioManagerBookmarkUpdated, object: nil)
    }
    
    fileprivate func addBoundaryTimeHandler() {
        weak var weakSelf = self
        if let observer = self.boundaryObserver {
            self.player?.removeTimeObserver(observer)
            self.boundaryObserver = nil
        }
        // crash if times is empty
        if self.bookmarkTimes.count > 0 {
            self.boundaryObserver = self.player?.addBoundaryTimeObserver(forTimes: self.bookmarkTimes as [NSValue], queue: nil, using: {
                weakSelf?.handleReachBoundaryTime()
            })
        }
    }
}
 

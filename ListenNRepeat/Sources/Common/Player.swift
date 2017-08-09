//
//  Player.swift
//  ListenNRepeat
//
//  Created by KimYongSeong on 2017. 5. 14..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import RealmSwift

extension Notification.Name {
    static let playerItemDidSet = Notification.Name("player.item.set")
    static let playerStop = Notification.Name("player.stop")
    static let playerTimeUpdated = Notification.Name("player.time.update")
    static let playerBookmakrUpdated = Notification.Name("player.bookmark.update")
    static let playerStateUpdated = Notification.Name("player.state.updated")
}

enum PlayerError: Error {
    case invalidArgumentPlayerItem
    case alreadExistBookmarkNearby
    case bookmarkTooCloseFinish
}

enum RepeatMode {
    case None
    case All        // 전곡 반복
    case One        // 한곡 반복
}

struct PlayerState {
    var isPlaying = false
    var repeatMode = RepeatMode.None
    var repeatBookmark = false
    var rate:Float = Player.defaultRate
}

class Player: NSObject {
    //MARK: Constant
    static let shared = Player()
    public let notificationCenter = NotificationCenter()
    fileprivate var hasLoaded = false
    fileprivate static let bookmarkNearbyLimitSeconds = 0.4
    fileprivate static let repeatModes = [RepeatMode.None, RepeatMode.All, RepeatMode.One]
    fileprivate static let defaultRate: Float = 1.0
    fileprivate static let rates: [Float] = [0.5, 0.8, Player.defaultRate, 1.25, 1.5]
    
    //MARK: Properties
    public var bookmarkTimes: [Double] {
        return self._bookmarkTimes
    }
    public var currentTime: Double {
        return self._currentTime
    }
    public var duration: Double {
        guard let duration = self.player?.durationSeconds else { return 0 }
        return duration
    }
    public var state: PlayerState {
        get {
            var state = PlayerState()
            if let player = self.player {
                state.isPlaying = player.isPlaying
            }
            state.repeatMode = self.repeatMode
            state.repeatBookmark = self.repeatBookmark
            state.rate = self.rate
            return state
        }
    }
    public var currentItem: PlayerItem?
    fileprivate var player: AVPlayer?
    fileprivate var movedTime: Double = 0
    fileprivate var currentItemIndex: Int? {
        guard let currentItem = self.currentItem else {
            return nil
        }
        return items.index(of: currentItem)
    }
    fileprivate var items = [PlayerItem]()
    fileprivate var repeatMode = RepeatMode.None
    fileprivate var repeatBookmark = false
    fileprivate var rate = Player.defaultRate {
        didSet {
            self.player?.rate = rate
        }
    }
    fileprivate var periodicObserver: Any?
    fileprivate var boundaryObserver: Any?
    fileprivate var _currentTime: Double = 0
    fileprivate var _bookmarkTimes = [Double]()
    
    override init() {
        super.init()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        NotificationCenter.default.addObserver(self, selector: #selector(handleFinished(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func play(items: [PlayerItem], startAt: Int) throws {
        if (items.count <= startAt) {
            throw PlayerError.invalidArgumentPlayerItem
        }
        
        if let currentItem = self.currentItem {
            if currentItem == items[startAt] {
                return
            }
        }
        self.items = items
        self.loadPlayer(item: items[startAt])
    }
    
    public func pause() {
        self.player?.pause()
        self.notificationCenter.post(name: .playerStateUpdated, object: self.currentItem)
    }
    
    public func resume() {
        self.player?.play()
        self.notificationCenter.post(name: .playerStateUpdated, object: self.currentItem)
    }
    
    public func playNext() {
        var item: PlayerItem? = nil
        switch self.repeatMode {
        case .One:
            item = self.currentItem
            break
        case .All:
            if let idx = self.currentItemIndex, self.items.count > 0 {
                item = self.items[(idx + 1) % self.items.count]
            }
            break
        case .None:
            if let idx = self.currentItemIndex {
                if idx <= (self.items.count - 2) && idx >= 0 {
                    item = self.items[idx + 1]
                }
            }
            break
        }
        self.loadPlayer(item: item)
    }
    
    public func playPrev() {
        var item: PlayerItem? = nil
        switch self.repeatMode {
        case .One:
            item = self.currentItem
            break
        case .All:
            if let idx = self.currentItemIndex, self.items.count > 0 {
                item = self.items[(idx + self.items.count - 1) % self.items.count]
            }
            break
        case .None:
            if let idx = self.currentItemIndex {
                if idx >= 1 {
                    item = self.items[idx - 1]
                }
            }
            break
        }
        self.loadPlayer(item: item)
    }
    
    public func move(to: Double) {
        // 모든 move는 이 method를 call해야 한다. movedTime 관리를 위해
        var time = to
        if (time < 0) {
            time = 0
        }
        if (time > self.duration) {
            time = self.duration.leftSide()
        }
        time = time.roundTo(place: 2)
        self.movedTime = time
        self.player?.seek(to: time)
    }
    
    public func moveForward(seconds: Double) {
        var time = self._currentTime + seconds
        if (time >= duration) {
            time = duration.leftSide()
        }
        self.move(to: time)
    }
    
    public func moveBackward(seconds: Double) {
        var time = self._currentTime - seconds
        if (time < 0) {
            time = 0
        }
        self.move(to: time)
    }
    
    public func moveLatestBookmark() {
        var time: Double = 0
        if let currentBookmark = (self._bookmarkTimes.filter { return $0 < self._currentTime }.last) {
            time = currentBookmark
        }
        self.move(to: time.rightSide())
    }
    
    public func movePreviousBookmark() {
        var time: Double = 0
        let filtered = self._bookmarkTimes.filter { return $0 <= self._currentTime }
        if filtered.count > 1 {
            time = filtered[filtered.count - 2]
        }
        self.move(to: time.rightSide())
    }
    
    public func moveNextBookmark() {
        if let nextBookmark = (self._bookmarkTimes.filter { return $0 > self._currentTime }).first {
            self.move(to: nextBookmark.rightSide())
            return
        }
        self.moveLatestBookmark()
    }
    
    public func addBookmark() throws {
        guard let item = self.currentItem else { return }
        // 둘째 자리까지 기록
        let current = self._currentTime.roundTo(place: 2)
        if self.isAlreadyExistBookmarkNearby(current: current, times: self._bookmarkTimes) {
            throw PlayerError.alreadExistBookmarkNearby
        }
        if current + Player.bookmarkNearbyLimitSeconds > self.duration {
            throw PlayerError.bookmarkTooCloseFinish
        }
        var times = self._bookmarkTimes
        times.append(current)
        self._bookmarkTimes = times.sorted()
        self.didUpdatedBookmark(item:item, times: self._bookmarkTimes)
    }
    
    public func removeBookmark(at: Double) {
        guard let item = self.currentItem else { return }
        self._bookmarkTimes = self._bookmarkTimes.filter { return $0 != at }.sorted()
        self.didUpdatedBookmark(item:item, times: self._bookmarkTimes)
    }
    
    public func removeAllBookmarks() {
        let realm = try! Realm()
        let bookmarkObjs = realm.objects(BookmarkObject.self)
        try? realm.write {
            realm.delete(bookmarkObjs)
        }
        self._bookmarkTimes = [Double]()
        self.notificationCenter.post(name: .playerBookmakrUpdated, object: self.currentItem)
    }
    
    public func removeCurrentPlayingItemAllBookmarks() {
        let realm = try! Realm()
        if let bookmarkKey = self.currentItem?.bookmarkKey {
            let bookmarkObjs = realm.objects(BookmarkObject.self).filter("path = '\(bookmarkKey)'")
            try? realm.write {
                realm.delete(bookmarkObjs)
            }
            self._bookmarkTimes = [Double]()
        }
        self.notificationCenter.post(name: .playerBookmakrUpdated, object: self.currentItem)
    }
    
    public func nextRepeatMode() {
        if let index = Player.repeatModes.index(of: self.repeatMode) {
            let nextMode = Player.repeatModes[((index + 1) % Player.repeatModes.count)]
            self.repeatMode = nextMode
            self.notificationCenter.post(name: .playerStateUpdated, object: nil)
        }
    }
    
    public func switchRepeatBookmark() {
        self.repeatBookmark = !self.repeatBookmark
        self.notificationCenter.post(name: .playerStateUpdated, object: nil)
    }
    
    public func nextRate() {
        if let index = Player.rates.index(of: self.rate) {
            let nextRate = Player.rates[((index + 1) % Player.rates.count)]
            self.rate = nextRate
            self.notificationCenter.post(name: .playerStateUpdated, object: nil)
        }
    }
    
    //MARK: Handle event
    @objc func handleFinished(notification: Notification) {
        if (self.repeatBookmark) {
            self.moveLatestBookmark()
            self.player?.play()
            return
        }
        self.playNext()
    }
    
    func handleReachBoundary() {
        if (self.repeatBookmark) {
            self.moveLatestBookmark()
        }
    }
    
    func handleTimeChanged() {
        if let playingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            var info = playingInfo
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: self.currentTime)
            info[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: self.duration)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
        }
        var albumInfo = Dictionary<String, Any>()
        albumInfo[MPMediaItemPropertyTitle] = self.currentItem?.title
        albumInfo[MPMediaItemPropertyArtist] = self.currentItem?.artist
        albumInfo[MPMediaItemPropertyAlbumTitle] = self.currentItem?.albumTitle
        albumInfo[MPMediaItemPropertyArtwork] = self.currentItem?.artwork
        albumInfo[MPMediaItemPropertyPlaybackDuration] = self.duration
        albumInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.currentTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = albumInfo
        
        self.notificationCenter.post(name: .playerTimeUpdated, object: nil)
    }
    
    //MARK: Private
    fileprivate func loadPlayer(item: PlayerItem?) {
        let resetCurrentItem = (item == nil || item?.url == nil)
        var playingItem = item
        if resetCurrentItem {
            playingItem = self.currentItem
        }
        
        guard let url = playingItem?.url else {
            self.notificationCenter.post(name: .playerItemDidSet, object: currentItem)
            return
        }
        
        // 기존에 있는 observer 제거
        if let periodicObserver = self.periodicObserver {
            self.player?.removeTimeObserver(periodicObserver)
            self.periodicObserver = nil
        }
        if let boundaryObserver = self.boundaryObserver {
            self.player?.removeTimeObserver(boundaryObserver)
            self.boundaryObserver = nil
        }

        self.currentItem = playingItem
        self.notificationCenter.post(name: .playerItemDidSet, object: self.currentItem)
        
        self.loadCommandCenterIfNecessary()
        self.player = AVPlayer(playerItem: AVPlayerItem(url: url))
        self.player?.rate = self.rate
        self.player?.pause()
        self.movedTime = 0
        self._currentTime = 0
        self.periodicObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.05, Int32(NSEC_PER_SEC)),
                                                                     queue: nil,
                                                                     using: { [weak self] (time) in
                                                                        guard let `self` = self else { return }
                                                                        let seconds = CMTimeGetSeconds(time).roundTo(place: 2)
                                                                        if let status = self.player?.currentItem?.status, status == .readyToPlay {
                                                                            if (seconds >= self.movedTime) {
                                                                                self._currentTime = seconds
                                                                            }
                                                                            self.handleTimeChanged()
                                                                        } else {
                                                                            self._currentTime = 0
                                                                        }
        })
        
        // load bookmark
        self._bookmarkTimes = [Double]()
        if let bookmarkKey = playingItem?.bookmarkKey {
            let realm = try! Realm()
            if let bookmarkObj = realm.objects(BookmarkObject.self).filter("path = '\(bookmarkKey)'").first {
                self._bookmarkTimes = bookmarkObj.times.map({ (dObj) -> Double in return dObj.value }).sorted()
                self.addBookmarkBoundary(times: self._bookmarkTimes)
            }
        }
        
        if !resetCurrentItem {
            self.player?.play()
        }
        self.notificationCenter.post(name: .playerStateUpdated, object: nil)
        self.notificationCenter.post(name: .playerTimeUpdated, object: nil)
    }
    
    fileprivate func didUpdatedBookmark(item: PlayerItem, times: [Double]) {
        guard let bookmarkKey = item.bookmarkKey else { return }
        let realm = try! Realm()
        try? realm.write {
            let bookmarkObj = BookmarkObject(path: bookmarkKey)
            times.forEach({ (time) in
                bookmarkObj.times.append(DoubleObject(doubleValue: time))
            })
            realm.create(BookmarkObject.self, value: bookmarkObj, update: true)
        }
        self.addBookmarkBoundary(times: times)
        self.notificationCenter.post(name: .playerBookmakrUpdated, object: item)
    }
    
    fileprivate func addBookmarkBoundary(times: [Double]) {
        if let observer = self.boundaryObserver {
            self.player?.removeTimeObserver(observer)
            self.boundaryObserver = nil
        }
        // crash if times is empty
        if times.count > 0 {
            self.boundaryObserver = self.player?.addBoundaryTimeObserver(forTimes: times as [NSValue], queue: nil, using: { [weak self] in
                guard let weakSelf = self else { return }
                guard let time = weakSelf.player?.currentTime() else { return }
                let seconds = CMTimeGetSeconds(time)
                if (weakSelf.movedTime <= seconds) {
                    weakSelf.handleReachBoundary()
                }
            })
        }
    }
    
    fileprivate func isAlreadyExistBookmarkNearby(current: Double, times: [Double]) -> Bool {
        if (times.filter { return abs($0 - current) < Player.bookmarkNearbyLimitSeconds }.first) != nil {
            return true
        }
        return false
    }
    
    fileprivate func loadCommandCenterIfNecessary() {
        if (!hasLoaded) {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                
                let commandCenter = MPRemoteCommandCenter.shared()
                commandCenter.playCommand.isEnabled = true
                commandCenter.playCommand.addTarget(self, action:#selector(resume))
                commandCenter.pauseCommand.isEnabled = true
                commandCenter.pauseCommand.addTarget(self, action:#selector(pause))
                commandCenter.previousTrackCommand.isEnabled = true
                commandCenter.previousTrackCommand.addTarget(self, action:#selector(playPrev))
                commandCenter.nextTrackCommand.isEnabled = true
                commandCenter.nextTrackCommand.addTarget(self, action:#selector(playNext))
            } catch let error as NSError {
                print(error)
            }
            self.hasLoaded = true
        }
    }
    
    fileprivate func loadPlayingInfo() {
        guard let item = self.currentItem else { return }
        var playingInfo:[String: Any] = [:]
        if let title = item.title {
            playingInfo[MPMediaItemPropertyTitle] = title
        }
        if let artist = item.artist {
            playingInfo[MPMediaItemPropertyArtist] = artist
        }
        if let albumTitle = item.albumTitle {
            playingInfo[MPMediaItemPropertyAlbumTitle] = albumTitle
        }
        //        // TODO: artwork 없을 때 app image 넣기
        if let artwork = item.artwork {
            playingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: artwork.size,
                                                                         requestHandler: { (size) -> UIImage in
                                                                            return artwork
            })
        } else if let logoImage = UIImage(named: "more_logo_100pt") {
            playingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: logoImage.size,
                                                                         requestHandler: { (size) -> UIImage in
                                                                            return logoImage
            })
        }
        playingInfo[MPNowPlayingInfoPropertyPlaybackRate] = NSNumber(value: self.rate)
        playingInfo[MPNowPlayingInfoPropertyMediaType] = NSNumber(value: MPNowPlayingInfoMediaType.audio.rawValue)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
    }
}

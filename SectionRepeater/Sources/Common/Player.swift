//
//  Player.swift
//  SectionRepeater
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
    public let notificationCenter = NotificationCenter()
    fileprivate static let bookmarkNearbyLimitSeconds = 0.3
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
    public var currentItem: PlayerItem? {
        didSet {
            self.didSetPlayerItem(currentItem: currentItem)
        }
    }
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
    
    func play(items: [PlayerItem], startAt: Int) throws {
        if (items.count <= startAt) {
            throw PlayerError.invalidArgumentPlayerItem
        }
        
        if let currentItem = self.currentItem {
            if currentItem == items[startAt] {
                return
            }
        }
        self.items = items
        self.currentItem = items[startAt]
    }
    
    func pause() {
        self.player?.pause()
        self.notificationCenter.post(name: .playerStateUpdated, object: self.currentItem)
    }
    
    func resume() {
        self.player?.play()
        self.notificationCenter.post(name: .playerStateUpdated, object: self.currentItem)
    }
    
    func playNext() {
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
        self.currentItem = item
    }
    
    func playPrev() {
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
        self.currentItem = item
    }
    
    func move(to: Double) {
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
    
    func moveForward(seconds: Double) {
        var time = self._currentTime + seconds
        if (time >= duration) {
            time = duration.leftSide()
        }
        self.move(to: time)
    }
    
    func moveBackward(seconds: Double) {
        var time = self._currentTime - seconds
        if (time < 0) {
            time = 0
        }
        self.move(to: time)
    }
    
    func moveLatestBookmark() {
        var time: Double = 0
        if let currentBookmark = (self._bookmarkTimes.filter { return $0 < self._currentTime }.last) {
            time = currentBookmark
        }
        self.move(to: time.rightSide())
    }
    
    func movePreviousBookmark() {
        var time: Double = 0
        let filtered = self._bookmarkTimes.filter { return $0 <= self._currentTime }
        if filtered.count > 1 {
            time = filtered[filtered.count - 2]
        }
        self.move(to: time.rightSide())
    }
    
    func moveNextBookmark() {
        if let nextBookmark = (self._bookmarkTimes.filter { return $0 > self._currentTime }).first {
            self.move(to: nextBookmark.rightSide())
            return
        }
        self.moveLatestBookmark()
    }
    
    func addBookmark() throws {
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
    
    func removeBookmark(at: Double) {
        guard let item = self.currentItem else { return }
        self._bookmarkTimes = self._bookmarkTimes.filter { return $0 != at }.sorted()
        self.didUpdatedBookmark(item:item, times: self._bookmarkTimes)
    }
    
    func nextRepeatMode() {
        if let index = Player.repeatModes.index(of: self.repeatMode) {
            let nextMode = Player.repeatModes[((index + 1) % Player.repeatModes.count)]
            self.repeatMode = nextMode
            self.notificationCenter.post(name: .playerStateUpdated, object: nil)
        }
    }
    
    func switchRepeatBookmark() {
        self.repeatBookmark = !self.repeatBookmark
        self.notificationCenter.post(name: .playerStateUpdated, object: nil)
    }
    
    func nextRate() {
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
        self.notificationCenter.post(name: .playerTimeUpdated, object: nil)
    }
    
    //MARK: Private
    fileprivate func didSetPlayerItem(currentItem: PlayerItem?) {
        // 기존에 있는 observer 제거
        if let periodicObserver = self.periodicObserver {
            self.player?.removeTimeObserver(periodicObserver)
            self.periodicObserver = nil
        }
        if let boundaryObserver = self.boundaryObserver {
            self.player?.removeTimeObserver(boundaryObserver)
            self.boundaryObserver = nil
        }
        self.loadPlayer(item: currentItem)
        self.notificationCenter.post(name: .playerItemDidSet, object: currentItem)
    }
    
    fileprivate func loadPlayer(item: PlayerItem?) {
        guard let url = currentItem?.url else {
            self.player = nil
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
        } catch let error as NSError {
            print(error)
        }
        if !FileManager.default.fileExists(atPath: url.path) {
            self.player = nil
            self.currentItem = nil
//            throw PlayerError.invalidArgumentPlayerItem
            return
        }
        self.player = AVPlayer(playerItem: AVPlayerItem(url: url))
        self.player?.rate = self.rate
        self.player?.play()
        self.movedTime = 0
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
        
        self.notificationCenter.post(name: .playerStateUpdated, object: item)

        self._bookmarkTimes = [Double]()
        if let bookmarkKey = item?.bookmarkKey {
            let realm = try! Realm()
            if let bookmarkObj = realm.objects(BookmarkObject.self).filter("path = '\(bookmarkKey)'").first {
                self._bookmarkTimes = bookmarkObj.times.map({ (dObj) -> Double in return dObj.value }).sorted()
                self.addBookmarkBoundary(times: self._bookmarkTimes)
            }
        }
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
                guard let `self` = self else { return }
                guard let time = self.player?.currentTime() else { return }
                let seconds = CMTimeGetSeconds(time)
                if (self.movedTime <= seconds) {
                    self.handleReachBoundary()
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
}

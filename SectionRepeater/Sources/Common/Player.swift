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
    case playlistOutOfRange
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
    var rate:Float = Player.defaultRate
}

class Player {
    //MARK: Constant
    public let notificationCenter = NotificationCenter()
    fileprivate static let bookmarkNearbyLimitSeconds = 0.3
    fileprivate static let repeatModes = [RepeatMode.None, RepeatMode.All, RepeatMode.One]
    fileprivate static let defaultRate: Float = 1.0
    fileprivate static let rates: [Float] = [0.5, 0.8, Player.defaultRate, 1.25, 1.5]
    
    //MARK: Properties
    public var bookmarks: [Double] {
        get {
            return self.bookmarkTimes
        }
    }
    public var currentSeconds: Double {
        get {
            guard let current = self.player?.currentSeconds else { return 0 }
            return current
        }
    }
    public var duration: Double {
        get {
            guard let duration = self.player?.durationSeconds else { return 0 }
            return duration
        }
    }
    public var state: PlayerState {
        get {
            var state = PlayerState()
            if let player = self.player {
                state.isPlaying = player.isPlaying
            }
            state.repeatMode = self.repeatMode
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
    fileprivate var currentItemIndex: Int? {
        get {
            guard let currentItem = self.currentItem else {
                return nil
            }
            return items.index(of: currentItem)
        }
    }
    fileprivate var items = [PlayerItem]()
    fileprivate var repeatMode = RepeatMode.None
    fileprivate var rate = Player.defaultRate {
        didSet {
            self.player?.rate = rate
        }
    }
    fileprivate var periodicObserver: Any?
    fileprivate var boundaryObserver: Any?
    fileprivate var bookmarkTimes = [Double]() {
        didSet {
            self.updateLatestBookmark(at: self.currentSeconds)
        }
    }
    fileprivate var latestBookmark: Double = 0
    
    init() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }
        NotificationCenter.default.addObserver(self, selector: #selector(handleFinished(notification:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func play(items: [PlayerItem], startAt: Int) throws {
        if (items.count <= startAt) {
            throw PlayerError.playlistOutOfRange
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
    
    func move(at: Double) {
        var time = at
        if (time < 0) {
            time = 0
        }
        if (time > self.duration) {
            time = self.duration.leftSide()
        }
        self.updateLatestBookmark(at: time)
        self.player?.seek(to: time)
    }
    
    func moveForward(seconds: Double) {
        var time = self.currentSeconds + seconds
        if (time >= duration) {
            time = duration.leftSide()
        }
        self.player?.seek(to: time)
    }
    
    func moveBackward(seconds: Double) {
        var time = self.currentSeconds - seconds
        if (time < 0) {
            time = 0
        }
        self.player?.seek(to: time)
    }
    
    func moveLastestBookmark() {
        self.move(at: self.latestBookmark)
    }
    
    func movePreviousBookmark() {
        var time: Double = 0
        if let previous = (self.bookmarkTimes.filter { return $0 < self.latestBookmark }.last) {
            time = previous
        }
        self.move(at: time)
    }
    
    func moveNextBookmark() {
        var time: Double = self.latestBookmark
        if let next = (self.bookmarkTimes.filter { return $0 > self.latestBookmark }.first) {
            time = next
        }
        self.move(at: time)
    }
    
    func addBookmark() throws {
        guard let item = self.currentItem else { return }
        // 둘째 자리까지 기록
        let current = self.currentSeconds.roundTo(place: 3)
        if self.isAlreadyExistBookmarkNearby(current: current, times: self.bookmarkTimes) {
            throw PlayerError.alreadExistBookmarkNearby
        }
        if current + Player.bookmarkNearbyLimitSeconds > self.duration {
            throw PlayerError.bookmarkTooCloseFinish
        }
        var times = self.bookmarkTimes
        times.append(current)
        self.bookmarkTimes = times.sorted()
        self.didUpdatedBookmark(item:item, times: self.bookmarkTimes)
    }
    
    func removeBookmark(at: Double) {
        guard let item = self.currentItem else { return }
        self.bookmarkTimes = self.bookmarkTimes.filter { return $0 != at }.sorted()
        self.didUpdatedBookmark(item:item, times: self.bookmarkTimes)
    }
    
    func nextRepeatMode() {
        if let index = Player.repeatModes.index(of: self.repeatMode) {
            let nextMode = Player.repeatModes[((index + 1) % Player.repeatModes.count)]
            self.repeatMode = nextMode
            self.notificationCenter.post(name: .playerStateUpdated, object: nil)
        }
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
        self.playNext()
    }
    
    func handleReachBoundary() {
        self.updateLatestBookmark(at: self.currentSeconds)
    }
    
    func handleTimeChanged(_ time: Double) {
        self.notificationCenter.post(name: .playerTimeUpdated, object: self.player?.currentSeconds)
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
        self.player = AVPlayer(playerItem: AVPlayerItem(url: url))
        self.player?.rate = self.rate
        self.player?.play()
        self.notificationCenter.post(name: .playerStateUpdated, object: item)
        
        // observer 추가하기
        self.periodicObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.05, Int32(NSEC_PER_SEC)),
                                                                     queue: nil,
                                                                     using: { (time) in
                                                                        self.handleTimeChanged(time.seconds) })
        self.bookmarkTimes = [Double]()
        if let bookmarkKey = item?.bookmarkKey {
            let realm = try! Realm()
            if let bookmarkObj = realm.objects(BookmarkObject.self).filter("path = '\(bookmarkKey)'").first {
                self.bookmarkTimes = bookmarkObj.times.map({ (dObj) -> Double in return dObj.value }).sorted()
                self.addBookmarkBoundary(times: self.bookmarkTimes)
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
    
    fileprivate func updateLatestBookmark(at: Double) {
        var time: Double = 0
        if let latest = (self.bookmarkTimes.filter { return $0 <= at}.last) {
            time = latest
        }
        self.latestBookmark = time
    }
    
    fileprivate func addBookmarkBoundary(times: [Double]) {
        if let observer = self.boundaryObserver {
            self.player?.removeTimeObserver(observer)
            self.boundaryObserver = nil
        }
        // crash if times is empty
        if times.count > 0 {
            weak var weakSelf = self
            self.boundaryObserver = self.player?.addBoundaryTimeObserver(forTimes: times as [NSValue], queue: nil, using: {
                weakSelf?.handleReachBoundary()
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

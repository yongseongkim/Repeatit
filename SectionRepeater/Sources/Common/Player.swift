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
}

class Player {
    //MARK: Constant
    public let notificationCenter = NotificationCenter()
    fileprivate static let bookmarkNearbyLimitSeconds = 0.3
    fileprivate static let repeatModes = [RepeatMode.None, RepeatMode.All, RepeatMode.One]
    
    //MARK: Properties
    public var audioInformation: AudioInformation?
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
            return state
        }
    }
    
    fileprivate var player: AVPlayer?
    fileprivate var currentItem: AVPlayerItem? {
        didSet {
            self.didSetPlayerItem(currentItem: currentItem)
        }
    }
    fileprivate var currentItemIndex: Int? {
        get {
            guard let currentItem = self.currentItem else {
                return nil
            }
            return items.index(of: currentItem)
        }
    }
    fileprivate var items = [AVPlayerItem]()
    fileprivate var repeatMode = RepeatMode.None
    fileprivate var periodicObserver: Any?
    fileprivate var boundaryObserver: Any?
    fileprivate var bookmarkTimes = [Double]() {
        didSet {
            guard let item = currentItem else { return }
            self.didSetBookmarkTimes(item:item, times: bookmarkTimes)
        }
    }
    
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
    
    func play(files: [File], startAt: Int) throws {
        if (files.count <= startAt) {
            throw PlayerError.playlistOutOfRange
        }
        if let currentURL = self.currentItem?.url {
            // 똑같은 url을 play하지 않는다.
            if files[startAt].url.absoluteString == currentURL.absoluteString {
                return
            }
        }
        self.items = files.map({ (f) -> AVPlayerItem in
            return AVPlayerItem(url: f.url)
        })
        self.currentItem = self.items[startAt]
    }
    
    func play(items: [MPMediaItem], startAt: Int) throws {
        let files = items.map { (item) -> File in
            return File(url: item.value(forProperty: MPMediaItemPropertyAssetURL) as! URL)
        }
        try self.play(files: files, startAt: startAt)
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
        var item: AVPlayerItem? = nil
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
        var item: AVPlayerItem? = nil
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
        if let duration = self.player?.durationSeconds {
            if (time > duration) {
                time = duration.leftSide()
            }
        }
        self.player?.seek(to: time)
    }
    
    func moveForward(seconds: Double) {
        guard let current = self.player?.currentSeconds else { return }
        guard let duration = self.player?.durationSeconds else { return }
        var time = current + seconds
        if (time >= duration) {
            time = duration.leftSide()
        }
        self.player?.seek(to: time)
    }
    
    func moveBackward(seconds: Double) {
        guard let current = self.player?.currentSeconds else { return }
        var time = current - seconds
        if (time < 0) {
            time = 0
        }
        self.player?.seek(to: time)
    }
    
    func moveLastestBookmark() {
        guard let current = self.player?.currentSeconds else { return }
        var time: Double = 0
        if let lastest = (self.bookmarkTimes.filter { return $0 <= current }.last) {
            time = lastest
        }
        self.move(at: time)
    }
    
    func movePreviousBookmark() {
        guard let current = self.player?.currentSeconds else { return }
        var time: Double = 0
        if let previous = (self.bookmarkTimes.filter { return $0 < current }.last) {
            time = previous
        }
        self.move(at: time)
    }
    
    func moveNextBookmark() {
        guard let current = self.player?.currentSeconds else { return }
        var time: Double = 0
        if let next = (self.bookmarkTimes.filter { return $0 > current }.first) {
            time = next
        }
        self.move(at: time)
    }
    
    func addBookmark() throws {
        // 둘째 자리까지 기록
        guard let currentSeconds = self.player?.currentSeconds.roundToPlace(place: 2) else { return }
        if self.isAlreadyExistBookmarkNearby(current: currentSeconds, times: self.bookmarkTimes) {
            throw PlayerError.alreadExistBookmarkNearby
        }
        if let duration = self.player?.durationSeconds {
            if currentSeconds + Player.bookmarkNearbyLimitSeconds > duration {
                throw PlayerError.bookmarkTooCloseFinish
            }
        }
        var times = self.bookmarkTimes
        times.append(currentSeconds)
        self.bookmarkTimes = times.sorted()
    }
    
    fileprivate func removeBookmark(removedTime: Double) {
        // 둘째 자리까지 기록
        self.bookmarkTimes = self.bookmarkTimes.filter { (time) -> Bool in
            return time != removedTime
        }.sorted()
    }
    
    func removeBookmark(at: Double) {
        self.bookmarkTimes = self.bookmarkTimes.filter { return $0 != at }
    }
    
    func nextRepeatMode() {
        if let index = Player.repeatModes.index(of: self.repeatMode) {
            let nextMode = Player.repeatModes[((index + 1) % Player.repeatModes.count)]
            self.repeatMode = nextMode
            self.notificationCenter.post(name: .playerStateUpdated, object: nil)
        }
    }
    
    //MARK: Handle event
    @objc func handleFinished(notification: Notification) {
        self.playNext()
    }
    
    func handleReachBoundary() {
        
    }
    
    func handleTimeChanged(_ time: Double) {
        guard let current = self.player?.currentSeconds else { return }
        self.notificationCenter.post(name: .playerTimeUpdated, object: current)
    }
    
    //MARK: Private
    fileprivate func didSetPlayerItem(currentItem: AVPlayerItem?) {
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
        if let url = currentItem?.url {
            self.audioInformation = AudioInformation(url: url)
        } else {
            self.audioInformation = nil
        }
        self.notificationCenter.post(name: .playerItemDidSet, object: currentItem)
    }
    
    fileprivate func loadPlayer(item: AVPlayerItem?) {
        guard let item = currentItem else {
            self.player = nil
            return
        }
        self.player = AVPlayer(playerItem: AVPlayerItem(asset: item.asset))
        self.player?.play()
        self.notificationCenter.post(name: .playerStateUpdated, object: item)
        
        // observer 추가하기
        self.periodicObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.05, Int32(NSEC_PER_SEC)),
                                                                     queue: nil,
                                                                     using: { (time) in
                                                                        self.handleTimeChanged(time.seconds) })
        self.bookmarkTimes = [Double]()
        if let currentPath = item.url?.path {
            let realm = try! Realm()
            if let bookmarkObj = realm.objects(BookmarkObject.self).filter("path = '\(currentPath)'").first {
                self.bookmarkTimes = bookmarkObj.times.map({ (dObj) -> Double in return dObj.value }).sorted()
                self.addBookmarkBounday(times: self.bookmarkTimes)
            }
        }
    }
    
    fileprivate func didSetBookmarkTimes(item: AVPlayerItem, times: [Double]) {
        guard let currentItemPath = self.currentItem?.url?.path else { return }
        let realm = try! Realm()
        try? realm.write {
            let bookmarkObj = BookmarkObject(path: currentItemPath)
            times.forEach({ (time) in
                bookmarkObj.times.append(DoubleObject(doubleValue: time))
            })
            realm.add(bookmarkObj, update: true)
        }
        self.addBookmarkBounday(times: times)
        self.notificationCenter.post(name: .playerBookmakrUpdated, object: self.currentItem)
    }
    
    fileprivate func addBookmarkBounday(times: [Double]) {
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

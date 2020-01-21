//
//  Player.swift
//  Repeatit
//
//  Created by KimYongSeong on 2017. 5. 14..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import AVFoundation
import MediaPlayer
import Firebase
import RxSwift
import RxCocoa

enum PlayerError: Error {
    case invalidArgumentPlayerItem
    case noSuchElement
}

enum RepeatMode {
    case None
    case All        // 전곡 반복
    case One        // 한곡 반복
}

protocol Player {
    // MARK: Properties
    var isPlaying: Bool { get }
    var currentPlayItem: PlayItem? { get }
    var currentPlayTime: Double { get }
    var duration: Double  { get }
    var playList: [PlayItem]  { get }
    var repeatMode: RepeatMode { get set }
    var rate: Double { get set }
    // MARK: -

    // MARK: Event
    var isPlayingObservable: Observable<Bool> { get }
    var currentPlayTimeObservable: Observable<Double> { get }
    // MARK: -

    // MARK - Actions
    func play(with list: [PlayItem], startAt: Int) throws
    func pause()
    func resume()
    func stop()
    func playNext() throws
    func playPrev() throws
    func move(to: Double)
    func moveForward(seconds: Double)
    func moveBackward(seconds: Double)
    // MARK: -
}

extension Player {
    func play(with list: [PlayItem], startAt: Int = 0) throws {
        try play(with: list, startAt: startAt)
    }
}

class BasicPlayer {
    var repeatMode: RepeatMode = .None
    var rate: Double = 1.0

    private let isPlayingRelay = BehaviorRelay<Bool>(value: false)
    // play time 변화 감지를 위해 AVPlayerItem 의 time 을 쓰지 않고 observer 를 이용하여 관리한다.
    private let currentPlayTimeRelay = BehaviorRelay<Double>(value: 0)
    private let playListRelay = BehaviorRelay<[PlayItem]>(value: [])
    private let currentPlayItemRelay = BehaviorRelay<PlayItem?>(value: nil)
    private let disposeBag = DisposeBag()

    private var avPlayer: AVPlayer?
    private var avPlayerItem: AVPlayerItem?
    private var playTimeObserverToken: Any?

    private var hasLoaded = false
    private var movedTime: Double?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)

        currentPlayItemRelay
            .subscribe(onNext: { [weak self] playItem in
                if let playItem = playItem {
                    self?.load(item: playItem)
                } else {
                    self?.stop()
                }
            })
            .disposed(by: disposeBag)

        currentPlayTimeRelay
            .subscribe(onNext: { [weak self] time in
                self?.updatePlayingInfo()
            })
            .disposed(by: disposeBag)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func playerDidFinishPlaying() {
        do {
            try playNext()
        } catch {
            stop()
        }
    }

    // Do not call this method for play.
    // Just set item to currentPlayItemRelay.
    private func load(item: PlayItem) {
        // Remove previouse player
        clear()

        // Create new player
        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: item.url))
        avPlayer?.rate = Float(rate)
        addPeriodicTimeObserver()
        avPlayer?.play()

        loadCommandCenterIfNecessary()
        updatePlayingInfo()
        updateIsPlaying()
    }

    private func updateIsPlaying() {
        isPlayingRelay.accept(avPlayer?.isPlaying ?? false)
    }

    private func loadCommandCenterIfNecessary() {
        guard !hasLoaded else { return }
        // Register event handler just once.
        hasLoaded = true
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            let commandCenter = MPRemoteCommandCenter.shared()
            commandCenter.playCommand.isEnabled = true
            commandCenter.playCommand.addTarget { [weak self] event in
                guard let self = self else { return .commandFailed }
                self.resume()
                return .success
            }
            commandCenter.pauseCommand.isEnabled = true
            commandCenter.pauseCommand.addTarget { [weak self] event in
                guard let self = self else { return .commandFailed }
                self.pause()
                return .success
            }
            commandCenter.previousTrackCommand.isEnabled = true
            commandCenter.previousTrackCommand.addTarget { [weak self] event in
                guard let self = self else { return .commandFailed }
                do {
                    try self.playPrev()
                    return .success
                } catch PlayerError.noSuchElement {
                    self.clear()
                    return .noSuchContent
                } catch {
                    return .commandFailed
                }
            }
            commandCenter.nextTrackCommand.isEnabled = true
            commandCenter.nextTrackCommand.addTarget { [weak self] event in
                guard let self = self else { return .commandFailed }
                do {
                    try self.playNext()
                    return .success
                } catch PlayerError.noSuchElement {
                    self.clear()
                    return .noSuchContent
                } catch {
                    return .commandFailed
                }
            }
        } catch let error as NSError {
            print(error)
        }
    }

    private func updatePlayingInfo() {
        if let playingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            var info = playingInfo
            info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: currentPlayTime)
            info[MPMediaItemPropertyPlaybackDuration] = NSNumber(value: duration)
            MPNowPlayingInfoCenter.default().nowPlayingInfo = playingInfo
        } else {
            var albumInfo = Dictionary<String, Any>()
            albumInfo[MPMediaItemPropertyTitle] = currentPlayItem?.title
            albumInfo[MPMediaItemPropertyArtist] = currentPlayItem?.artist
            albumInfo[MPMediaItemPropertyAlbumTitle] = currentPlayItem?.albumTitle
            if let artwork = currentPlayItem?.artwork {
                albumInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: UIScreen.mainSize) { (_) -> UIImage in
                    return artwork
                }
            }
            albumInfo[MPMediaItemPropertyPlaybackDuration] = duration
            albumInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentPlayTime
            MPNowPlayingInfoCenter.default().nowPlayingInfo = albumInfo

        }
    }

    private func addPeriodicTimeObserver() {
        // Notify every half second
        playTimeObserverToken = avPlayer?.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1/60, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main,
            using: { [weak self] time in
                // TODO: play 시간을 바꿨지만 그전 시간을 emit 하면서 waveform 스크롤 뷰가 튕기는 경우가 있다.
                // 임시 방편으로 movedTime 변수를 뒀지만 더 좋은 방법을 찾아야 한다.
                if let movedTime = self?.movedTime {
                    if abs(movedTime - time.seconds) < 0.05 {
                        self?.movedTime = nil
                    } else {
                        return
                    }
                }
                self?.currentPlayTimeRelay.accept(time.seconds)
            }
        )
    }

    private func removePeriodicTimeObserver() {
        defer {
            playTimeObserverToken = nil
        }
        guard let playTimeObserverToken = playTimeObserverToken else { return }
        avPlayer?.removeTimeObserver(playTimeObserverToken)
    }
}

extension BasicPlayer: Player {
    var isPlaying: Bool {
        return isPlayingRelay.value
    }

    var currentPlayItem: PlayItem? {
        return currentPlayItemRelay.value
    }

    var currentPlayTime: Double {
        return currentPlayTimeRelay.value
    }

    var duration: Double {
        guard let duration = avPlayer?.durationSeconds else { return 0 }
        return duration
    }

    var playList: [PlayItem] {
        return playListRelay.value
    }

    // MARK: Event
    var isPlayingObservable: Observable<Bool> {
        return isPlayingRelay.asObservable()
    }

    var currentPlayTimeObservable: Observable<Double> {
        return currentPlayTimeRelay.asObservable()
    }
    // MARK: -

    func play(with list: [PlayItem], startAt: Int = 0) throws {
        if (list.count <= startAt) {
            throw PlayerError.invalidArgumentPlayerItem
        }
        playListRelay.accept(list)
        currentPlayItemRelay.accept(list[startAt])
    }

    func pause() {
        avPlayer?.pause()
        updateIsPlaying()
    }

    func resume() {
        avPlayer?.play()
        updateIsPlaying()
    }

    func stop() {
        move(to: 0)
        avPlayer?.pause()
        updateIsPlaying()
    }

    func clear() {
        defer {
            avPlayer = nil
        }
        avPlayer?.pause()
        updateIsPlaying()
        removePeriodicTimeObserver()
    }

    func playNext() throws {
        var nextPlayItem: PlayItem? = nil
        switch repeatMode {
        case .One:
            nextPlayItem = currentPlayItem
        case .All:
            if let currentPlayItem = currentPlayItem,
                let currentPlayItemIdx = playList.firstIndex(where: { $0.url == currentPlayItem.url }) {
                nextPlayItem = playList[(currentPlayItemIdx + 1) % playList.count]
            }
        case .None:
            if let currentPlayItem = currentPlayItem,
                let currentPlayItemIdx = playList.firstIndex(where: { $0.url == currentPlayItem.url }),
                currentPlayItemIdx < playList.count - 1 {
                nextPlayItem = playList[currentPlayItemIdx + 1]
            }
        }
        if let nextPlayItem = nextPlayItem {
            currentPlayItemRelay.accept(nextPlayItem)
        } else {
            throw PlayerError.noSuchElement
        }
    }

    func playPrev() throws {
        var nextPlayItem: PlayItem? = nil
        switch repeatMode {
        case .One:
            nextPlayItem = currentPlayItem
        case .All:
            if let currentPlayItem = currentPlayItem,
                let currentPlayItemIdx = playList.firstIndex(where: { $0.url == currentPlayItem.url }) {
                nextPlayItem = playList[(currentPlayItemIdx - 1 + playList.count) % playList.count]
            }
        case .None:
            if let currentPlayItem = currentPlayItem,
                let currentPlayItemIdx = playList.firstIndex(where: { $0.url == currentPlayItem.url }),
                currentPlayItemIdx > 0 {
                nextPlayItem = playList[currentPlayItemIdx - 1]
            }
        }
        if let nextPlayItem = nextPlayItem {
            currentPlayItemRelay.accept(nextPlayItem)
        } else {
            throw PlayerError.noSuchElement
        }
    }

    func move(to: Double) {
        // 모든 move는 이 method를 call해야 한다. movedTime 관리를 위해
        var time = to
        if (time < 0) {
            time = 0
        }
        if (time > duration) {
            time = duration.leftSide()
        }
        time = time.roundTo(place: 2)
        avPlayer?.seek(to: time)
        movedTime = time
    }

    func moveForward(seconds: Double) {
        var time = currentPlayTime + seconds
        if (time >= duration) {
            time = duration.leftSide()
        }
        move(to: time)
    }

    func moveBackward(seconds: Double) {
        var time = currentPlayTime - seconds
        if (time < 0) {
            time = 0
        }
        move(to: time)
    }
}

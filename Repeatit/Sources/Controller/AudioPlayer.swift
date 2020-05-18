//
//  AudioPlayer.swift
//  Repeatit
//
//  Created by KimYongSeong on 2017. 5. 14..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import AVFoundation
import Combine
import Firebase
import Foundation
import MediaPlayer

enum PlayerError: Error {
    case invalidArgumentPlayerItem
    case noSuchElement
}

enum RepeatMode {
    case none
    case all        // 전곡 반복
    case one        // 한곡 반복
}

protocol AudioPlayer {
    // MARK: Properties
    var isPlaying: Bool { get }
    var playItem: AudioItem? { get }
    var playTimeSeconds: Double { get }
    var playTimeMillis: Int { get }
    var duration: Double  { get }
    var playList: [AudioItem]  { get }
    var repeatMode: RepeatMode { get set }
    var rate: Double { get set }
    // MARK: -

    // MARK: Event
    var isPlayingPublisher: AnyPublisher<Bool, Never> { get }
    var playTimePublisher: AnyPublisher<Double, Never> { get }
    // MARK: -

    // MARK - Actions
    func play(with list: [AudioItem], startAt: Int) throws
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

extension AudioPlayer {
    func play(with list: [AudioItem], startAt: Int = 0) throws {
        try play(with: list, startAt: startAt)
    }
}

class BasicAudioPlayer {
    var repeatMode: RepeatMode = .none
    var rate: Double = 1.0

    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    // play time 변화 감지를 위해 AVPlayerItem 의 time 을 쓰지 않고 observer 를 이용하여 관리한다.
    private let playTimeSubject = CurrentValueSubject<Double, Never>(0)
    private let playListSubject = CurrentValueSubject<[AudioItem], Never>([])
    private let playItemSubject = CurrentValueSubject<AudioItem?, Never>(nil)
    private var cancellables: [AnyCancellable] = []

    private var avPlayer: AVPlayer?
    private var avPlayerItem: AVPlayerItem?
    private var playTimeObserverToken: Any?

    private var hasLoaded = false
    private var movedTime: Double?

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        playItemSubject
            .sink(
                receiveValue: { [weak self] value in
                    if let playItem = value {
                        self?.load(item: playItem)
                    } else {
                        self?.stop()
                    }
                }
            )
            .store(in: &cancellables)
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
    private func load(item: AudioItem) {
        // Remove previouse player
        clear()

        // Create new player
        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: item.url))
        avPlayer?.rate = Float(rate)
        addPeriodicTimeObserver()
        avPlayer?.play()
        updateIsPlaying()
    }

    private func updateIsPlaying() {
        isPlayingSubject.send(avPlayer?.isPlaying ?? false)
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
                self?.playTimeSubject.send(time.seconds)
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

extension BasicAudioPlayer: AudioPlayer {
    var isPlaying: Bool { isPlayingSubject.value }

    var playItem: AudioItem? { playItemSubject.value }

    var playTimeSeconds: Double { playTimeSubject.value.roundTo(place: 1) }

    var playTimeMillis: Int { Int(playTimeSeconds * 1000) }

    var duration: Double {
        guard let duration = avPlayer?.durationSeconds else { return 0 }
        return duration
    }

    var playList: [AudioItem] { playListSubject.value }

    // MARK: Event
    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        isPlayingSubject.removeDuplicates().eraseToAnyPublisher()
    }

    var playTimePublisher: AnyPublisher<Double, Never> {
        playTimeSubject.eraseToAnyPublisher()
    }
    // MARK: -

    func play(with list: [AudioItem], startAt: Int = 0) throws {
        if (list.count <= startAt) {
            throw PlayerError.invalidArgumentPlayerItem
        }
        playListSubject.send(list)
        playItemSubject.send(list[startAt])
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
        var nextPlayItem: AudioItem? = nil
        switch repeatMode {
        case .one:
            nextPlayItem = playItem
        case .all:
            if let currentPlayItem = playItem,
                let currentPlayItemIdx = playList.firstIndex(where: { $0.url == currentPlayItem.url }) {
                nextPlayItem = playList[(currentPlayItemIdx + 1) % playList.count]
            }
        case .none:
            if let currentPlayItem = playItem,
                let currentPlayItemIdx = playList.firstIndex(where: { $0.url == currentPlayItem.url }),
                currentPlayItemIdx < playList.count - 1 {
                nextPlayItem = playList[currentPlayItemIdx + 1]
            }
        }
        if let nextPlayItem = nextPlayItem {
            playItemSubject.send(nextPlayItem)
        } else {
            throw PlayerError.noSuchElement
        }
    }

    func playPrev() throws {
        var nextPlayItem: AudioItem? = nil
        switch repeatMode {
        case .one:
            nextPlayItem = playItem
        case .all:
            if let currentPlayItem = playItem,
                let currentPlayItemIdx = playList.firstIndex(where: { $0.url == currentPlayItem.url }) {
                nextPlayItem = playList[(currentPlayItemIdx - 1 + playList.count) % playList.count]
            }
        case .none:
            if let currentPlayItem = playItem,
                let currentPlayItemIdx = playList.firstIndex(where: { $0.url == currentPlayItem.url }),
                currentPlayItemIdx > 0 {
                nextPlayItem = playList[currentPlayItemIdx - 1]
            }
        }
        if let nextPlayItem = nextPlayItem {
            playItemSubject.send(nextPlayItem)
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
        var time = playTimeSeconds + seconds
        if (time >= duration) {
            time = duration.leftSide()
        }
        move(to: time)
    }

    func moveBackward(seconds: Double) {
        var time = playTimeSeconds - seconds
        if (time < 0) {
            time = 0
        }
        move(to: time)
    }
}

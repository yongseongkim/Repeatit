//
//  AudioPlayer.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import AVFoundation
import Combine
import Foundation

class AudioPlayer {
    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    // play time 변화 감지를 위해 AVPlayerItem 의 time 을 쓰지 않고 observer 를 이용하여 관리한다.
    private let playTimeSubject = CurrentValueSubject<Double, Never>(0)
    private let playItemSubject = CurrentValueSubject<AudioItem?, Never>(nil)
    private var cancellables: [AnyCancellable] = []

    fileprivate(set) var playItem: PlayItem?
    private var avPlayer: AVPlayer?
    private var avPlayerItem: AVPlayerItem?
    private var playTimeObserverToken: Any?
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
        stop()
    }

    // Do not call this method for play.
    // Just set item to currentPlayItemRelay.
    private func load(item: AudioItem) {
        // Remove previouse player
        clear()

        // Create new player
        avPlayer = AVPlayer(playerItem: AVPlayerItem(url: item.url))
        addPeriodicTimeObserver()
        avPlayer?.play()
        updateIsPlaying()
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

    private func updateIsPlaying() {
        isPlayingSubject.send(avPlayer?.isPlaying ?? false)
    }

    private func clear() {
        defer {
            avPlayer = nil
        }
        avPlayer?.pause()
        updateIsPlaying()
        removePeriodicTimeObserver()
    }
}

extension AudioPlayer: Player {
    var isPlaying: Bool { isPlayingSubject.value }
    var playTimeSeconds: Double { playTimeSubject.value.roundTo(place: 1) }
    var playTimeMillis: Int { Int(playTimeSeconds * 1000) }
    var duration: Double {
        guard let duration = avPlayer?.durationSeconds else { return 0 }
        return duration
    }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        isPlayingSubject.removeDuplicates().eraseToAnyPublisher()
    }

    var playTimePublisher: AnyPublisher<Double, Never> {
        playTimeSubject.eraseToAnyPublisher()
    }

    func togglePlay() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    func play(item: PlayItem) {
        playItem = item
        playItemSubject.send(AudioItem(url: item.url))
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

    func move(to: Double) {
        // 모든 move는 이 method를 call해야 한다. movedTime 관리를 위해
        var time = to
        if time < 0 {
            time = 0
        }
        if time > duration {
            time = duration.leftSide()
        }
        time = time.roundTo(place: 2)
        avPlayer?.seek(to: time)
        movedTime = time
    }

    func moveForward(by seconds: Double) {
        var time = playTimeSeconds + seconds
        if time >= duration {
            time = duration.leftSide()
        }
        move(to: time)
    }

    func moveBackward(by seconds: Double) {
        var time = playTimeSeconds - seconds
        if time < 0 {
            time = 0
        }
        move(to: time)
    }
}

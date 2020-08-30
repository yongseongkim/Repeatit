//
//  MediaPlayer.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import AVFoundation
import Combine
import Foundation

class MediaPlayer {
    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    private let playTimeSubject = CurrentValueSubject<Double, Never>(0)
    private var cancellables: [AnyCancellable] = []

    private let avPlayer = AVPlayer()
    private(set) var playItem: PlayItem? {
        didSet {
            stop()
            removePeriodicTimeObserver()
            // Set new item.
            if let newURL = playItem?.url {
                if avPlayer.currentItem?.url != newURL {
                    avPlayer.replaceCurrentItem(with: AVPlayerItem(url: newURL))
                }
                addPeriodicTimeObserver()
                isPlayingSubject.send(avPlayer.isPlaying)
            }
        }
    }
    private var playTimeObserverToken: Any?
    private var movedTime: Double?
    lazy var layer: AVPlayerLayer = {
        return AVPlayerLayer(player: avPlayer)
    }()

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func playerDidFinishPlaying() {
        stop()
    }

    private func addPeriodicTimeObserver() {
        playTimeObserverToken = avPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1/60, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main,
            using: { [weak self] time in
                // TODO: play 시간을 변경했지만 변경하기 전 시간이 emit 되면서 이상하게 동작한다.
                // 임시방편으로 변경하기 전 시간을 무시하는 코드를 넣는다.
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
        avPlayer.removeTimeObserver(playTimeObserverToken)
    }
}

extension MediaPlayer: Player {
    var isPlaying: Bool { isPlayingSubject.value }
    var playTimeSeconds: Double { playTimeSubject.value.roundTo(place: 1) }
    var playTimeMillis: Int { Int(playTimeSeconds * 1000) }
    var duration: Double { avPlayer.durationSeconds }

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
        resume()
    }

    func pause() {
        avPlayer.pause()
        isPlayingSubject.send(avPlayer.isPlaying)
        removePeriodicTimeObserver()
    }

    func resume() {
        addPeriodicTimeObserver()
        avPlayer.play()
        isPlayingSubject.send(avPlayer.isPlaying)
    }

    func stop() {
        move(to: 0)
        pause()
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
        avPlayer.seek(to: time)
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

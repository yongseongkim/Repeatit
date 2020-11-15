//
//  AudioClient.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import AVFoundation
import Combine
import ComposableArchitecture

struct AudioClient {
    let play: (AnyHashable, URL) -> Effect<Action, Failure>
    let resume: (AnyHashable) -> Void
    let pause: (AnyHashable) -> Void
    let move: (AnyHashable, Seconds) -> Void

    enum Action: Equatable {
        case durationDidChange(Seconds)
        case playingDidChange(Bool)
        case playTimeDidChange(Seconds)
    }

    enum Failure: Error, Equatable {
    }
}

extension AudioClient: PlayerControlClient {
}

extension AudioClient {
    static let production = AudioClient(
        play: { id, url in
            Effect.run { subscriber in
                let cancellable = AnyCancellable {
                    dependencies[id]?.pause()
                    dependencies[id] = nil
                }
                let audioPlayer = AudioClientDependencies(
                    url: url,
                    playTimeDidChange: { subscriber.send(.playTimeDidChange($0)) },
                    playingDidChange: { subscriber.send(.playingDidChange($0)) }
                )
                dependencies[id] = audioPlayer
                subscriber.send(.durationDidChange(audioPlayer.duration))
                audioPlayer.resume()
                return cancellable
            }
        },
        resume: { id in
            guard let player = dependencies[id] else { return }
            player.resume()
        },
        pause: { id in
            guard let player = dependencies[id] else { return }
            player.pause()
        },
        move: { id, seconds in
            guard let player = dependencies[id] else { return }
            player.move(to: seconds)
        }
    )

    static let mock = AudioClient(
        play: { _, _ in .none },
        resume: { _ in },
        pause: { _ in },
        move: { _, _ in }
    )
}

private var dependencies: [AnyHashable: AudioClientDependencies] = [:]

private class AudioClientDependencies: NSObject {
    // MARK: - Injected properties
    private let player: AVPlayer
    private let playTimeDidChange: (Seconds) -> Void
    private let playingDidChange: (Bool) -> Void
    // MARK: -

    private var playTimeObserverToken: Any?
    private var movedTime: Double?
    var duration: Seconds { player.durationSeconds }
    var playTime: Seconds { player.currentSeconds.roundTo(place: 2) }

    init(
        url: URL,
        playTimeDidChange: @escaping (Seconds) -> Void,
        playingDidChange: @escaping (Bool) -> Void
    ) {
        self.player = AVPlayer(url: url)
        self.playTimeDidChange = playTimeDidChange
        self.playingDidChange = playingDidChange
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        removePeriodicTimeObserver()
    }

    @objc func playerDidFinishPlaying() {
        playingDidChange(false)
    }

    func pause() {
        player.pause()
        removePeriodicTimeObserver()
        playingDidChange(false)
    }

    func resume() {
        addPeriodicTimeObserver()
        player.play()
        playingDidChange(true)
    }

    func move(to: Seconds) {
        // 모든 move는 이 method를 call해야 한다. movedTime 관리를 위해
        var time = to
        if time < 0 {
            time = 0
        }
        if time > duration {
            time = duration.leftSide()
        }
        time = time.roundTo(place: 2)
        player.seek(to: time)
        movedTime = time
    }

    private func addPeriodicTimeObserver() {
        playTimeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1/60, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main,
            using: { [weak self] time in
                // TODO: play 시간을 변경했지만 변경하기 전 시간이 emit 되면서 이상하게 동작한다.
                // 임시방편으로 변경하기 전 시간을 무시하는 코드를 넣는다.
                if let movedTime = self?.movedTime {
                    if abs(movedTime - time.seconds) < 1/60 {
                        self?.movedTime = nil
                    } else {
                        return
                    }
                }
                self?.playTimeDidChange(time.seconds)
            }
        )
    }

    private func removePeriodicTimeObserver() {
        defer {
            playTimeObserverToken = nil
        }
        guard let playTimeObserverToken = playTimeObserverToken else { return }
        player.removeTimeObserver(playTimeObserverToken)
    }
}

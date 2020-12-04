//
//  AudioClient.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import AVFoundation
import Combine
import ComposableArchitecture

struct LocalMediaClient {
    let open: (AnyHashable, URL) -> Effect<Action, Never>
    let resume: (AnyHashable) -> Void
    let pause: (AnyHashable) -> Void
    let move: (AnyHashable, Seconds) -> Void
    let moveForward: (AnyHashable, Seconds) -> Void
    let moveBackward: (AnyHashable, Seconds) -> Void

    enum Action: Equatable {
        case layerDidLoad(AVPlayerLayer)
        case durationDidChange(Seconds)
        case playingDidChange(Bool)
        case playTimeDidChange(Seconds)
    }
}

extension LocalMediaClient {
    static let production = LocalMediaClient(
        open: { id, url in
            Effect.run { subscriber in
                let cancellable = AnyCancellable {
                    dependencies[id]?.pause()
                    dependencies[id] = nil
                }
                let mediaDependencies = Dependencies(
                    url: url,
                    playingDidChange: { subscriber.send(.playingDidChange($0)) },
                    playTimeDidChange: { subscriber.send(.playTimeDidChange($0)) }
                )
                subscriber.send(.durationDidChange(mediaDependencies.duration))
                subscriber.send(.layerDidLoad(mediaDependencies.layer))
                mediaDependencies.resume()
                dependencies[id] = mediaDependencies
                return cancellable
            }
        },
        resume: { id in
            guard let mediaDependencies = dependencies[id] else { return }
            mediaDependencies.resume()
        },
        pause: { id in
            guard let mediaDependencies = dependencies[id] else { return }
            mediaDependencies.pause()
        },
        move: { id, seconds in
            guard let mediaDependencies = dependencies[id] else { return }
            mediaDependencies.move(to: seconds)
        },
        moveForward: { id, seconds in
            guard let mediaDependencies = dependencies[id] else { return }
            mediaDependencies.move(to: mediaDependencies.playTime + seconds)
        },
        moveBackward: { id, seconds in
            guard let mediaDependencies = dependencies[id] else { return }
            mediaDependencies.move(to: mediaDependencies.playTime - seconds)
        }
    )
}

private var dependencies: [AnyHashable: Dependencies] = [:]

private class Dependencies: NSObject {
    // MARK: - Injected properties
    private let player: AVPlayer
    private let playingDidChange: (Bool) -> Void
    private let playTimeDidChange: (Seconds) -> Void
    // MARK: -

    private var playTimeObserverToken: Any?
    private var movedTime: Double?
    lazy var layer: AVPlayerLayer = { AVPlayerLayer(player: player) }()
    var duration: Seconds { player.durationSeconds }
    var playTime: Seconds { player.currentSeconds.roundTo(place: 2) }

    init(
        url: URL,
        playingDidChange: @escaping (Bool) -> Void,
        playTimeDidChange: @escaping (Seconds) -> Void
    ) {
        self.player = AVPlayer(url: url)
        self.playingDidChange = playingDidChange
        self.playTimeDidChange = playTimeDidChange
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
        // Do not access avplayer for move to manage moved time.
        var time = to
        if time < 0 {
            time = 0
        }
        if time > duration {
            time = duration.leftSide()
        }
        time = time.roundTo(place: 2)
        player.seek(to: time)
        playTimeDidChange(time)
        movedTime = time
    }

    private func addPeriodicTimeObserver() {
        playTimeObserverToken = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 1/30, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
            queue: .main,
            using: { [weak self] time in
                // Ignore times emitted before calling move function.
                // TODO: To find better ways
                if let movedTime = self?.movedTime {
                    if abs(movedTime - time.seconds) < 1/30 {
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

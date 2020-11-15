//
//  YouTubeClient.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import Combine
import ComposableArchitecture
import youtube_ios_player_helper

struct YouTubeClient {
    let load: (AnyHashable, String) -> Effect<Action, Failure>
    let resume: (AnyHashable) -> Void
    let pause: (AnyHashable) -> Void
    let move: (AnyHashable, Seconds) -> Void

    enum Action: Equatable {
        case layerDidLoad(YTPlayerView)
        case durationDidChange(Seconds)
        case playingDidChange(Bool)
        case playTimeDidChange(Seconds)
    }

    enum Failure: Error, Equatable {
    }
}

extension YouTubeClient: PlayerControlClient {
}

extension YouTubeClient {
    static let production = YouTubeClient(
        load: { id, videoID in
            Effect.run { subscriber in
                let cancellable = AnyCancellable {
                    dependencies[id]?.pause()
                    dependencies[id] = nil
                }
                let client = YouTubeClientDependencies(
                    videoID: videoID,
                    durationDidLoad: { subscriber.send(.durationDidChange($0)) },
                    playTimeDidChange: { subscriber.send(.playTimeDidChange($0)) },
                    playingDidChange: { subscriber.send(.playingDidChange($0)) }
                )
                dependencies[id] = client
                subscriber.send(.layerDidLoad(client.view))
                return cancellable
            }
        },
        resume: { id in
            guard let client = dependencies[id] else { return }
            client.resume()
        },
        pause: { id in
            guard let client = dependencies[id] else { return }
            client.pause()
        },
        move: { id, seconds in
            guard let client = dependencies[id] else { return }
            client.move(to: seconds)
        }
    )
}

private var dependencies: [AnyHashable: YouTubeClientDependencies] = [:]

private class YouTubeClientDependencies: NSObject {
    // MARK: - Injected properties
    private let durationDidLoad: (Seconds) -> Void
    private let playTimeDidChange: (Seconds) -> Void
    private let playingDidChange: (Bool) -> Void
    // MARK: -
    let view = YTPlayerView()

    init(
        videoID: String,
        durationDidLoad: @escaping(Seconds) -> Void,
        playTimeDidChange: @escaping (Seconds) -> Void,
        playingDidChange: @escaping (Bool) -> Void
    ) {
        self.durationDidLoad = durationDidLoad
        self.playTimeDidChange = playTimeDidChange
        self.playingDidChange = playingDidChange
        super.init()
        // https://developers.google.com/youtube/player_parameters?hl=ko#Parameters
        view.load(
            withVideoId: videoID,
            playerVars: [
                "controls": 1,
                "playsinline": 1,
                "cc_load_policy": 1
            ]
        )
    }

    @objc func playerDidFinishPlaying() {
        playingDidChange(false)
    }

    func pause() {
        view.pauseVideo()
        playingDidChange(false)
    }

    func resume() {
        view.playVideo()
        playingDidChange(true)
    }

    func move(to: Seconds) {
        view.seek(toSeconds: Float(to), allowSeekAhead: true)
    }
}

extension YouTubeClientDependencies: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playingDidChange(false)
        playerView.duration { [weak self] time, _ in
            self?.durationDidLoad(time)
        }
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        playingDidChange(state == .playing)
    }

    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        playTimeDidChange(Double(playTime))
    }
}

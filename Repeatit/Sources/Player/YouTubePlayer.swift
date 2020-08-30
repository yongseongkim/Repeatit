//
//  YouTubePlayer.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import Combine
import SwiftUI
import youtube_ios_player_helper

class YouTubePlayer: NSObject, YTPlayerViewDelegate {
    fileprivate(set) var playItem: PlayItem?
    fileprivate(set) var playerView: YTPlayerView? {
        didSet { load() }
    }
    let stateSubject = CurrentValueSubject<YTPlayerState, Never>(.unstarted)
    let playTimeSubject = CurrentValueSubject<Double, Never>(0)
    let durationSubject = CurrentValueSubject<Double, Never>(0)
    var state: YTPlayerState { stateSubject.value }

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        stateSubject.send(.paused)
        playerView.duration { [weak self] time, _ in
            self?.durationSubject.send(time)
        }
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        stateSubject.send(state)
    }

    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        playTimeSubject.send(Double(playTime))
    }

    fileprivate func load() {
        guard let item = self.playItem, let videoId = YouTubeItem.from(item: item)?.videoId else { return }
        // https://developers.google.com/youtube/player_parameters?hl=ko#Parameters
        playerView?.load(
            withVideoId: videoId,
            playerVars: [
                "controls": 1,
                "playsinline": 1,
                "cc_load_policy": 1
            ]
        )
    }
}

extension YouTubePlayer: Player {
    var isPlaying: Bool { state == .playing }
    var playTimeSeconds: Double { playTimeSubject.value.roundTo(place: 1) }
    var playTimeMillis: Int { Int(playTimeSeconds * 1000) }
    var duration: Double { durationSubject.value }

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        stateSubject.map { $0 == .playing }.removeDuplicates().eraseToAnyPublisher()
    }
    var playTimePublisher: AnyPublisher<Double, Never> { playTimeSubject.eraseToAnyPublisher() }

    func togglePlay() {
        switch stateSubject.value {
        case .paused:
            playerView?.playVideo()
        case .playing:
            playerView?.pauseVideo()
        default:
            break
        }
    }

    func play(item: PlayItem) {
        playItem = item
        load()
        resume()
    }

    func pause() {
        playerView?.pauseVideo()
    }

    func resume() {
        playerView?.playVideo()
    }

    func stop() {
        playerView?.stopVideo()
    }

    func move(to: Double) {
        playerView?.seek(toSeconds: Float(to), allowSeekAhead: true)
    }

    func moveForward(by seconds: Double) {
        let currentTime = playTimeSubject.value
        move(to: currentTime + seconds)
    }

    func moveBackward(by seconds: Double) {
        let currentTime = playTimeSubject.value
        move(to: currentTime - seconds)
    }
}

struct YouTubeContentView: UIViewRepresentable {
    let youtubePlayer: YouTubePlayer

    func makeUIView(context: Context) -> YouTubeContentUIView {
        let uiView = YouTubeContentUIView()
        youtubePlayer.playerView = uiView.playerView
        uiView.playerView.delegate = youtubePlayer
        return uiView
    }

    func updateUIView(_ uiView: YouTubeContentUIView, context: Context) {
    }
}

class YouTubeContentUIView: UIView {
    fileprivate let playerView = YTPlayerView()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playerView)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerView.frame = self.frame
    }
}

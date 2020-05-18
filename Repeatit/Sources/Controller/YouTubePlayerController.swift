//
//  YouTubePlayerController.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import Combine
import SwiftUI
import youtube_ios_player_helper

class YouTubePlayerController: NSObject, YTPlayerViewDelegate {
    let videoId: String

    fileprivate(set) var playerView: YTPlayerView?
    let stateSubject = CurrentValueSubject<YTPlayerState, Never>(.unstarted)
    let playTimeSubject = CurrentValueSubject<Double, Never>(0)
    let durationSubject = CurrentValueSubject<Double, Never>(0)

    var state: YTPlayerState { stateSubject.value }
    var playTimeSeconds: Double { playTimeSubject.value.roundTo(place: 1) }
    var playTimeMillis: Int { Int(playTimeSeconds * 1000) }
    var duration: Double { durationSubject.value }

    init(videoId: String) {
        self.videoId = videoId
    }

    func load() {
        // https://developers.google.com/youtube/player_parameters?hl=ko#Parameters
        playerView?.load(
            withVideoId: videoId,
            playerVars: [
                "controls": 0,
                "playsinline": 1,
                "cc_load_policy": 1
            ]
        )
    }

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

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        stateSubject.send(.paused)
        durationSubject.send(playerView.duration())
    }

    func playerView(_ playerView: YTPlayerView, didChangeTo state: YTPlayerState) {
        stateSubject.send(state)
    }

    func playerView(_ playerView: YTPlayerView, didPlayTime playTime: Float) {
        playTimeSubject.send(Double(playTime))
    }

}

struct YouTubeView: UIViewRepresentable {
    let playerController: YouTubePlayerController

    func makeUIView(context: Context) -> YouTubeContentView {
        let contentView = YouTubeContentView()
        playerController.playerView = contentView.playerView
        contentView.playerView.delegate = playerController
        return contentView
    }

    func updateUIView(_ uiView: YouTubeContentView, context: Context) {
    }
}

class YouTubeContentView: UIView {
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

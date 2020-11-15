//
//  VideoPlayerCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/25.
//

import AVFoundation
import Combine
import ComposableArchitecture
import UIKit

struct VideoClientID: Hashable {}

enum VideoPlayerAction: Equatable {
    case play
    case move(to: Seconds)

    case player(Result<VideoClient.Action, VideoClient.Failure>)
    case playerControl(PlayerControlAction)
}

struct VideoPlayerState: Equatable {
    let current: Document
    var videoLayer: AVPlayerLayer? = nil
    var isPlaying: Bool = false
    var playTimeSeconds: Double = 0
    var durationSeconds: Double = 0
    var playerControl: PlayerControlState
}

struct VideoPlayerEnvironment {
    let videoClient: VideoClient
}

let videoPlayerReducer = Reducer<VideoPlayerState, VideoPlayerAction, VideoPlayerEnvironment> {
    state, action, environment in
    switch action {
    case .play:
        let url = state.current.url
        return environment.videoClient.play(VideoClientID(), state.current.url)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(VideoPlayerAction.player)
            .eraseToEffect()
            .cancellable(id: VideoClientID())
    case .move(let seconds):
        environment.videoClient.move(VideoClientID(), seconds)
        return .none
    case .player(.success(.layerDidLoad(let layer))):
        state.videoLayer = layer
        return .none
    case .player(.success(.durationDidChange(let seconds))):
        state.durationSeconds = seconds
        return .none
    case .player(.success(.playingDidChange(let isPlaying))):
        state.isPlaying = isPlaying
        state.playerControl = state
            .playerControl
            .updated(isPlaying: isPlaying)
        return .none
    case .player(.success(.playTimeDidChange(let seconds))):
        state.playTimeSeconds = seconds
        state.playerControl = state
            .playerControl
            .updated(playTime: seconds)
        return .none
    case .playerControl:
        return .none
    }
}
.playerControl(
    state: \.playerControl,
    action: /VideoPlayerAction.playerControl,
    environment: { PlayerControlEnvironment(client: $0.videoClient) }
)
.lifecycle(
    onAppear: { _ in Effect(value: .play) },
    onDisappear: { _ in .cancel(id: VideoClientID()) }
)

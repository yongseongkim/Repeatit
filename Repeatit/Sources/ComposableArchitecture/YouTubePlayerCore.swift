//
//  YouTubePlayerCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/25.
//

import ComposableArchitecture
import youtube_ios_player_helper

struct YouTubeClientID: Hashable {}

// MARK: - Composable Architecture Components
enum YouTubePlayerAction: Equatable {
    case load

    case player(Result<YouTubeClient.Action, YouTubeClient.Failure>)
    case playerControl(PlayerControlAction)
    case bookmark(BookmarkAction)
}

struct YouTubePlayerState: Equatable {
    let current: Document
    var playerView: YTPlayerView?

    var playerControl: PlayerControlState
    var bookmark: BookmarkState
}

struct YouTubePlayerEnvironment {
    let youtubeClient: YouTubeClient
    let bookmarkClient: BookmarkClient
}
//MARK: -

let youtubePlayerReducer = Reducer<YouTubePlayerState, YouTubePlayerAction, YouTubePlayerEnvironment> { state, action, environment in
    switch action {
    case .load:
        let id = state.current.toYouTubeItem().id
        return environment.youtubeClient.load(YouTubeClientID(), id)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(YouTubePlayerAction.player)
            .eraseToEffect()
            .cancellable(id: AudioClientID())
    case .player(.success(.layerDidLoad(let view))):
        state.playerView = view
        return .none
    case .player(.success(.durationDidChange(let seconds))):
        return .none
    case .player(.success(.playingDidChange(let isPlaying))):
        state.playerControl = state
            .playerControl
            .updated(isPlaying: isPlaying)
        return .none
    case .player(.success(.playTimeDidChange)):
        return .none
    case .playerControl:
        return .none
    case .bookmark:
        return .none
    }
}
.playerControl(
    state: \.playerControl,
    action: /YouTubePlayerAction.playerControl,
    environment: { PlayerControlEnvironment(client: $0.youtubeClient) }
)
.bookmark(
    state: \.bookmark,
    action: /YouTubePlayerAction.bookmark,
    environment: {
        BookmarkEnvironment(
            bookmarkClient: $0.bookmarkClient,
            player: $0.youtubeClient
        )
    }
)
.lifecycle(
    onAppear: { _ in Effect(value: .load) },
    onDisappear: { _ in .cancel(id: YouTubeClientID()) }
)

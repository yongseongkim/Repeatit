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
        state.playerControl = PlayerControlState(isPlaying: isPlaying)
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
    environment: { environment in
        PlayerControlEnvironment(
            resume: { environment.youtubeClient.resume(YouTubeClientID()) },
            pause: { environment.youtubeClient.pause(YouTubeClientID()) },
            moveForward: { environment.youtubeClient.moveForward(YouTubeClientID(), $0) },
            moveBackward: { environment.youtubeClient.moveBackward(YouTubeClientID(), $0) }
        )
    }
)
.bookmark(
    state: \.bookmark,
    action: /YouTubePlayerAction.bookmark,
    environment: {
        BookmarkEnvironment(
            move: { _ in },
            bookmarkClient: $0.bookmarkClient
        )
    }
)
.lifecycle(
    onAppear: { _ in Effect(value: .load) },
    onDisappear: { _ in .cancel(id: YouTubeClientID()) }
)

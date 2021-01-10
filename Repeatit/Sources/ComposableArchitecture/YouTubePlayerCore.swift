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
    case bookmarkControl(Result<BookmarkClient.Action, BookmarkClient.Failure>)
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
            .cancellable(id: YouTubeClientID())
    case .player(.success(.layerDidLoad(let view))):
        state.playerView = view
        return .none
    case .player(.success(.durationDidChange(let seconds))):
        return environment.bookmarkClient.load(state.current, Int(seconds * 1000))
            .first()
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(YouTubePlayerAction.bookmarkControl)
            .eraseToEffect()
            .cancellable(id: BookmarkClientID())
    case .player(.success(.playingDidChange(let isPlaying))):
        state.playerControl = PlayerControlState(isPlaying: isPlaying)
        return .none
    case .player(.success(.playTimeDidChange(let playTime))):
        state.bookmark.playTime = playTime
        return .none
    case .playerControl:
        return .none
    case .bookmark:
        return .none
    case .bookmarkControl(.success(.bookmarksDidChange(let bookmarks))):
        state.bookmark = .init(current: state.current, bookmarks: bookmarks)
        return .none
    case .bookmarkControl(.failure):
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

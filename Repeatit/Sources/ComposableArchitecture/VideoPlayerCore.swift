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

// MARK: - Composable Architecture Components
enum VideoPlayerAction: Equatable {
    case open

    // Environment
    case player(Result<LocalMediaClient.Action, Never>)
    // Reusable reducers
    case playerControl(PlayerControlAction)
    case bookmark(BookmarkAction)
    case bookmarkControl(Result<BookmarkClient.Action, BookmarkClient.Failure>)
}

struct VideoPlayerState: Equatable {
    let current: Document
    var videoLayer: AVPlayerLayer? = nil
    var playerControl: PlayerControlState
    var bookmark: BookmarkState
}

struct VideoPlayerEnvironment {
    let videoClient: LocalMediaClient
    let bookmarkClient: BookmarkClient
}
// MARK: -

let videoPlayerReducer = Reducer<VideoPlayerState, VideoPlayerAction, VideoPlayerEnvironment> {
    state, action, environment in
    switch action {
    case .open:
        return environment.videoClient.open(VideoClientID(), state.current.url)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(VideoPlayerAction.player)
            .eraseToEffect()
            .cancellable(id: VideoClientID())
    case .player(.success(.layerDidLoad(let layer))):
        state.videoLayer = layer
        return .none
    case .player(.success(.durationDidChange(let seconds))):
        return environment.bookmarkClient.load(state.current, Int(seconds * 1000))
            .first()
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(VideoPlayerAction.bookmarkControl)
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
    action: /VideoPlayerAction.playerControl,
    environment: { environment in
        PlayerControlEnvironment(
            resume: { environment.videoClient.resume(VideoClientID()) },
            pause: { environment.videoClient.pause(VideoClientID()) },
            moveForward: { environment.videoClient.moveForward(VideoClientID(), $0) },
            moveBackward: { environment.videoClient.moveBackward(VideoClientID(), $0) }
        )
    }
)
.bookmark(
    state: \.bookmark,
    action: /VideoPlayerAction.bookmark,
    environment: {
        BookmarkEnvironment(
            move: { _ in },
            bookmarkClient: $0.bookmarkClient
        )
    }
)
.lifecycle(
    onAppear: { _ in Effect(value: .open) },
    onDisappear: { _ in .cancel(id: VideoClientID()) }
)

//
//  AudioPlayerCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/25.
//

import AVFoundation
import Combine
import ComposableArchitecture
import UIKit

struct AudioClientID: Hashable {}
struct WaveformClientID: Hashable {}

// MARK: - Composable Architecture Components
enum AudioPlayerAction: Equatable {
    case play
    case loadWaveform(WaveformBarOption)
    case resume
    case pause
    case move(to: Seconds)

    case player(Result<AudioClient.Action, AudioClient.Failure>)
    case waveform(Result<UIImage, WaveformClient.Failure>)
    case playerControl(PlayerControlAction)
    case bookmark(BookmarkAction)
}

struct AudioPlayerState: Equatable {
    let current: Document
    var waveformImage: UIImage? = nil
    var isPlaying: Bool = false
    var playTimeSeconds: Double = 0
    var durationSeconds: Double = 0

    var playerControl: PlayerControlState
    var bookmark: BookmarkState
}

struct AudioPlayerEnvironment {
    let audioClient: AudioClient
    let waveformClient: WaveformClient
    let bookmarkClient: BookmarkClient
}
// MARK: -

let audioPlayerReducer = Reducer<AudioPlayerState, AudioPlayerAction, AudioPlayerEnvironment> {
    state, action, environment in
    switch action {
    case .play:
        let url = state.current.url
        return environment.audioClient.play(AudioClientID(), state.current.url)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(AudioPlayerAction.player)
            .eraseToEffect()
            .cancellable(id: AudioClientID())
    case .loadWaveform(let option):
        let url = state.current.url
        return environment.waveformClient.loadWaveform(url, option)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(AudioPlayerAction.waveform)
            .cancellable(id: WaveformClientID())
    case .resume:
        environment.audioClient.resume(AudioClientID())
        return .none
    case .pause:
        environment.audioClient.pause(AudioClientID())
        return .none
    case .move(let seconds):
        environment.audioClient.move(AudioClientID(), seconds)
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
        state.bookmark = state
            .bookmark
            .updated(playTime: seconds)
        return .none
    case .waveform(.success(let waveformImage)):
        state.waveformImage = waveformImage
        return .none
    case .waveform(.failure(.couldntLoadWaveform)):
        state.waveformImage = nil
        return .none
    case .playerControl:
        return .none
    case .bookmark:
        return .none
    }
}
.playerControl(
    state: \.playerControl,
    action: /AudioPlayerAction.playerControl,
    environment: { PlayerControlEnvironment(client: $0.audioClient) }
)
.bookmark(
    state: \.bookmark,
    action: /AudioPlayerAction.bookmark,
    environment: { BookmarkEnvironment(bookmarkClient: $0.bookmarkClient) }
)
.lifecycle(
    onAppear: { _ in Effect(value: .play) },
    onDisappear: { _ in .cancel(id: AudioClientID()) }
)

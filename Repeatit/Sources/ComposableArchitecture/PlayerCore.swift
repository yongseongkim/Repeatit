//
//  PlayerCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/14.
//

import ComposableArchitecture
import AVFoundation

enum PlayerAction: Equatable {
    case playButtonTapped
    case moveForward(seconds: Double)
    case isPlayingChanged(Bool)
    case isPlayTimeChanged(Double)
}

struct PlayerState: Equatable {
    var current: Document
    var isPlaying: Bool
    var playTime: Double
    var duration: Int
}

struct PlayerEnvironment {
    let player: Player
}

let playerReducer = Reducer<PlayerState, PlayerAction, PlayerEnvironment> { state, action, environment in
    switch action {
    case .playButtonTapped:
        state.isPlaying.toggle()
        state.isPlaying ? environment.player.resume() : environment.player.pause()
        return environment.player.isPlayingPublisher
            .receive(on: DispatchQueue.main)
            .map { PlayerAction.isPlayingChanged($0) }
            .eraseToEffect()
    case .moveForward(let seconds):
        environment.player.moveForward(by: seconds)
        return environment.player.playTimePublisher
            .receive(on: DispatchQueue.main)
            .map { PlayerAction.isPlayTimeChanged($0) }
            .eraseToEffect()
    case .isPlayingChanged(let isPlaying):
        state.isPlaying = isPlaying
    case .isPlayTimeChanged(let playTime):
        state.playTime = playTime
    }
    return .none
}
.debug()

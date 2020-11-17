//
//  PlayerControlCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import ComposableArchitecture

struct PlayerControlState: Equatable {
    var playerID: AnyHashable
    var isPlaying: Bool = false

    func updated(isPlaying: Bool? = nil) -> PlayerControlState {
        return .init(
            playerID: playerID,
            isPlaying: isPlaying ?? self.isPlaying
        )
    }
}

enum PlayerControlAction: Equatable {
    case togglePlay
    case moveForward(by: Seconds)
    case moveBackward(by: Seconds)
}

struct PlayerControlEnvironment {
    let client: PlayerControlClient
}

extension Reducer {
    func playerControl(
        state: WritableKeyPath<State, PlayerControlState>,
        action: CasePath<Action, PlayerControlAction>,
        environment: @escaping (Environment) -> PlayerControlEnvironment
    ) -> Reducer {
        .combine(
            self,
            Reducer<PlayerControlState, PlayerControlAction, PlayerControlEnvironment> { state, action, environment in
                switch action {
                case .togglePlay:
                    state.isPlaying
                        ? environment.client.pause(state.playerID)
                        : environment.client.resume(state.playerID)
                    return .none
                case .moveForward(let seconds):
                    let millis = environment.client.playTimeMillis(state.playerID)
                    environment.client.move(state.playerID, (Double(millis) / 1000) + seconds)
                    return .none
                case .moveBackward(let seconds):
                    let millis = environment.client.playTimeMillis(state.playerID)
                    environment.client.move(state.playerID, (Double(millis) / 1000) - seconds)
                    return .none
                }
            }
            .pullback(state: state, action: action, environment: environment)
        )
    }
}


//
//  PlayerControlCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import ComposableArchitecture

struct PlayerControlState: Equatable {
    var id: AnyHashable
    var isPlaying: Bool = false
    var playTime: Seconds = 0

    func updated(isPlaying: Bool? = nil, playTime: Seconds? = nil) -> PlayerControlState {
        return .init(
            id: id,
            isPlaying: isPlaying ?? self.isPlaying,
            playTime: playTime ?? self.playTime
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
                        ? environment.client.pause(state.id)
                        : environment.client.resume(state.id)
                    return .none
                case .moveForward(let seconds):
                    environment.client.move(state.id, state.playTime + seconds)
                    return .none
                case .moveBackward(let seconds):
                    environment.client.move(state.id, state.playTime - seconds)
                    return .none
                }
            }
            .pullback(state: state, action: action, environment: environment)
        )
    }
}


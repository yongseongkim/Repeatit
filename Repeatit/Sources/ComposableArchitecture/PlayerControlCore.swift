//
//  PlayerControlCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import ComposableArchitecture

struct PlayerControlState: Equatable {
    var isPlaying: Bool = false
}

enum PlayerControlAction: Equatable {
    case togglePlay
    case moveForward(by: Seconds)
    case moveBackward(by: Seconds)
}

struct PlayerControlEnvironment {
    let resume: () -> Void
    let pause: () -> Void
    let moveForward: (Seconds) -> Void
    let moveBackward: (Seconds) -> Void
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
                        ? environment.pause()
                        : environment.resume()
                    return .none
                case .moveForward(let seconds):
                    environment.moveForward(seconds)
                    return .none
                case .moveBackward(let seconds):
                    environment.moveBackward(seconds)
                    return .none
                }
            }
            .pullback(state: state, action: action, environment: environment)
        )
    }
}

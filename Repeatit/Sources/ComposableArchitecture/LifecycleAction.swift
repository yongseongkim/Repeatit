//
//  LifecycleAction.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import ComposableArchitecture

enum LifecycleAction<Action> {
    case onAppear
    case onDisappear
    case action(Action)
}

extension LifecycleAction: Equatable where Action: Equatable {}

extension Reducer {
    func lifecycle(
        onAppear: @escaping (Environment) -> Effect<Action, Never>,
        onDisappear: @escaping (Environment) -> Effect<Never, Never>
    ) -> Reducer<State?, LifecycleAction<Action>, Environment> {
        return .init { state, action, environment in
            switch action {
            case .onAppear:
                return onAppear(environment).map(LifecycleAction.action)
            case .onDisappear:
                return onDisappear(environment).fireAndForget()
            case .action(let action):
                guard state != nil else { return .none }
                return self.run(&state!, action, environment)
                    .map(LifecycleAction.action)
            }
        }
    }
}

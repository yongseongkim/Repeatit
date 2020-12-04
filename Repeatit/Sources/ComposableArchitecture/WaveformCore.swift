//
//  WaveformCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/20.
//

import ComposableArchitecture
import UIKit

// MARK: - Composable Architecture Components
enum WaveformAction: Equatable {
    case load(WaveformBarOption)
    case resume
    case pause
    case move(to: Seconds)

    // Environment
    case waveformClient(Result<UIImage, WaveformClient.Failure>)
}

struct WaveformState: Equatable {
    let current: Document
    var waveformImage: UIImage? = nil
    var isPlaying: Bool = false
    var playTime: Seconds = 0
    var duration: Seconds = 0

    func updated(
        isPlaying: Bool? = nil,
        playTime: Seconds? = nil,
        duration: Seconds? = nil
    ) -> WaveformState {
        return .init(
            current: self.current,
            waveformImage: self.waveformImage,
            isPlaying: isPlaying ?? self.isPlaying,
            playTime: playTime ?? self.playTime,
            duration: duration ?? self.duration
        )
    }
}

struct WaveformEnvironment {
    let resume: () -> Void
    let pause: () -> Void
    let move: (Seconds) -> Void
    let waveformClient: WaveformClient
}
// MARK: -

let waveformReducer = Reducer<WaveformState, WaveformAction, WaveformEnvironment> {
    state, action, environment in
    switch action {
    case .load(let option):
        let url = state.current.url
        return environment.waveformClient.load(url, option)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(WaveformAction.waveformClient)
    case .resume:
        environment.resume()
        return .none
    case .pause:
        environment.pause()
        return .none
    case .move(let seconds):
        environment.move(seconds)
        return .none
    case .waveformClient(.success(let waveformImage)):
        state.waveformImage = waveformImage
        return .none
    case .waveformClient(.failure(.couldntLoadWaveform)):
        state.waveformImage = nil
        return .none
    }
}

extension Reducer {
    func waveform(
        state: WritableKeyPath<State, WaveformState>,
        action: CasePath<Action, WaveformAction>,
        environment: @escaping (Environment) -> WaveformEnvironment
    ) -> Reducer {
        .combine(
            self,
            waveformReducer
                .pullback(state: state, action: action, environment: environment)
        )
    }
}


//
//  AppCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/13.
//

import ComposableArchitecture

enum AppAction: Equatable {
    // Integrate other reducers
    case documentExplorer(DocumentExplorerAction)
    case player(PlayerAction)

    // Set presntation of sheets
    case setPlayerSheet(isPresented: Bool)
}

struct AppState: Equatable {
    var documentExplorer: DocumentExplorerState
    var player: PlayerState?
}

struct AppEnvironment {
    let fileManager: FileManager = .default
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    documentExplorerReducer
        .pullback(
            state: \.documentExplorer,
            action: /AppAction.documentExplorer,
            environment: { DocumentExplorerEnvironment(fileManager: $0.fileManager) }
        ),
    playerReducer
        .optional()
        .pullback(
            state: \.player,
            action: /AppAction.player,
            environment: { _ in PlayerEnvironment(player: MediaPlayer()) }
        ),
    Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        switch action {
        case .documentExplorer(let action):
            switch action {
            case .documentTapped(let document):
                state.player = PlayerState(
                    current: document,
                    isPlaying: false,
                    playTime: 0,
                    duration: 0
                )
            default:
                break
            }
            return .none
        case .player(let action):
            return .none
        case .setPlayerSheet(false):
            state.player = nil
            return .none
        default:
            return .none
        }
    }
    .debug()
)

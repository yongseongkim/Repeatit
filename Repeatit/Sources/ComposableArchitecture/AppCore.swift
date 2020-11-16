//
//  AppCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/13.
//

import Combine
import ComposableArchitecture

enum AppAction: Equatable {
    // Integrate other reducers
    case documentExplorer(DocumentExplorerAction)
    case audioPlayer(LifecycleAction<AudioPlayerAction>)
    case videoPlayer(LifecycleAction<VideoPlayerAction>)
    case youtubePlayer(LifecycleAction<YouTubePlayerAction>)

    // Set presntation of sheets
    case setPlayerSheet(isPresented: Bool)
}

struct AppState: Equatable {
    var documentExplorer: DocumentExplorerState
    var audioPlayer: AudioPlayerState?
    var videoPlayer: VideoPlayerState?
    var youtubePlayer: YouTubePlayerState?
}

struct AppEnvironment {
    static let production = AppEnvironment(
        fileManager: .default
    )

    let fileManager: FileManager
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
    documentExplorerReducer
        .pullback(
            state: \.documentExplorer,
            action: /AppAction.documentExplorer,
            environment: { DocumentExplorerEnvironment(fileManager: $0.fileManager) }
        ),
    audioPlayerReducer
        .pullback(
            state: \.audioPlayer,
            action: /AppAction.audioPlayer,
            environment: { _ in
                AudioPlayerEnvironment(
                    audioClient: .production,
                    waveformClient: .production,
                    bookmarkClient: .production
                )
            }
        ),
    videoPlayerReducer
        .pullback(
            state: \.videoPlayer,
            action: /AppAction.videoPlayer,
            environment: { _ in
                VideoPlayerEnvironment(
                    videoClient: .production,
                    bookmarkClient: .production
                )
            }
        ),
    youtubePlayerReducer
        .pullback(
            state: \.youtubePlayer,
            action: /AppAction.youtubePlayer,
            environment: { _ in
                YouTubePlayerEnvironment(
                    youtubeClient: .production,
                    bookmarkClient: .production
                )
            }
        ),
    Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
        switch action {
        case .documentExplorer(let action):
            switch action {
            case .documentTapped(let document):
                if document.isAudioFile {
                    state.audioPlayer = .init(
                        current: document,
                        playerControl: .init(
                            id: AudioClientID()
                        ),
                        bookmark: .init(current: document)
                    )
                } else if document.isVideoFile {
                    state.videoPlayer = .init(
                        current: document,
                        playerControl: .init(id: VideoClientID()),
                        bookmark: .init(current: document)
                    )
                } else if document.isYouTubeFile {
                    state.youtubePlayer = .init(
                        current: document,
                        playerView: nil,
                        playerControl: .init(id: YouTubeClientID()),
                        bookmark: .init(current: document)
                    )
                }
            default:
                break
            }
            return .none
        case .setPlayerSheet(false):
            state.audioPlayer = nil
            state.videoPlayer = nil
            state.youtubePlayer = nil
            return .none
        default:
            return .none
        }
    }
)

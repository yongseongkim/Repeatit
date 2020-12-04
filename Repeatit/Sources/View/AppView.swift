//
//  RootView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/06.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(
            store,
            removeDuplicates: {
                $0.textContents == $1.textContents
                    && $0.audioPlayer == $1.audioPlayer
                    && $0.videoPlayer == $1.videoPlayer
                    && $0.youtubePlayer == $1.youtubePlayer
            }
        ) { viewStore in
            DocumentExplorerView(
                store: store.scope(
                    state: { $0.documentExplorer },
                    action: AppAction.documentExplorer
                )
            )
            .background(
                EmptyView().sheet(
                    isPresented: viewStore.binding(
                        get: { $0.textContents != nil },
                        send: AppAction.setPlayerSheet(isPresented:)
                    ),
                    content: { TextContentsView(value: viewStore.textContents ?? .empty) }
                )
            )
            .background(
                EmptyView().sheet(
                    isPresented: viewStore.binding(
                        get: { $0.audioPlayer != nil },
                        send: AppAction.setPlayerSheet(isPresented:)
                    ),
                    content: {
                        IfLetStore(
                            store.scope(
                                state: { $0.audioPlayer },
                                action: AppAction.audioPlayer
                            )
                        ) { AudioPlayerView(store: $0) }
                    }
                )
            )
            .background(
                EmptyView().sheet(
                    isPresented: viewStore.binding(
                        get: { $0.videoPlayer != nil },
                        send: AppAction.setPlayerSheet(isPresented:)
                    ),
                    content: {
                        IfLetStore(
                            store.scope(
                                state: { $0.videoPlayer },
                                action: AppAction.videoPlayer
                            )
                        ) { VideoPlayerView(store: $0) }
                    }
                )
            )
            .background(
                EmptyView().sheet(
                    isPresented: viewStore.binding(
                        get: { $0.youtubePlayer != nil },
                        send: AppAction.setPlayerSheet(isPresented:)
                    ),
                    content: {
                        IfLetStore(
                            store.scope(
                                state: { $0.youtubePlayer },
                                action: AppAction.youtubePlayer)
                        ) { YouTubePlayerView(store: $0) }
                    }
                )
            )
        }
    }
}

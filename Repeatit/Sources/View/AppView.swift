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
        WithViewStore(store) { viewStore in
            IfLetStore(store.scope(state: { $0.documentExplorer }, action: AppAction.documentExplorer)) { store in
                DocumentExplorer(store: store)
            }
            .background(
                EmptyView().sheet(
                    isPresented: viewStore.binding(
                        get: { $0.textContents != nil },
                        send: AppAction.setPlayerSheet(isPresented:)
                    ),
                    content: {
                        TextContentsView(
                            value: viewStore.textContents ?? .empty
                        )
                    }
                )
            )
            .background(
                EmptyView().sheet(
                    isPresented: viewStore.binding(
                        get: { $0.audioPlayer != nil },
                        send: AppAction.setPlayerSheet(isPresented:)
                    ),
                    content: {
                        IfLetStore(store.scope(state: { $0.audioPlayer }, action: AppAction.audioPlayer)) {
                            AudioPlayerView(store: $0)
                        }
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
                        ) {
                            VideoPlayerView(store: $0)
                        }
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
                        IfLetStore(store.scope(state: { $0.youtubePlayer }, action: AppAction.youtubePlayer)) {
                            YouTubePlayerView(store: $0)
                        }
                    }
                )
            )
        }
    }
}

//struct AppView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppView(
//            store: Store(
//                initialState: AppState(
//                    documentExplorer: DocumentExplorerState(
//                        currentURL: URL.homeDirectory,
//                        documents: [:],
//                        selectedDocuments: []
//                    )
//                ),
//                reducer: appReducer,
//                environment: AppEnvironment()
//            )
//        )
//    }
//}

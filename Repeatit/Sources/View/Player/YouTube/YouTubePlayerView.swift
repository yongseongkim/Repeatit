//
//  YouTubePlayerView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/06.
//

import ComposableArchitecture
import SwiftUI

struct YouTubePlayerView: View {
    let store: Store<YouTubePlayerState, LifecycleAction<YouTubePlayerAction>>

    @State var keyboardHeight: CGFloat = 0

    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if let playerView = viewStore.playerView {
                        YouTubeContentView(youtubeLayer: playerView)
                            .frame(height: ceil(geometry.size.width * 9 / 16), alignment: .top)
                            .background(Color.systemGray4)
                    }
                    PlayerControlView(
                        store: store.scope(
                            state: { $0.playerControl },
                            action: { LifecycleAction.action(YouTubePlayerAction.playerControl($0)) }
                        )
                    )
                    BookmarkListView(
                        store: store.scope(
                            state: { $0.bookmark },
                            action: { LifecycleAction.action(YouTubePlayerAction.bookmark($0)) }
                        )
                    )
                }
            }
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
        }
        .modifier(KeyboardHeightDetector(self.$keyboardHeight))
    }
}

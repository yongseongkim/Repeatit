//
//  VideoPlayerView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/06.
//

import ComposableArchitecture
import SwiftUI

struct VideoPlayerView: View {
    let store: Store<VideoPlayerState, LifecycleAction<VideoPlayerAction>>

    @State var keyboardHeight: CGFloat = 0

    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    if let videoLayer = viewStore.videoLayer {
                        AVPlayerView(videoLayer: videoLayer)
                            .frame(height: ceil(geometry.size.width * 9 / 16), alignment: .top)
                            .background(Color.systemGray4)
                    }
                    PlayerControlView(
                        store: store.scope(
                            state: { $0.playerControl },
                            action: { LifecycleAction.action(VideoPlayerAction.playerControl($0)) }
                        )
                    )
                }
            }
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
        }
    }
}

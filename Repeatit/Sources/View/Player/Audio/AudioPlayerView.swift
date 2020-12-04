//
//  AudioPlayerView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/25.
//

import ComposableArchitecture
import SwiftUI

struct AudioPlayerView: View {
    let store: Store<AudioPlayerState, LifecycleAction<AudioPlayerAction>>

    @State var keyboardHeight: CGFloat = 0

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                VStack(spacing: 0) {
                    if keyboardHeight > 0 {
                        AudioPlayerSimpleHeaderView(
                            model: .init(metadata: viewStore.current.metadata)
                        )
                        AudioPlayerWaveformView(
                            store: store.scope(
                                state: { $0.waveform },
                                action: { LifecycleAction.action(AudioPlayerAction.waveform($0)) }
                            ),
                            waveformOption: .init(width: 2, interval: 1, maxHeight: 70, style: .up)
                        )
                        .frame(height: 70)
                    } else {
                        AudioPlayerHeaderView(
                            model: .init(metadata: viewStore.current.metadata)
                        )
                        AudioPlayerWaveformView(
                            store: store.scope(
                                state: { $0.waveform },
                                action: { LifecycleAction.action(AudioPlayerAction.waveform($0)) }
                            ),
                            waveformOption: .init(width: 2, interval: 1, maxHeight: 140, style: .upDown)
                        )
                        .frame(height: 140)
                        PlayerControlView(
                            store: store.scope(
                                state: { $0.playerControl },
                                action: { LifecycleAction.action(AudioPlayerAction.playerControl($0)) }
                            )
                        )
                    }
                    BookmarkListView(
                        store: store.scope(
                            state: { $0.bookmark },
                            action: { LifecycleAction.action(AudioPlayerAction.bookmark($0)) }
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

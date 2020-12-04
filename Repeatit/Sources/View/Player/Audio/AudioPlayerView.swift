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
                .padding(.bottom, keyboardHeight > 0 ? PlayerControlViewAboveKeyboard.height : 0)
                VStack {
                    Spacer()
                    PlayerControlViewAboveKeyboard(
                        store: store.scope(
                            state: { $0.playerControl },
                            action: { LifecycleAction.action(AudioPlayerAction.playerControl($0)) }
                        )
                    )
                }
                .visibleOrInvisible(keyboardHeight > 0)
            }
            .onAppear { viewStore.send(.onAppear) }
            .onDisappear { viewStore.send(.onDisappear) }
        }
        .modifier(KeyboardHeightDetector(self.$keyboardHeight))
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioPlayerView(
                store: .init(
                    initialState: .init(
                        current: Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                        waveform: .init(current: Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))),
                        playerControl: .init(isPlaying: true),
                        bookmark: .init(
                            current: Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                            playTime: 0,
                            bookmarks: [
                                Bookmark(millis: 10000, text: "bookmark text 1"),
                                Bookmark(millis: 20000, text: "bookmark text 2"),
                                Bookmark(millis: 30000, text: "bookmark text 3"),
                                Bookmark(millis: 40000, text: "bookmark text 4")
                            ]
                        )
                    ),
                    reducer: Reducer<AudioPlayerState, LifecycleAction<AudioPlayerAction>, AudioPlayerEnvironment> { _, _, _ in return .none},
                    environment: AudioPlayerEnvironment(
                        audioClient: .production,
                        waveformClient: .production,
                        bookmarkClient: .production
                    )
                ),
                keyboardHeight: 0
            )
            .environment(\.colorScheme, .light)
            AudioPlayerView(
                store: .init(
                    initialState: .init(
                        current: Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                        waveform: .init(current: Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))),
                        playerControl: .init(isPlaying: false),
                        bookmark: .init(
                            current: Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                            playTime: 0,
                            bookmarks: [
                                Bookmark(millis: 10000, text: "bookmark text 1"),
                                Bookmark(millis: 20000, text: "bookmark text 2"),
                                Bookmark(millis: 40000, text: "bookmark text 3"),
                                Bookmark(millis: 80000, text: "bookmark text 4")
                            ]
                        )
                    ),
                    reducer: Reducer<AudioPlayerState, LifecycleAction<AudioPlayerAction>, AudioPlayerEnvironment> { _, _, _ in return .none},
                    environment: AudioPlayerEnvironment(
                        audioClient: .production,
                        waveformClient: .production,
                        bookmarkClient: .production
                    )
                ),
                keyboardHeight: 375
            )
            .environment(\.colorScheme, .dark)
        }
    }
}

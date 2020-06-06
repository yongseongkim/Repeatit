//
//  AudioPlayerView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/22.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI
import AVFoundation

struct AudioPlayerView: View {
    @State var keyboardHeight: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var store: PlayerStore

    var body: some View {
        let isDicationMode = keyboardHeight > 0
        return VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                if isDicationMode {
                    AudioPlayerSimpleHeaderView(model: .init(item: self.store.item))
                    AudioPlayerWaveformView(item: AudioItem(url: self.store.item.url), barStyle: .up)
                        .frame(height: 100)
                } else {
                    AudioPlayerHeaderView(model: .init(item: self.store.item))
                    AudioPlayerWaveformView(item: AudioItem(url: self.store.item.url), barStyle: .upDown)
                        .frame(height: 140)
                    PlayerControlView()
                }
            }
            .onTapGesture { UIApplication.hideKeyboard() }
            BookmarkListView()
                .environmentObject(self.store.bookmarkStore)
            Spacer()
        }
        .background(Color.systemGray6)
        .modifier(KeyboardHeightDetector(self.$keyboardHeight))
        .onAppear { self.store.play() }
        .onDisappear { self.store.pause() }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioPlayerView()
                .environmentObject(PlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")), player: AudioPlayer()))
                .environment(\.colorScheme, .light)
            AudioPlayerView()
                .environmentObject(PlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")), player: AudioPlayer()))
                .environment(\.colorScheme, .dark)
            AudioPlayerView(keyboardHeight: 140)
                .environmentObject(PlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")), player: AudioPlayer()))
                .environment(\.colorScheme, .dark)
        }
    }
}

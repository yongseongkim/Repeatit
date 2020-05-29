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
    let item: AudioItem
    let audioPlayer: AudioPlayer

    @State var keyboardHeight: CGFloat = 0
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        let isDicationMode = keyboardHeight > 0
        return VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                if isDicationMode {
                    AudioPlayerSimpleHeaderView(model: .init(title: self.item.title, artist: self.item.artist))
                    AudioPlayerWaveformView(url: self.item.url, audioPlayer: self.audioPlayer, barStyle: .up)
                        .frame(height: 100)
                } else {
                    AudioPlayerHeaderView(model: .init(title: self.item.title, artist: self.item.artist, artwork: self.item.artwork))
                    AudioPlayerWaveformView(url: self.item.url, audioPlayer: self.audioPlayer, barStyle: .upDown)
                        .frame(height: 140)
                    AudioPlayerControlView(model: .init(audioPlayer: self.audioPlayer))
                }
            }
            .onTapGesture { UIApplication.hideKeyboard() }
            AudioPlayerBookmarkListView(model: .init(audioPlayer: self.audioPlayer, audioItem: item))
        }
        .background(Color.systemGray6)
        .modifier(KeyboardHeightDetector(self.$keyboardHeight))
        .onAppear { try? self.audioPlayer.play(with: [self.item]) }
        .onDisappear { self.audioPlayer.pause() }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioPlayerView(
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                audioPlayer: BasicAudioPlayer()
            )
            .environment(\.colorScheme, .light)
            AudioPlayerView(
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                audioPlayer: BasicAudioPlayer()
            )
            .environment(\.colorScheme, .dark)
            AudioPlayerView(
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                audioPlayer: BasicAudioPlayer(),
                keyboardHeight: 140
            )
            .environment(\.colorScheme, .dark)
        }
    }
}

//
//  PlayerView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/22.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI
import AVFoundation

// Sibling 의 크기를 계산할 수 있는 로직이 필요.
struct SizeCalculator: View {
    @Binding var size: CGSize

    var body: some View {
        GeometryReader { self.calculate(geometryProxy: $0) }
    }

    private func calculate(geometryProxy: GeometryProxy) -> some View {
        DispatchQueue.main.async { self.size = geometryProxy.size }
        return Rectangle().background(Color.clear)
    }
}

struct PlayerView: View {
    let item: AudioItem
    let audioPlayer: AudioPlayer

    @State var keyboardHeight: CGFloat = 0
    @State var headerViewSize: CGSize = .zero
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        let isDicationMode = keyboardHeight > 0
        return GeometryReader { outerGeometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .center, spacing: 0) {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()
                            Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.systemBlack)
                                    .frame(width: 56, height: 56)
                            }
                        }
                        .background(Color.systemGray6)
                        if isDicationMode {
                            PlayerSimpleHeaderView(model: .init(title: self.item.title, artist: self.item.artist))
                            PlayerWaveformView(url: self.item.url, audioPlayer: self.audioPlayer, barStyle: .up)
                                .frame(height: 100)
                        } else {
                            PlayerHeaderView(model: .init(title: self.item.title, artist: self.item.artist, artwork: self.item.artwork))
                            PlayerWaveformView(url: self.item.url, audioPlayer: self.audioPlayer, barStyle: .upDown)
                                .frame(height: 140)
                            PlayerControlView(model: .init(audioPlayer: self.audioPlayer))
                        }
                    }
                    .onTapGesture { UIApplication.hideKeyboard() }
                    .background(SizeCalculator(size: self.$headerViewSize))
                    DictationNoteView(audioPlayer: self.audioPlayer, url: self.item.url)
                        .frame(height: outerGeometry.size.height - self.keyboardHeight - self.headerViewSize.height)
                        .background(Color.systemGray5)
                        .padding(15)
                    Spacer()
                }
                .background(Color.systemGray6)
                .modifier(KeyboardHeightDetector(self.$keyboardHeight))
            }
            .onDisappear {
                self.audioPlayer.pause()
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayerView(
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                audioPlayer: BasicAudioPlayer()
            )
            .environment(\.colorScheme, .light)
            PlayerView(
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                audioPlayer: BasicAudioPlayer()
            )
            .environment(\.colorScheme, .dark)
            PlayerView(
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                audioPlayer: BasicAudioPlayer(),
                keyboardHeight: 140
            )
            .environment(\.colorScheme, .dark)
        }
    }
}

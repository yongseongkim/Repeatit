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
    let item: PlayItem
    let player: Player

    @State var keyboardHeight: CGFloat = 0
    @State var headerViewSize: CGSize = .zero
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        GeometryReader { outerGeometry in
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.presentationMode.wrappedValue.dismiss()
                            }) {
                                Image("close")
                                    .resizable()
                                    .padding(18)
                                    .foregroundColor(.systemBlack)
                                    .frame(width: 56, height: 56)
                            }
                        }

                        if self.keyboardHeight > 0 {
                            PlayerSimpleHeaderView(model: .init(title: self.item.title, artist: self.item.artist))
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        } else {
                            PlayerHeaderView(model: .init(title: self.item.title, artist: self.item.artist, artwork: self.item.artwork))
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                        }
                        PlayerWaveformView(url: self.item.url, player: self.player)
                            .frame(height: 140)
                        if self.keyboardHeight == 0 {
                            PlayerControlView(player: self.player)
                                .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                        }
                    }
                    .background(Color.white)
                    .background(SizeCalculator(size: self.$headerViewSize))
                    DictationNoteView(player: self.player)
                        .padding(EdgeInsets(top: 15, leading: 25, bottom: 15, trailing: 25))
                        .frame(height: outerGeometry.size.height - self.keyboardHeight - self.headerViewSize.height)
                    Spacer()
                }
                .modifier(KeyboardHeightDetector(self.$keyboardHeight))
            }
            .onDisappear {
                self.player.pause()
            }
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(
            item: PlayItem(url: URL.documentsURL),
            player: BasicPlayer()
        )
    }
}

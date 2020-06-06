//
//  AudioPlayerWaveformView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/27.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct AudioPlayerWaveformView: View {
    let item: AudioItem
    let barStyle: WaveformBarStyle
    @EnvironmentObject var store: PlayerStore

    var body: some View {
        return ZStack(alignment: .top) {
            WaveformViewUI(
                url: item.url,
                player: store.player,
                barStyle: barStyle
            )
                .frame(minHeight: 0, maxHeight: .infinity)
            WaveformTimeView()
        }
        .background(Color.systemWhite)
    }
}

struct AudioPlayerWaveformView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioPlayerWaveformView(
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                barStyle: .upDown
            )
                .previewLayout(.fixed(width: 360, height: 140))
                .environment(\.colorScheme, .light)
                .environmentObject(PlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")), player: AudioPlayer()))
            AudioPlayerWaveformView(
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                barStyle: .upDown
            )
                .previewLayout(.fixed(width: 360, height: 140))
                .environment(\.colorScheme, .dark)
            .environmentObject(PlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")), player: AudioPlayer()))
            AudioPlayerWaveformView(
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                barStyle: .up
            )
                .previewLayout(.fixed(width: 360, height: 70))
                .environment(\.colorScheme, .dark)
                .environmentObject(PlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")), player: AudioPlayer()))
        }
    }
}

//
//  AudioPlayerWaveformView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/27.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct AudioPlayerWaveformView: View {
    let barStyle: WaveformBarStyle
    let item: AudioItem
    let player: MediaPlayer

    var body: some View {
        return ZStack(alignment: .top) {
            WaveformViewUI(
                barStyle: barStyle,
                player: player,
                url: item.url
            )
                .frame(minHeight: 0, maxHeight: .infinity)
            WaveformTimeView(model: .init(player: self.player))
        }
        .background(Color.systemWhite)
    }
}

struct AudioPlayerWaveformView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioPlayerWaveformView(
                barStyle: .upDown,
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                player: MediaPlayer()
            )
                .previewLayout(.fixed(width: 360, height: 140))
                .environment(\.colorScheme, .light)
            AudioPlayerWaveformView(
                barStyle: .upDown,
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                player: MediaPlayer()
            )
                .previewLayout(.fixed(width: 360, height: 140))
                .environment(\.colorScheme, .dark)
            AudioPlayerWaveformView(
                barStyle: .up,
                item: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                player: MediaPlayer()
            )
                .previewLayout(.fixed(width: 360, height: 70))
                .environment(\.colorScheme, .dark)
        }
    }
}

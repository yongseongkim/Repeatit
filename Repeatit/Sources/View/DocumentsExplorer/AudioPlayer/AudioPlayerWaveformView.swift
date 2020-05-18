//
//  AudioPlayerWaveformView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/27.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI



struct AudioPlayerWaveformView: View {
    let url: URL
    let audioPlayer: AudioPlayer
    let barStyle: WaveformBarStyle
    
    var body: some View {
        return ZStack(alignment: .top) {
            WaveformViewUI(
                url: url,
                audioPlayer: audioPlayer,
                barStyle: barStyle
            )
                .accentColor(Color.systemBlack)
                .frame(minHeight: 0, maxHeight: .infinity)
            WaveformTimeView(model: .init(audioPlayer: self.audioPlayer))
        }
        .background(Color.systemWhite)
    }
}

struct AudioPlayerWaveformView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioPlayerWaveformView(
                url: URL.homeDirectory.appendingPathComponent("sample.mp3"),
                audioPlayer: BasicAudioPlayer(),
                barStyle: .upDown
            )
                .previewLayout(.fixed(width: 360, height: 140))
                .environment(\.colorScheme, .light)
            AudioPlayerWaveformView(
                url: URL.homeDirectory.appendingPathComponent("sample.mp3"),
                audioPlayer: BasicAudioPlayer(),
                barStyle: .upDown
            )
                .previewLayout(.fixed(width: 360, height: 140))
                .environment(\.colorScheme, .dark)
            AudioPlayerWaveformView(
                url: URL.homeDirectory.appendingPathComponent("sample.mp3"),
                audioPlayer: BasicAudioPlayer(),
                barStyle: .up
            )
                .previewLayout(.fixed(width: 360, height: 70))
                .environment(\.colorScheme, .dark)
        }
    }
}

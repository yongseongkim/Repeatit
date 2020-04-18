//
//  PlayerWaveformView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/27.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI

struct PlayerWaveformView: View {
    let url: URL
    let audioPlayer: AudioPlayer
    let barStyle: WaveformBarStyle

    var body: some View {
        return ZStack(alignment: barStyle == .up ? .top : .bottom) {
            WaveformViewUI(
                url: url,
                audioPlayer: audioPlayer,
                barStyle: barStyle
            )
                .frame(maxHeight: .infinity)
            Path()
                .background(Color.classicBlue)
                .frame(width: 2)
                .frame(minHeight: 0, maxHeight: .infinity)
            WaveformTimeView(model: .init(audioPlayer: audioPlayer))
        }
    }
}

struct PlayerWaveformView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerWaveformView(
            url: URL.documentsURL,
            audioPlayer: BasicAudioPlayer(),
            barStyle: .upDown
        )
    }
}

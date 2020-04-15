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

    var body: some View {
        return ZStack(alignment: .bottom) {
            WaveformViewUI(
                url: url,
                audioPlayer: audioPlayer
            )
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
            audioPlayer: BasicAudioPlayer()
        )
    }
}

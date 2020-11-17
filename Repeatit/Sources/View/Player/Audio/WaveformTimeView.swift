//
//  WaveformTimeView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/03/08.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct WaveformTimeView: View {
    let store: Store<AudioPlayerState, AudioPlayerAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            HStack(spacing: 0) {
                Text(secondsToFormat(time: viewStore.playTime))
                    .padding(9)
                    .foregroundColor(Color.systemBlack)
                    .background(Color.systemGray6.opacity(0.95))
                Spacer()
                Text(secondsToFormat(time: viewStore.duration))
                    .padding(9)
                    .foregroundColor(Color.systemBlack)
                    .background(Color.systemGray6.opacity(0.95))
            }
        }
        .background(Color.clear)
    }

    private func secondsToFormat(time: Double) -> String {
        let minutes = Int(time.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = time.truncatingRemainder(dividingBy: 60)
        let remainder = Int((seconds * 10).truncatingRemainder(dividingBy: 10))
        return String.init(format: "%02d:%02d.%02d", minutes, Int(seconds), remainder)
    }
}

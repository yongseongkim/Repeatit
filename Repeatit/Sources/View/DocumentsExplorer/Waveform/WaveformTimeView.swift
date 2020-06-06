//
//  WaveformTimeView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/03/08.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import Combine
import SwiftUI

struct WaveformTimeView: View {
    @EnvironmentObject var store: PlayerStore

    var body: some View {
        HStack(spacing: 0) {
            Text(secondsToFormat(time: self.store.playTime.playTime))
                .padding(9)
                .foregroundColor(Color.systemBlack)
                .background(Color.systemGray6.opacity(0.95))
            Spacer()
            Text(secondsToFormat(time: self.store.playTime.duration))
                .padding(9)
                .foregroundColor(Color.systemBlack)
                .background(Color.systemGray6.opacity(0.95))
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

struct WaveformTimeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WaveformTimeView()
                .environmentObject(AudioPlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")), audioPlayer: AudioPlayer()))
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .light)
                .environmentObject(PlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")), player: AudioPlayer()))
            WaveformTimeView()
                .environmentObject(AudioPlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")), audioPlayer: AudioPlayer()))
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .dark)
                .environmentObject(PlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3")), player: AudioPlayer()))
        }
    }
}

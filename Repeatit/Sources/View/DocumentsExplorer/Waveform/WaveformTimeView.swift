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
    @ObservedObject var model: ViewModel

    var body: some View {
        HStack(spacing: 0) {
            Text(secondsToFormat(time: self.model.playTimeSeconds))
                .padding(9)
                .foregroundColor(Color.systemBlack)
                .background(Color.systemGray6.opacity(0.95))
            Spacer()
            Text(secondsToFormat(time: self.model.durationSeconds))
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

extension WaveformTimeView {
    class ViewModel: ObservableObject {
        let player: MediaPlayer
        private var cancellables: [AnyCancellable]

        @Published var playTimeSeconds: Double = 0
        @Published var durationSeconds: Double = 0

        init(player: MediaPlayer) {
            self.player = player
            self.cancellables = []

            self.player.playTimePublisher
                .sink { [weak self] in
                    self?.playTimeSeconds = $0
                }
                .store(in: &cancellables)
            self.durationSeconds = self.player.duration
        }
    }
}

struct WaveformTimeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WaveformTimeView(model: .init(player: MediaPlayer()))
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .light)
            WaveformTimeView(model: .init(player: MediaPlayer()))
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .dark)
        }
    }
}

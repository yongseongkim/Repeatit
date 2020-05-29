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
            Text(secondsToFormat(time: self.model.playTime))
                .padding(9)
                .foregroundColor(Color.systemBlack)
                .background(Color.systemWhite.opacity(0.95))
            Spacer()
            Text(secondsToFormat(time: self.model.duration))
                .padding(9)
                .foregroundColor(Color.systemBlack)
                .background(Color.systemWhite.opacity(0.95))
        }
        .background(Color.clear)
    }

    private func secondsToFormat(time: Double) -> String {
        let hour = Int(time / 3600)
        let minutes = Int(time.truncatingRemainder(dividingBy: 3600) / 60)
        let seconds = time.truncatingRemainder(dividingBy: 60)
        let remainder = Int((seconds * 10).truncatingRemainder(dividingBy: 10))
        return String.init(format: "%02d:%02d:%02d.%02d", hour, minutes, Int(seconds), remainder)
    }
}

extension WaveformTimeView {
    class ViewModel: ObservableObject {
        let audioPlayer: AudioPlayer
        @Published var playTime: Double = 0
        @Published var duration: Double = 0

        private var cancellables: [AnyCancellable] = []

        init(audioPlayer: AudioPlayer) {
            self.audioPlayer = audioPlayer
            self.duration = audioPlayer.duration
            audioPlayer.playTimePublisher
                // TODO: receive(RunLoop.main) 를 사용하면 bookmark scrolling 중에 이동이 멈춘다.
                .sink(receiveValue: { playTime in
                    DispatchQueue.main.async {
                        self.playTime = playTime
                        self.duration = audioPlayer.duration
                    }
                })
                .store(in: &cancellables)
        }
    }
}

struct WaveformTimeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WaveformTimeView(model: .init(audioPlayer: BasicAudioPlayer()))
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .light)
            WaveformTimeView(model: .init(audioPlayer: BasicAudioPlayer()))
                .previewLayout(.sizeThatFits)
                .environment(\.colorScheme, .dark)
        }
    }
}

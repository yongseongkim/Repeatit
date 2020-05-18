//
//  AudioPlayerControlView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/27.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import Combine
import SwiftUI

struct AudioPlayerControlView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                TimeControlButton(direction: .backward, seconds: 5)
                    .onTapGesture { self.model.backward(by: 5) }
                Spacer()
                TimeControlButton(direction: .backward, seconds: 1)
                    .onTapGesture { self.model.backward(by: 1) }
                Spacer()
                TimeControlButton(direction: .backward, seconds: 0)
                    .onTapGesture { self.model.moveToStart() }
                Spacer()
                TimeControlButton(direction: .forward, seconds: 1)
                    .onTapGesture { self.model.forward(by: 1) }
                Spacer()
                TimeControlButton(direction: .forward, seconds: 5)
                    .onTapGesture { self.model.forward(by: 5) }
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 8, trailing: 10))
            HStack(spacing: 0) {
                Spacer()
                Image(systemName: "backward.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)
                Spacer()
                Image(systemName: self.model.isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)
                    .onTapGesture { self.model.togglePlay() }
                Spacer()
                Image(systemName: "forward.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)
                Spacer()
            }
        }
        .padding(10)
        .background(Color.systemGray6)
    }
}

extension AudioPlayerControlView {
    class ViewModel: ObservableObject {
        let audioPlayer: AudioPlayer
        @Published var isPlaying: Bool = false

        private var cancellables: [AnyCancellable] = []

        init(audioPlayer: AudioPlayer) {
            self.audioPlayer = audioPlayer
            audioPlayer.isPlayingPublisher
                .receive(on: RunLoop.main)
                .assign(to: \.isPlaying, on: self)
                .store(in: &cancellables)
        }

        func togglePlay() {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
            } else {
                audioPlayer.resume()
            }
        }

        func forward(by seconds: Double) {
            audioPlayer.moveForward(seconds: seconds)
        }

        func backward(by seconds: Double) {
            audioPlayer.moveBackward(seconds: seconds)
        }

        func moveToStart() {
            audioPlayer.move(to: 0)
        }
    }
}

struct AudioPlayerControlView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioPlayerControlView(model: .init(audioPlayer: BasicAudioPlayer()))
                .environment(\.colorScheme, .light)
                .previewLayout(.sizeThatFits)
            AudioPlayerControlView(model: .init(audioPlayer: BasicAudioPlayer()))
                .environment(\.colorScheme, .dark)
                .previewLayout(.sizeThatFits)
        }
    }
}

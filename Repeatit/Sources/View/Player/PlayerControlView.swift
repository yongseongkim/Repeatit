//
//  PlayerControlView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/27.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import Combine
import SwiftUI

struct PlayerControlView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        VStack(spacing: 15) {
            HStack {
                PlayerMoveControlButtonUI(direction: .backward, seconds: 5)
                    .frame(width: 44, height: 44)
                    .onTapGesture { self.model.backward(by: 5) }
                Spacer()
                PlayerMoveControlButtonUI(direction: .backward, seconds: 1)
                    .frame(width: 44, height: 44)
                    .onTapGesture { self.model.backward(by: 1) }
                Spacer()
                PlayerMoveControlButtonUI(direction: .backward, seconds: 0)
                    .frame(width: 44, height: 44)
                    .onTapGesture { self.model.moveToStart() }
                Spacer()
                PlayerMoveControlButtonUI(direction: .forward, seconds: 1)
                    .frame(width: 44, height: 44)
                    .onTapGesture { self.model.forward(by: 1) }
                Spacer()
                PlayerMoveControlButtonUI(direction: .forward, seconds: 5)
                    .frame(width: 44, height: 44)
                    .onTapGesture { self.model.forward(by: 5) }
            }
            .padding(EdgeInsets(top: 5, leading: 10, bottom: 8, trailing: 10))
            HStack(spacing: 0) {
                Spacer()
                Image(systemName: "backward.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                Spacer()
                Image(systemName: self.model.isPlaying ? "pause.fill" : "play.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                    .onTapGesture { self.model.togglePlay() }
                Spacer()
                Image(systemName: "forward.fill")
                    .resizable()
                    .foregroundColor(.systemBlack)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 56, height: 56)
                Spacer()
            }
        }
        .padding(10)
        .background(Color.systemGray6)
    }
}

extension PlayerControlView {
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

struct PlayerControlView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayerControlView(model: .init(audioPlayer: BasicAudioPlayer()))
                .environment(\.colorScheme, .light)
                .previewLayout(.sizeThatFits)
            PlayerControlView(model: .init(audioPlayer: BasicAudioPlayer()))
                .environment(\.colorScheme, .dark)
                .previewLayout(.sizeThatFits)
        }
    }
}

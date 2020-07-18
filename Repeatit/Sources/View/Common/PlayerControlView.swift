//
//  PlayerControlView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/04.
//

import Combine
import SwiftUI

struct PlayerControlView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                TimeControlButton(direction: .backward, seconds: 5)
                    .onTapGesture { self.model.player.moveBackward(by: 5) }
                Spacer()
                TimeControlButton(direction: .backward, seconds: 1)
                    .onTapGesture { self.model.player.moveBackward(by: 1) }
                Spacer()
            }
            Spacer()
            Image(systemName: self.model.isPlaying ? "pause.fill" : "play.fill")
                .resizable()
                .foregroundColor(.systemBlack)
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .onTapGesture { self.model.player.togglePlay() }
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                TimeControlButton(direction: .forward, seconds: 1)
                    .onTapGesture { self.model.player.moveForward(by: 1) }
                Spacer()
                TimeControlButton(direction: .forward, seconds: 5)
                    .onTapGesture { self.model.player.moveForward(by: 5) }
                Spacer()
            }
            Spacer()
        }
        .padding([.top, .bottom], 10)
        .background(Color.systemWhite)
        .cornerRadius(8)
        .padding(10)
        .background(Color.systemGray6)
    }
}

extension PlayerControlView {
    class ViewModel: ObservableObject {
        let player: Player
        var cancellables: [AnyCancellable]
        @Published var isPlaying: Bool

        init(player: Player) {
            self.player = player
            self.cancellables = []
            self.isPlaying = false
            self.player.isPlayingPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] in
                    self?.isPlaying = $0
                }
                .store(in: &cancellables)
        }
    }
}

struct PlayerControlView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlayerControlView(model: .init(player: MediaPlayer()))
                .environment(\.colorScheme, .light)
                .previewLayout(.sizeThatFits)
            PlayerControlView(model: .init(player: MediaPlayer()))
                .environment(\.colorScheme, .dark)
                .previewLayout(.sizeThatFits)
        }
    }
}

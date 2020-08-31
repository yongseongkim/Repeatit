//
//  BookmarkInputAccessaryView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import Combine
import SwiftUI

struct BookmarkInputAccessaryView: View {
    static let height: CGFloat = 50

    @ObservedObject var model: ViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                InputAccessaryTimeControlButton(direction: .backward, seconds: 5)
                    .onTapGesture { self.model.player.moveBackward(by: 5) }
                InputAccessaryTimeControlButton(direction: .backward, seconds: 1)
                    .onTapGesture { self.model.player.moveBackward(by: 1) }
                Spacer()
                Button(
                    action: { self.model.player.togglePlay() },
                    label: { self.buttonImage }
                )
                    .frame(width: 44, height: 44)
                Spacer()
                InputAccessaryTimeControlButton(direction: .forward, seconds: 1)
                    .onTapGesture { self.model.player.moveForward(by: 1) }
                InputAccessaryTimeControlButton(direction: .forward, seconds: 5)
                    .onTapGesture { self.model.player.moveForward(by: 5) }
                Spacer()
            }
            Spacer()
            Divider()
                .frame(height: 40)
            Button(
                action: { UIApplication.hideKeyboard() },
                label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .foregroundColor(Color.systemBlack)
                }
            )
                .frame(width: 44, height: 44)
        }
    }

    private var buttonImage: some View {
        Image(systemName: self.model.isPlaying ? "pause.fill" : "play.fill")
            .foregroundColor(Color.systemBlack)
    }
}

extension BookmarkInputAccessaryView {
    class ViewModel: ObservableObject {
        @Published var isPlaying: Bool = false

        let player: Player
        var cancellables: [AnyCancellable] = []

        init(player: Player) {
            self.player = player
            self.player.isPlayingPublisher
                .sink { [weak self] in
                    self?.isPlaying = $0
                }
                .store(in: &cancellables)
        }
    }
}

struct BookmarkInputAccessaryView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkInputAccessaryView(model: .init(player: MediaPlayer()))
    }
}

//
//  YouTubeBookmarkInputAccessaryView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import Combine
import SwiftUI

struct YouTubeBookmarkInputAccessaryView: View {
    static let height: CGFloat = 50

    @ObservedObject var model: ViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                InputAccessaryTimeControlButton(direction: .backward, seconds: 5)
                    .onTapGesture { self.model.moveBackward(by: 5) }
                InputAccessaryTimeControlButton(direction: .backward, seconds: 1)
                    .onTapGesture { self.model.moveBackward(by: 1) }
                Spacer()
                Button(
                    action: { self.model.togglePlay() },
                    label: { self.buttonImage }
                )
                    .frame(width: 44, height: 44)
                Spacer()
                InputAccessaryTimeControlButton(direction: .forward, seconds: 1)
                    .onTapGesture { self.model.moveForward(by: 1) }
                InputAccessaryTimeControlButton(direction: .forward, seconds: 5)
                    .onTapGesture { self.model.moveForward(by: 5) }
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

extension YouTubeBookmarkInputAccessaryView {
    class ViewModel: ObservableObject {
        let playerController: YouTubePlayerController
        var cancellables: [AnyCancellable] = []

        @Published var isPlaying: Bool = false

        init(playerController: YouTubePlayerController) {
            self.playerController = playerController
            self.playerController.stateSubject
                .map { $0 == .playing }
                .assign(to: \.isPlaying, on: self)
                .store(in: &cancellables)
        }

        func togglePlay() {
            playerController.togglePlay()
        }

        func moveForward(by seconds: Double) {
            playerController.moveForward(by: seconds)
        }

        func moveBackward(by seconds: Double) {
            playerController.moveBackward(by: seconds)
        }
    }
}

struct YouTubeBookmarkInputAccessaryView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubeBookmarkInputAccessaryView(model: .init(playerController: YouTubePlayerController(videoId: "")))
            .previewLayout(.sizeThatFits)
    }
}

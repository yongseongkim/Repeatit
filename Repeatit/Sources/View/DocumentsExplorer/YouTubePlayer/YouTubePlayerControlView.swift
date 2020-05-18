//
//  YouTubePlayerControlView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import Combine
import SwiftUI

struct YouTubePlayerControlView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        HStack {
            TimeControlButton(direction: .backward, seconds: 5)
                .onTapGesture { self.model.moveBackward(by: 5) }
            Spacer()
            TimeControlButton(direction: .backward, seconds: 1)
                .onTapGesture { self.model.moveBackward(by: 1) }
            Spacer()
            Image(systemName: self.model.isPlaying ? "pause.fill" : "play.fill")
                .resizable()
                .foregroundColor(.systemBlack)
                .aspectRatio(contentMode: .fit)
                .frame(width: 34, height: 34)
                .onTapGesture { self.model.togglePlay() }
            Spacer()
            TimeControlButton(direction: .forward, seconds: 1)
                .onTapGesture { self.model.moveForward(by: 1) }
            Spacer()
            TimeControlButton(direction: .forward, seconds: 5)
                .onTapGesture { self.model.moveForward(by: 5) }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
        .background(Color.systemGray6)
    }
}

extension YouTubePlayerControlView {
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

struct YouTubePlayerControlView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubePlayerControlView(model: .init(playerController: YouTubePlayerController(videoId: "")))
            .previewLayout(.sizeThatFits)
    }
}

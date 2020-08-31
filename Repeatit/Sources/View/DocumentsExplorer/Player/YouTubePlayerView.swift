//
//  YouTubePlayerView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/12.
//

import Combine
import SwiftUI
import youtube_ios_player_helper

struct YouTubePlayerView: View {
    @State var keyboardHeight: CGFloat = 0
    @ObservedObject var model: ViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                YouTubeContentView(youtubePlayer: self.model.player)
                    .frame(height: ceil(geometry.size.width * 9 / 16), alignment: .top)
                    .background(Color.systemGray4)
                if self.keyboardHeight ==  0 {
                    PlayerControlView(model: .init(player: self.model.player))
                }
                if self.model.isLoading {
                    InfiniteLoadingView()
                        .frame(width: 44, height: 44)
                } else {
                    BookmarkListView(model: .init(player: self.model.player, controller: self.model.webVTTController!))
                }
            }
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .modifier(KeyboardHeightDetector(self.$keyboardHeight))
    }
}

extension YouTubePlayerView {
    class ViewModel: ObservableObject {
        @Published var isLoading: Bool = true

        let player: YouTubePlayer
        let item: PlayItem
        var webVTTController: WebVTTController?
        var cancellables: [AnyCancellable] = []

        init(player: YouTubePlayer, item: PlayItem) {
            self.player = player
            self.item = item
            self.player.play(item: item)
            self.player.durationSubject.sink { duration in
                if duration > 0 {
                    self.webVTTController = WebVTTController(
                        url: item.url.deletingPathExtension().appendingPathExtension("vtt"),
                        duration: Int(duration)
                    )
                    self.isLoading = false
                }
            }
            .store(in: &cancellables)
        }
    }
}

struct YouTubePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubePlayerView(
            model: .init(
                player: YouTubePlayer(),
                item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.youtube"))
            )
        )
    }
}

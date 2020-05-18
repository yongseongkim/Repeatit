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

    private let playerController: YouTubePlayerController

    init(item: YouTubeVideoItem) {
        playerController = YouTubePlayerController(videoId: item.videoId)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                YouTubeView(playerController: self.playerController)
                    .frame(height: ceil(geometry.size.width * 9 / 16), alignment: .top)
                    .background(Color.systemGray4)
                if self.keyboardHeight ==  0 {
                    YouTubePlayerControlView(model: .init(playerController: self.playerController))
                }
                YouTubePlayerBookmarkListView(model: .init(playerController: self.playerController))
            }
            .modifier(KeyboardHeightDetector(self.$keyboardHeight))
            .background(Color.systemGray6)
        }
        .onAppear {
            self.playerController.load()
        }
    }
}

struct YouTubePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubePlayerView(item: YouTubeVideoItem(videoId: "dJ2pbTsbwPc"))
    }
}

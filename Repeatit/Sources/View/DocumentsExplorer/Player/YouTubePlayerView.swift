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
    @EnvironmentObject var store: PlayerStore

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                YouTubeView(player: self.store.player)
                    .frame(height: ceil(geometry.size.width * 9 / 16), alignment: .top)
                    .background(Color.systemGray4)
                if self.keyboardHeight ==  0 {
                    PlayerControlView()
                }
                BookmarkListView()
                    .environmentObject(self.store.bookmarkStore)
                Spacer()
            }
            .modifier(KeyboardHeightDetector(self.$keyboardHeight))
            .background(Color.systemGray6)
        }
        .onAppear { self.store.play() }
    }
}

struct YouTubePlayerView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubePlayerView()
            .environmentObject(YouTubePlayerStore(item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.youtube"))))
    }
}

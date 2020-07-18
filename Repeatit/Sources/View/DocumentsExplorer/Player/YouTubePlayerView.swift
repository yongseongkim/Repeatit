//
//  YouTubePlayerView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/12.
//

import Combine
import RealmSwift
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
                BookmarkListView(model: .init(player: self.model.player, bookmarks: self.model.bookmarks))
                Spacer()
            }
            .modifier(KeyboardHeightDetector(self.$keyboardHeight))
            .background(Color.systemGray6)
        }
    }
}

extension YouTubePlayerView {
    class ViewModel: ObservableObject {
        let player: YouTubePlayer
        let item: PlayItem
        var bookmarks: [Bookmark] {
            if let realm = try? Realm() {
                return realm.objects(BookmarkObject.self)
                    .filter("relativePath = '\(URL.relativePathFromHome(url: item.url))'")
                    .sorted(byKeyPath: "startMillis")
                    .reduce([], { $0 + [Bookmark(object: $1)] })
            } else {
                return []
            }
        }

        init(player: YouTubePlayer, item: PlayItem) {
            self.player = player
            self.item = item
            self.player.play(item: item)
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

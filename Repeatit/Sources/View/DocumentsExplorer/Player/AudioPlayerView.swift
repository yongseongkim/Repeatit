//
//  AudioPlayerView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/22.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import SwiftUI
import RealmSwift

struct AudioPlayerView: View {
    @State var keyboardHeight: CGFloat = 0
    @ObservedObject var model: ViewModel

    var body: some View {
        let isDicationMode = keyboardHeight > 0
        return VStack(alignment: .center, spacing: 0) {
            VStack(alignment: .center, spacing: 0) {
                if isDicationMode {
                    AudioPlayerSimpleHeaderView(model: .init(item: self.model.item))
                    AudioPlayerWaveformView(barStyle: .up, item: AudioItem(url: self.model.item.url), player: self.model.player)
                        .frame(height: 100)
                } else {
                    AudioPlayerHeaderView(model: .init(item: self.model.item))
                    AudioPlayerWaveformView(barStyle: .upDown, item: AudioItem(url: self.model.item.url), player: self.model.player)
                        .frame(height: 140)
                    PlayerControlView(model: .init(player: self.model.player))
                }
            }
            .onTapGesture { UIApplication.hideKeyboard() }
            BookmarkListView(model: .init(player: self.model.player, bookmarks: self.model.bookmarks))
            Spacer()
        }
        .background(Color.systemGray6)
        .modifier(KeyboardHeightDetector(self.$keyboardHeight))
        .onAppear { self.model.player.resume() }
        .onDisappear { self.model.player.pause() }
    }
}

extension AudioPlayerView {
    class ViewModel: ObservableObject {
        let player: MediaPlayer
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

        init(player: MediaPlayer, item: PlayItem) {
            self.player = player
            self.item = item
            self.player.play(item: item)
        }
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AudioPlayerView(
                model: .init(
                    player: MediaPlayer(),
                    item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))
                )
            )
            .environment(\.colorScheme, .light)
            AudioPlayerView(
                model: .init(
                    player: MediaPlayer(),
                    item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))
                )
            )
            .environment(\.colorScheme, .dark)
        }
    }
}

//
//  VideoPlayerView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/12.
//

import AVFoundation
import RealmSwift
import SwiftUI
import UIKit


struct VideoPlayerView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                AVPlayerView(mediaPlayer: self.model.player)
                    .frame(height: ceil(geometry.size.width * 9 / 16), alignment: .top)
                    .background(Color.systemGray4)
                PlayerControlView(model: .init(player: self.model.player))
                BookmarkListView(model: .init(player: self.model.player, bookmarks: self.model.bookmarks))
                Spacer()
            }
            .background(Color.systemGray6)
        }
        .onAppear { self.model.player.resume() }
        .onDisappear { self.model.player.pause() }
    }
}

extension VideoPlayerView {
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

struct AVPlayerView: UIViewRepresentable {
    let mediaPlayer: MediaPlayer

    func makeUIView(context: Context) -> AVPlayerUIView {
        return AVPlayerUIView(mediaPlayer: mediaPlayer)
    }

    func updateUIView(_ uiView: AVPlayerUIView, context: Context) {
    }
}

class AVPlayerUIView: UIView {
    private let mediaPlayer: MediaPlayer

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(mediaPlayer: MediaPlayer) {
        self.mediaPlayer = mediaPlayer
        super.init(frame: .zero)
        self.layer.addSublayer(self.mediaPlayer.layer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.mediaPlayer.layer.frame = self.bounds
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(
            model: .init(
                player: MediaPlayer(),
                item: DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))
            )
        )
    }
}

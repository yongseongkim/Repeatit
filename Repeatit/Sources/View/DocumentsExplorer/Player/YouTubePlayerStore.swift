//
//  YouTubePlayerStore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import Combine
import Foundation
import RealmSwift

class YouTubePlayerStore: ObservableObject {
    let item: PlayItem
    let player: YouTubePlayer
    lazy var bookmarkStore: BookmarkStore = {
        var bookmarks: [Bookmark] = []
        if let realm = try? Realm() {
            bookmarks = realm.objects(BookmarkObject.self)
                .filter("relativePath = '\(URL.relativePathFromHome(url: item.url))'")
                .sorted(byKeyPath: "startMillis")
                .reduce([], { $0 + [Bookmark(object: $1)] })
        }
        return BookmarkStore(bookmarks: bookmarks, player: self.player)
    }()
    private var cancellables: [AnyCancellable] = []

    @Published var isPlaying: Bool = false

    init(item: PlayItem) {
        self.item = item
        self.player = YouTubePlayer()
        self.player.stateSubject
            .map { $0 == .playing }
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
    }

    func play() {
        player.play(item: item)
    }

    func togglePlay() {
        player.togglePlay()
    }

    func move(to: Double) {
        player.move(to: to)
    }

    func moveForward(by seconds: Double) {
        player.moveForward(by: seconds)
    }

    func moveBackward(by seconds: Double) {
        player.moveBackward(by: seconds)
    }
}

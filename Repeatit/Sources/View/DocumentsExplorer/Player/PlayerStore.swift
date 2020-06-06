//
//  PlayerStore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/05.
//

import Combine
import Foundation
import RealmSwift

class PlayerStore: ObservableObject {
    let item: PlayItem
    let player: Player

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

    @Published var playTime: (playTime: Double, duration: Double) = (0, 0)
    @Published var isPlaying: Bool = false


    init(item: PlayItem, player: Player) {
        self.item = item
        self.player = player
        player.isPlayingPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
        player.playTimePublisher
        // TODO: receive(RunLoop.main) 를 사용하면 bookmark scrolling 중에 이동이 멈춘다.
            .sink(receiveValue: { playTime in
                DispatchQueue.main.async {
                    self.playTime = (playTime, player.duration)
                }
            })
            .store(in: &cancellables)
    }

    func play() {
        player.play(item: item)
    }

    func pause() {
        player.pause()
    }

    func togglePlay() {
        player.togglePlay()
    }

    func move(to: Double) {
        player.move(to: 0)
    }

    func moveForward(by seconds: Double) {
        player.moveForward(by: seconds)
    }

    func moveBackward(by seconds: Double) {
        player.moveBackward(by: seconds)
    }
}

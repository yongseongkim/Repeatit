//
//  AudioPlayerStore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/01.
//

import Combine
import Foundation
import RealmSwift

class AudioPlayerStore: ObservableObject {
    let item: PlayItem
    let player: AudioPlayer
    lazy var bookmarkStore: BookmarkStore = {
        var bookmarks: [Bookmark] = []
        if let realm = try? Realm() {
            bookmarks = realm.objects(BookmarkObject.self)
                .filter("relativePath = '\(URL.relativePathFromHome(url: item.url))'")
                .sorted(byKeyPath: "startMillis")
                .reduce([], { $0 + [Bookmark(object: $1)] })
        }
        return BookmarkStore(bookmarks: bookmarks, player: player)
    }()
    private var cancellables: [AnyCancellable] = []

    @Published var playTime: (playTime: Double, duration: Double) = (0, 0)
    @Published var isPlaying: Bool = false

    init(item: PlayItem, audioPlayer: AudioPlayer) {
        self.item = item
        self.player = audioPlayer
        audioPlayer.isPlayingPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isPlaying, on: self)
            .store(in: &cancellables)
        audioPlayer.playTimePublisher
        // TODO: receive(RunLoop.main) 를 사용하면 bookmark scrolling 중에 이동이 멈춘다.
            .sink(receiveValue: { playTime in
                DispatchQueue.main.async {
                    self.playTime = (playTime, audioPlayer.duration)
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

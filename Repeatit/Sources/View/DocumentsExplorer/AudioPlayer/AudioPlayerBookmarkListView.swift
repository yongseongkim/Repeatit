//
//  AudioPlayerBookmarkListView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import SwiftUI
import RealmSwift

struct AudioPlayerBookmarkListView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        let withIndex = self.model.items.enumerated().map({ $0 })
        return List(withIndex, id: \.element.id) { idx, _ in
            self.model.rowBuilder(idx: idx)
        }
        .onAppear {
            self.model.refresh()
        }
    }
}

extension AudioPlayerBookmarkListView {
    struct BookmarkListItem: Identifiable {
        enum `Type` {
            case edit
            case add
        }
        var type: Type
        var value: AudioBookmark?

        var id: String {
            if type == .add {
                return "ADD"
            }
            return value?.keyId ?? "EDIT"
        }
    }

    class ViewModel: ObservableObject {
        let audioPlayer: AudioPlayer
        let audioItem: AudioItem

        @Published var items: [BookmarkListItem] = [BookmarkListItem(type: .add, value: nil)]
        var bookmarks: [AudioBookmark] = [] {
            didSet { items = bookmarks.map { BookmarkListItem(type: .edit, value: $0) } + [BookmarkListItem(type: .add, value: nil)] }
        }

        init(audioPlayer: AudioPlayer, audioItem: AudioItem) {
            self.audioPlayer = audioPlayer
            self.audioItem = audioItem
            refresh()
        }

        func rowBuilder(idx: Int) -> AnyView {
            let item = self.items[idx]
            if item.type == .add {
                return AnyView(
                    AudioBookmarkAddRow()
                        .onTapGesture { self.onAddRowTapGesture() }
                )
            } else {
                return AnyView(
                    AudioBookmarkRow(
                        audioPlayer: self.audioPlayer,
                        bookmark: self.items[idx].value!,
                        text: .init(
                            get: { self.items[idx].value!.note },
                            set: { self.handleTextChanges(idx: idx, text: $0) }
                        )
                    )
                )
            }
        }

        func onAddRowTapGesture() {
            guard let item = audioPlayer.playItem, let realm = try? Realm() else { return }
            let relativePath = URL.relativePathFromHome(url: item.url)
            let bookmarkKeyId = AudioBookmark.makeKeyId(
                relativePath: relativePath,
                startMillis: audioPlayer.playTimeMillis
            )
            if realm.object(ofType: AudioBookmark.self, forPrimaryKey: bookmarkKeyId) != nil {
                return
            }

            let new = AudioBookmark()
            new.keyId = bookmarkKeyId
            new.relativePath = relativePath
            new.note = ""
            new.startMillis = audioPlayer.playTimeMillis
            new.createdAt = Date()
            new.updatedAt = Date()
            try? realm.write {
                realm.add(new)
            }
            refresh()
        }

        func handleTextChanges(idx: Int, text: String) {
            guard let realm = try? Realm(), let item = self.items[idx].value else { return }
            try? realm.write {
                item.note = text
            }
        }

        func refresh() {
            guard let realm = try? Realm() else { return }
            bookmarks = realm.objects(AudioBookmark.self)
                .filter("relativePath = '\(URL.relativePathFromHome(url: audioItem.url))'")
                .sorted(byKeyPath: "startMillis")
                .reduce([], { $0 + [$1] })
        }
    }
}

struct AudioPlayerBookmarkListView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerBookmarkListView(model: .init(audioPlayer: BasicAudioPlayer(), audioItem: AudioItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))))
    }
}

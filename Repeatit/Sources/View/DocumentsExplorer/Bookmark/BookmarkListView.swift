//
//  BookmarkListView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import Combine
import SwiftUI
import RealmSwift

struct BookmarkListView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        List {
            ForEach(self.model.items, id: \.id, content: {
                self.rowBuilder(item: $0)
            })
            .onDelete(perform: { idxSet in
                idxSet.forEach { self.model.deleteBookmark(at: $0) }
            })
        }
    }

    func rowBuilder(item: BookmarkItem) -> AnyView {
        switch item {
        case _ as AddBookmarkItem:
            return AnyView(
                BookmarkAddRow()
                    .onTapGesture { self.model.addBookmark() }
            )
        case let edit as EditBookmarkItem:
            return AnyView(
                BookmarkEditRow(
                    bookmark: edit.value,
                    player: self.model.player,
                    text: .init(
                        get: { edit.value.note },
                        set: { self.model.handleTextChange(bookmark: edit.value, text: $0) }
                    )
                )
            )
        default:
            return AnyView(EmptyView())
        }
    }
}

extension BookmarkListView {
    class ViewModel: ObservableObject {
        let player: Player
        @Published var bookmarks: [Bookmark]
        @Published var isPlaying: Bool = false
        private var cancellables: [AnyCancellable] = []

        var items: [BookmarkItem] {
            bookmarks.map { EditBookmarkItem(value: $0) } + [AddBookmarkItem()]
        }

        init(player: Player, bookmarks: [Bookmark]) {
            self.player = player
            self.bookmarks = bookmarks
        }

        func addBookmark() {
            guard let item = player.playItem, let realm = try? Realm() else { return }
            let relativePath = URL.relativePathFromHome(url: item.url)
            let bookmarkKeyId = Bookmark.makeKeyId(
                relativePath: relativePath,
                startMillis: player.playTimeMillis
            )
            if bookmarks.contains(where: { $0.keyId == bookmarkKeyId }) {
                return
            }

            let new = BookmarkObject()
            new.keyId = bookmarkKeyId
            new.relativePath = relativePath
            new.note = ""
            new.startMillis = player.playTimeMillis
            new.createdAt = Date()
            new.updatedAt = Date()
            do {
                try realm.write {
                    realm.add(new)
                }
                bookmarks.insertionSort(with: Bookmark(object: new))
            } catch let exception {
                print(exception)
            }
        }

        func deleteBookmark(at idx: Int) {
            guard let realm = try? Realm() else { return }
            do {
                let deleted = bookmarks[idx]
                if let deletedObject = realm.object(ofType: BookmarkObject.self, forPrimaryKey: deleted.keyId) {
                    try realm.write {
                        realm.delete(deletedObject)
                    }
                }
                bookmarks.remove(at: idx)
            } catch let exception {
                print(exception)
            }
        }

        func handleTextChange(bookmark: Bookmark, text: String) {
            guard let realm = try? Realm(), let object = realm.object(ofType: BookmarkObject.self, forPrimaryKey: bookmark.keyId) else { return }
            do {
                try realm.write {
                    object.note = text
                }
                bookmark.note = text
            } catch let exception {
                print(exception)
            }
        }
    }
}

struct BookmarkListView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkListView(model: .init(player: MediaPlayer(), bookmarks: []))
    }
}

//
//  YouTubePlayerBookmarkListView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import SwiftUI
import RealmSwift

struct YouTubePlayerBookmarkListView: View {
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

extension YouTubePlayerBookmarkListView {
    struct BookmarkListItem: Identifiable {
        enum `Type` {
            case edit
            case add
        }
        var type: Type
        var value: YouTubeBookmark?

        var id: String {
            if type == .add {
                return "ADD"
            }
            return value?.keyId ?? "EDIT"
        }
    }

    class ViewModel: ObservableObject {
        let playerController: YouTubePlayerController

        @Published var items: [BookmarkListItem] = [BookmarkListItem(type: .add, value: nil)]
        var bookmarks: [YouTubeBookmark] = [] {
            didSet { items = bookmarks.map { BookmarkListItem(type: .edit, value: $0) } + [BookmarkListItem(type: .add, value: nil)] }
        }

        init(playerController: YouTubePlayerController) {
            self.playerController = playerController
            refresh()
        }

        func rowBuilder(idx: Int) -> AnyView {
            let item = self.items[idx]
            if item.type == .add {
                return AnyView(
                    YouTubeBookmarkAddRow()
                        .onTapGesture { self.onAddRowTapGesture() }
                )
            } else {
                return AnyView(
                    YouTubeBookmarkRow(
                        playerController: self.playerController,
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
            guard let realm = try? Realm() else { return }
            let relativePath = URL.relativePathFromHome(url: URL.homeDirectory)
            let bookmarkKeyId = YouTubeBookmark.makeKeyId(
                relativePath: relativePath,
                videoId: self.playerController.videoId,
                startMillis: self.playerController.playTimeMillis
            )
            if realm.object(ofType: YouTubeBookmark.self, forPrimaryKey: bookmarkKeyId) != nil {
                return
            }

            let new =  YouTubeBookmark()
            new.keyId = bookmarkKeyId
            new.relativePath = relativePath
            new.videoId = playerController.videoId
            new.note = ""
            new.startMillis = playerController.playTimeMillis
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
            let videoId = playerController.videoId
            bookmarks = realm.objects(YouTubeBookmark.self)
                .filter("videoId = '\(videoId)'")
                .sorted(byKeyPath: "startMillis")
                .reduce([], { $0 + [$1] })
        }
    }
}

struct YouTubePlayerBookmarkListView_Previews: PreviewProvider {
    static var previews: some View {
        YouTubePlayerBookmarkListView(model: .init(playerController: YouTubePlayerController(videoId: "")))
    }
}

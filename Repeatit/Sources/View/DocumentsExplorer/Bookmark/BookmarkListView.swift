//
//  BookmarkListView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import Combine
import SwiftUI

struct BookmarkListView: View {
    @ObservedObject var model: ViewModel

    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(self.model.bookmarks, id: \.millis, content: { bookmark in
                    BookmarkEditItemView(
                        model: .init(
                            bookmark: bookmark,
                            player: self.model.player
                        ),
                        listener: .init(
                            onTapGesture: { self.model.player.move(to: Double($0 / 1000)) },
                            onEndEditing: { self.model.handleTextChange(millis: $0, text: $1) },
                            onDone: { self.model.handleTextChange(millis: $0, text: $1) }
                        )
                    )
                })
                .onDelete { idxSet in idxSet.forEach { self.model.deleteBookmark(at: $0) } }
                BookmarkAddItemView(listener: .init(onTapGesture: { self.model.addBookmark() }))
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
            }
        }
        .background(Color.systemGray6)
    }
}

extension BookmarkListView {
    class ViewModel: ObservableObject {
        let player: Player
        let controller: BookmarkController
        @Published var bookmarks: [Bookmark]
        private var cancellables: [AnyCancellable]

        init(player: Player, controller: BookmarkController) {
            self.player = player
            self.controller = controller
            self.bookmarks = controller.bookmarks
            self.cancellables = []
            self.controller.bookmarkChangesPublisher
                .sink { [weak self] in
                    guard let self = self else { return }
                    self.bookmarks = self.controller.bookmarks
                }
                .store(in: &cancellables)
        }

        func addBookmark() {
            controller.addBookmark(at: player.playTimeMillis)
        }

        func deleteBookmark(at idx: Int) {
            controller.removeBookmark(at: bookmarks[idx].millis)
        }

        func handleTextChange(millis: Int, text: String) {
            controller.updateBookmark(at: millis, text: text)
        }
    }
}

struct BookmarkListView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkListView(model: .init(player: MediaPlayer(), controller: LRCController(url: URL.homeDirectory.appendingPathComponent("sample.lrc"))))
    }
}

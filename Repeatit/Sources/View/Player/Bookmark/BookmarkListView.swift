//
//  BookmarkListView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import ComposableArchitecture
import SwiftUI

struct BookmarkListView: View {
    let store: Store<BookmarkState, BookmarkAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            GeometryReader { geometry in
                List {
                    ForEach(
                        viewStore.bookmarks, id: \.millis,
                        content: { bookmark in
                            BookmarkEditItemView(
                                millis: bookmark.millis,
                                listener: .init(
                                    onTapGesture: { _ in
                                        viewStore.send(.play(at: bookmark.millis))
                                    },
                                    onTextChange: {
                                        viewStore.send(.update($0, $1))
                                    }
                                ),
                                text: bookmark.text
                            )
                        })
                        .onDelete { idxSet in idxSet.forEach { _ in /* delete the bookmark */ } }
                    BookmarkAddItemView(
                        listener: .init(
                            onTapGesture: { viewStore.send(.add) }
                        )
                    )
                }
                .listStyle(PlainListStyle())
            }
            .background(Color.systemGray6)
            .onAppear { viewStore.send(.load) }
        }
    }
}

struct BookmarkListView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookmarkListView(
                store: .init(
                    initialState: .init(
                        current: Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                        playTime: 0,
                        bookmarks: [
                            Bookmark(millis: 10000, text: "bookmark text 1"),
                            Bookmark(millis: 20000, text: "bookmark text 2")
                        ]),
                    reducer: Reducer<BookmarkState, BookmarkAction, BookmarkEnvironment> { _, _, _ in return .none },
                    environment: .mock
                )
            )
            .environment(\.colorScheme, .light)
            .previewLayout(.fixed(width: 320, height: 500))
            BookmarkListView(
                store: .init(
                    initialState: .init(
                        current: Document(url: URL.homeDirectory.appendingPathComponent("sample.mp3")),
                        playTime: 0,
                        bookmarks: [
                            Bookmark(millis: 10000, text: "bookmark text 1"),
                            Bookmark(millis: 20000, text: "bookmark text 2"),
                            Bookmark(millis: 40000, text: "bookmark text 3"),
                            Bookmark(millis: 80000, text: "bookmark text 4")
                        ]),
                    reducer: Reducer<BookmarkState, BookmarkAction, BookmarkEnvironment> { _, _, _ in return .none },
                    environment: .mock
                )
            )
            .environment(\.colorScheme, .dark)
            .previewLayout(.fixed(width: 320, height: 500))
        }
    }
}

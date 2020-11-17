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
        WithViewStore(self.store) { viewStore in
            GeometryReader { geometry in
                List {
                    ForEach(
                        viewStore.bookmarks, id: \.millis,
                        content: { bookmark in
                            BookmarkEditItemView(
                                millis: bookmark.millis,
                                listener: .init(
                                    onTapGesture: { _ in /* move to bookmark millis */ },
                                    onEndEditing: { _, _ in /* update bookmark */ },
                                    onDone: { _, _ in /* update bookmark */ }
                                ),
                                text: bookmark.text)
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

//
//  BookmarkListView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import Combine
import SwiftUI

struct BookmarkListView: View {
    @State var bookmarks: [Bookmark]

    var body: some View {
        GeometryReader { geometry in
            List {
                ForEach(bookmarks, id: \.millis, content: { bookmark in
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
                BookmarkAddItemView(listener: .init(onTapGesture: { /* add bookmark on the time */ }))
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
            }
            .listStyle(PlainListStyle())
        }
        .background(Color.systemGray6)
    }
}

struct BookmarkListView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkListView(bookmarks: [])
    }
}

//
//  BookmarkListView.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import SwiftUI

struct BookmarkListView: View {
    @EnvironmentObject var store: BookmarkStore

    var body: some View {
        List {
            ForEach(self.store.items, id: \.id, content: {
                self.rowBuilder(item: $0)
            })
            .onDelete(perform: { idxSet in
                idxSet.forEach { self.store.deleteBookmark(at: $0) }
            })
        }
    }

    func rowBuilder(item: BookmarkItem) -> AnyView {
        switch item {
        case _ as AddBookmarkItem:
            return AnyView(
                BookmarkAddRow()
                    .onTapGesture {
                        self.store.addBookmark()
                    }
            )
        case let edit as EditBookmarkItem:
            return AnyView(
                BookmarkEditRow(
                    bookmark: edit.value,
                    text: .init(
                        get: { edit.value.note },
                        set: { self.store.handleTextChange(bookmark: edit.value, text: $0) }
                    )
                )
            )
        default:
            return AnyView(EmptyView())
        }
    }
}

struct BookmarkListView_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkListView()
    }
}

//
//  BookmarkItem.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/06/02.
//

import Foundation

protocol BookmarkItem {
    var id: String { get }
}

struct AddBookmarkItem: BookmarkItem {
    var id: String {
        return "ADD"
    }
}

struct EditBookmarkItem: BookmarkItem {
    var id: String {
        return value.keyId
    }

    let value: Bookmark
}

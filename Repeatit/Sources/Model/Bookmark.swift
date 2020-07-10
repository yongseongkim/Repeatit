//
//  YouTubeBookmark.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import Foundation
import RealmSwift

class Bookmark {
    static func makeKeyId(relativePath: String, startMillis: Int) -> String {
        return "\(relativePath)_\(startMillis)"
    }

    let keyId: String
    let relativePath: String
    let startMillis: Int
    var note: String
    let createdAt: Date
    let updatedAt: Date

    init(relativePath: String, startMillis: Int, note: String = "", createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.keyId = Bookmark.makeKeyId(relativePath: relativePath, startMillis: startMillis)
        self.relativePath = relativePath
        self.startMillis = startMillis
        self.note = note
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(object: BookmarkObject) {
        self.keyId = object.keyId
        self.relativePath = object.relativePath
        self.startMillis = object.startMillis
        self.note = object.note
        self.createdAt = object.createdAt
        self.updatedAt = object.updatedAt
    }
}

class BookmarkObject: Object {
    @objc dynamic var keyId: String = ""
    @objc dynamic var relativePath: String = ""
    @objc dynamic var note: String = ""
    @objc dynamic var startMillis: Int = 0
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()

    override static func primaryKey() -> String? {
        return "keyId"
    }

    static func copy(previous: BookmarkObject, relativePath: String) -> BookmarkObject {
        return BookmarkObject().apply {
            $0.keyId = Bookmark.makeKeyId(
                relativePath: relativePath,
                startMillis: previous.startMillis
            )
            $0.relativePath = relativePath
            $0.note = previous.note
            $0.startMillis = previous.startMillis
            $0.createdAt = previous.createdAt
            $0.updatedAt = Date()
        }
    }
}

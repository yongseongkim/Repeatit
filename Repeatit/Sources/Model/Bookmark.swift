//
//  YouTubeBookmark.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/05/14.
//

import RealmSwift

class AudioBookmark: Object {
    @objc dynamic var keyId: String = ""
    @objc dynamic var relativePath: String = ""
    @objc dynamic var note: String = ""
    @objc dynamic var startMillis: Int = 0
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()

    override static func primaryKey() -> String? {
        return "keyId"
    }

    static func makeKeyId(relativePath: String, startMillis: Int) -> String {
        return "\(relativePath)_\(startMillis)"
    }

    static func copy(previous: AudioBookmark, relativePath: String) -> AudioBookmark {
        return AudioBookmark().apply {
            $0.keyId = AudioBookmark.makeKeyId(
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

class YouTubeBookmark: Object {
    @objc dynamic var keyId: String = ""
    @objc dynamic var relativePath: String = ""
    @objc dynamic var videoId: String = ""
    @objc dynamic var note: String = ""
    @objc dynamic var startMillis: Int = 0
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()

    override static func primaryKey() -> String? {
        return "keyId"
    }

    static func makeKeyId(relativePath: String, videoId: String, startMillis: Int) -> String {
        return "\(relativePath)_\(videoId)_\(startMillis)"
    }

    static func copy(previous: YouTubeBookmark, relativePath: String) -> YouTubeBookmark {
        return YouTubeBookmark().apply {
            $0.keyId = YouTubeBookmark.makeKeyId(
                relativePath: relativePath,
                videoId: previous.videoId,
                startMillis: previous.startMillis
            )
            $0.relativePath = relativePath
            $0.videoId = previous.videoId
            $0.note = previous.note
            $0.startMillis = previous.startMillis
            $0.createdAt = previous.createdAt
            $0.updatedAt = Date()
        }
    }
}


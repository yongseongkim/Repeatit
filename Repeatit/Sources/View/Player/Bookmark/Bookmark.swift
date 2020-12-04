//
//  BookmarkProtocol.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/21.
//

import Combine
import Foundation

struct Bookmark: Equatable {
    let millis: Int
    let text: String
}

extension Bookmark {
    static func from(line: LRCLine) -> Bookmark {
        return .init(
            millis: line.millis,
            text: line.lyrics
        )
    }

    static func from(component: SRTComponent) -> Bookmark {
        return .init(
            millis: component.startMillis,
            text: component.caption
        )
    }

    static func from(cue: WebVTTCue) -> Bookmark {
        return .init(
            millis: cue.startMillis,
            text: cue.payload
        )
    }
}

protocol BookmarkController: AnyObject {
    var bookmarks: [Bookmark] { get }
    var bookmarkChangesPublisher: AnyPublisher<[Bookmark], Never> { get }

    func addBookmark(at millis: Int)
    func removeBookmark(at millis: Int)
    func updateBookmark(at millis: Int, text: String)
}

extension LRCController: BookmarkController {
    var bookmarks: [Bookmark] {
        lines.map { Bookmark.from(line: $0) }
    }

    var bookmarkChangesPublisher: AnyPublisher<[Bookmark], Never> {
        changesPublisher
            .map { lines in lines.map { Bookmark.from(line: $0) } }
            .eraseToAnyPublisher()
    }

    func addBookmark(at millis: Int) {
        self.addLine(at: millis)
    }

    func removeBookmark(at millis: Int) {
        self.removeLine(at: millis)
    }

    func updateBookmark(at millis: Int, text: String) {
        self.updateLine(at: millis, lyrics: text)
    }
}

extension SRTController: BookmarkController {
    var bookmarks: [Bookmark] {
        components.map { Bookmark.from(component: $0) }
    }

    var bookmarkChangesPublisher: AnyPublisher<[Bookmark], Never> {
        changesPublisher
            .map { components in components.map { Bookmark.from(component: $0) } }
            .eraseToAnyPublisher()
    }

    func addBookmark(at millis: Int) {
        self.addComponent(at: millis)
    }

    func removeBookmark(at millis: Int) {
        self.removeComponent(at: millis)
    }

    func updateBookmark(at millis: Int, text: String) {
        self.updateComponent(at: millis, caption: text)
    }
}

extension WebVTTController: BookmarkController {
    var bookmarks: [Bookmark] {
        cues.map { Bookmark.from(cue: $0)}
    }

    var bookmarkChangesPublisher: AnyPublisher<[Bookmark], Never> {
        cuesChangesPublisher
            .map { cues in cues.map { Bookmark.from(cue: $0) } }
            .eraseToAnyPublisher()
    }

    func addBookmark(at millis: Int) {
        self.addCue(at: millis)
    }

    func removeBookmark(at millis: Int) {
        self.removeCue(at: millis)
    }

    func updateBookmark(at millis: Int, text: String) {
        self.updateCue(at: millis, payload: text)
    }
}

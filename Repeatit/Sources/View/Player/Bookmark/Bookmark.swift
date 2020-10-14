//
//  BookmarkProtocol.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/07/21.
//

import Combine
import Foundation

protocol Bookmark {
    var millis: Int { get }
    var text: String { get }
}

protocol BookmarkController {
    var bookmarks: [Bookmark] { get }
    var bookmarkChangesPublisher: AnyPublisher<Void, Never> { get }

    func addBookmark(at millis: Int)
    func removeBookmark(at millis: Int)
    func updateBookmark(at millis: Int, text: String)
}

extension LRCLine: Bookmark {
    var text: String { lyrics }
}

extension LRCController: BookmarkController {
    var bookmarks: [Bookmark] { self.lines }

    var bookmarkChangesPublisher: AnyPublisher<Void, Never> {
        self.changesPublisher
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

extension SRTComponent: Bookmark {
    var millis: Int { startMillis }
    var text: String { caption }
}

extension SRTController: BookmarkController {
    var bookmarks: [Bookmark] { self.components }

    var bookmarkChangesPublisher: AnyPublisher<Void, Never> {
        self.changesPublisher
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

extension WebVTTCue: Bookmark {
    var millis: Int { startMillis }
    var text: String { payload }
}

extension WebVTTController: BookmarkController {
    var bookmarks: [Bookmark] { self.cues }

    var bookmarkChangesPublisher: AnyPublisher<Void, Never> {
        self.changesPublisher
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

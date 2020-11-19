//
//  BookmarkClient.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import Combine
import ComposableArchitecture

struct BookmarkClient {
    typealias Millis = Int

    let load: (Document) -> Effect<Action, Failure>
    let add: (URL, Millis) -> Void
    let update: (URL, Millis, String) -> Void
    let remove: (URL, Millis) -> Void

    enum Action: Equatable {
        case bookmarkDidChange
        case bookmarksDidChange([Bookmark])
    }

    enum Failure: Error, Equatable {
        case couldntLoadBookmarks
    }
}

extension BookmarkClient {
    static let production = BookmarkClient(
        load: { document in
            let url = document.url
            let controller: BookmarkController
            // TODO: duration 반영하기
            if document.isYouTubeFile {
                controller = WebVTTController(url: url.deletingPathExtension().appendingPathExtension("vtt"), duration: 100000)
            } else if document.isVideoFile {
                controller = SRTController(url: url.deletingPathExtension().appendingPathExtension("srt"), duration: 100000)
            } else {
                controller = LRCController(url: url.deletingPathExtension().appendingPathExtension("lrc"))
            }
            dependencies[url] = controller
            return controller.bookmarkChangesPublisher
                .prepend(controller.bookmarks)
                .mapError { _ in BookmarkClient.Failure.couldntLoadBookmarks }
                .handleEvents(
                    receiveCompletion: { _ in dependencies[url] = nil },
                    receiveCancel: { dependencies[url] = nil }
                )
                .eraseToAnyPublisher()
                .map(BookmarkClient.Action.bookmarksDidChange)
                .eraseToEffect()
        },
        add: { url, millis in
            guard let controller = dependencies[url] else { return }
            controller.addBookmark(at: millis)
        },
        update: { url, millis, text in
            guard let controller = dependencies[url] else { return }
            controller.updateBookmark(at: millis, text: text)
        },
        remove: { url, millis in
            guard let controller = dependencies[url] else { return }
            controller.removeBookmark(at: millis)
        }
    )
}

private var dependencies: [AnyHashable: BookmarkController] = [:]

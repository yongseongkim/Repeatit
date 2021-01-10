//
//  BookmarkClient.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import Combine
import ComposableArchitecture

struct BookmarkClient {
    let load: (Document, Millis) -> Effect<Action, Failure>
    let add: (URL, Millis) -> Effect<[Bookmark], Failure>
    let update: (URL, Millis, String) -> Effect<[Bookmark], Failure>
    let remove: (URL, Millis) -> Effect<[Bookmark], Failure>

    enum Action: Equatable {
        case bookmarksDidChange([Bookmark])
    }

    enum Failure: Error, Equatable {
        case couldntLoadBookmarks
    }
}

extension BookmarkClient {
    static let production = BookmarkClient(
        load: { document, duration in
            let url = document.url
            let controller: BookmarkController
            if document.isYouTubeFile {
                controller = WebVTTController(
                    url: url.deletingPathExtension().appendingPathExtension("vtt"),
                    duration: duration
                )
            } else if document.isVideoFile {
                controller = SRTController(
                    url: url.deletingPathExtension().appendingPathExtension("srt"),
                    duration: duration
                )
            } else {
                controller = LRCController(url: url.deletingPathExtension().appendingPathExtension("lrc"))
            }
            dependencies[url] = controller
            return controller.bookmarkChangesPublisher
                .prepend(controller.bookmarks)
                .mapError { _ in BookmarkClient.Failure.couldntLoadBookmarks }
                .eraseToAnyPublisher()
                .map(BookmarkClient.Action.bookmarksDidChange)
                .eraseToEffect()
        },
        add: { url, millis in
            return .future { callback in
                guard let controller = dependencies[url] else {
                    callback(.failure(.couldntLoadBookmarks))
                    return
                }
                controller.addBookmark(at: millis)
                callback(.success(controller.bookmarks))
            }
        },
        update: { url, millis, text in
            return .future { callback in
                guard let controller = dependencies[url] else {
                    callback(.failure(.couldntLoadBookmarks))
                    return
                }
                controller.updateBookmark(at: millis, text: text)
                callback(.success(controller.bookmarks))
            }
        },
        remove: { url, millis in
            return .future { callback in
                guard let controller = dependencies[url] else {
                    callback(.failure(.couldntLoadBookmarks))
                    return
                }
                controller.removeBookmark(at: millis)
                callback(.success(controller.bookmarks))
            }
        }
    )
}

private var dependencies: [AnyHashable: BookmarkController] = [:]

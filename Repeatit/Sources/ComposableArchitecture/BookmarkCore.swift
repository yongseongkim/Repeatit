//
//  BookmarkCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/16.
//

import ComposableArchitecture

struct BookmarkClientID: Hashable {}

struct BookmarkState: Equatable {
    let current: Document
    var playTime: Seconds = 0
    var bookmarks: [Bookmark] = []

    func updated(
        playTime: Double? = nil,
        bookmarks: [Bookmark]? = nil
    ) -> BookmarkState {
        return .init(
            current: self.current,
            playTime: playTime ?? self.playTime,
            bookmarks: bookmarks ?? self.bookmarks
        )
    }
}

enum BookmarkAction: Equatable {
    case add
    case update(Millis, String)
    case remove(Millis)
    case move(to: Millis)

    case bookmark(Result<BookmarkClient.Action, BookmarkClient.Failure>)
}

struct BookmarkEnvironment {
    let move: (Seconds) -> Void
    let bookmarkClient: BookmarkClient
}

extension BookmarkEnvironment {
    static let mock = BookmarkEnvironment(
        move: { _ in },
        bookmarkClient: .init(
            load: { _, _ in return .none },
            add: { _, _ in return .none },
            update: { _, _, _ in return .none },
            remove: { _, _ in return .none }
        )
    )
}

let bookmarkReducer = Reducer<BookmarkState, BookmarkAction, BookmarkEnvironment> { state, action, environment in
    switch action {
    case .add:
        let millis = Int(state.playTime * 1000)
        return environment.bookmarkClient.add(state.current.url, millis)
            .map(BookmarkClient.Action.bookmarksDidChange)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(BookmarkAction.bookmark)
            .eraseToEffect()
    case .update(let millis, let text):
        return environment.bookmarkClient.update(state.current.url, millis, text)
            .map(BookmarkClient.Action.bookmarksDidChange)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(BookmarkAction.bookmark)
            .eraseToEffect()
    case .remove(let millis):
        let millis = Int(state.playTime * 1000)
        return environment.bookmarkClient.remove(state.current.url, millis)
            .map(BookmarkClient.Action.bookmarksDidChange)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(BookmarkAction.bookmark)
            .eraseToEffect()
    case .move(let millis):
        environment.move(Double(millis) / 1000)
        return .none
    case .bookmark(.success(.bookmarksDidChange(let bookmarks))):
        state.bookmarks = bookmarks
        return .none
    case .bookmark(.failure):
        return .none
    }
}

extension Reducer {
    func bookmark(
        state: WritableKeyPath<State, BookmarkState>,
        action: CasePath<Action, BookmarkAction>,
        environment: @escaping (Environment) -> BookmarkEnvironment
    ) -> Reducer {
        .combine(
            self,
            bookmarkReducer
                .pullback(state: state, action: action, environment: environment)
        )
    }
}


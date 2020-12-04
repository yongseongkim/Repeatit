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

    func updated() -> BookmarkState {
        return .init(
            current: self.current,
            playTime: self.playTime,
            bookmarks: self.bookmarks
        )
    }
}

enum BookmarkAction: Equatable {
    case load
    case add
    case update(Millis, String)
    case remove(Millis)
    case play(at: Millis)
    
    case bookmarkControl(Result<BookmarkClient.Action, BookmarkClient.Failure>)
}

struct BookmarkEnvironment {
    let move: (Seconds) -> Void
    let bookmarkClient: BookmarkClient
}

extension BookmarkEnvironment {
    static let mock = BookmarkEnvironment(
        move: { _ in },
        bookmarkClient: .init(
            load: { _ in return .none },
            add: { _, _ in },
            update: { _, _, _ in },
            remove: { _, _ in }
        )
    )
}

let bookmarkReducer = Reducer<BookmarkState, BookmarkAction, BookmarkEnvironment> { state, action, environment in
    switch action {
    case .load:
        return environment.bookmarkClient.load(state.current)
            .receive(on: DispatchQueue.main)
            .catchToEffect()
            .map(BookmarkAction.bookmarkControl)
            .eraseToEffect()
            .cancellable(id: BookmarkClientID())
    case .add:
        let millis = Int(state.playTime * 1000)
        environment.bookmarkClient.add(state.current.url, millis)
        return .none
    case .update(let millis, let text):
        environment.bookmarkClient.update(state.current.url, millis, text)
        return .none
    case .remove(let millis):
        environment.bookmarkClient.remove(state.current.url, millis)
        return .none
    case .play(let millis):
        environment.move(Double(millis) / 1000)
        return .none
    case .bookmarkControl(.success(.bookmarkDidChange)):
        return .none
    case .bookmarkControl(.success(.bookmarksDidChange(let bookmarks))):
        print("bookmarksDidChange \(bookmarks)")
        state.bookmarks = bookmarks
        return .none
    case .bookmarkControl(.failure):
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


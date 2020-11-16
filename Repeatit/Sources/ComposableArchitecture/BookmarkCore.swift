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
    var bookmarks: [Bookmark] = []
    var playTime: Seconds = 0

    func updated(playTime: Seconds? = nil) -> BookmarkState {
        return .init(
            current: self.current,
            bookmarks: self.bookmarks,
            playTime: playTime ?? self.playTime
        )
    }
}

enum BookmarkAction: Equatable {
    case load
    case add
    case update(Millis, String)
    case remove(Millis)

    case bookmarkControl(Result<BookmarkClient.Action, BookmarkClient.Failure>)
}

struct BookmarkEnvironment {
    let bookmarkClient: BookmarkClient
}

extension Reducer {
    func bookmark(
        state: WritableKeyPath<State, BookmarkState>,
        action: CasePath<Action, BookmarkAction>,
        environment: @escaping (Environment) -> BookmarkEnvironment
    ) -> Reducer {
        .combine(
            self,
            Reducer<BookmarkState, BookmarkAction, BookmarkEnvironment> { state, action, environment in
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
                case .bookmarkControl(.success(.bookmarkDidChange)):
                    return .none
                case .bookmarkControl(.success(.bookmarksDidChange(let bookmarks))):
                     state.bookmarks = bookmarks
                    return .none
                default:
                    return .none
                }
            }
            .pullback(state: state, action: action, environment: environment)
        )
    }
}


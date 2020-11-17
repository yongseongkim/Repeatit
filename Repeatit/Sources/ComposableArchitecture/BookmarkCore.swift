//
//  BookmarkCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/16.
//

import ComposableArchitecture

protocol BookmarkPlayer {
    var move: (AnyHashable, Seconds) -> Void { get }
    var playTimeMillis: (AnyHashable) -> Millis { get }
}

struct BookmarkClientID: Hashable {}

struct BookmarkState: Equatable {
    // At the beginning, the state had playTime of player and player reducer updated that.
    // But it made performance issues, so remove the property from the state.
    let playerID: AnyHashable
    let current: Document
    var bookmarks: [Bookmark] = []
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
    let player: BookmarkPlayer
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
                    let millis = environment.player.playTimeMillis(state.playerID)
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


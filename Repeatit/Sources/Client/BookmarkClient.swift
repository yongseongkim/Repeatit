//
//  BookmarkClient.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/11/14.
//

import ComposableArchitecture

struct BookmarkClient {
    typealias Millis = Int

    let add: (Millis) -> Effect<[Bookmark], Failure>
    let update: (Millis, String) -> Effect<Bookmark, Failure>
    let remove: (Millis) -> Effect<[Bookmark], Failure>

    enum Failure: Error {
    }
}

extension BookmarkClient {
    static let production = BookmarkClient(
        add: { millis in
            return .none
        },
        update: { millis, text in
            return .none
        },
        remove: { millis in
            return .none
        }
    )
}

//
//  SelectedDocumentsDestinationNavigatorCore.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/14.
//

import ComposableArchitecture

struct SelectedDocumentsDestinationNavigatiorState: Equatable {
    enum Mode {
        case move
        case copy
    }
    let mode: Mode
    var currentURL: URL
    var documents: [URL: [Document]]
    var selectedDocuments: [Document]
}

enum SelectedDocumentsDestinationNavigatorAction: Equatable {
    case destinationViewAppeared(url: URL)
    case confirmButtonTapped
    case cancelButtonTapped
    case actionCompleted
}

struct SelectedDocumentsDestinationNavigatiorEnvironment {
    let fileManager: FileManager
}

let selectedDocumentsDestinationNavigatorReducer = Reducer<
    SelectedDocumentsDestinationNavigatiorState,
    SelectedDocumentsDestinationNavigatorAction,
    SelectedDocumentsDestinationNavigatiorEnvironment
> { state, action, environment in
    switch action {
    case .destinationViewAppeared(let url):
        state.currentURL = url
        state.documents[url] = environment.fileManager.getDocuments(in: url)
        return .none
    case .confirmButtonTapped:
        switch state.mode {
        case .move:
            let targetURL = state.currentURL
            state.selectedDocuments.forEach {
                try? environment.fileManager.moveItem(at: $0.url, to: targetURL.appendingPathComponent($0.url.lastPathComponent))
            }
            return Effect(value: .actionCompleted)
        case .copy:
            let targetURL = state.currentURL
            var fromURLs = Set<URL>()
            state.selectedDocuments.forEach {
                try? environment.fileManager.copyItem(at: $0.url, to: targetURL.appendingPathComponent($0.url.lastPathComponent))
            }
            return Effect(value: .actionCompleted)
        }
    case .cancelButtonTapped:
        return .none
    case .actionCompleted:
        return .none
    }
}

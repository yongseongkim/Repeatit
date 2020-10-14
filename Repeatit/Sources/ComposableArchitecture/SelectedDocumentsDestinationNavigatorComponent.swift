//
//  SelectedDocumentsDestinationNavigatorComponent.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/14.
//

import ComposableArchitecture

struct SelectedDocumentsDestinationNavigatiorState: Equatable {
    var currentURL: URL
    var documents: [URL: [Document]]
    var selectedDocuments: [Document]
}

enum SelectedDocumentsDestinationNavigatiorAction: Equatable {
    case destinationViewAppeared(url: URL)
}

struct SelectedDocumentsDestinationNavigatiorEnvironment {
    let fileManager: FileManager = .default
}

let selectedDocumentsDestinationNavigatorReducer = Reducer<
    SelectedDocumentsDestinationNavigatiorState,
    SelectedDocumentsDestinationNavigatiorAction,
    SelectedDocumentsDestinationNavigatiorEnvironment
> { state, action, environment in
    switch action {
    case .destinationViewAppeared(let url):
        state.currentURL = url
        state.documents[url] = environment.fileManager.getDocuments(in: url)
    }
    return .none
}

//
//  Repeatit.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/11.
//

import SwiftUI
import ComposableArchitecture

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
    switch action {
    case .documentsExplorerAppear(let url):
        state.currentURL = url
        state.documentItems[url] = FileManager.default.getDocumentItems(in: url)
    case .editButtonTap(let isEditing):
        state.isEditing = isEditing
        // Clear selected items when editing ends.
        state.selectedDocumentItems = []
    case .documentItemTapWhileEditing(let item):
        state.selectedDocumentItems.append(item)
    }
    return .none
}

@main
struct Repeatit: App {
    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppState(
                        currentURL: URL.homeDirectory,
                        documentItems: [URL.homeDirectory: FileManager.default.getDocumentItems(in: URL.homeDirectory)],
                        selectedDocumentItems: []
                    ),
                    reducer: appReducer,
                    environment: AppEnvironment()
                )
            )
        }
    }
}

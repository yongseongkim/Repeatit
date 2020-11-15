//
//  Repeatit.swift
//  Repeatit
//
//  Created by YongSeong Kim on 2020/10/11.
//

import SwiftUI
import ComposableArchitecture

@main
struct Repeatit: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(
                    initialState: AppState(
                        documentExplorer: .init(
                            currentURL: URL.homeDirectory,
                            documents: [:],
                            selectedDocuments: [],
                            selectedDocumentsDestinationNavigator: .init(
                                mode: .move,
                                currentURL: URL.homeDirectory,
                                documents: [:],
                                selectedDocuments: []
                            )
                        )
                    ),
                    reducer: appReducer,
                    environment: .production
                )
            )
        }
    }
}


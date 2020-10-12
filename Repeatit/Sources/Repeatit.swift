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

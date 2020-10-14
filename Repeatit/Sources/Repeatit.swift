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
                        documents: [URL.homeDirectory: FileManager.default.getDocuments(in: URL.homeDirectory)],
                        selectedDocuments: []
                    ),
                    reducer: appReducer,
                    environment: AppEnvironment()
                )
            )
        }
    }
}

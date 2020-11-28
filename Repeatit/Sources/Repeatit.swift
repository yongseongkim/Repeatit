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
                store: .init(
                    initialState: .init(
                        documentExplorer: .init(
                            visibleURL: URL.homeDirectory,
                            isEditing: false,
                            documents: [:],
                            selectedDocuments: []
                        )
                    ),
                    reducer: appReducer,
                    environment: .production
                )
            )
        }
    }
}

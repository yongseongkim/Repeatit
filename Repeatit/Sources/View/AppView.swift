//
//  RootView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/06.
//

import ComposableArchitecture
import SwiftUI

struct AppView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(self.store) { viewStore in
            IfLetStore(self.store.scope(state: { $0.documentExplorer }, action: AppAction.documentExplorer)) { store in
                DocumentExplorer(store: store)
            }
            .background(
                EmptyView().sheet(
                    isPresented: viewStore.binding(
                        get: { $0.player != nil },
                        send: AppAction.setPlayerSheet(isPresented:)
                    )
                ) {
                    IfLetStore(store.scope(state: { $0.player }, action: AppAction.player)) { store in
                        EmptyView()
                    }
                }
            )
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: Store(
                initialState: AppState(
                    documentExplorer: DocumentExplorerState(
                        currentURL: URL.homeDirectory,
                        documents: [:],
                        selectedDocuments: []
                    )
                ),
                reducer: appReducer,
                environment: AppEnvironment()
            )
        )
    }
}

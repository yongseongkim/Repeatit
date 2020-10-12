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
            ZStack {
                NavigationView {
                    DocumentExplorerView(
                        store: store,
                        url: URL.homeDirectory
                    )
                }
                DocumentExplorerFloatingActionButtons(store: store)
                    .visible(viewStore.isFloatingActionButtonsVisible)
                    .padding(.bottom, 25)
                    .padding(.trailing, 15)
            }
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static var previews: some View {
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

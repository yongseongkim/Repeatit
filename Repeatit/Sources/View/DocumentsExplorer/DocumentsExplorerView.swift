//
//  DocumentsExplorerView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import ComposableArchitecture
import SwiftUI

struct DocumentExplorerView: View {
    let store: Store<AppState, AppAction>
    let url: URL

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                if viewStore.isDocumentExplorerEditing {
                    DocumentExplorerMultiSelectableListView(
                        store: store,
                        items: viewStore.documentItems[url] ?? []
                    )
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(
                        trailing: Image(systemName: "xmark")
                            .padding(12)
                            .foregroundColor(.systemBlack)
                            .onTapGesture { viewStore.send(.editButtonTapped(false)) }
                    )
                } else {
                    DocumentExplorerListView(
                        items: viewStore.documentItems[url] ?? [],
                        destinationViewBuilder: { DocumentExplorerView(store: store, url: $0) }
                    )
                    .navigationBarBackButtonHidden(false)
                    .navigationBarItems(
                        trailing: Image(systemName: "list.bullet")
                            .padding(12)
                            .foregroundColor(.systemBlack)
                            .onTapGesture { viewStore.send(.editButtonTapped(true)) }
                    )
                }
            }
            .navigationBarTitle(url.lastPathComponent)
            .onAppear { viewStore.send(.documentsExplorerAppeared(url: url)) }
        }
    }
}

struct DocumentExplorer_Preview: PreviewProvider {
    static var previews: some View {
        DocumentExplorerView(
            store: Store(
                initialState: AppState(
                    currentURL: URL.homeDirectory,
                    documentItems: [URL.homeDirectory: FileManager.default.getDocumentItems(in: URL.homeDirectory)],
                    selectedDocumentItems: []
                ),
                reducer: appReducer,
                environment: AppEnvironment()
            ),
            url: URL.homeDirectory
        )
    }
}

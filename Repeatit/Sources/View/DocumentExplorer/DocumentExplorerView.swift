//
//  DocumentExplorerView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import ComposableArchitecture
import SwiftUI

struct DocumentExplorer: View {
    let store: Store<DocumentExplorerState, DocumentExplorerAction>

    var body: some View {
        GeometryReader { geometry in
            WithViewStore(self.store) { viewStore in
                ZStack {
                    VStack(spacing: 0) {
                        NavigationView {
                            DocumentExplorerView(
                                store: store,
                                url: URL.homeDirectory
                            )
                        }
                        .accentColor(.systemBlack)
                        .padding(.bottom, viewStore.isActionSheetVisible ? 0 : geometry.safeAreaInsets.bottom)
                        DocumentExplorerActionSheet(store: store)
                            .visibleOrGone(viewStore.isActionSheetVisible)
                            .padding(.bottom, geometry.safeAreaInsets.bottom)
                            .background(Color.systemGray6)
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    DocumentExplorerFloatingActionButtons(store: store)
                        .visibleOrInvisible(viewStore.isFloatingActionButtonsVisible)
                        .padding(.bottom, 25)
                        .padding(.trailing, 15)
                }
                .background(
                    EmptyView().sheet(
                        isPresented: viewStore.binding(
                            get: { $0.isSelectedDocumentsDestinationNavigatorPresented },
                            send: DocumentExplorerAction.setSelectedDocumentsDestinationNavigatorSheet(isPresented:)
                        )
                    ) {
                        IfLetStore(
                            store.scope(state: { $0.selectedDocumentsDestinationNavigator }, action: DocumentExplorerAction.selectedDocumentsDestinationNavigator),
                            then: { SelectedDocumentsDestinationNavigatorView(store: $0) }
                        )
                    }
                )
            }
        }
    }
}

struct DocumentExplorerView: View {
    let store: Store<DocumentExplorerState, DocumentExplorerAction>
    let url: URL

    var body: some View {
        WithViewStore(self.store) { viewStore in
            ZStack {
                if viewStore.isEditing {
                    DocumentExplorerMultiSelectableListView(
                        store: store,
                        documents: viewStore.documents[url] ?? []
                    )
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(
                        leading: EmptyView(),
                        trailing: Image(systemName: "xmark")
                            .padding(12)
                            .foregroundColor(.systemBlack)
                            .onTapGesture { viewStore.send(.editButtonTapped(false)) }
                    )
                } else {
                    DocumentExplorerListView(
                        documents: viewStore.documents[url] ?? [],
                        destinationViewBuilder: { DocumentExplorerView(store: store, url: $0) },
                        documentTapped: { viewStore.send(.documentTapped($0)) }
                    )
                    .navigationBarBackButtonHidden(false)
                    .navigationBarItems(
                        leading: EmptyView(),
                        trailing: Image(systemName: "list.bullet")
                            .padding(12)
                            .foregroundColor(.systemBlack)
                            .onTapGesture { viewStore.send(.editButtonTapped(true)) }
                    )
                }
            }
            .navigationBarTitle(url.lastPathComponent)
            .onAppear { viewStore.send(.documentExplorerAppeared(url: url)) }
        }
    }
}

struct DocumentExplorerView_Preview: PreviewProvider {
    static var previews: some View {
        DocumentExplorerView(
            store: Store(
                initialState: DocumentExplorerState(
                    currentURL: URL.homeDirectory,
                    documents: [URL.homeDirectory: FileManager.default.getDocuments(in: URL.homeDirectory)],
                    selectedDocuments: []
                ),
                reducer: documentExplorerReducer,
                environment: DocumentExplorerEnvironment(fileManager: .default)
            ),
            url: URL.homeDirectory
        )
    }
}

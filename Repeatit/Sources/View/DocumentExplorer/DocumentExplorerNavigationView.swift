//
//  DocumentExplorerNavigationView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/01/19.
//  Copyright © 2020 yongseongkim. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct DocumentExplorerNavigationView: View {
    let store: Store<DocumentExplorerState, DocumentExplorerAction>

    var body: some View {
        NavigationView {
            DocumentExplorerListView(url: .homeDirectory, store: store)
        }
        .accentColor(.systemBlack)
    }
}

struct DocumentExplorerListView: View {
    let url: URL
    let store: Store<DocumentExplorerState, DocumentExplorerAction>

    var body: some View {
        WithViewStore(
            store,
            removeDuplicates: {
                $0.documents[url] == $1.documents[url]
                    && $0.isEditing == $1.isEditing
                    && $0.selectedDocuments == $1.selectedDocuments
            }
        ) { viewStore in
            ZStack {
                if viewStore.isEditing {
                    DocumentExplorerMultiSelectableListView(
                        documents: viewStore.documents[url] ?? [],
                        selectedDocuments: viewStore.selectedDocuments,
                        documentTapped: { viewStore.send(.toggleDocumentSelection($0)) }
                    )
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(
                        leading: EmptyView(),
                        trailing: Image(systemName: "xmark")
                            .padding(12)
                            .foregroundColor(.systemBlack)
                            .onTapGesture { viewStore.send(.toggleEditing) }
                    )
                } else {
                    DocumentExplorerNonSelectableListView(
                        documents: viewStore.documents[url] ?? [],
                        destinationViewBuilder: { DocumentExplorerListView(url: $0, store: store) },
                        documentTapped: { viewStore.send(.didTap($0)) }
                    )
                    .navigationBarBackButtonHidden(false)
                    .navigationBarItems(
                        leading: EmptyView(),
                        trailing: Image(systemName: "list.bullet")
                            .padding(12)
                            .foregroundColor(.systemBlack)
                            .onTapGesture { viewStore.send(.toggleEditing) }
                    )
                }
            }
            .navigationBarTitle(url.lastPathComponent)
            .onAppear { viewStore.send(.didAppear(url)) }
        }
    }
}

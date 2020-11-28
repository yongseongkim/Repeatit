//
//  DocumentExplorerView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/04.
//

import ComposableArchitecture
import SwiftUI

struct DocumentExplorerView: View {
    let store: Store<DocumentExplorerState, DocumentExplorerAction>

    var body: some View {
        return GeometryReader { geometry in
            WithViewStore(store) { viewStore in
                ZStack {
                    VStack(spacing: 0) {
                        DocumentExplorerNavigationView(store: store)
                            .padding(.bottom, viewStore.actionSheet != nil ? 0 : geometry.safeAreaInsets.bottom)
                        IfLetStore(store.scope(state: { $0.actionSheet }, action: DocumentExplorerAction.actionSheet)) { store in
                            DocumentExplorerActionSheet(store: store)
                                .padding(.bottom, geometry.safeAreaInsets.bottom)
                                .background(Color.systemGray6)
                        }
                    }
                    .edgesIgnoringSafeArea(.bottom)
                    IfLetStore(store.scope(state: { $0.floatingActionButtons }, action: DocumentExplorerAction.floatingActionButtons)) { store in
                        DocumentExplorerFloatingActionButtons(store: store)
                            .padding(.bottom, 25)
                            .padding(.trailing, 15)
                    }
                }
                .background(
                    EmptyView().sheet(
                        isPresented: viewStore.binding(
                            get: { $0.selectedDocumentsNavigator != nil },
                            send: DocumentExplorerAction.setSelectedDocumentsNavigator(isPresented:)
                        ),
                        content: {
                            IfLetStore(
                                store.scope(
                                    state: { $0.selectedDocumentsNavigator },
                                    action: DocumentExplorerAction.selectedDocumentsNavigator
                                )
                            ) { store in
                                SelectedDocumentsDestinationNavigatorView(store: store)
                            }
                        }
                    )
                )
            }
        }
    }
}

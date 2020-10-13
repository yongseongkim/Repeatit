//
//  DocumentExplorerDestinationView.swift
//  Repeatit
//
//  Created by yongseongkim on 2020/05/03.
//

import ComposableArchitecture
import SwiftUI


struct SelectedDocumentItemsDestinationNavigatiorState: Equatable {
    var currentURL: URL
    var documentItems: [URL: [DocumentsExplorerItem]]
    var selectedDocumentItems: [DocumentsExplorerItem]
}

enum SelectedDocumentItemsDestinationNavigatiorAction: Equatable {
    case destinationViewAppeared(url: URL)
}

struct SelectedDocumentItemsDestinationNavigatiorEnvironment {
    let fileManager: FileManager = .default
}

let selectedDocumentItemsDestinationNavigatorReducer = Reducer<
    SelectedDocumentItemsDestinationNavigatiorState,
    SelectedDocumentItemsDestinationNavigatiorAction,
    SelectedDocumentItemsDestinationNavigatiorEnvironment> { state, action, environment in
    switch action {
    case .destinationViewAppeared(let url):
        state.currentURL = url
        state.documentItems[url] = environment.fileManager.getDocumentItems(in: url)
    }
    return .none
}

struct SelectedDocumentItemsDestinationNavigatorView: View {
    let store: Store<SelectedDocumentItemsDestinationNavigatiorState, SelectedDocumentItemsDestinationNavigatiorAction>
    let onConfirmTapped: ((URL) -> Void)
    let onCancelTapped: (() -> Void)

    var body: some View {
        WithViewStore(self.store) { viewStore in
            GeometryReader { geometry in
                VStack {
                    ZStack {
                        NavigationView { SelectedDocumentDestinationView(store: store, url: URL.homeDirectory) }
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Spacer()
                                Button(
                                    action: { onCancelTapped() },
                                    label: {
                                        Image(systemName: "xmark")
                                            .padding(12)
                                            .foregroundColor(.systemBlack)
                                    }
                                )
                                .padding([.top, .trailing], 10)
                            }
                            Spacer()
                        }
                    }
                    Button(
                        action: { onConfirmTapped(viewStore.currentURL) },
                        label: { Text("Confirm").foregroundColor(Color.white) }
                    )
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .frame(height: 50)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .background(Color.classicBlue)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

struct SelectedDocumentDestinationView: View {
    let store: Store<SelectedDocumentItemsDestinationNavigatiorState, SelectedDocumentItemsDestinationNavigatiorAction>
    let url: URL

    var body: some View {
        WithViewStore(self.store) { viewStore in
            List(viewStore.documentItems[url] ?? [], id: \.nameWithExtension) { item in
                if item.isDirectory && !viewStore.selectedDocumentItems.contains(item) {
                    NavigationLink(
                        destination: SelectedDocumentDestinationView(store: store, url: item.url),
                        label: { DocumentsExplorerRow(item: item) }
                    )
                } else {
                    DocumentsExplorerRow(item: item).opacity(0.6)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle(url.lastPathComponent)
            .onAppear { viewStore.send(.destinationViewAppeared(url: url)) }
        }
    }
}

struct DocumentExplorerDestinationView_Previews: PreviewProvider {
    static var previews: some View {
        SelectedDocumentItemsDestinationNavigatorView(
            store: .init(
                initialState: .init(
                    currentURL: URL.homeDirectory,
                    documentItems: [:],
                    selectedDocumentItems: [
                        DocumentsExplorerItem(url: URL.homeDirectory.appendingPathComponent("sample.mp3"))
                    ]
                ),
                reducer: selectedDocumentItemsDestinationNavigatorReducer,
                environment: SelectedDocumentItemsDestinationNavigatiorEnvironment()
            ),
            onConfirmTapped: { _ in },
            onCancelTapped: { }
        )
    }
}
